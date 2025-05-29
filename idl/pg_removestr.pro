;+
; Name: pg_removestr
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.05.28.
;
; Purpose: Replace special characters from string
;
; Calling sequence:
;	str2=pg_removestr(str1)
;
; Input: 
;	str1: string
;
; Output: 
;	str2: string
;-

function pg_removestr, str1

ch1=[' ']
ch2=['/','[',']','(',')',':']

str2=str1
for i=0,n_elements(ch1)-1 do begin
	while strpos(str2,ch1[i]) NE -1 do str2=strmid(str2,0,strpos(str2,ch1[i]))+'_'+strmid(str2,strpos(str2,ch1[i])+1)
endfor
for i=0,n_elements(ch2)-1 do begin
	while strpos(str2,ch2[i]) NE -1 do str2=strmid(str2,0,strpos(str2,ch2[i]))+'-'+strmid(str2,strpos(str2,ch2[i])+1)
endfor

return, str2

end
