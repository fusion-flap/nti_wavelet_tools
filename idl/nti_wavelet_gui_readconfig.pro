;+
; NAME:
;	NTI_WAVELET_GUI_READCONFIG
;
; PURPOSE:
;	This procedure reads all off the setups of NTI Wavelet Tools
;	Graphical User Interface's main widget.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_READCONFIG, (/processing, /visualization)
;
;		This procedure works only if at least one keyword is set.
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; INPUTS:
;	/processing:	Reads all off the setups of Processing block.
;	/visualization:	Reads all off the setups of Visualization block.
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
; EXAMPLE:
;	NTI_WAVELET_GUI_READCONFIG, /processing, /visualization
;
;-


pro nti_wavelet_gui_readconfig, processing=processing, visualization=visualization
@nti_wavelet_gui_common.pro

if keyword_set(processing) then begin

  ;READ PROCESSING BLOCK CONFIGURATION:
  ;**************************************

  ;TRANSFORMS selection:
  widget_control, nti_wavelet_gui_process_transf_select_widg, get_value = proc_transf_selection
  datablock.proc_transf_selection = proc_transf_selection
  ;CWT selection:
  widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = proc_transf_cwt_selection
  datablock.proc_transf_cwt_selection = proc_transf_cwt_selection
  ;CWT FAMILY:
  cwt_family_ind = widget_info(nti_wavelet_gui_process_transf_cwt_family_widg, /droplist_select)
  datablock.proc_transf_cwt_family = guiblock.cwt_family[cwt_family_ind]
  ;CWT ORDER:
  widget_control, nti_wavelet_gui_process_transf_cwt_order_widg, get_value = proc_transf_cwt_order
  datablock.proc_transf_cwt_order = proc_transf_cwt_order
  widget_control, nti_wavelet_gui_process_transf_cwt_dscale_widg, get_value = proc_transf_cwt_dscale
  datablock.proc_transf_cwt_dscale = proc_transf_cwt_dscale
  ;STFT selection:
  widget_control, nti_wavelet_gui_process_transf_stft_widg, get_value = proc_transf_stft_selection
  datablock.proc_transf_stft_selection = proc_transf_stft_selection
  ;STFT WINDOW:
  stft_window_ind = widget_info(nti_wavelet_gui_process_transf_stft_window_widg, /droplist_select)
  datablock.proc_transf_stft_window = guiblock.stft_window[stft_window_ind]
  ;STFT LENGTH:
  widget_control, nti_wavelet_gui_process_transf_stft_length_widg, get_value = proc_transf_stft_length
  datablock.proc_transf_stft_length = proc_transf_stft_length
  ;STFT FRES:
  widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, get_value = proc_transf_stft_fres
  datablock.proc_transf_stft_fres = proc_transf_stft_fres
  ;STFT STEP:
  widget_control,  nti_wavelet_gui_process_transf_stft_step_widg, get_value = proc_transf_stft_step
  datablock.proc_transf_stft_step = proc_transf_stft_step
  ;FREQUENCY MIN:
  widget_control, nti_wavelet_gui_process_freqrange_min_widg, get_value = proc_transf_freq_min
  datablock.proc_transf_freq_min = proc_transf_freq_min
  ;FREQUENCY MAX:
  widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = proc_transf_freq_max
  datablock.proc_transf_freq_max = proc_transf_freq_max
  ;CROSS-TRANSFORMS selection:
  widget_control, nti_wavelet_gui_process_crosstr_widg, get_value = proc_crosstr_selection
  datablock.proc_crosstr_selection = proc_crosstr_selection
  ;CROSS-PHASE CORRECTION:
  widget_control, nti_wavelet_gui_process_crosstr_correction_widg, get_value = proc_crosstr_correction_selection
  datablock.proc_crosstr_correction_selection = proc_crosstr_correction_selection
  ;COHERENCES selection:
  widget_control, nti_wavelet_gui_process_coh_widg,  get_value = proc_coh_selection
  datablock.proc_coh_selection = proc_coh_selection
  ;AVERAGE:
  widget_control, nti_wavelet_gui_process_coh_avg_widg, get_value = proc_coh_avg
  datablock.proc_coh_avg = proc_coh_avg
  ;TRANSFER FUNCTION:
  widget_control, nti_wavelet_gui_process_coh_transfer_widg, get_value = proc_transfer_selection
  datablock.proc_transfer_selection = proc_transfer_selection
  ;MODENUMBERS selection:
  widget_control, nti_wavelet_gui_process_mode_select_widg, get_value = proc_mode_selection
  datablock.proc_mode_selection = proc_mode_selection
  ;TYPE:
  proc_mode_type = widget_info(nti_wavelet_gui_process_mode_type_widg, /droplist_select)
  datablock.proc_mode_type = guiblock.mode_type[proc_mode_type]
  ;FILTER:
  proc_mode_filter = widget_info(nti_wavelet_gui_process_mode_filter_widg, /droplist_select)
  datablock.proc_mode_filter = guiblock.filter[proc_mode_filter]
  ;OPTIMIZED selection:
  widget_control, nti_wavelet_gui_process_mode_optimized_widg, get_value = proc_mode_optimized
  datablock.proc_mode_optimized = proc_mode_optimized
  ;STEPS:
  widget_control, nti_wavelet_gui_process_mode_filterparam_steps_widg, get_value = proc_mode_steps
  datablock.proc_mode_steps = proc_mode_steps
  ;RANGE:
  widget_control, nti_wavelet_gui_process_mode_filterparam_range_min_widg, get_value = proc_mode_min
  datablock.proc_mode_min = proc_mode_min
  widget_control, nti_wavelet_gui_process_mode_filterparam_range_max_widg, get_value = proc_mode_max
  datablock.proc_mode_max = proc_mode_max

