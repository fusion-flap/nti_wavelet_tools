;+
;NAME: pg_filename
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.05.29.
;
; PURPOSE: Create filename from title
;
;
; CALLING SEQUENCE:
;	filename=pg_filename(title [,ext] [,dir])
;
; INPUTS:
;	title: Title of the plot (string)
;	ext (optional): Extension of file; default: '.ps'
;	dir (optional): Subdirectory of data; default: 'output'
;
; OUTPUT:
;	filename: Filename of the PS file
;
;-

function pg_filename, title, ext=ext, dir=dir

; Set defaults, constants
if not(keyword_set(ext)) then ext='.ps'
if not (keyword_set(dir)) then cd, current=dir

filename=pg_removestr(title)
if keyword_set(dir) && ~(file_test(dir,/directory)) then file_mkdir, dir
filename=filepath(nti_wavelet_i2str(1000*systime(1))+'_'+filename+ext,root_dir=dir)

return, filename

end
