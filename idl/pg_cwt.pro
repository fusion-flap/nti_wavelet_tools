;+
;NAME: WV_CWT
;
; PURPOSE
;    This function computes the continuous wavelet transform
;    for one-dimensional arrays.
;
; CALLING SEQUENCE
;    Result = WV_CWT( Array, Family, Order)
;
; INPUTS
;   Array = A one-dimensional array of data, either real or complex.
;
;   Family = A string giving the name of the wavelet function to use.
;
;   Order = A scalar specifying the order or parameter
;           for the wavelet function.
;
;
; OUTPUTS
;    Result = A two-dimensional array containing the wavelet transform.
;             If Family is symmetric in Fourier space then Result will
;             be real (e.g. the 'Gaussian' family). If Family is not
;             symmetric then Result will be complex (e.g. 'Morlet' or 'Paul').
;
; KEYWORD PARAMETERS
;   DOUBLE = Set this keyword to force the computation to be done in
;        double precision arithmetic.
;
;   DSCALE = Set this keyword to a scalar value giving the spacing
;        between scale values, in logarithmic units. The default is 0.25,
;        which gives four subscales within each major scale.
;
;   NSCALE = Set this keyword to a scalar value giving the total number
;        of scale values to use for the wavelet transform.
;        The default is [log 2 (N/START_SCALE)]/DSCALE+1.
;
;   PAD = Set this keyword to force Array to be padded with zeroes before
;        computing the transform. Enough zeroes are added to make the
;        total length of Array equal to the next-higher power-of-two
;        greater than 2N. Padding with zeroes prevents wraparound
;        of the Array and speeds up the fast Fourier transform.
;
;      Note - Padding with zeroes reduces, but does not eliminate,
;        edge effects caused by the discontinuities at the start
;        and end of the data.
;
;   SCALE = Set this keyword to a named variable in which to return
;        the scale values used for the continuous wavelet transform.
;        The SCALE values range from START_SCALE up to
;        START_SCALE*2^[(NSCALE-1)*DSCALE].
;
;   START_SCALE = Set this keyword to a scalar value giving the
;        starting scale, in non-dimensional units.
;        The default is 2, which gives a starting scale that is
;        twice the spacing between Array elements.
;
; REFERENCE
;    Torrence, C. and G.P. Compo, 1998: A practical guide to wavelet analysis.
;        Bull. Amer. Meteor. Soc., v. 79, pp. 61-78.
;
; EXAMPLE
;   Morlet wavelet transform using convolution:
;      n = 1024
;      time = FINDGEN(n)
;      data = RANDOMN(seed, n)   ; choose a random time series length n
;
;   Find wavelet transform for Morlet order=6:
;      cwt = WV_CWT(data, 'Morlet', 6, SCALE=scale)
;
;   Color contour plot:
;      LOADCT, 39
;      CONTOUR, cwt, time, scale, /YLOG, /FILL, XSTYLE=1, YSTYLE=1, $
;          XTITLE='Time', YTITLE='Scale'
;
; MODIFICATION HISTORY
;    Written by: Chris Torrence, 2000
;    CT, RSI, Sept 2001: Complex input was being converted to real.
;                        Now uses both real & imaginary parts.
;
;    Gergo Pokol 2003.05.15: Progress indicator added, calls pg_fn_*.pro for wavelets
;
;-




;----------------------------------------------------------------
; ALOG2
;    Compute the logarithm base-2.
;
; Result = ALOG2(Array)
;
; Array = input variable of any simple type. If Array is of type double
;         or double-complex then the computation will be double precision.
;
; Result = output variable of type single-precision or double-precision.
;
FUNCTION alog2, array
    COMPILE_OPT STRICTARR, HIDDEN
    tname = SIZE(array, /TNAME)
    two = ((tname EQ 'DOUBLE') OR (tname EQ 'DCOMPLEX')) ? 2d : 2.0
    RETURN, ALOG(array)/ALOG(two)
END



