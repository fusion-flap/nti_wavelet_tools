;+
;
;NAME: nti_wavelet_read_wav
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2014.05.21.
;
; PURPOSE: Read wav file and save to sav file that can be read and analysed by NTI Wavelet Tools.
;
; CALLING SEQUENCE (optional variables marked by []): 
;    nti_wavelet_read_wav, filename
;
; INPUTS:
;    filename: File name string of wav file with path
;
; FILE OUTPUTS:
;    .sav file written to same folder as input with same name as input .wav
;
;-

pro nti_wavelet_read_wav,$
  ; Input
    filename=filename

compile_opt defint32 ; 32 bit integers

; Set defaults and constants

; Read wav file
if query_wav(filename,info) then begin
  expname=strsplit(filename,'.\/',count=strsplit_count,/extract)
  expname=expname(strsplit_count-2)
  shotnumber=0
  channels=i2str(indgen(info.channels))
  signal=read_wav(filename)
  data=double(transpose(signal))
  data_history='Converted from '+filename
  ; Duplicate data if mono signal was loaded
  if channels EQ 0 then begin
    data=transpose([transpose(reform(data)),transpose(dblarr(n_elements(data)))])
    data_history=data_history+', second data channel filled with zeros'
    channels=[channels,'empty']
  endif
  elements=n_elements(data(*,0))
  channelnum=n_elements(data(0,*))
  timeax=dindgen(elements)/double(info.samples_per_sec)
  theta=fltarr(channelnum)
  phi=fltarr(channelnum)
  coord_history='Filled with zeros'
  new_filename=strsplit(filename,'.',count=strsplit_count,/extract)
  new_filename=strjoin([new_filename(0:strsplit_count-2),'sav'],'.')
  save, expname, shotnumber, channels, data, timeax, theta, phi, data_history, coord_history, filename = new_filename
  print, 'Converted file saved to: '+new_filename
endif else begin
  print, 'No proper wav file found!'
endelse


end