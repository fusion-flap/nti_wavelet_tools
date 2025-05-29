;+
;
;NAME: nti_wavelet_defined
;
; Written by: Sandor Zoletnik
;
; PURPOSE: Return 1, if variable exists, otherwise 0. 
;    If keyword /nullarray is set, it also returns 0 for a variable equaling 0.
;
; Calling sequence:
;   vareixsts=nti_wavelet_defined(var,[nullarray])
;
; Inputs:
;   var: variable name to be examined
;   /nullarray (optianal): switch to return 0 also for a variable equaling 0
;
; Output:
;   return value: 0 or 1 
;
; Example:
;  print, nti_wavelet_defined(x)
;  x=0
;  print, nti_wavelet_defined(x)
;  print, nti_wavelet_defined(x,/nullarray)
;  x=0
;  print, nti_wavelet_defined(x,/nullarray)
;
;-

function nti_wavelet_defined,var,nullarray=nullarray

if (((size(var))(0) eq 0) and ((size(var))(1) eq 0)) then begin
  return,0
endif else begin
  if (keyword_set(nullarray)) then $
    ;String:
      if (size(var, /type) eq 7) then begin
       if ((where(var ne ''))(0) lt 0) then return,0
      endif else begin
    ;Not String
       if ((where(var ne 0))(0) lt 0) then return,0
      endelse
  return,1
endelse
end
