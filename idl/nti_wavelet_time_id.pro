;+
; NAME:
; NTI_WAVELET_TIMESTAMP
;
; PURPOSE:
; This function extracts the timestamp from the name of the plot (standard NTI Wavelet name)
; e.g.: 1469999157957_Toroidal_mode_numbers_of_AUGD_23418 >>> 1469999157957
;
; CALLING SEQUENCE:
; TIME_ID=NTI_WAVELET_TIMESTAMP(FILE_ID=FILE_ID)
;
;   THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;   DO NOT CALL THIS ROUTINE ALONE!
;   
;   INPUT:
;   FILE_ID: the full name of the file (returned by pg_filename.pro)
;   
;   OUTPUT:
;   TIME_ID: the timestamp of the file
;
;-
;

function nti_wavelet_time_ID,$
  file_id
  
  if nti_wavelet_defined(file_id) then begin
    temp_1 = strsplit(file_id, '/\',/EXTRACT)
    temp_2 = strsplit(temp_1(n_elements(temp_1)-1), '_', /EXTRACT)
    time_ID = temp_2(0)  
      return, time_ID
  endif else begin
    time_ID = '0'
    print, 'file_id input has not been specified.'
      return, time_ID
  endelse
end