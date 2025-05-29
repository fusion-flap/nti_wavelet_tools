;+
; NAME:
; NTI_WAVELET_GUI_SAVEMAT
;
; PURPOSE:
; This procedure is save the raw data from the GUI
; to a Matlba binary file (.mat).
;
;   THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;   DO NOT CALL THIS ROUTINE ALONE!
;
;
; CALLING SEQUENCE:
; NTI_WAVELET_GUI_SAVEMAT, $
;   [,filename] [,expname] [,shotnumber] $
;   [,channels] [,data_data] [,timeax] $
;   [,theta] [,phi] $
;   [,data_history] [,coord_history]
;
; INPUTS:
;   filename:       The filename of the .mat file to be saved.
; Variables to be saves to the .mat file:
;   expname:        Name of the experiment. [string]
;   shotnumber:     Shotnumber. [long integer]
;   channels:       Name of the different signals. [string array]
;   data_data:      Array containing all signals. [floating point array]
;   timeax:         Vector containing the time axis. [floating point vector]
;   theta:          Theta coordinates. [floating point vector]
;   phi:            Phi coordinates. [floating point vector]
;   data_history:   Short description of data. [string]
;   coord_history:  Short description of coordinates. [string]
;
;-


pro nti_wavelet_gui_savemat, $
  filename = filename, expname = expname, shotnumber = shotnumber, $
  channels = channels, data_data = data_data, timeax = timeax, theta = theta, $
  phi = phi, data_history = data_history, coord_history = coord_history

; Save .mat file using Slither Python IDL Bridge
sio = pyimport("scipy.io")
; Create Python dicitonary which contains the variables to be saved to the .mat file:
dict = pykwargs("expname", expname, "shotnumber", shotnumber, "channels", channels, $
  "data", data_data, "timeax", timeax, "theta", theta, "phi", phi, "data_history", data_history, $
  "coord_history", coord_history)
; Save .mat file using scipy.io Python library
tmp = sio->savemat(filename, dict)

end