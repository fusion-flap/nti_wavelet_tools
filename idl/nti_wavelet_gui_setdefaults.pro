;+
; NAME:
;	NTI_WAVELET_GUI_SETDEFAULTS
;
; PURPOSE:
;	This program sets defaults of NTI Wavelet Tools
;	Graphical User Interface at startup.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_SETDEFAULTS, (/processing, /visualization, $
;		/proc_transforms, /proc_crosstransforms,  /proc_coherences, $
;		/proc_modenumbers)
;
;		This procedure works only if at least one keyword is set.
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; INPUTS:
;	/processing:	Sets all off the defaults of Processing block.
;	/visualization:	Sets all off the defaults of Visualization block.
;	/proc_transforms:	Sets only the defaults of Transforms block.
;	/proc_crosstransforms:	Sets only the defaults of Cross-transforms block.
;	/proc_coherences:	Sets only the defaults of Coherences block.
;	/proc_modenumbers:	Sets only the defaults of Modenumbers block.
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
; EXAMPLE:
;	NTI_WAVELET_GUI_SETDEFAULTS, /processing, /visualization
;
;-


pro nti_wavelet_gui_setdefaults, processing = processing, visualization = visualization, proc_transforms = proc_transforms, $
	proc_crosstransforms = proc_crosstransforms, proc_coherences = proc_coherences, proc_modenumbers = proc_modenumbers

@nti_wavelet_gui_common.pro

widget_control, nti_wavelet_gui_widg, sensitive = 0

if (nti_wavelet_defined(processing, /nullarray)) then begin
  proc_transforms = 1
  proc_crosstransforms = 1
  proc_coherences = 1
  proc_modenumbers = 1
endif

;Processing:
;===========

  if (nti_wavelet_defined(proc_transforms, /nullarray)) then begin
  ;TRANSFORM CWT SELECTION:
    widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 0
    ;TRANSFORM CWT ORDER:
      widget_control, nti_wavelet_gui_process_transf_cwt_order_widg, set_value = 6
    ;TRANSFORM CWT DSCALE:
      widget_control, nti_wavelet_gui_process_transf_cwt_dscale_widg, set_value = 0.1D
  ;TRANSFORM STFT SELECTION:
    widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 1
    ;TRANSFORM STFT LENGTH:
      widget_control, nti_wavelet_gui_process_transf_stft_length_widg, set_value = 100
    ;TRANSFORM STFT FRES:
      widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = 500
    ;TRANSFORM STFT STEP:
      widget_control, nti_wavelet_gui_process_transf_stft_step_widg, set_value = 1
    ;FREQUENCY RANGE:
      widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = 0D
      widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = (0.5D*datablock.samplefreq)
  endif

  if (nti_wavelet_defined(proc_coherences, /nullarray)) then begin
  ;COHERENCE AVG:
      widget_control, nti_wavelet_gui_process_coh_avg_widg, set_value = 0
  endif

  if (nti_wavelet_defined(proc_modenumbers, /nullarray)) then begin
  ;MODENUMBER STEPS:
      widget_control, nti_wavelet_gui_process_mode_filterparam_steps_widg, set_value = 1
  ;MODENUMBER RANGE:
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_min_widg, set_value = -6
      widget_control, nti_wavelet_gui_process_mode_filterparam_range_max_widg, set_value = 6
  endif


;Visualization:
;==============

if (nti_wavelet_defined(visualization, /nullarray)) then begin
  ;GENERAL SETTINGS:
    widget_control, nti_wavelet_gui_visual_genset_poster_widg, set_value = 1
    ;FREQUENCY RANGE:
      widget_control, nti_wavelet_gui_visual_genset_freqrange_min_widg, set_value = 0D
      widget_control, nti_wavelet_gui_visual_genset_freqrange_max_widg, set_value = (0.5D*datablock.samplefreq)
  ;TRANSFORMS:
    widget_control, nti_wavelet_gui_visual_transf_param_smooth_param_widg, set_value = [1,0]
    widget_control, nti_wavelet_gui_visual_transf_param_cscale_widg, set_value = 0.2D
  ;CROSS-TRANSFORMS:
    widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_param_widg, set_value = [1,0]
    widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg, set_value = 0.2D
  ;COHERENCES:
    widget_control, nti_wavelet_gui_visual_coh_param_widg, set_value = [0,0,1]
  ;TRANSFER FUNCTIONS:
    widget_control, nti_wavelet_gui_visual_transfer_param_coh_widg, set_value = 0.
    widget_control, nti_wavelet_gui_visual_transfer_param_pow_widg, set_value = 0.
    widget_control, nti_wavelet_gui_visual_transfer_param_cscale_widg, set_value = 0.2D
  ;MODENUMBERS:
    widget_control, nti_wavelet_gui_visual_mode_param_coh_widg, set_value = 0.
    widget_control, nti_wavelet_gui_visual_mode_param_pow_widg, set_value = 0.
    widget_control, nti_wavelet_gui_visual_mode_param_q_widg, set_value = 100
  ;SAVEPATH:
    cd, current = current_path
    datablock.plot_savepath = current_path + "/save_data"
    widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, set_value = datablock.plot_savepath
endif

widget_control, nti_wavelet_gui_widg, sensitive = 1

end