endif

if keyword_set(visualization) then begin

  ;READ VISUALIZATION BLOCK CONFIGURATION:
  ;**************************************
  ;GENERAL SETTINGS:
  widget_control, nti_wavelet_gui_visual_genset_linfreqax_widg, get_value = plot_linear_freqax
  datablock.plot_linear_freqax = plot_linear_freqax
  widget_control, nti_wavelet_gui_visual_genset_poster_widg, get_value = plot_poster
  datablock.plot_poster = plot_poster
  widget_control, nti_wavelet_gui_visual_genset_freqrange_min_widg, get_value = plot_gen_freq_min
  datablock.plot_gen_freq_min = plot_gen_freq_min
  widget_control, nti_wavelet_gui_visual_genset_freqrange_max_widg, get_value = plot_gen_freq_max
  datablock.plot_gen_freq_max = plot_gen_freq_max
  ;TRANSFORMS selection:
  widget_control, nti_wavelet_gui_visual_transf_select_widg, get_value = plot_transf_selection
  datablock.plot_transf_selection = plot_transf_selection
  ;SMOOTH:
  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, get_value = plot_transf_smooth
  datablock.plot_transf_smooth = plot_transf_smooth
  ;TYPE:
  widget_control, nti_wavelet_gui_visual_transf_param_smooth_param_widg, get_value = plot_transf_type
  datablock.plot_transf_energy = plot_transf_type[0]
  datablock.plot_transf_phase = plot_transf_type[1]
  ;COLOR SCALE OPT:
  widget_control, nti_wavelet_gui_visual_transf_param_cscale_widg, get_value = plot_transf_cscale
  datablock.plot_transf_cscale = plot_transf_cscale
  ;CROSS-TRANSFORMS selection:
  widget_control, nti_wavelet_gui_visual_crosstr_select_widg, get_value = plot_crosstr_selection
  datablock.plot_crosstr_selection = plot_crosstr_selection
  ;SMOOTH:
  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, get_value = plot_crosstr_smooth
  datablock.plot_crosstr_smooth = plot_crosstr_smooth
  ;SMOOTH TYPE:
  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_param_widg, get_value = plot_crosstr_type
  datablock.plot_crosstr_energy = plot_crosstr_type[0]
  datablock.plot_crosstr_phase = plot_crosstr_type[1]
  ;COLOR SCALE OPT:
  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg, get_value = plot_crosstr_cscale
  datablock.plot_crosstr_cscale = plot_crosstr_cscale
  ;COHERENCES selection:
  widget_control, nti_wavelet_gui_visual_coh_select_widg, get_value = plot_coh_selection
  datablock.plot_coh_selection = plot_coh_selection
  ;TYPE:
  widget_control, nti_wavelet_gui_visual_coh_param_widg, get_value = plot_coh_type
  datablock.plot_coh_all = plot_coh_type[0]
  datablock.plot_coh_avg = plot_coh_type[1]
  datablock.plot_coh_min = plot_coh_type[2]
  ;TRANSFER FUNCTIONS selection:
  widget_control, nti_wavelet_gui_visual_transfer_select_widg, get_value = plot_transfer_selection
  datablock.plot_transfer_selection = plot_transfer_selection
  ;COH LIMIT:
  widget_control, nti_wavelet_gui_visual_transfer_param_coh_widg, get_value = plot_transfer_cohlimit
  datablock.plot_transfer_cohlimit = plot_transfer_cohlimit
  ;POWER LIMIT:
  widget_control, nti_wavelet_gui_visual_transfer_param_pow_widg, get_value = plot_transfer_powlimit
  datablock.plot_transfer_powlimit = plot_transfer_powlimit
  ;COLOR SCALE OPT:
  widget_control, nti_wavelet_gui_visual_transfer_param_cscale_widg, get_value = plot_transfer_cscale
  datablock.plot_transfer_cscale = plot_transfer_cscale
  ;MODENUMBERS selection:
  widget_control, nti_wavelet_gui_visual_mode_select_widg, get_value = plot_mode_selection
  datablock.plot_mode_selection = plot_mode_selection
  ;COH LIMIT:
  widget_control, nti_wavelet_gui_visual_mode_param_coh_widg, get_value = plot_mode_cohlimit
  datablock.plot_mode_cohlimit = plot_mode_cohlimit
  ;POWER LIMIT:
  widget_control, nti_wavelet_gui_visual_mode_param_pow_widg, get_value = plot_mode_powlimit
  datablock.plot_mode_powlimit = plot_mode_powlimit
  ;Q LIMIT:
  widget_control, nti_wavelet_gui_visual_mode_param_q_widg, get_value = plot_mode_qlimit
  datablock.plot_mode_qlimit = plot_mode_qlimit
  ;SAVEPATH:
  widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, get_value = plot_savepath
  datablock.plot_savepath = plot_savepath
endif

end