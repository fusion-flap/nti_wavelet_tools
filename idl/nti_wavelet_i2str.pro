function nti_wavelet_i2str,i_in,digits=digits
; **********************************************************************
; converts an integer to string using only as many characters as necessary
; digits: converts to at least <digits> long string by using leading zeros
;************************************************************************

; Modified in 2005. 06. 10.  by D.Dunai

sz=size(i_in)
num=n_elements(sz)

type=sz[num-2]

if (type eq 7) then begin

str=i_in
str1=''
; print, 'Argument of nti_wavelet_i2str was string type'

endif else begin

if (abs(i_in) lt 1) then begin
  if (not keyword_set(digits)) then return,'0'
  str=''
  for ii=1,digits do str=str+'0'
  return,str
endif
i=i_in
str=''
if (i lt 0) then begin
  i = -i
  str1='-'
endif   else begin
  str1=''
endelse
n=fix(alog10(i))+1
if (n lt 10) then nstr=string(n,format='(I1)') else nstr=string(n,format='(I2)')
f='(I'+nstr+')'
str=string(i,format=f)
if (keyword_set(digits)) then begin
  len=strlen(str)
  if (len lt digits) then begin
    for i=1,digits-len do str='0'+str
  endif
endif
endelse
str=str1+str
return,str
end

