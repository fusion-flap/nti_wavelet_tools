;+
; Name: nti_wavelet_sinc
;
; Written by: Laszlo Horvath 2010.04.24.
;
; Purpose: returns the normalized sinc function of an array
;
; Definition of normalized sinc function:
;        y = sin(Pi*x)/(Pi*x)    if x EQ 0
;        y = 1                   if x NE 0
;
; Calling sequence:
; y=nti_wavelet_sinc(x)
;
; Input:
; x: data array
; 
; Output:
; y: sinc of the input array
;-


function nti_wavelet_sinc,xfix

x=double(xfix)

counter=where(x EQ 0)                 ;find zeros in data array
if (counter NE -1) then x(counter)=1  ;if zeros were finded, set them to 1 avoid division-by-zero

y=sin(!DPi*x)/(!DPi*x)                 ;count sinc of the array
if (counter NE -1) then y(counter)=1  ;if zeros were finded, due to definition y(0)=1

return,y

end