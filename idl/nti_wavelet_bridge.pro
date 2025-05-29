;+
; NAME: nti_wavelet_bridge
;
; PURPOSE: The routine accepts input data as arrays, assemble the input_structure and call nti_wavelet_gui.pro.
;          The call of nti_wavelet_gui.pro can be disabled, the assembled input_stucture is an optional output.
;          Primary area of application is to serve as a bridge between nti_wavelet_gui.pro and routines outside IDL.
;
; INPUTS:
;   expname:        Name of the experiment. [string]
;   shotnumber:     Shotnumber. [long integer]
;   channels:       Name of the different signals. [string array]
;   datas:      Array containing all signals. [floating point array]
;   time:         Vector containing the time axis. [floating point vector]
;   theta:          Theta coordinates. [floating point vector]
;   phi:            Phi coordinates. [floating point vector]
;   data_history:   Short description of data. [string]
;   coord_history:  Short description of coordinates. [string]
;   file_name(optional): File name to save input structure to
;   nocall (optional): Switch to disable call of nti_wavelet_gui.pro  [boolean]
;
; OUTPUT:
;   input_structure (optional): input_structure of nti_wavelet_gui
;-

pro nti_wavelet_bridge, expname=expname, shotnumber=shotnumber, channels=channels, datas=datas,$
  time=time, theta=theta, phi=phi, data_history=data_history, coord_history=coord_history,$
  file_name=file_name, nocall=nocall, input_structure=input_structure

nti_wavelet_default,nocall,0

input_structure = { $
;Signal features:
	expname : expname, $
	shotnumber : shotnumber, $
	channels : channels, $
	coord_history : coord_history, $
	data_history : "Loaded-with-MTR", $
;Data of signals:
	data : datas, $
	time : time, $
	theta : theta, $
	phi : phi $
}

if nti_wavelet_defined(file_name) then begin 
  timeax=time
  data=datas
  save, expname, shotnumber, channels, coord_history, data_history, data, timeax, theta, phi, filename=file_name
  print, 'input structure saved to '+file_name
endif

if not nocall then nti_wavelet_gui, input_structure=input_structure

end