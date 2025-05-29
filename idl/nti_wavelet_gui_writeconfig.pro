;+
; NAME:
;	NTI_WAVELET_GUI_WRITECONFIG
;
; PURPOSE:
;	This procedure writes the saved setups of NTI Wavelet Tools
;	Graphical User Interface's to the main widget.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_WRITECONFIG, (/processing, /visualization, $
;		/proc_transforms, /proc_crosstransforms,  /proc_coherences, $
;		/proc_modenumbers)
;
;		This procedure works only if at least one keyword is set.
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; INPUTS:
;	/processing:	Writes all off the setups of Processing block.
;	/visualization:	Writes all off the setups of Visualization block.
;	/proc_transforms:	Writes only the setups of Transforms block.
;	/proc_crosstransforms:	Writes only the setups of Cross-transforms block.
;	/proc_coherences:	Writes only the setups of Coherences block.
;	/proc_modenumbers:	Writes only the setups of Modenumbers block.
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
; EXAMPLE:
;	NTI_WAVELET_GUI_WRITECONFIG, /processing, /visualization
;
;-


pro nti_wavelet_gui_writeconfig, processing = processing, visualization = visualization, proc_transforms = proc_transforms, $
	proc_crosstransforms = proc_crosstransforms, proc_coherences = proc_coherences, proc_modenumbers = proc_modenumbers

@nti_wavelet_gui_common.pro

if keyword_set(processing) then begin
  proc_transforms = 1
  proc_crosstransforms = 1
  proc_coherences = 1
  proc_modenumbers = 1
endif


  ;WRITE PROCESSING BLOCK CONFIGURATION:
  ;**************************************

if keyword_set(proc_transforms) then begin
  ;TRANSFORMS selection:
    widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = datablock.proc_transf_selection
    ;TRANSFORM CWT SELECTION:
      widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = datablock.proc_transf_cwt_selection
    ;TRANSFORM FAMILY:
      widget_control, nti_wavelet_gui_process_transf_cwt_family_widg,$
	set_droplist_select = where (datablock.proc_transf_cwt_family eq guiblock.cwt_family)
      ;TRANSFORM CWT ORDER:
	widget_control, nti_wavelet_gui_process_transf_cwt_order_widg, set_value = datablock.proc_transf_cwt_order
      ;TRANSFORM CWT DSCALE:
	widget_control, nti_wavelet_gui_process_transf_cwt_dscale_widg, set_value = datablock.proc_transf_cwt_dscale
    ;TRANSFORM STFT SELECTION:
      widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = datablock.proc_transf_stft_selection
    ;TRANSFORM STFT WINDOW
      widget_control, nti_wavelet_gui_process_transf_stft_window_widg,$
	set_droplist_select = where (datablock.proc_transf_stft_window eq guiblock.stft_window)
      ;TRANSFORM STFT LENGTH:
	widget_control, nti_wavelet_gui_process_transf_stft_length_widg, set_value = datablock.proc_transf_stft_length
      ;TRANSFORM STFT FREQUENCY:
	widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = datablock.proc_transf_stft_fres
      ;TRANSFORM STFT STEP:
	widget_control, nti_wavelet_gui_process_transf_stft_step_widg, set_value = datablock.proc_transf_stft_step
      ;FREQUENCY RANGE:
	widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = datablock.proc_transf_freq_min
	widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = datablock.proc_transf_freq_max
endif

if keyword_set(proc_crosstransforms) then begin
  ;CROSS-TRANSFORMS selection:
    widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = datablock.proc_crosstr_selection
  ;CROSS-PHASE CORRECTION:
    widget_control, nti_wavelet_gui_process_crosstr_correction_widg, set_value = datablock.proc_crosstr_correction_selection    
endif

if keyword_set(proc_coherences) then begin
  ;COHERENCES selection:
    widget_control, nti_wavelet_gui_process_coh_widg, set_value = datablock.proc_coh_selection
    ;COHERENCE AVG:
      widget_control, nti_wavelet_gui_process_coh_avg_widg, set_value = datablock.proc_coh_avg
    ;TRANSFER FUNCTION:
      widget_control, nti_wavelet_gui_process_coh_transfer_widg, set_value = datablock.proc_transfer_selection
