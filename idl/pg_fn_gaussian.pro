;----------------------------------------------------------------
; $Id: pg_fn_gaussian.pro,v 1.1 2008-07-23 16:44:38 pokol Exp $
;
; Copyright (c) 2000-2002, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;+
; NAME
;    WV_FN_GAUSSIAN
;
; PURPOSE
;    This function returns the Gaussian-derivative wavelet.
;
; CALLING SEQUENCE
;    Info = WV_FN_GAUSSIAN( [Parameter] [, Scale, N]
;          [, /DOUBLE] [, /SPATIAL]
;          [, WAVELET=Wavelet] )
;
; INPUTS
;    Parameter
;        A scalar integer specifying the nondimensional frequency parameter
;        for the Gaussian-derivative wavelet. The default is 2 (also known
;        as the Marr or Mexican Hat wavelet).
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
;       Info = {family:'Gaussian', $    ; name of wavelet family
;               order_name:'Derivative', $     ; term used for "order"
;               order_range:[1,6,2], $   ; valid range [first,last,default]
;               order:2, $                ; order number
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
;   Gaussian-derivative wavelet transform using convolution:
;      n = 1024
;      x = RANDOMN(seed, n)   ; choose a random time series length n
;
;    parameter 6.0, scale 8, filter width 79 points
;      info = WV_FN_GAUSSIAN(6.0, 8, 79, /SPATIAL, WAVELET=wavelet)
;    find wavelet transform at scale 8:
;      cwtConvol = COMPLEX(CONVOL(x, FLOAT(wavelet), /EDGE_WRAP), $
;                    CONVOL(x, IMAGINARY(wavelet), /EDGE_WRAP))
;
;   The same transform using the fast Fourier transform:
;      info = WV_FN_GAUSSIAN(6.0, 8, n, WAVELET=wavelet)
;      cwtFFT = FFT(FFT(x)*CONJ(wavelet),/INVERSE)
;
;   Note that the FFT method is both much easier (since you don't need
;   to choose a filter width) and much faster.
;
; MODIFICATION HISTORY
;    Written by: Chris Torrence, 2000
;
;-

FUNCTION wv_fn_gauss_deriv, x, order, underflow
    COMPILE_OPT strictarr, hidden
    ON_ERROR,2  ; return to caller

    result = x*0
; eliminate underflow errors
    good = WHERE(-ABS(x) GT underflow, ngood)
    IF (ngood EQ 0) THEN RETURN, result

    y = x[good]
    y2 = y^2

    CASE order OF
    1: poly = -y
    2: poly = (y2 - 1)
    3: poly = y*(3 - y2)
    4: poly = 3 + y2*(-6 + y2)
    5: poly = y*(-15 + y2*(10 - y2))
    6: poly = -15 + y2*(45 + y2*(-15 + y2))
    7: poly = -y*(-105 + y2*(105 + y2*(-21 + y2)))
    8: poly = 105 + y2*(-420 + y2*(210 + y2*(-28 + y2)))
    9: poly = -y*(945 + y2*(-1260 + y2*(378 + y2*(-36 + y2))))
    10: poly = -945 + y2*(4725 + y2*(-3150 + y2*(630 + y2*(-45 + y2))))
    ELSE: MESSAGE,'Value for ORDER is out of range.'
    ENDCASE

    result[good] = TEMPORARY(poly)*EXP(-y2/2)
    RETURN, result
END


;----------------------------------------------------------------
FUNCTION wv_fn_gaussian, orderInput, scaleInput, nInput, $
    DOUBLE=double, $
    FREQUENCY=frequency, $
    SPATIAL=spatial, $
    WAVELET=wavelet

    COMPILE_OPT strictarr
    ON_ERROR,2  ; return to caller

;defaults
    order_range = [1,10,2]  ; [first,last,default]
    IF (N_ELEMENTS(orderInput) LT 1) THEN orderInput = order_range[2]
    order = FIX(orderInput)

; check for invalid Order
    IF ((order LT order_range[0]) OR (order GT order_range[1])) THEN BEGIN
        MESSAGE,/INFO,'Order out of range, reverting to default...'
        order = order_range[2]  ; default
    ENDIF

    fourier_period = 2*!DPI/SQRT(order + 0.5d)
    gammaFactor = SQRT(GAMMA(order + 0.5d))
    psizero = (-1^(order+1))/gammaFactor
    IF (order EQ 2) THEN BEGIN
    ; the following are only valid for order=2
        reconstruct = 3.541d
        time_decorr = 1.43d
        scale_decorr = 1.4d
    ENDIF ELSE BEGIN
        reconstruct = -1d
        time_decorr = -1d
        scale_decorr = -1d
    ENDELSE

; construct Info structure
    info = {family:'Gaussian', $
        order_name:'Derivative', $
        order_range:order_range, $
        order:order, $
        discrete:0, $
        orthogonal:0, $
        symmetric:1, $
        support:-1, $
        moments:-1, $
        regularity:-1d, $
        efolding: SQRT(2d), $
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
        ii = DCOMPLEX(0,1)
        scale = DOUBLE(scale)
        underflow = -SQRT(2*100.)
    ENDIF ELSE BEGIN
        pi = !PI
        ii = COMPLEX(0,1)
        scale = FLOAT(scale)
        underflow = -SQRT(2*50.)
        psizero = FLOAT(psizero)
    ENDELSE

    IF (NOT spatial) THEN BEGIN  ; Fourier space

        IF (double) THEN BEGIN
            wavelet = DCOMPLEXARR(n)
            frequency = DINDGEN(n)
        ENDIF ELSE BEGIN
            wavelet = COMPLEXARR(n)
            frequency = FINDGEN(n)
        ENDELSE
        frequency[n/2 + 1] = frequency[(n/2 + 1):*] - n  ; negative freqs
        frequency = (2*pi/n)*TEMPORARY(frequency)   ; TC Eqn (5)

        energyFactor = SQRT(2*pi*scale)
        factor = -(ii^order)/gammaFactor
        exponent = scale*frequency

; eliminate underflow errors
        good = WHERE(-ABS(exponent) GT underflow, ngood)
        IF (ngood GT 0) THEN BEGIN
            scaleFreq = exponent[good]
            wavelet[good] = (energyFactor*factor)* $
                (scaleFreq^order)*EXP(-scaleFreq^2/2)
        ENDIF

    ENDIF ELSE BEGIN  ; spatial

        x = double ? DINDGEN(n) - (n-1)/2d : $
            FINDGEN(n) - (n-1)/2.0

        energyFactor = SQRT(1/scale)
        wavelet = energyFactor*psizero* $
            WV_FN_GAUSS_DERIV(x/scale, order, underflow)

    ENDELSE

    RETURN, info
END

