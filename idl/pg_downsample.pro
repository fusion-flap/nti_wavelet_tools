;+
; Name: pg_downsample
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.04.15.
;
; Purpose: Perform downsampling on 1D data vector
;
; Calling sequence:
;	y=pg_downsample(x [,step])
;
; Input:
;	x: 1D data vector to be downsampled
;	step (optional): scale of downsampling; default: 2
;
; Output:
;	y: Downsampled vector: (y=(x(0),x(step),x(2*step),...)
;
; Modification:
;	2005.04.14: later: (y=(x(step-1),x(2*step-1),...)
;
;-


function pg_downsample, x, step=step

compile_opt defint32 ; 32 bit integers

; Set defaults
size=n_elements(x)
if not(keyword_set(step)) then step=2

newsize=floor(size/step)
y=dblarr(newsize)
for i=1,newsize do y(i-1)=x(step*(i-1))

return, y

end