;----------------------------------------------------------------
; Main function
;
FUNCTION pg_cwt, dataInput, family, order, $
    DOUBLE=double, $
    DSCALE=dscaleIn, $
    NSCALE=nscaleIn, $
    PAD=pad, $
    SCALE=scale, $
    START_SCALE=start_scaleIn

    COMPILE_OPT STRICTARR

    ON_ERROR, 2
; check input parameters
    IF (N_PARAMS() LT 2) THEN MESSAGE, $
        'Incorrect number of arguments.'

    IF (SIZE(dataInput,/N_DIMENSIONS) NE 1) THEN MESSAGE, $
        'Input array must be a one-dimensional vector.'

    nData = N_ELEMENTS(dataInput)
    IF (nData LT 3) THEN MESSAGE, $
        'Input array must have at least 3 elements.'


; check keywords
    tname = SIZE(dataInput, /TNAME)
    double = KEYWORD_SET(double) OR $
        (tname EQ 'DOUBLE') OR (tname EQ 'DCOMPLEX')
    doComplex = (tname eq 'COMPLEX') or (tname eq 'DCOMPLEX')

    n = KEYWORD_SET(pad) ? 2L^CEIL(ALOG2(2L*nData)) : nData


; check scaleIn parameters
    IF (N_ELEMENTS(start_scaleIn) EQ 0) THEN start_scaleIn = 2d
    start_scale = start_scaleIn[0]  ; convert 1-element array to scalar
    IF (N_ELEMENTS(dscaleIn) EQ 0) THEN dscaleIn = 0.25d
    dscale = dscaleIn[0]
    IF (N_ELEMENTS(nscaleIn) EQ 0) THEN $
        nscaleIn = ALOG2(nData/start_scale)/dscale + 1  ; TC Eqn (10)
    nscale = nscaleIn[0]


; construct arrays, either single or double precision
    IF (double) THEN BEGIN
        pi = !DPI
        frequency = DINDGEN(n)
        scale = DINDGEN(nscale)
        data = doComplex ? DCOMPLEXARR(n) : DBLARR(n)
        cwt = DCOMPLEXARR(nData, nscale, /NOZERO)
    ENDIF ELSE BEGIN
        pi = !PI
        frequency = FINDGEN(n)
        scale = FINDGEN(nscale)
        data = doComplex ? COMPLEXARR(n) : FLTARR(n)
        cwt = COMPLEXARR(nData, nscale, /NOZERO)
    ENDELSE


; construct scale vector
    scale = start_scale*(2^(dscale*TEMPORARY(scale)))   ; TC Eqn (9)


; forward Fourier transform of the data
    data[0] = dataInput - TOTAL(dataInput)/nData   ; remove mean
    dataFFT = FFT(TEMPORARY(data), DOUBLE=double)   ; TC Eqn (3)

; Initialize progress indicator
	T=systime(1)

; loop over all scales, construct CWT for each scale
    FOR j = 0, nscale-1 DO BEGIN
        ; get wavelet filter for scale[j]
        waveInfo = CALL_FUNCTION('pg_fn_' + strlowcase(family), $
            order, scale[j], n, $
            DOUBLE=double, $
            WAVELET=wavelet)
        ; inverse Fourier transform  TC Eqn (4)
        cwt[0,j] = (FFT(TEMPORARY(wavelet)*dataFFT, $
            /INVERSE, $
            DOUBLE=double))[0:nData-1]
		; Progress indicator
		if floor(systime(1)-T) GE 5 then begin
			print, pg_num2str(double(j)/(nscale-1)*100)+' % done'
			T=systime(1)
			wait,0.1
		endif
    ENDFOR


; complex or not?
    ; call the wavelet function with only 1 point, single-precision
    waveInfo = CALL_FUNCTION('pg_fn_' + STRLOWCASE(family), $
        order, scale[0], 1, $
        /SPATIAL, WAVELET=wavelet)
    ; the result will either be FLOAT or COMPLEX
    IF (SIZE(wavelet,/TNAME) EQ 'FLOAT') THEN $
        cwt = double ? DOUBLE(TEMPORARY(cwt)) : FLOAT(TEMPORARY(cwt))


    RETURN, cwt
END
