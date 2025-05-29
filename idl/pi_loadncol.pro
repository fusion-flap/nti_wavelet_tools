;+
;
;NAME: pi_loadancol
;
; ************************** LOADNCOL.PRO *************** 28.07.2000 ******************
;                                                 Written by S. Zoletnik
;   Modified by Istvan Pusztai; 19.07.2007
;   Modified by Gergo Pokol; 21.07.2008, stringout switch added
; This function reads numbers (or strings) arranged in rows and columns from and ASCII file.
; This program replaces and old version which used unix systems calls to determine
; the number of lines and columns. The present version uses only IDL file operations
; this it shoudl be system-independent.
;   Each line should contain exactly the same amount of numbers (or strings). A file header can be
; handled if the headerline argument gives the number of header lines.
;   The return value is a 2D array of float numbers (or strings), first index is line number, second
; is column. In case of error, 0 is returned.
;
; INPUT:
;   file: name of file (string)
;   n: number of columns (optional, if not given will be determined from first non-header
;      line
;   headerline: number of header lines
;   text: The header text is returned in this variable (string array)
;   /cutzero: omit trailing lines with all zeros
; /silent: DO not print info and error messages
;   errormess: error message or ''  (string)
;   tmpfile: not used, kept for compatibility with all loadncol
; block_line_n:
; /stringout: Return string array, no conversion to floating point
; ***************************************************************************************
;-

function pi_loadncol,file,n,headerline=headn,cutzero=cutzero,silent=silent,$
  tmpfile=tmpfile,text=text,errormess=errormess,block_line_n=block_line_n,$
  stringout=stringout


nti_wavelet_default,headn,0
nti_wavelet_default,block_line_n,10l
nti_wavelet_default,stringout,0
block_line_n=long(block_line_n)

errormess=''

if (!version.os eq 'Win32') then begin
  while (strpos(file,'/') ge 0) do begin
    strput,file,'\',strpos(file,'/')
  endwhile
endif

openr,unit,file,/get_lun,error=error
if (error ne 0) then begin
  errormess = 'Cannot open file '+file
		if (not keyword_set(silent)) then print,errormess
		return,0
endif

if (headn ne 0) then begin
;  on_ioerror,err
  text=strarr(headn)
  txt='a'
  for i=1,headn do begin
    readf,unit,txt
    text(i-1)=txt
  endfor
endif

line_counter=long(0)
while (not eof(unit)) do begin
  txt=''
		readf,unit,txt
		txt=strcompress(strtrim(txt,2))
		txt_arr=strsplit(txt,' ',/extract)
		if (not keyword_set(n)) then n=n_elements(txt_arr)
		if (line_counter eq 0) then begin
				if (not keyword_set(silent)) then begin
				  print,'Reading '+string(n,format='(I2)')+' columns from file '+file
				endif
				if stringout then data=strarr(block_line_n,n) $
					else data=fltarr(block_line_n,n)
				act_line_n=block_line_n
		endif
		if (line_counter ge act_line_n) then begin
		  data1=data
				if stringout then data=strarr(act_line_n+block_line_n,n) $
					else data=fltarr(act_line_n+block_line_n,n)
				data(0:act_line_n-1,*)=data1
				act_line_n=act_line_n+block_line_n
		endif
		if stringout then flt_arr=txt_arr $
			else flt_arr=float(txt_arr)
		if (n_elements(flt_arr) ne n) then begin
		  errormess='Number of data in line is different from expected. (file: '+file+')'
		  if (not keyword_set(silent)) then print,errormess
		  close,unit & free_lun,unit
		  return,0
		endif
		data(line_counter,*)=flt_arr
		line_counter=line_counter+1
endwhile
close,unit & free_lun,unit
data=data(0:line_counter-1,*)

if (keyword_set(cutzero)) then begin
  nn = total(data(*,0) ne 0)
  data=data(0:nn-1,*)
endif


return,data

err:
  errormess = 'Error reading from file '+file
		if (not keyword_set(silent)) then print,errormess
		close,unit & free_lun,unit
		return,0

end
