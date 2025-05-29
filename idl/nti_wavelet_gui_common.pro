;+
; NAME:
;	NTI_WAVELET_COMMON
;
; PURPOSE:
;	This is the common block of NTI Wavelet Tools Graphical User Interface routines.
;
;-


common nti_wavelet_common, $

;STRUCTURES:
;-----------
  inputblock, datablock, guiblock, cfgblock, $

;WIDGET IDs:
;-----------

;Main widget:
  nti_wavelet_gui_widg, $
;Menubar:
  nti_wavelet_gui_menu_widg, $
;Input Data block:
  nti_wavelet_gui_setup_widg, nti_wavelet_gui_setup_label_widg, nti_wavelet_gui_setup_dataman_widg, $
  nti_wavelet_gui_setup_dataman_load_widg, nti_wavelet_gui_setup_dataman_save_widg, $
  nti_wavelet_gui_setup_dataman_help_widg, nti_wavelet_gui_setup_history_base_widg, $
  nti_wavelet_gui_setup_history_data_widg, nti_wavelet_gui_setup_history_coord_widg, $
;Statusblock:
  nti_wavelet_gui_statustext_widg, $
;Startblock:
  nti_wavelet_gui_startblock_widg, nti_wavelet_gui_datainfo_block_widg, nti_wavelet_gui_expname_widg, $
  nti_wavelet_gui_shotnumber_widg, nti_wavelet_gui_timerange_widg, nti_wavelet_gui_sfreq_widg, $
  nti_wavelet_gui_numchannels_widg, nti_wavelet_gui_numdatapoints_widg, $
;Processing block:
  ;Others:
  nti_wavelet_gui_process_widg, nti_wavelet_gui_process_label_widg, $
  nti_wavelet_gui_process_loadbutton_pairselect_base_widg, nti_wavelet_gui_process_loadbutton_base_widg, $
  nti_wavelet_gui_process_loadbutton_widg, nti_wavelet_gui_process_pairselect_base_widg, $
  nti_wavelet_gui_setup_pairselect_button_widg, nti_wavelet_gui_setup_pairselect_selectednum_widg, $
  nti_wavelet_gui_setup_pairselect_help_widg, nti_wavelet_gui_process_versioninfo_base_widg, $
  nti_wavelet_gui_process_versioninfo_button_widg, $

  ;Transforms
  nti_wavelet_gui_process_transfmain_widg, nti_wavelet_gui_process_transf_widg, $
  nti_wavelet_gui_process_transf_inidic_widg, nti_wavelet_gui_process_transf_select_widg, $
  nti_wavelet_gui_process_transfparam_widg, nti_wavelet_gui_process_exact_time_widg, $
    ;CWT
  nti_wavelet_gui_process_transf_cwt_param_widg, $
  nti_wavelet_gui_process_transf_cwt_widg, nti_wavelet_gui_process_transf_cwt_base_widg, $
  nti_wavelet_gui_process_transf_cwt_family_label_widg, nti_wavelet_gui_process_transf_cwt_family_widg, $
  nti_wavelet_gui_process_transf_cwt_order_widg, nti_wavelet_gui_process_transf_cwt_dscale_widg, $
  nti_wavelet_gui_process_transf_cwt_help_widg, $
    ;STFT
  nti_wavelet_gui_process_transf_stft_param_widg, nti_wavelet_gui_process_transf_stft_widg, $
  nti_wavelet_gui_process_transf_stft_base_widg, nti_wavelet_gui_process_transf_stft_window_widg, $
  nti_wavelet_gui_process_transf_stft_length_widg, nti_wavelet_gui_process_transf_stft_freq_widg, $
  nti_wavelet_gui_process_transf_stft_step_widg, nti_wavelet_gui_process_transf_stft_help_widg, $
  nti_wavelet_gui_process_quick_base_widg, nti_wavelet_gui_process_quick_buttons_widg, nti_wavelet_gui_process_quick_help_widg, $
    ;Frequency Range
  nti_wavelet_gui_process_freqrange_widg, nti_wavelet_gui_process_freqrange_label_widg, $
  nti_wavelet_gui_process_freqrange_min_widg, nti_wavelet_gui_process_freqrange_minlabel_widg, $
  nti_wavelet_gui_process_freqrange_max_widg, nti_wavelet_gui_process_freqrange_maxlabel_widg, $
  nti_wavelet_gui_process_freqrange_help_widg, nti_wavelet_gui_process_numdatapoints_widg, $

  ;Cross-transforms
  nti_wavelet_gui_process_crosstr_base_widg, nti_wavelet_gui_process_crosstr_inidic_widg, $
  nti_wavelet_gui_process_crosstr_widg, nti_wavelet_gui_process_crosstr_correction_widg, $
  nti_wavelet_gui_process_crosstr_correction_help, $

  ;Coherences
  nti_wavelet_gui_process_coh_base_widg, nti_wavelet_gui_process_coh_inidic_widg, $
  nti_wavelet_gui_process_coh_widg, nti_wavelet_gui_process_coh_avg_widg, $
  nti_wavelet_gui_process_coh_help_widg, nti_wavelet_gui_process_coh_transfer_base, $
  nti_wavelet_gui_process_coh_transfer_widg, nti_wavelet_gui_process_coh_transfer_help_widg, $

  ;Modenumbers
  nti_wavelet_gui_process_mode_base_widg, nti_wavelet_gui_process_mode_widg, $
  nti_wavelet_gui_process_mode_inidic_widg, nti_wavelet_gui_process_mode_select_widg, $
  nti_wavelet_gui_process_mode_type_widg, nti_wavelet_gui_process_mode_filter_label_widg, $
  nti_wavelet_gui_process_mode_filter_widg, nti_wavelet_gui_process_mode_optimized_widg, $
  nti_wavelet_gui_process_mode_help_widg, $
  nti_wavelet_gui_process_mode_filterparam_widg, nti_wavelet_gui_process_mode_filterparam_label_widg, $
  nti_wavelet_gui_process_mode_filterparam_steps_widg, nti_wavelet_gui_process_mode_filterparam_range_label_widg, $
  nti_wavelet_gui_process_mode_filterparam_range_min_widg, nti_wavelet_gui_process_mode_filterparam_range_max_widg, $
  nti_wavelet_gui_process_mode_filterparam_help_widg, $

  ;Processing action buttons:
  nti_wavelet_gui_process_buttons_widg, nti_wavelet_gui_process_buttons_memory_widg, $
  nti_wavelet_gui_process_buttons_memory_label_widg, nti_wavelet_gui_process_buttons_start_widg, $
  nti_wavelet_gui_process_buttons_save_widg, $

