;+
; NAME:
; NTI_WAVELET_SIGNUM
;
; PURPOSE:
; This function returns the sign of the input data in an array of the same size:
;   -1  for negative elements
;   1   for positive elements
;   0   for 0 and complex number
;     only works for numerics

; CALLING SEQUENCE:
; NTI_WAVELET_SIGNUM, input,
;
; INPUTS:
; input:    scalar,vector, or array
;
; EXAMPLE:
;    a = [[1., -2.], [0., 3.]]
;    print, NTI_WAVELET_SIGNUM(a)
;     1    -1
;     0    1
;-

function nti_wavelet_signum, input

return, fix(input gt 0.) - fix(input lt 0.)

end