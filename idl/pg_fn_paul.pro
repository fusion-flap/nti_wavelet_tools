;----------------------------------------------------------------
; $Id: pg_fn_paul.pro,v 1.1 2008-07-23 16:44:38 pokol Exp $
;
; Copyright (c) 2000-2002, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;+
; NAME
;    WV_FN_PAUL
;
; PURPOSE
;    This function returns the Paul wavelet.
;
; CALLING SEQUENCE
;    Info = WV_FN_PAUL( [Parameter] [, Scale, N]
;          [, /DOUBLE] [, /SPATIAL]
;          [, WAVELET=Wavelet] )
;
; INPUTS
;    Parameter
;        A scalar integer specifying the nondimensional frequency parameter
;        for the Paul wavelet. The default is 4.
;
;    Scale
;        A scalar specifying the normalized wavelet scale of the resulting
;        wavelet function.
;
;    N = A scalar specifying either the number of points in the data set
;        (for Fourier frequencies) or the width of the wavelet function
;        (if /SPATIAL is set).
;
;    Note - if keyword WAVELET is missing then Scale and N are ignored
;           and only Info is returned.
;
; RETURN VALUE:
;    Returns a structure with the following information:
;          (this is an example for Parameter=6)
;       Info = {family:'Paul', $    ; name of wavelet family
;               order_name:'Parameter', $     ; term used for "order"
;               order_range:[1,20,4], $   ; valid range [first,last,default]
;               order:4, $                ; order number
;               discrete:0, $             ; 0=continuous, 1=discrete
;               orthogonal:0, $           ; 0=nonorthogonal, 1=orthogonal
;               symmetric:1, $            ; 0=asymmetric, 1=symmetric
;               support:-1, $              ; support width
;               moments:-1, $              ; # of vanishing moments
;               regularity:-1}         ; # of continuous derivatives
;
; KEYWORD PARAMETERS
;    DOUBLE = Set this keyword to force the computation to be done in
;        double precision arithmetic.
;
;    WAVELET = Upon return, this keyword will contain a vector of wavelet
;        coefficients evaluated either at the spatial coordinates (/SPATIAL), or
;        at the Fourier frequencies.
;
;        The spatial coordinates range from -(N-1)/2 to (N-1)/2.
;        The Fourier frequencies are in the same order as the FFT,
;        and range from:
;           [0, 2pi/N, 4pi/N, ..., pi, -pi(N+1)/N, ... -2pi(N-1)/N]
;
;    SPATIAL = Set this keyword to return the wavelet as a function of spatial
;        coordinates instead of the default Fourier frequencies.
;
; REFERENCE
;    Torrence, C. and G.P. Compo, 1998: A practical guide to wavelet analysis.
;        Bull. Amer. Meteor. Soc., v. 79, pp. 61-78.
;
; EXAMPLE
;   Paul wavelet transform using convolution:
;      n = 1024
;      x = RANDOMN(seed, n)   ; choose a random time series length n
;
;    parameter 6.0, scale 8, filter width 79 points
;      info = WV_FN_PAUL(6.0, 8, 79, /SPATIAL, WAVELET=wavelet)
;    find wavelet transform at scale 8:
;      cwtConvol = COMPLEX(CONVOL(x, FLOAT(wavelet), /EDGE_WRAP), $
;                    CONVOL(x, IMAGINARY(wavelet), /EDGE_WRAP))
;
;   The same transform using the fast Fourier transform:
;      info = WV_FN_PAUL(6.0, 8, n, WAVELET=wavelet)
;      cwtFFT = FFT(FFT(x)*CONJ(wavelet),/INVERSE)
;
;   Note that the FFT method is both much easier (since you don't need
;   to choose a filter width) and much faster.
;
; MODIFICATION HISTORY
;    Written by: Chris Torrence, 2000
;
;-




;----------------------------------------------------------------
FUNCTION wv_fn_paul, orderInput, scaleInput, nInput, $
    DOUBLE=double, $
    FREQUENCY=frequency, $
    SPATIAL=spatial, $
    WAVELET=wavelet

    COMPILE_OPT strictarr
    ON_ERROR,2  ; return to caller

