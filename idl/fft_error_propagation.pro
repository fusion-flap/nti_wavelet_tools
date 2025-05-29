;+
; NAME:
;	FFT_ERROR_PROPAGATION
;
; PURPOSE:
;	This procedure calculates the propagation of the errors in time domain to frequency domain
;
; CALLING SEQUENCE:
;	FFT_ERROR_PROPAGATION, ...
;
; INPUTS:
;	fourier:	The FFT of the signal (complex array)
;	td_err:		The error in the time domain (function of time)
;	win:		The used window for the FFT
;
; INPUTS:
;
;	re_err:		The error on the real part of the fft
;	im_err:		The error on the imaginary part of the fft
;	abs_err:	The error on the absolute of the fft
;	abs_crit:	Shows the points where the results of abs_err can be used
;	abs_quad:	The second term of the Taylor series of the absolute value
;	phase_err:	The error on the phase of the fft
;	phase_crit:	Shows the points where the results of phase_err can be used
;	phase_quad:	The second term of the Taylor series of the phase
;	crit_ratio:	The usable value is where the second term of the Taylor series
;			is at least crit_ratio times smaller than the first term
;
; EXAMPLE:
;	
;
;-

pro fft_error_propagation, fourier = fourier, td_err = td_err, win = win, $
  re_err = re_err, im_err = im_err, $
  abs_err = abs_err, abs_crit = abs_crit, abs_quad = abs_quad, filtered_abs_err = filtered_abs_err, $
  phase_err = phase_err, phase_crit = phase_crit, phase_quad = phase_quad, filtered_phase_err = filtered_phase_err, $
  crit_ratio = crit_ratio
  

;Set defaults
nti_wavelet_default, win, 1
nti_wavelet_default, crit_ratio, 5

;Creating arrays from FFT
re_ft    = real_part(fourier)		;real part of the FFT
im_ft    = imaginary(fourier)		;imaginary part of the FFT
abs_ft   = abs(fourier)			;absolute value of the FFT
phase_ft = atan(fourier, /phase)	;phase of the FFT

;Number of datapoints
n = n_elements(fourier)

;Time indicator
time = systime(1)

;Initialize indices for matrix multification
z = findgen(n) ## findgen(n); z = u*x


;Real part of FFT
;--------------------------------------------------------------------------------
re_err_2 = reform(1./n^2*((cos(2*!pi*z/n)^2) ## (td_err^2*win^2)))	;calculate squared error
re_err = sqrt(re_err_2)							;calculate error

;Imaginary part of FFT
;--------------------------------------------------------------------------------
im_err_2 = reform(1./n^2*((sin(2*!pi*z/n)^2) ## (td_err^2*win^2)))	;calculate squared error
im_err = sqrt(im_err_2)							;calculate error

;Covariance
;--------------------------------------------------------------------------------
cov = reform(-0.5*1./n^2*(sin(2*2*!pi*z/n) ## (td_err^2*win^2)))	;calculate covariance

;Abs of FFT
;--------------------------------------------------------------------------------
abs_err_2 = 1./(abs(fourier))^2 * ( (re_ft)^2*re_err_2 + (im_ft)^2*im_err_2 + 2*re_ft*im_ft*cov )	;calculate squared error
abs_err = sqrt(abs_err_2)									;calculate error

;Phase of FFT
;--------------------------------------------------------------------------------
phase_err_2 = 1./(abs(fourier))^4 * ( (im_ft)^2*re_err_2 + (re_ft)^2*im_err_2 - 2*re_ft*im_ft*cov )	;calculate squared error
phase_err = sqrt(phase_err_2)									;calculate error

;Applicability criteria of the Abs of FFT
;--------------------------------------------------------------------------------
  ;The second term of the Taylor series of the absolute value
  abs_quad = 0.5*( re_err^2*(im_ft^2)/(abs_ft^3) - 2*cov*(re_ft*im_ft)/(abs_ft^3) + im_err^2*(re_ft^2)/(abs_ft^3) )
  ;The applicability criteria of the Abs of FFT
  abs_crit = fltarr(n)
  crit_index = where(crit_ratio*abs(abs_quad) lt abs(abs_ft), count)
  if count ne 0 then  abs_crit(crit_index) = 1
  filtered_abs_err = abs_err
  indices = where(~abs_crit, count)
  if keyword_set(count) then begin
    filtered_abs_err(indices) = 0
  endif

;Applicability criteria of the Phase of FFT
;--------------------------------------------------------------------------------
  ;The second term of the Taylor series of the Phase
  phase_quad = 0.5*( re_err^2*(2*re_ft*im_ft)/(abs_ft^4) + 2*cov*(im_ft^2 - re_ft^2)/(abs_ft^4) - im_err^2*(2*re_ft*im_ft)/(abs_ft^4) )
  ;The applicability criteria of the Abs of FFT
  phase_crit = fltarr(n)
  crit_index = where(crit_ratio*abs(phase_quad) lt abs(phase_ft), count)
  if count ne 0 then  phase_crit(crit_index) = 1
  filtered_phase_err = phase_err
  indices = where(~phase_crit, count)
  if keyword_set(count) then begin
    filtered_phase_err(indices) = 0
  endif

filtered_abs_err = reform(filtered_abs_err)
filtered_phase_err = reform(filtered_phase_err)

;--------------------------------------------------------------------------------

end