endif

if keyword_set(proc_modenumbers) then begin
  ;MODENUMBERS selection:
    widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = datablock.proc_mode_selection
    ;MODENUMBER TYPE:
      widget_control, nti_wavelet_gui_process_mode_type_widg,$
	set_droplist_select = (where (datablock.proc_mode_type eq guiblock.mode_type))(0)
    ;MODENUMBER FILTER:
      widget_control, nti_wavelet_gui_process_mode_filter_widg,$
	set_droplist_select = where (datablock.proc_mode_filter eq guiblock.filter)
    ;MODENUMBER STEPS:
      widget_control, nti_wavelet_gui_process_mode_filterparam_steps_widg, set_value = datablock.proc_mode_steps
    ;MODENUMBER RANGE:
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_min_widg, set_value = datablock.proc_mode_min
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_max_widg, set_value = datablock.proc_mode_max
endif


if keyword_set(visualization) then begin

  ;WRITE VISUALIZATION BLOCK CONFIGURATION:
  ;****************************************
    ;GENERAL SETTINGS:
      widget_control, nti_wavelet_gui_visual_genset_linfreqax_widg, set_value = datablock.plot_linear_freqax
      widget_control, nti_wavelet_gui_visual_genset_poster_widg, set_value = datablock.plot_poster
      widget_control, nti_wavelet_gui_visual_genset_freqrange_min_widg, set_value = datablock.plot_gen_freq_min
      widget_control, nti_wavelet_gui_visual_genset_freqrange_max_widg, set_value = datablock.plot_gen_freq_max
    ;TRANSFORMS selection:
      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = datablock.plot_transf_selection
      ;SMOOTH:
	widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, set_value = datablock.plot_transf_smooth
      ;TYPE:
	widget_control, nti_wavelet_gui_visual_transf_param_smooth_param_widg,$
	  set_value = [datablock.plot_transf_energy, datablock.plot_transf_phase]
      ;COLOR SCALE OPT:
	widget_control, nti_wavelet_gui_visual_transf_param_cscale_widg, set_value = datablock.plot_transf_cscale
    ;CROSS-TRANSFORMS selection:
      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = datablock.plot_crosstr_selection
      ;SMOOTH:
	widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, set_value = datablock.plot_crosstr_smooth
      ;SMOOTH TYPE:
	widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_param_widg,$
	  set_value = [datablock.plot_crosstr_energy, datablock.plot_crosstr_phase]
      ;COLOR SCALE OPT:
	widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg, set_value = datablock.plot_crosstr_cscale
    ;COHERENCES selection:
      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = datablock.plot_coh_selection
      ;TYPE:
	widget_control, nti_wavelet_gui_visual_coh_param_widg,$
	  set_value = [datablock.plot_coh_all, datablock.plot_coh_avg, datablock.plot_coh_min]
    ;TRANSFER FUNCTIONS selection:
      widget_control, nti_wavelet_gui_visual_transfer_select_widg, set_value = datablock.plot_transfer_selection
      ;COH LIMIT:
	widget_control, nti_wavelet_gui_visual_transfer_param_coh_widg, set_value = datablock.plot_transfer_cohlimit
      ;POWER LIMIT:
	widget_control, nti_wavelet_gui_visual_transfer_param_pow_widg, set_value = datablock.plot_transfer_powlimit
      ;COLOR SCALE OPT:
	widget_control, nti_wavelet_gui_visual_transfer_param_cscale_widg, set_value = datablock.plot_transfer_cscale
    ;MODENUMBERS selection:
      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = datablock.plot_mode_selection
      ;COH LIMIT:
	widget_control, nti_wavelet_gui_visual_mode_param_coh_widg, set_value = datablock.plot_mode_cohlimit
      ;POWER LIMIT:
	widget_control, nti_wavelet_gui_visual_mode_param_pow_widg, set_value = datablock.plot_mode_powlimit
      ;Q LIMIT:
	widget_control, nti_wavelet_gui_visual_mode_param_q_widg, set_value = datablock.plot_mode_qlimit
    ;SAVEPATH:
      widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, set_value = datablock.plot_savepath

endif

end