;defaults
    order_range = [1,20,4]  ; [first,last,default]
    IF (N_ELEMENTS(orderInput) LT 1) THEN orderInput = order_range[2]
    order = FIX(orderInput)

; check for invalid Order
    IF ((order LT order_range[0]) OR (order GT order_range[1])) THEN BEGIN
        MESSAGE,/INFO,'Order out of range, reverting to default...'
        order = order_range[2]  ; default
    ENDIF

    fourier_period = 4*!DPI/(2*order + 1)
    psizero = (2d^order)*FACTORIAL(order)/ $
        SQRT(!DPI*FACTORIAL(2*order))
    IF (order EQ 4) THEN BEGIN
    ; the following are only valid for order=4
        reconstruct = 1.132d
        time_decorr = 1.17d
        scale_decorr = 1.5d
    ENDIF ELSE BEGIN
        reconstruct = -1d
        time_decorr = -1d
        scale_decorr = -1d
    ENDELSE

; construct Info structure
    info = {family:'Paul', $
        order_name:'Order', $
        order_range:order_range, $
        order:order, $
        discrete:0, $
        orthogonal:0, $
        symmetric:1, $
        support:!VALUES.d_infinity, $
        moments:1, $
        regularity:!VALUES.d_infinity, $
        efolding: 1/SQRT(2d), $
        fourier_period: fourier_period}
;       reconstruct: reconstruct, $
;       time_decorr: time_decorr, $
;       scale_decorr: scale_decorr, $
;       psizero: psizero}

    IF (NOT ARG_PRESENT(wavelet)) THEN RETURN, info ; don't bother with rest

; make sure we have Parameter, Order, N
    IF (N_PARAMS() LT 3) THEN MESSAGE, 'Incorrect number of arguments.'

    double = KEYWORD_SET(double)
    spatial = KEYWORD_SET(spatial)

; choose scaling coefficients
    n = nInput[0]  ; turn 1-element vectors into scalars
    scale = scaleInput[0]  ; turn 1-element vectors into scalars
    IF (double) THEN BEGIN
        pi = !DPI
        scale = DOUBLE(scale)
        underflow = -100
    ENDIF ELSE BEGIN
        pi = !PI
        scale = FLOAT(scale)
        underflow = -50
    ENDELSE

    IF (NOT spatial) THEN BEGIN  ; Fourier space

        IF (double) THEN BEGIN
            wavelet = DBLARR(n)
            frequency = DINDGEN(n)
        ENDIF ELSE BEGIN
            wavelet = FLTARR(n)
            frequency = FINDGEN(n)
        ENDELSE
        frequency[n/2 + 1] = frequency[(n/2 + 1):*] - n  ; negative freqs
        frequency = (2*pi/n)*TEMPORARY(frequency)   ; TC Eqn (5)

        energyFactor = SQRT(2*pi*scale)
        factor = (2d^order)/SQRT(order*FACTORIAL(2*order-1))
        exponent = scale*frequency

; use Heaviside step function and eliminate underflow errors
        good = WHERE((frequency GT 0) AND (-exponent GT underflow), ngood)
        IF (ngood GT 0) THEN BEGIN
            scaleFreq = exponent[good]
            wavelet[good] = (energyFactor*factor)* $
                (scaleFreq^order)*EXP(-scaleFreq)
        ENDIF

    ENDIF ELSE BEGIN  ; spatial

        IF (double) THEN BEGIN
            wavelet = DCOMPLEXARR(n)
            x = DINDGEN(n) - (n-1)/2d
        ENDIF ELSE BEGIN
            wavelet = COMPLEXARR(n)
            x = FINDGEN(n) - (n-1)/2.0
        ENDELSE
        energyFactor = SQRT(1/scale)
        wavelet[*] = (energyFactor*psizero)/ $
            ((1 - DCOMPLEX(0,x/scale))^(order+1))

    ENDELSE

    RETURN, info
END