;Visualization:
  nti_wavelet_gui_visual_widg, nti_wavelet_gui_visual_label_widg, $

  ;General settings:
  nti_wavelet_gui_visual_genset_widg, nti_wavelet_gui_visual_genset_label_widg, $
  nti_wavelet_gui_visual_genset_base_widg, nti_wavelet_gui_visual_genset_button_widg, $
  nti_wavelet_gui_visual_genset_linfreqax_widg, nti_wavelet_gui_visual_genset_poster_widg, $
  nti_wavelet_gui_visual_genset_freqrange_widg, nti_wavelet_gui_visual_genset_freqrange_label_widg, $
  nti_wavelet_gui_visual_genset_freqrange_min_widg, nti_wavelet_gui_visual_genset_freqrange_minlabel_widg, $
  nti_wavelet_gui_visual_genset_freqrange_max_widg, nti_wavelet_gui_visual_genset_freqrange_maxlabel_widg, $
  nti_wavelet_gui_visual_genset_help_widg, $

  ;Transforms
  nti_wavelet_gui_visual_transfmain_widg, nti_wavelet_gui_visual_transf_select_widg, $
  nti_wavelet_gui_visual_transf_param_widg, nti_wavelet_gui_visual_transf_param_smooth_widg, $
  nti_wavelet_gui_visual_transf_param_smooth_param_widg, nti_wavelet_gui_visual_transf_param_cscale_widg, $
  nti_wavelet_gui_visual_transf_param_help_widg, $

  ;Cross-transforms
  nti_wavelet_gui_visual_crosstr_base_widg, nti_wavelet_gui_visual_crosstr_select_widg, $
  nti_wavelet_gui_visual_crosstr_param_widg, nti_wavelet_gui_visual_crosstr_param_smooth_widg, $
  nti_wavelet_gui_visual_crosstr_param_smooth_param_widg, nti_wavelet_gui_visual_crosstr_param_smooth_cscale_widg, $
  nti_wavelet_gui_visual_crosstr_param_help_widg, $

  ;Coherences
  nti_wavelet_gui_visual_coh_base_widg, nti_wavelet_gui_visual_coh_select_widg, $
  nti_wavelet_gui_visual_coh_param_widg, nti_wavelet_gui_visual_coh_param_help_widg, $

  ;Transfer functions
  nti_wavelet_gui_visual_transfer_base_widg, nti_wavelet_gui_visual_transfer_select_widg, $
  nti_wavelet_gui_visual_transfer_param_widg, nti_wavelet_gui_visual_transfer_param_coh_widg, $
  nti_wavelet_gui_visual_transfer_param_coh_label_widg, nti_wavelet_gui_visual_transfer_param_pow_widg, $
  nti_wavelet_gui_visual_transfer_param_pow_label_widg, nti_wavelet_gui_visual_transfer_param_cscale_widg, $
  nti_wavelet_gui_visual_transfer_param_help_widg, $

  ;Modenumbers
  nti_wavelet_gui_visual_mode_base_widg, nti_wavelet_gui_visual_mode_select_widg, $
  nti_wavelet_gui_visual_mode_param_widg, nti_wavelet_gui_visual_mode_param_coh_widg, $
  nti_wavelet_gui_visual_mode_param_coh_label_widg, nti_wavelet_gui_visual_mode_param_pow_widg, $
  nti_wavelet_gui_visual_mode_param_pow_label_widg, nti_wavelet_gui_visual_mode_param_q_widg, $
  nti_wavelet_gui_visual_mode_param_q_label_widg, nti_wavelet_gui_visual_mode_param_help_widg, $

  ;Visualization action buttons:
  nti_wavelet_gui_visual_buttons_widg, nti_wavelet_gui_visual_buttons_start_widg, $
  nti_wavelet_gui_visual_buttons_save_widg, nti_wavelet_gui_visual_buttons_save_path_widg, $


;PAIRSELECT WIDGET IDs:
;----------------------

  nti_wavelet_gui_pairselect_base_widg, nti_wavelet_gui_pairselect_buttons_widg, nti_wavelet_gui_pairselect_reset_widg, $
  nti_wavelet_gui_pairselect_all_widg, nti_wavelet_gui_pairselect_ok_widg, nti_wavelet_gui_pairselect_cancel_widg, $
  nti_wavelet_gui_pairselect_widg