;+
; Name: pg_log2
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.04.17.
;
; Purpose: Return log base 2 of a number
;
; Calling sequence:
;	y=pg_log2(x)
;
; Input: 
;	x: number
;
; Output: 
;	y: log base 2 of x
;
;-

function pg_log2, x

return, alog(x)/alog(2)

end
