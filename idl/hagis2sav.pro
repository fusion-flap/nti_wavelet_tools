;********************************************************************************************************
; Name: hagis2sav.pro
;
; PURPOSE
; =======
; This program converts data exported from HAGIS to plain text output with the following structure:
; 1st column: time vector
; 2nd column: signal vector
;
; INPUTS
; =======
; filename:               Name of text file to convert with path
; noise_level (optional): Noise level measured in power ratio; default: 0.05
;
; OUTPUT
; =======
; .sav file in a format cmpatible with NWT
; 
; USAGE
; =======
; hagis2sav,'A:\3programs\NTI_Wavelet_Tools\trunk\save_data\mode_100_66_33_res_free'
; 
;********************************************************************************************************
pro hagis2sav, filepathname, noise_level=noise_level

  nti_wavelet_default, noise_level, 0.05
  
  data_read = pi_loadncol(filepathname, headerline=0)
  
  if (size(data_read))[0] EQ 1 then return ; Scalar output indicates error
  
  filename = (strsplit(filepathname, '/\', /EXTRACT))[-1] ; Recover stripped file name
  
  data = data_read[*,1]
  noiseAmpl = sqrt(noise_level*mean(abs(data)^2))
  data+=noiseAmpl*randomn(seed,n_elements(data)); Add noise
  timeax = reform(data_read[*,0])
  phi = 0.
  theta = 0.
  shotnumber = 0
  expname = 'HAGIS'
  channels = filename
  coord_history = 'Not modelled'
  data_history = 'HAGIS output'
  
  save, data, timeax, phi, theta, shotnumber, expname, channels, coord_history, data_history,$
      filename=filepathname+'.sav'
      
  print, 'HAGIS data written to ' + filepathname+'.sav'
      
end