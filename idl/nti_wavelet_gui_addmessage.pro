;+
; NAME:
;	NTI_WAVELET_GUI_ADDMESSAGE
;
; PURPOSE:
;	This procedure extends the existing statustext and prints to text box
;	of NTI Wavelet Tools Graphical User Interface.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_ADDMESSAGE, addtext = addtext
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; INPUTS:
;	addtext:	This is the text to be printed out to text box.
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
; EXAMPLE:
;	NTI_WAVELET_GUI_ADDMESSAGE, addtext = 'Write here your messages!'
;
;-


pro nti_wavelet_gui_addmessage, addtext=addtext
@nti_wavelet_gui_common.pro

  ;read data from statusblock -> add new message -> write back to statusblock
  widget_control,nti_wavelet_gui_statustext_widg,get_value=statustext
  statustext=[addtext,statustext]
  widget_control,nti_wavelet_gui_statustext_widg,set_value=statustext
  return

end