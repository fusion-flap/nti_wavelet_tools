;+
;
;NAME: nti_wavelet_default
;
; Written by: Sandor Zoletnik
;
; PURPOSE: Set default value for variable, if it is not defined. 
;    If keyword /nullarray is set, it also sets default value for a variable equaling 0.
;
; Calling sequence:
;   nti_wavelet_default,var,value,[nullarray]
;
; Inputs:
;   var: variable name to be examined
;   val: default value to be set
;   /nullarray (optianal): switch to set default value also for a variable equaling 0
;
; Output:
;   var: returns default value or original value 
;
; Example:
;  nti_wavelet_default,x,0
;  print,x
;  nti_wavelet_default,x,1
;  print,x
;  nti_wavelet_default,x,1,/nullarray
;  print, x
;
;-

forward_function nti_wavelet_defined

pro nti_wavelet_default,var,value,nullarray=nullarray
  if (not nti_wavelet_defined(var,nullarray=nullarray)) then var=value
end
