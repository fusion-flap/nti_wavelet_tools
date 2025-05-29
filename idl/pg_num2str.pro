;+
; Name: pg_num2str
;
; Written by: Gergo Pokol (pokol@rmki.kfki.hu) 2003.03.24.
;
; Purpose: Convert a number to a string of minimum or specified length
;
; Calling sequence:
;	str = pg_num2str(num [,length])
;
; Inputs:
;	num: Number
;	length (optional): Length of the resulting string
;
; Output:
;	str: string
;
;-


function pg_num2str, num, length=length

;compile_opt defint32 ; 32 bit integers

str=strtrim(string(num),2)
if keyword_set(length) then str=strmid(str,0,length)
return, str

end
