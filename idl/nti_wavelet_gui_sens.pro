;+
; NAME:
;	NTI_WAVELET_GUI_SENS
;
; PURPOSE:
;	This procedure handles the sensitivity of NTI Wavelet Tools
;	Graphical User Interface's main widget.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_SENS, (/processing, /visualization)
;
;		This procedure works only if at least one keyword is set.
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; INPUTS:
;	/processing:	Sets sensitivity on Processing block.
;	/visualization:	Sets sensitivity on Visualization block.
;	/datapoints:	Calculate and plot the number of data points after changing the frequency range panel.
;	/set_minimum_frequency: Calculate and set in the GUI the actual value of minimum frequency of wavelet transforms
;	/calc_minimum_frequency: Only calculate the actual value of minimum frequency of wavelet transforms
;				and return it in minimum_frequency variable
; /cross_phase_correction: Check the possibility of cross-phase correction and handle sensitivity if required
;
; OUTPUTS:
;	/minimum_frequency: the actual value of minimum frequency of wavelet transforms
;			calculated only if /set_minimum_frequency or /calc_minimum_frequency is used
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
; EXAMPLE:
;	NTI_WAVELET_GUI_SENS, /processing, /visualization
;
;-


pro nti_wavelet_gui_sens, processing=processing, visualization=visualization, $
  datapoints=datapoints, set_minimum_frequency=set_minimum_frequency, $
  calc_minimum_frequency=calc_minimum_frequency, minimum_frequency=minimum_frequency, $
  cross_phase_correction=cross_phase_correction
@nti_wavelet_gui_common.pro


  ;HANDLE SENSITIVITY OF PROCESSING BLOCK
  ;**************************************

if nti_wavelet_defined(processing, /nullarray) then begin

    ;TRANSFORMS:
      widget_control, nti_wavelet_gui_process_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 0
      endelse

      ;TRANSFORMS CWT SELECT
	widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = cwt_select
	  if cwt_select then begin
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 0
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0
	  endif else begin
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 1
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_freqrange_min_widg, sensitive = 0
	  endelse

      ;TRANSFORMS STFT SELECT
	widget_control, nti_wavelet_gui_process_transf_stft_widg, get_value = stft_select
	  if stft_select then begin
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 0
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_process_freqrange_min_widg, sensitive = 0
	  endif else begin
	    widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0
	    widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 1
	    widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 1
	  endelse

    ;CROSS-TRANSFORMS:
      widget_control, nti_wavelet_gui_process_crosstr_widg, get_value = crosstr_select_index
      if keyword_set(crosstr_select_index) then begin
  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 1
  if guiblock.cross_phase_correction_indic then begin
    widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 1
  endif else begin
    widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
  endelse
      endif else begin
  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 0
  widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
      endelse

    ;COHERENCES:
      widget_control, nti_wavelet_gui_process_coh_widg, get_value = coh_select_index
      if keyword_set(coh_select_index) then begin
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 0
      endelse

    ;MODENUMBERS:
      widget_control, nti_wavelet_gui_process_mode_select_widg, get_value = mode_select_index
      if keyword_set(mode_select_index) then begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 1
	
      endif else begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
      endelse

endif


  ;HANDLE SENSITIVITY OF VISUALIZATION BLOCK
  ;*****************************************

if nti_wavelet_defined(visualization, /nullarray) then begin

    ;TRANSFORMS:
      widget_control, nti_wavelet_gui_visual_transf_select_widg, get_value = plot_transf_selection
	if keyword_set(plot_transf_selection) then begin
	  widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
	endelse

    ;CROSS-TRANSFORMS
      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, get_value = plot_crosstr_selection
	if keyword_set(plot_crosstr_selection) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
	endelse

    ;COHERENCES:
      widget_control, nti_wavelet_gui_visual_coh_select_widg, get_value = plot_coh_selection
	if keyword_set(plot_coh_selection) then begin
	  widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	endelse

    ;TRANSFER FUNCTIONS:
      widget_control, nti_wavelet_gui_visual_transfer_select_widg, get_value = plot_transfer_selection
	if keyword_set(plot_mode_selection) then begin
	  widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 0
	endelse

    ;MODENUMBERS:
      widget_control, nti_wavelet_gui_visual_mode_select_widg, get_value = plot_mode_selection
	if keyword_set(plot_mode_selection) then begin
	  widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endelse

endif

if nti_wavelet_defined(datapoints, /nullarray) then begin
  ;Calculate number of data points after resampling:
    widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = freqrange_max
      freqrange_max = double(freqrange_max)
    datablock.proc_transf_freq_resdatapoints = round(double(n_elements((*datablock.data)(*,0)))*(2*freqrange_max/datablock.samplefreq))
      string_resdatapoints = (strsplit(datablock.proc_transf_freq_resdatapoints,'.',/extract))(0)
    widget_control, nti_wavelet_gui_process_numdatapoints_widg, set_value="Number of data points after downsampling: "+string(string_resdatapoints)
endif

if (nti_wavelet_defined(set_minimum_frequency, /nullarray) or $
  nti_wavelet_defined(calc_minimum_frequency, /nullarray)) then begin
  ;Calculate the actual value of minimum frequency of wavelet transforms
  ;---------------------------
    ;Check the type of transform (STFT or CWT)
    widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = is_cwt
    if is_cwt then begin	;only in the case of CWT
      ;Read order of CWT:
      widget_control, nti_wavelet_gui_process_transf_cwt_order_widg, get_value = cwt_order
      cwt_order = double(cwt_order)
      ;Read number of averages:
      widget_control, nti_wavelet_gui_process_coh_avg_widg, get_value = coh_avr
      coh_avr = double(coh_avr)
      ;Calculate minimum frequency
	;Read current minimum frequency:
	widget_control, nti_wavelet_gui_process_freqrange_min_widg, get_value = freq_min
	freq_min = double(freq_min)
	timeax = *datablock.time
	;Calculate minimum frequency
	freq_min=max([1,coh_avr])*cwt_order*2/(timeax(n_elements(timeax)-1)-timeax(0)) ; in Hz
	freq_min=freq_min/1000. ; Conver to kHz and return
	minimum_frequency = freq_min
	;Write result to GUI
	if nti_wavelet_defined(set_minimum_frequency, /nullarray) then begin
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = freq_min
	endif
    endif
endif

if nti_wavelet_defined(cross_phase_correction, /nullarray) then begin

  ; Check the availability of cross-phase correction
  nti_wavelet_crossphase_correction, $
    expname = datablock.expname, startpath = guiblock.startpath, $
    channel_pairs = *datablock.channelpairs, ind_channel_pairs = *datablock.channelpairs_ind, $
    /check_correction_indicator, correction_indicator = correction_indicator
  
  ; Set cross_phase_correction_indic parameter:
  if correction_indicator eq 0 then begin
    guiblock.cross_phase_correction_indic = 0
  endif else begin
    guiblock.cross_phase_correction_indic = 1
  endelse

endif

end