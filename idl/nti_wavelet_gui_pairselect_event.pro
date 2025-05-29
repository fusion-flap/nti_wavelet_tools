;+
; NAME:
;	NTI_WAVELET_GUI_PAIRSELECT_EVENT
;
; PURPOSE:
;	This procedure is the event handler of the channel pair selection
;	widget (nti_wavelet_gui_pairselect_base_widg) in NTI Wavelet
;	Tools Graphical User Interface.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_EVENT
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
;-


pro nti_wavelet_gui_pairselect_event, event
@nti_wavelet_gui_common.pro

;RESET button
  if (event.ID eq nti_wavelet_gui_pairselect_reset_widg) then begin
    channelpairs_ind = (*datablock.channelpairs_ind)[*]
    channelpairs_ind(*) = 0
    widget_control, nti_wavelet_gui_pairselect_widg, set_value=channelpairs_ind
  endif

;ALL button
  if (event.ID eq nti_wavelet_gui_pairselect_all_widg) then begin
    channelpairs_ind = (*datablock.channelpairs_ind)[*]
    channelpairs_ind(*) = 1
    widget_control, nti_wavelet_gui_pairselect_widg, set_value=channelpairs_ind
  endif

;OK button
  if (event.ID eq nti_wavelet_gui_pairselect_ok_widg) then begin
    widget_control, nti_wavelet_gui_pairselect_widg, get_value=*datablock.channelpairs_ind
    ;Calculate number of selected channel pairs, and write to input data widget
      wh = where(*datablock.channelpairs_ind, count)
      datablock.channelpairs_select_num = count
      widget_control, nti_wavelet_gui_setup_pairselect_selectednum_widg, set_value="Num. of Sel. Ch. Pairs: "+string(datablock.channelpairs_select_num)
    widget_control,/destroy,nti_wavelet_gui_pairselect_base_widg
    if (datablock.channelpairs_select_num eq 0) then begin
      nti_wavelet_gui_addmessage, addtext='No Channel pairs selected!'
    endif else begin
    nti_wavelet_gui_addmessage, addtext='Channel pairs selected!'
    endelse

      ;Handle sensitivity
	if keyword_set (datablock.channelpairs_select_num) then begin
	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 0
	endelse

      ;INITIALIZE USED CHANNELS:
      if keyword_set (datablock.channelpairs_select_num) then begin
	channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind))
	channelpairs_used=reform((*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)), n_elements(channelpairs_used))
	channels_ind = intarr(n_elements(*datablock.channels))
	  for i=0L,n_elements(channelpairs_used)-1 do begin
	    ind = where(*datablock.channels eq channelpairs_used[i])
	    channels_ind[ind] = 1
	  endfor
	*datablock.channels_ind = channels_ind


	;CHECK CHANNEL POSITIONS: (if all positions equals, modenumber calculations will be forbidden)
	  used_theta = (*datablock.theta)(where(*datablock.channels_ind))
	  res = where((used_theta eq used_theta(0)), theta_num)
	  if (theta_num eq n_elements(used_theta)) then begin
	    guiblock.theta_equal = 1
	  endif else begin
	    guiblock.theta_equal = 0
	  endelse
	  used_phi = (*datablock.phi)(where(*datablock.channels_ind))
	  res = where((used_phi eq used_phi(0)), phi_num)
	  if (phi_num eq n_elements(used_phi)) then begin
	    guiblock.phi_equal = 1
	  endif else begin
	    guiblock.phi_equal = 0
	  endelse
	  
  ;HANDLE cross-phase-correction-indicator:
      nti_wavelet_gui_sens, /cross_phase_correction

      endif

      ;CALCULATE USED MEMORY:
      nti_wavelet_gui_calcmemory

      ;Handle indicators and calculated data:
      if nti_wavelet_defined(*datablock.transforms, /nullarray) then begin
	nti_wavelet_gui_addmessage, addtext = "Processed data deleted!"
      endif
	;Reset calculated values:
	  *datablock.transf_timeax = 0
	  *datablock.transf_freqax = 0
	  *datablock.transf_scaleax = 0
	  *datablock.transforms = 0
	  *datablock.smoothed_apsds = 0
	  *datablock.crosstransforms = 0
	  *datablock.smoothed_crosstransforms = 0
	  *datablock.coherences = 0
	  *datablock.modenumbers = 0
	  *datablock.qs = 0
	;Set indicators color and version info:
	  ;TRAMSFROMS
	    widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	    widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 0
	    widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
	    datablock.transf_version = '-'
	 ;CROSS-TRAMSFROMS
	    widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	    widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0
	    widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	    datablock.crosstr_version = '-'
	  ;COHERENCES
	    widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	    widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	    widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	    datablock.coh_version = '-'
	  ;MODENUMBERS
	    widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	    widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	    widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	    datablock.mode_version = '-'
	    
    ;HANDLE cross-phase-correction button:
        widget_control, nti_wavelet_gui_process_crosstr_correction_widg, set_value = 0
    ;HANDLE sensitivity:
        nti_wavelet_gui_sens, /processing

      widget_control, nti_wavelet_gui_widg, sensitive = 1

  endif

;CANCEL button
  if ((event.ID eq nti_wavelet_gui_pairselect_cancel_widg) or $
	  (TAG_NAMES(event, /STRUCTURE_NAME) EQ 'WIDGET_KILL_REQUEST'))then begin
    widget_control,/destroy,nti_wavelet_gui_pairselect_base_widg
    nti_wavelet_gui_addmessage, addtext='No changes in channel pair selection!'

      widget_control, nti_wavelet_gui_widg, sensitive = 1

      ;Handle sensitivity
	if keyword_set (datablock.channelpairs_select_num) then begin
	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 0
	endelse

  endif

end