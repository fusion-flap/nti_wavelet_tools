;----------------------------------------------------------------
; $Id: pg_fn_morlet.pro,v 1.2 2009-06-05 11:37:18 pokol Exp $
;
;+
; NAME: PG_FN_MORLET
;
; PURPOSE
;    This function returns the Morlet wavelet.
;
; CALLING SEQUENCE
;    Info = PG_FN_MORLET( [Parameter] [, Scale, N]
;          [, /DOUBLE] [, /SPATIAL]
;          [, WAVELET=Wavelet] )
;
; INPUTS
;    Parameter
;        A scalar specifying the nondimensional frequency parameter
;        for the Morlet wavelet. The default is 6.0.
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
;       Info = {family:'Morlet', $    ; name of wavelet family
;               order_name:'Parameter', $     ; term used for "order"
;               order_range:[3,24,6], $   ; valid range [first,last,default]
;               order:6, $                ; order number
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
;        There is a phase and time shift between the spatial and Fourier wavelets!
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
;   Morlet wavelet transform using convolution:
;      n = 1024
;      x = RANDOMN(seed, n)   ; choose a random time series length n
;
;    parameter 6.0, scale 8, filter width 79 points
;      info = WV_FN_MORLET(6.0, 8, 79, /SPATIAL, WAVELET=wavelet)
;    find wavelet transform at scale 8:
;      cwtConvol = COMPLEX(CONVOL(x, FLOAT(wavelet), /EDGE_WRAP), $
;                    CONVOL(x, IMAGINARY(wavelet), /EDGE_WRAP))
;
;   The same transform using the fast Fourier transform:
;      info = WV_FN_MORLET(6.0, 8, n, WAVELET=wavelet)
;      cwtFFT = FFT(FFT(x)*CONJ(wavelet),/INVERSE)
;
;   Note that the FFT method is both much easier (since you don't need
;   to choose a filter width) and much faster.
;
; MODIFICATION HISTORY
;    Written by: Chris Torrence, 2000
;    Modified by: Gergo Pokol 2003.05.27: Allow parameters (orders) upto 100000
;-




;----------------------------------------------------------------
FUNCTION pg_fn_morlet, orderInput, scaleInput, nInput, $
    DOUBLE=double, $
    FREQUENCY=frequency, $
    SPATIAL=spatial, $
    WAVELET=wavelet

    COMPILE_OPT strictarr
    ON_ERROR,2  ; return to caller

;defaults
    order_range = [3d,100000d,6d]  ; [first,last,default]
    IF (N_ELEMENTS(orderInput) LT 1) THEN orderInput = order_range[2]
    order = DOUBLE(orderInput)

; check for invalid Order
    IF ((order LT order_range[0]) OR (order GT order_range[1])) THEN BEGIN
        MESSAGE,/INFO,'Order out of range, reverting to default...'
        order = order_range[2]  ; default
    ENDIF

    fourier_period = 4*!DPI/(order + SQRT(2d + order^2))
    reconstruct = EXP(1.65d)*order^(-1.06d)  ; empirical formula
    psizero = !DPI^(-0.25d)
    IF (order EQ 6) THEN BEGIN
    ; the following are only valid for order=6
        time_decorr = 2.32d
        scale_decorr = 0.60d
    ENDIF ELSE BEGIN
        time_decorr = -1d
        scale_decorr = -1d
    ENDELSE

; construct Info structure
    info = {family:'Morlet', $
        order_name:'Order', $
        order_range:order_range, $
        order:order, $
        discrete:0, $
        orthogonal:0, $
        symmetric:1, $
        support:!VALUES.d_infinity, $
        moments:1, $
        regularity:!VALUES.d_infinity, $
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
        frequency[n/2 + 1] = frequency[(n/2 + 1):*] - n  ; negative frequencies
        frequency = (2*pi/n)*TEMPORARY(frequency)   ; TC Eqn (5)

        energyFactor = SQRT(2*pi*scale)
        exponent = -(scale*frequency - order)^2/2

; use Heaviside step function and eliminate underflow errors
        good = WHERE((frequency GT 0) AND (exponent GT underflow), ngood)
        IF (ngood GT 0) THEN wavelet[good] = $
            (energyFactor*(pi^(-0.25)))*EXP(exponent[good])

    ENDIF ELSE BEGIN  ; spatial

        IF (double) THEN BEGIN
            wavelet = DCOMPLEXARR(n)
            x = DINDGEN(n) - (n-1)/2d
        ENDIF ELSE BEGIN
            wavelet = COMPLEXARR(n)
            x = FINDGEN(n) - (n-1)/2.0
        ENDELSE
        energyFactor = SQRT(1/scale)
        xdscale = x/scale
        exponent = -(xdscale)^2/2

;   eliminate underflow errors
        good = WHERE(exponent GT underflow, ngood)
        IF (ngood GT 0) THEN BEGIN
            xdscale = order*xdscale[good]
            cmplxExp = double ? DCOMPLEX(COS(xdscale),SIN(xdscale)) : $
                COMPLEX(COS(xdscale),SIN(xdscale))
            wavelet[good] = (energyFactor*(pi^(-0.25)))* $
                EXP(exponent[good])*cmplxExp
        ENDIF

    ENDELSE

    RETURN, info
END
