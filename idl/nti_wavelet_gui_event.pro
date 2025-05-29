;+
; NAME:
;	NTI_WAVELET_GUI_EVENT
;
; PURPOSE:
;	This procedure is the event handler of NTI Wavelet Tools Graphical User Interface
;	main widget (nti_wavelet_gui_widg).
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


pro nti_wavelet_gui_event,event
@nti_wavelet_gui_common.pro


;PRE-EVENTS
;==========
;==========

;Pre-events are introduced to make a pop-up warning message possible, which indicates that, the entered
;parameter is out of the limits. For example: The maximum frequency range cannot be higher than the
;half of the sample frequency. So it need to be indicated for the user.

;MOTIVATION
;----------
;The motivation of introducing pre-events is the following: Changes in an entry field can generate
;event in three different ways. The first is no event. The second is generating event after a
;carriage return character. The third is generating event after every chareacter entered in the field.
;None of them matches with our conception, because we want event without carriage return character, but
;not after all entered character.

;OPERATION
;---------
;The entry fields are set to generate event after every character entered, but this event won't start
;the checking of the accuracy of the parameter, just set an indicator from 0 to 1. For example:
;
;	if (event.ID eq nti_wavelet_gui_process_freqrange_min_widg) then begin
;		guiblock.pre_events = 1
;		guiblock.pre_event_freq_min = 1
;	endif
;
;This indicator will start checking the accuracy of the parameter only in the case if a different event
;comes. If the parameter is out of the limits, a pop-up message will appear, but as long as the user
;enters characters in the investigated field, nothing happens.

if guiblock.pre_events then begin

;Save event ID
event_ID = event.ID

  ;Pre-event of minimum frequency
  ;------------------------------
  if guiblock.pre_event_freq_min then begin
    if (event.ID ne nti_wavelet_gui_process_freqrange_min_widg) then begin
      ;Event is different from STFT or CWT selection
      ;---------------------------------------------
      if ((event_ID ne nti_wavelet_gui_process_transf_cwt_widg) and (event_ID ne nti_wavelet_gui_process_transf_stft_widg)) then begin

	;In the case of CWT
	widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = is_cwt
	if is_cwt then begin
	  ;Calculate the actual value of minimum frequency of wavelet transforms
	  nti_wavelet_gui_sens, /calc_minimum_frequency, minimum_frequency = possible_minimum_frequency
	  ;Read current minimum frequency:
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, get_value = actual_minimum_frequency
	  if (actual_minimum_frequency lt possible_minimum_frequency) then begin
	    res = dialog_message(['The lowest possible minimum frequency value is determined by the transform parameters.', $
	      strjoin(['Cannot set to a value lower than ', pg_num2str(possible_minimum_frequency), ' kHz!'])], $ 
	      dialog_parent=event.top, title='Minimum frequency')
	    widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = possible_minimum_frequency
	    event.ID = event_ID
	  endif
	  guiblock.pre_events = 0
	  guiblock.pre_event_freq_min = 0
	endif

	;In the case of STFT
	widget_control, nti_wavelet_gui_process_transf_stft_widg, get_value = is_stft
	if is_stft then begin
	  ;Read current minimum frequency:
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, get_value = actual_minimum_frequency
	  if (actual_minimum_frequency gt 0) then begin
	    res = dialog_message(['The minimum frequency for STFT is always 0 kHz.', $
	      strjoin(['Cannot set to a value different from 0 kHz!'])], $ 
	      dialog_parent=event.top, title='Minimum frequency')
	    widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = 0
	    event.ID = event_ID
	  endif
	  guiblock.pre_events = 0
	  guiblock.pre_event_freq_min = 0
	endif

      endif
      ;Event is CWT selection
      ;----------------------
      if (event_ID eq nti_wavelet_gui_process_transf_cwt_widg) then begin
	nti_wavelet_gui_sens, /set_minimum_frequency
	guiblock.pre_events = 0
	guiblock.pre_event_freq_min = 0
      endif
      ;Event is STFT selection
      ;-----------------------
      if (event_ID eq nti_wavelet_gui_process_transf_stft_widg) then begin
	widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = 0
	guiblock.pre_events = 0
	guiblock.pre_event_freq_min = 0
      endif
    endif
  endif

  ;Pre-event of maximum frequency
  ;------------------------------
  if guiblock.pre_event_freq_max then begin
    ;Calculating number of datapoints after downsampling
      nti_wavelet_gui_sens, /datapoints
    if (event.ID ne nti_wavelet_gui_process_freqrange_max_widg) then begin
      ;Calculate Nyquist frequency
      nyquistfreq = 0.5*datablock.samplefreq
      ;Read current maximum frequency:
      widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = actual_maximum_frequency
      if (actual_maximum_frequency gt nyquistfreq) then begin
	res = dialog_message(['The highest possible maximum frequency is determined by the Nyquist frequency.', $
	    strjoin(['Cannot set to a value higher than ', pg_num2str(nyquistfreq), ' kHz!'])], $ 
	    dialog_parent=event.top, title='Maximum frequency')
	widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = nyquistfreq
	event.ID = event_ID
      endif
      guiblock.pre_events = 0
      guiblock.pre_event_freq_min = 0
    endif
  endif

  ;Pre-event of averages
  ;------------------------------
  if guiblock.pre_event_coh_avg then begin
    if (event.ID ne nti_wavelet_gui_process_coh_avg_widg) then begin
      res = dialog_message(['The transforms was calculated by taking the number of averages into account!', $
	'Do you want to recalculate the transforms with the new parameters?'], $ 
	dialog_parent=event.top, /question, title = 'Coherences averaging')
      if strcmp(res, 'Yes') then begin
	event.ID = nti_wavelet_gui_process_transf_select_widg
	widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	nti_wavelet_gui_sens, /set_minimum_frequency
      endif else begin
	event.ID = event_ID
      endelse
      guiblock.pre_events = 0
      guiblock.pre_event_coh_avg = 0
    endif
  endif
endif

if (not guiblock.pre_events) then begin

;HELP
;========
;========

  ;INPUT DATA block:
      if (event.ID eq nti_wavelet_gui_setup_dataman_help_widg) then begin
	res = dialog_message($
	  ['Load data:', $
	  ' - Data can be loaded from IDL (.sav) binary files with specific variable names.',$
	  ' - An example is the test.sav in the program directory.',$
	  ' ', $
	  'Save data:', $
    ' - Data can be saved to IDL (.sav) and Matlab (.mat) binary files.',$
    ' - The desired binary file type (IDL or Matlab) can be selected by giving',$
    '   appropriate extension to the filename (.sav or .mat).',$
    ' ', $
	  'Data manipulations should be traced by adding a string to the data_history or',$
	  'coordinates_history variable.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

      if (event.ID eq nti_wavelet_gui_setup_pairselect_help_widg) then begin
	res = dialog_message($
	  ['Prior to further analysis, signal pairs to be taken into account in mode number determination are to be selected.',$
	  'Transforms will only be calculated for signals being in a selected pair.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

  ;PROCESSING BLOCK:
    ;CWT:
      if (event.ID eq nti_wavelet_gui_process_transf_cwt_help_widg) then begin
	res = dialog_message($
	  ['CWT selects Contimuous Wavelet Transform as the type of continuous linear time-frequency transform to be used.',$
	  '- It is important to use analytical wavelets, so Family should be selected accordingly - Morlet wavelet is a straightforward choice.',$
	  '- Order of the wavelet defines its form: e.g. number of periods within the 2 sigma_t wide envelope is approximatelly order/3.',$
	  '- Dscale defines the fraction of the dyadic scaling for the discretizition of the scale axis.',$
	  'Largest value should be 0.25 for continuous transform. Lower values can also be used for nicer images.']$
	  , dialog_parent=event.top, Title="HELP")
      endif

    ;STFT:
      if (event.ID eq nti_wavelet_gui_process_transf_stft_help_widg) then begin
	res = dialog_message($
	  ['STFT selects Short-Time Fourier Transform as the type of continuous linear time-frequency transform to be used.',$
    '- Window type should be selected to satisfy the time-frequency resolution requirements - Gauss window is a straightforward choice.',$
    '- Length of the window is 2*sigma_t, given in number of samples.',$
    '- F.res is the required discretization of the frequency axis. This should always be at least 4* the length of the window to give a continuous transform.',$
    '- Step determines the discretization of the time axis. It should be at most length of the window /4.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;FREQUENCY RANGE:
      if (event.ID eq nti_wavelet_gui_process_freqrange_help_widg) then begin
	res = dialog_message($
	  ['Frequency range for the calculation can be set here.',$
    '- The minimum for STFT is always 0 kHz.',$
    '- For CWT the possible minimum value is determined by the transfrorm parameters but can be forced to be higher.',$
    '- Maximum value can be the Nyquist frequency at most, but lower values can be given.',$
    'Giving a maximum value lower than the Nyquist frequency will cause a Fourier domain downsampling of the signals.']$
    , dialog_parent=event.top, Title="HELP")
      endif
 
      ;QUICK AND DIRTY HELP:
      if (event.ID eq nti_wavelet_gui_process_quick_help_widg) then begin
        res = dialog_message($
          ['Pressing Quick settings button will change the parameters of STFT.',$
          '- Parameters will be set, to calculate roughly as many points as many will be plotted.',$
          '- Length will be set to 1 kHz frequency resolution',$
          '- F. res. will be 4 times the length, but least 400',$
          ' ', $
          'Selecting exact time axis will use the whole dataset for calculations. Without that if number of datapoints exceed ' + pg_num2str(guiblock.exact_limit) + $ 
          ' the last few will be neglected for faster FFT calculations.']$
          , dialog_parent=event.top, Title="HELP")
      endif     
      
      
    ;CROSS-TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_process_crosstr_correction_help) then begin
  res = dialog_message($
    ['The transfer function of a probe can be affected by the bandwidth of the signal processing analogue electronics.',$
    'In cases where the transfer function of the probes were measured it is possible to take them into account in the cross-phase calculations.']$
    , dialog_parent=event.top, Title="HELP")
      endif
   
    ;COHERENCES:
      if (event.ID eq nti_wavelet_gui_process_coh_help_widg) then begin
	res = dialog_message($
	  ['Coherence gives a meaningful value, if the number of averages (Average) is >0.',$
    'Selecting Average>0 will initiate a smoothing of the transforms with a kernel length of 2*sigma_t*Average.',$
    'Secelting Average=0 switches the smoothing off, thus allowing mode number calculations with the best possible resolution.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;TRANSFER FUNCTIONS:
      if (event.ID eq nti_wavelet_gui_process_coh_transfer_help_widg) then begin
	res = dialog_message($
	  ['The averaging value set in Coherences panel is used for the transfer function calculations also.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;MODENUMBERS:
      if (event.ID eq nti_wavelet_gui_process_mode_help_widg) then begin
	res = dialog_message($
	  ['Mode numbers can be calculated in the poloidal or toroidal directions determinimg the coordinate set to use.',$
    'Combined direction calculates mode number pairs, this needs Python and plotting is only available from command line.',$
    '-The selected filter is run at every time-frequency point, and determines the best fitting mode number.',$
    '-Filter Rel.pos. determines the slope of the best fitting straight line to the measured phases as function of relative probe position.',$
    '-Filter Monotonic tries to add +-2*pi-s to the phases to get close to monotonic phase diagrams.'+$
    'The mode number will be the smaller of the positive and negative or 0.'+$
    'This case Mode steps / margin refers to fraction of default monotonization margin!',$
    '-Optimized fitting will use matrix operations to determine modenumbers. It only works, if the memory need is lower than 2GB.']$
    , dialog_parent=event.top, Title="HELP")
      endif

      if (event.ID eq nti_wavelet_gui_process_mode_filterparam_help_widg) then begin
	res = dialog_message($
	  ['Filter parameters determine the set of mode numbers to consider in the search for the best fitting one.',$
    '- For global modes, mode steps should be integers. It can be e.g. 2, if even or odd mode numbers can be ruled out.',$
    '- Mode number range is to be determined based considering probe positions and prior knowledge.']$
    , dialog_parent=event.top, Title="HELP")
      endif


  ;VISUALIZATION BLOCK:
    ;GENERAL SETTINGS:
      if (event.ID eq nti_wavelet_gui_visual_genset_help_widg) then begin
	res = dialog_message($
	  ['The following parameters can be set on this panel:', $
	  '  - Force linear frequency axis: In the case of CWT the default frequency axis is logarithmical.', $
	  '       This option makes graphs with linear frequency axis. In the case of STFT, this option is ignored.', $
	  '  - Poster: This option makes plots more suitable for direct publication. It means thicker lines, larger axis, texts, and title.', $
	  '  - Frequency Range: Frequency range for the visualization can be set here. Normally this means zooming in a frequency range,', $
	  '       but for linear frequency axis cwt it can be used to force 0 kHz lowest frequency.', $
	  'These have an effect only on the plotted figures!'], $
      dialog_parent=event.top, Title="HELP")
      endif

    ;TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_visual_transf_param_help_widg) then begin
	res = dialog_message($
	  ['Either transforms or smoothed transforms can be plotted to PS files at the Save path.',$
    '- For transforms both energy density distribution and the phase is availeble, while for smoothed transforms only the energy density distribution can be plotted.',$
    '- Cscale opt gives the exponent for the color scale of the energy density plots. Lower value means more resuolution at lower energy.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;CROSS-TRANSFORMS:
      if (event.ID eq nti_wavelet_gui_visual_crosstr_param_help_widg) then begin
	res = dialog_message($
    ['Either cross-transforms or smoothed cross-transforms can be plotted to PS files at the Save path.',$
    '- Energy density distributions and relative phases can be plotted.',$
    '- Cscale opt gives the exponent for the color scale of the energy density plots. Lower value means more resuolution at lower energy.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;COHERENCES:
      if (event.ID eq nti_wavelet_gui_visual_coh_param_help_widg) then begin
	res = dialog_message($
    ['Time-frequency coherences can be plotted to PS files at the Save path.',$
    '- All switch causes coherences to be plotted for all pairs of signals selected.',$
    '- Average switch makes a plot of the average coherence. This is useful for detecting partially coherent features.',$
    '- Minimum switch makes a plot of the minimum wavelet coherence. This is useful for detecting globally coherent features.',$
    'Average and minimum are taken at each time-frequency point.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;TRANSFER FUNCTIONS:
      if (event.ID eq nti_wavelet_gui_visual_transfer_param_help_widg) then begin
	res = dialog_message($
    ['Time-frequency transfer functions can be plotted to PS files at the Save path.',$
    'All pairs of signals selected are to be plotted in both directions.',$
    'Transfer functions are to be plotted only for the time-frequency points satisfying all filters:',$
    '- Minimum wavelet coherence must be higher than the value set.',$
    '- Average smoothed cross-energy density must be higher than the set percentage of the maximum.',$
    '- Cscale opt gives the exponent for the color scale of the plots. Lower value means more resuolution at lower transfer.']$
    , dialog_parent=event.top, Title="HELP")
      endif

    ;MODENUMBERS:
      if (event.ID eq nti_wavelet_gui_visual_mode_param_help_widg) then begin
	res = dialog_message($
    ['Estimated mode numbers on the time-frequency plane can be plotted to PS files at the Save path.',$
    'Mode numbers are to be plotted only for the time-frequency points satisfying all filters:',$
    '- Minimum wavelet coherence must be higher than the value set.',$
    '- Average smoothed cross-energy density must be higher than the set percentage of the maximum.',$
    '- The residual for the best fit must be lower than the set percentage of the maximum.',$
    'All the filtering values can be set with scientific notation as well (e.g.: 1E-6).']$
    , dialog_parent=event.top, Title="HELP")
      endif



;MENU BAR
;========
;========

  if (event.ID eq nti_wavelet_gui_menu_widg) then begin
    case Event.Value of
      'File.Open configuration': begin

	guiblock.loadfile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.cfg'], /must_exist)
	if not keyword_set(guiblock.loadfile_path) then begin
	  nti_wavelet_gui_addmessage, addtext='No loadpath selected, cannot load configuration!'
	endif else begin	;keywordset(guiblock.loadfile_path)
	  restore, guiblock.loadfile_path
	  guiblock.loadfile_path = 0

	  ;WRITE TO datablock:
	  struct_assign, cfgblock, datablock, /nozero

	  ;SET CONFIGURATION on WIDGETS, only where indicator is RED:
	  if not (nti_wavelet_defined(*datablock.transforms, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_transforms
	  endif
	  if not (nti_wavelet_defined(*datablock.crosstransforms, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_crosstransforms
	  endif
	  if not (nti_wavelet_defined(*datablock.coherences, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_coherences
	  endif
	  if not (nti_wavelet_defined(*datablock.modenumbers, /nullarray)) then begin
	    nti_wavelet_gui_writeconfig, /proc_modenumbers
	  endif

	  ;Set configuration on visual block:
	  nti_wavelet_gui_writeconfig, /visualization
    ;HANDLE SENSITIVITY:
	  nti_wavelet_gui_sens, /processing, /visualization, /datapoints
	end

      end
      'File.Save configuration': begin

      ;READ CONFIGURATION:
	nti_wavelet_gui_readconfig, /processing, /visualization

	;WRITE TO cfgblock:
	  struct_assign, datablock, cfgblock, /nozero
	;SAVE cfgblock:
	  save, cfgblock, filename = 'nti_wavelet_tools.cfg'

      end
      'File.Save configuration as ..': begin

	  guiblock.savefile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.cfg'], /overwrite_prompt,$
	    /write, file='nti_wavelet_tools_personal.cfg')

	  if not keyword_set(guiblock.savefile_path) then begin
	    nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save configuration!'
	  endif else begin
	  ;READ CONFIGURATION:
	    nti_wavelet_gui_readconfig, /processing, /visualization
	  ;WRITE TO cfgblock:
	    struct_assign, datablock, cfgblock, /nozero
	  ;SAVE cfgblock:
	    save, cfgblock, filename = guiblock.savefile_path
	  end

	guiblock.savefile_path = 0
      end
      'File.Reset configuration': begin
	widget_control, nti_wavelet_gui_widg, sensitive = 0
      
      ;Check existence of nti_wavelet_tools.cfg
	cfg_test = file_test ('nti_wavelet_tools.cfg')
	  ;DELETE nti_wavelet_tools.cfg:
	  if cfg_test then begin
	    file_delete, 'nti_wavelet_tools.cfg'
	  endif

	;RESET CONFIGURATION on WIDGETS, only where indicator is RED:
	if not (nti_wavelet_defined(*datablock.transforms, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_transforms
	endif
	if not (nti_wavelet_defined(*datablock.crosstransforms, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_crosstransforms
	endif
	if not (nti_wavelet_defined(*datablock.coherences, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_coherences
	endif
	if not (nti_wavelet_defined(*datablock.modenumbers, /nullarray)) then begin
	  nti_wavelet_gui_setdefaults, /proc_modenumbers
	endif
      ;Set defaults of visualization:
	nti_wavelet_gui_setdefaults, /visualization
      ;HANDLE SENSITIVITY:
	nti_wavelet_gui_sens, /processing, /visualization, /datapoints, /set_minimum_frequency
      ;CALCULATE USED MEMORY:
	nti_wavelet_gui_calcmemory

	widget_control, nti_wavelet_gui_widg, sensitive = 1
      end
      'File.Exit': begin

	print,'Thank you for using NTI Wavelet Tools!'
	; Destroy the whole widget tree
	widget_control,/destroy,nti_wavelet_gui_widg
	return

      end
      'Filter.Auto AR filtering': begin

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 0
      delete_proc_data = 0

      if nti_wavelet_defined(*datablock.data, /nullarray) then begin
	nti_wavelet_gui_addmessage, addtext = 'Starting AR Filtering method!'
	nti_wavelet_gui_addmessage, addtext = 'Working...'

	res1 = dialog_message(['Starting AR Filtering method!', 'Do you want to see filtered data?'], /center, /question, /cancel)
	history = '_AR-filtered'


	  if (res1 eq 'Yes') then begin
	    filtered_data = *datablock.data
	    filtered_data(*, *) = 0
	    i = 0
	    cancel = 0
	    exit = 0
	    while (exit eq 0) do begin
	      history = '_AR-filtered'
	      ardata = 0
	      ardata = (*datablock.data)(*,i)
		auto_ar_filter, data = ardata, timeax = *datablock.time, /gui, /verbose, channel_name = (*datablock.channels)(i)
	      res2 = dialog_message('Do you want to continue and see next?', /center, /information, /cancel)
		if (res2 eq 'OK')  then begin
		  filtered_data(*,i) = ardata
		endif
		if (res2 eq 'Cancel')  then begin
		  filtered_data(*, *) = 0
		  res3 = dialog_message('All filtered data was deleted, and original data was restored!', /center, /information)
		  nti_wavelet_gui_addmessage, addtext = 'Original data restored!'
		  exit = 1
		  cancel = 1
		  history = ''
		endif
	      if (i ge n_elements((*datablock.data)(0,*))-1) then exit = 1
	      i = i + 1
	    endwhile
	    wdelete
	    if not cancel then begin
	      *datablock.data = filtered_data
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	    endif
	  endif

	  if (res1 eq 'No') then begin
	    for i = 0, n_elements((*datablock.data)(0,*))-1 do begin
	      ardata = 0
	      ardata = (*datablock.data)(*,i)
		auto_ar_filter, data = ardata, timeax = *datablock.time, /gui, verbose = 0
		(*datablock.data)(*,i) = ardata
	    endfor
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	  endif

	  if (res1 eq 'Cancel') then begin
	    nti_wavelet_gui_addmessage, addtext = 'Starting AR Filtering method stoped!'
	  endif

	    ;HANDLE INDICATORS AND CALCULATED DATA:
	      if delete_proc_data then begin
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
		  ;Set indicators color and delete version:
		    ;TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
		      datablock.transf_version = '-'
		    ;CROSS-TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
		      datablock.crosstr_version = '-'
		    ;COHERENCES
		      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
		      datablock.coh_version = '-'
		    ;MODENUMBERS
		      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
		      datablock.mode_version = '-'
	      endif

	;Data_histrory:
	  datablock.data_history = datablock.data_history + history
	  widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)

      endif else begin
	res = dialog_message('Data was not loaded yet!', /center)
	nti_wavelet_gui_addmessage, addtext = 'AR Filtering failed!'
      endelse

      ;ACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 1

      end
      'Filter.Auto SPRT': begin
print, (*datablock.data)(10000,*)

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 0
      delete_proc_data = 0

      if nti_wavelet_defined(*datablock.data, /nullarray) then begin
	nti_wavelet_gui_addmessage, addtext = 'Starting SPRT Filtering method!'
	nti_wavelet_gui_addmessage, addtext = 'Working...'

	res1 = dialog_message(['Starting SPRT Filtering method!', 'Do you want to see filtered data?'], /center, /question, /cancel)
	history = '_SPRT-filtered'


	  if (res1 eq 'Yes') then begin
	    filtered_data = *datablock.data
	    filtered_data(*, *) = 0
	    i = 0
	    cancel = 0
	    exit = 0
	    while (exit eq 0) do begin
	      history = '_SPRT-filtered'
	      sprtdata = 0
	      sprtdata = (*datablock.data)(*,i)
		auto_sprt, data = sprtdata, timeax = *datablock.time, /gui, /verbose, channel_name = (*datablock.channels)(i)
	      res2 = dialog_message('Do you want to continue and see next?', /center, /information, /cancel)
		if (res2 eq 'OK')  then begin
		  filtered_data(*,i) = sprtdata
		endif
		if (res2 eq 'Cancel')  then begin
		  filtered_data(*, *) = 0
		  res3 = dialog_message('All filtered data was deleted, and original data was restored!', /center, /information)
		  nti_wavelet_gui_addmessage, addtext = 'Original data restored!'
		  exit = 1
		  cancel = 1
		  history = ''
		endif
	      if (i ge n_elements((*datablock.data)(0,*))-1) then exit = 1
	      i = i + 1
	    endwhile
	    wdelete
	    if not cancel then begin
	      *datablock.data = filtered_data
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	    endif
	  endif

	  if (res1 eq 'No') then begin
	    for i = 0, n_elements((*datablock.data)(0,*))-1 do begin
	      sprtdata = 0
	      sprtdata = (*datablock.data)(*,i)
		auto_sprt, data = sprtdata, timeax = *datablock.time, /gui, verbose = 0
		(*datablock.data)(*,i) = sprtdata
	    endfor
	      nti_wavelet_gui_addmessage, addtext = 'Ready!'
	      delete_proc_data = 1
	  endif

	  if (res1 eq 'Cancel') then begin
	    nti_wavelet_gui_addmessage, addtext = 'Starting SPRT Filtering method stoped!'
	  endif

	    ;HANDLE INDICATORS AND CALCULATED DATA:
	      if delete_proc_data then begin
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
		  ;Set indicators color and delete version:
		    ;TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
		      datablock.transf_version = '-'
		    ;CROSS-TRAMSFROMS
		      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
		      datablock.crosstr_version = '-'
		    ;COHERENCES
		      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
		      datablock.coh_version = '-'
		    ;MODENUMBERS
		      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
		      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
		      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
		      datablock.mode_version = '-'
	      endif

	;Data_histrory:
	  datablock.data_history = datablock.data_history + history
	  widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)

      endif else begin
	res = dialog_message('Data was not loaded yet!', /center)
	nti_wavelet_gui_addmessage, addtext = 'SPRT Filtering failed!'
      endelse

      ;ACTIVATE GUI
      widget_control, nti_wavelet_gui_widg, sensitive = 1

print, (*datablock.data)(10000,*)
      end
      'Help.Report bug': begin
	start_web_browser, 'https://deep.reak.bme.hu/projects/wavelet/issues/new'
      end
      'Help.Asking for support': begin
	start_web_browser, 'https://deep.reak.bme.hu/projects/wavelet/boards'
      end
      'Help.Documentation': begin
	start_web_browser, guiblock.startpath+$
    'documentation/user-manual/NTI_Wavelet_Tools_user-manual.pdf'
      end
      'Help.Notes on mode number estimation at AUG': begin
  start_web_browser, guiblock.startpath+$
    'documentation/short-manual/NTI_Wavelet_Tools_short-manual.pdf'
      end
      'Help.Development': begin
	start_web_browser, 'https://deep.reak.bme.hu/projects/wavelet/roadmap'
      end
      'Help.About': begin
	start_web_browser, 'https://deep.reak.bme.hu/projects/wavelet'
      end
    endcase
  endif


;INPUT DATA - SETUP BLOCK
;========================
;========================

  ;********************
  ;* LOAD DATA button *
  ;********************

  if (event.ID eq nti_wavelet_gui_setup_dataman_load_widg) then begin
    widget_control, nti_wavelet_gui_widg, sensitive = 0

    guiblock.loadfile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.sav'], /must_exist)

    if not keyword_set(guiblock.loadfile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No loadpath selected, cannot load data!'
    endif else begin	;keywordset(guiblock.loadfile_path)

    ;Delete old variables before restore:
      channels = 0
      coord_history = 0
      data = 0
      data_history = 0
      expname = 0
      phi = 0
      shotnumber = 0
      theta = 0
      timeax = 0

        restore, guiblock.loadfile_path

    ;CHECK LOADED DATA:
      load_data_error = 0
      if not nti_wavelet_defined(CHANNELS, /nullarray) then begin	;CHANNELS
	nti_wavelet_gui_addmessage, addtext='ERROR --- CHANNELS variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(COORD_HISTORY, /nullarray) then begin	;COORD_HISTORY
	nti_wavelet_gui_addmessage, addtext='ERROR --- COORD_HISTORY variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(DATA, /nullarray) then begin	;DATA
	nti_wavelet_gui_addmessage, addtext='ERROR --- DATA variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(DATA_HISTORY, /nullarray) then begin	;DATA_HISTORY
	nti_wavelet_gui_addmessage, addtext='ERROR --- DATA_HISTORY variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(EXPNAME, /nullarray) then begin	;EXPNAME
	nti_wavelet_gui_addmessage, addtext='ERROR --- EXPNAME variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(PHI) then begin	;PHI
	nti_wavelet_gui_addmessage, addtext='ERROR --- PHI variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(SHOTNUMBER) then begin	;SHOTNUMBER
	nti_wavelet_gui_addmessage, addtext='ERROR --- SHOTNUMBER variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(THETA) then begin	;THETA
	nti_wavelet_gui_addmessage, addtext='ERROR --- THETA variable is undefined!'
	load_data_error = 1
      endif
      if not nti_wavelet_defined(TIMEAX, /nullarray) then begin	;TIMEAX
	nti_wavelet_gui_addmessage, addtext='ERROR --- TIMEAX variable is undefined!'
	load_data_error = 1
      endif

      ;CHECK NUMBER OF CHANNELS
      if not load_data_error then begin
	data_nd = size(DATA, /n_dimensions) ;The number of dimension in data
	if (data_nd eq 1) then begin
	  nti_wavelet_gui_addmessage, addtext='Only a single channel has been loaded, it will be duplicated!'
	  CHANNELS = [CHANNELS,CHANNELS]
	  DATA = [[DATA],[DATA]]
	  PHI = [PHI,PHI]
	  THETA = [THETA,THETA]
	  data_nd = 2
	endif
	if (data_nd le 0) then begin
	  nti_wavelet_gui_addmessage, addtext='No channels have been loaded!'
	  nti_wavelet_gui_addmessage, addtext='ERROR --- Problem with DATA:'
	  load_data_error = 1
	endif
	;endif
      endif

      if not load_data_error then begin
	channels_d = size(CHANNELS, /dimensions)
	data_d = size(DATA, /dimensions)
	phi_d = size(PHI, /dimensions)
	theta_d = size(THETA, /dimensions)
	timeax_d = size(TIMEAX, /dimensions)

	;CHECK DIMENSIONS:
	size1 = [channels_d, data_d(1), phi_d, theta_d]
	res = where((size1(0) ne size1), size1_count)
	if (size1_count ne 0) then begin
	  nti_wavelet_gui_addmessage, addtext='ERROR --- Problem with dimensions of CHANNELS, DATA, PHI or THETA'
	  load_data_error = 1
	endif

	size2 = [data_d(0), timeax_d]
	res = where((size2(0) ne size2), size2_count)
	if (size2_count ne 0) then begin
	  nti_wavelet_gui_addmessage, addtext='ERROR --- Length of DATA and TIMEAX not equal!'
	  load_data_error = 1
	endif
      endif

      ;IF NO ERROR, CONTINUE:
      if not load_data_error then begin

	;Add loaded data to datablock
	  datablock.expname = expname
	  datablock.shotnumber = shotnumber
	  *datablock.channels = channels
	  *datablock.data = data
	  *datablock.time = timeax
	  *datablock.theta = theta
	  *datablock.phi = phi
	  datablock.data_history=data_history
	  datablock.coord_history=coord_history

	  ;Clear channelpairs information
	  *datablock.channelpairs_ind = 0
	  *datablock.channelpairs = 0
	  widget_control, nti_wavelet_gui_setup_pairselect_selectednum_widg, set_value="Num. of Sel. Ch. Pairs: "+string(0L)

	  widget_control, nti_wavelet_gui_process_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_buttons_widg, sensitive = 0

	  ;Calculate timerange, sample frequency, number of channels and number of data points:
	  datablock.timerange=[(*datablock.time)[0], (*datablock.time)[n_elements(*datablock.time)-1]]
	  datablock.samplefreq=1D-3/(((*datablock.time)[n_elements(*datablock.time)-1]-(*datablock.time)[0])/double(n_elements(*datablock.time)-1))
	  datablock.numofchann=n_elements(*datablock.channels)
	  datablock.datapoints = n_elements((*datablock.data)(*,0))

	  ;Replot infos from shot:
	    ;Experiment name:
	    widget_control, nti_wavelet_gui_expname_widg, set_value="Experiment: "+datablock.expname
	  ;Shotnumber:
	    widget_control, nti_wavelet_gui_shotnumber_widg, set_value="Shotnumber: "+string(datablock.shotnumber)
	  ;Timerange:
	    widget_control, nti_wavelet_gui_timerange_widg,$
	      set_value="Timerange: "+string(datablock.timerange[0])+" s - "+string(datablock.timerange[1])+" s"
	  ;Sample Frequency:
	    widget_control, nti_wavelet_gui_sfreq_widg, set_value="Sample Frequency: "+string(datablock.samplefreq)+" kHz"
	  ;Number of Channels:
	    widget_control, nti_wavelet_gui_numchannels_widg, set_value="Number of channels: "+string(datablock.numofchann)
	  ;Number of Data points:
	      string_datapoints = (strsplit(datablock.datapoints,'.',/extract))(0)
	    widget_control, nti_wavelet_gui_numdatapoints_widg, set_value="Number of data points: "+string(string_datapoints)

	  ;Data_histrory:
	    widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)
	  ;Coord_histrory:
	    widget_control, nti_wavelet_gui_setup_history_coord_widg, set_value = string(datablock.coord_history)

	nti_wavelet_gui_addmessage, addtext='Data loaded!'

	;Handle sensitivity:
	  widget_control, nti_wavelet_gui_process_pairselect_base_widg, sensitive = 1
	    widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = max_freq
	    if not keyword_set(double(max_freq)) then begin
	      widget_control, nti_wavelet_gui_process_freqrange_max_widg, set_value = (0.5D*datablock.samplefreq)
	    endif

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
	  ;Set indicators color and delete version:
	    ;TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
	      datablock.transf_version = '-'
	  ;CROSS-TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	      datablock.crosstr_version = '-'
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      datablock.coh_version = '-'
	    ;TRANSFER FUNCTIONS
	      widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transfer_select_widg, set_value = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      datablock.mode_version = '-'

	      nti_wavelet_gui_sens, /datapoints, /set_minimum_frequency

      endif else begin	;not load_data_error
	nti_wavelet_gui_addmessage, addtext = "Data loading failed!"
      endelse	;not load_data_error
     endelse	;keywordset(guiblock.loadfile_path)

    widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_setup_dataman_load_widg)


  ;********************
  ;* SAVE DATA button *
  ;********************

  if (event.ID eq nti_wavelet_gui_setup_dataman_save_widg) then begin
    widget_control, nti_wavelet_gui_widg, sensitive = 0

    guiblock.savefile_path = 0
    guiblock.savefile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.sav', '*.mat'], /overwrite_prompt, /write, path="./save_data",$
      file=string(datablock.expname)+"_"+strcompress(string(datablock.shotnumber), /remove_all)+"_"+$
      strcompress(string(datablock.data_history), /remove_all)+".sav")

    if not keyword_set(guiblock.savefile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save data!'
    endif else begin

      ; Extract file extension:
      extracted_filepath = strsplit(guiblock.savefile_path,'.',/extract)
      extension = extracted_filepath(n_elements(extracted_filepath)-1)
      if (not strcmp(extension, "sav")) and (not strcmp(extension, "mat")) then begin
        nti_wavelet_gui_addmessage, addtext='Cannot save data, wrong extension!'
        res = dialog_message("You can save only files with .sav or .mat extensions!", dialog_parent=event.top, Title="Wrong extension!")
      endif else begin

        file_mkdir, file_dirname(guiblock.savefile_path, /mark_directory)

        ;Create variables for saving:
        expname = datablock.expname
        shotnumber = datablock.shotnumber
        channels = *datablock.channels
        data = *datablock.data
        timeax = *datablock.time
        theta = *datablock.theta
        phi = *datablock.phi
        data_history = datablock.data_history
        coord_history = datablock.coord_history

        if strcmp(extension, "sav") then begin
          save, expname, shotnumber, channels, data, timeax, theta, phi, data_history, coord_history, filename = guiblock.savefile_path
          nti_wavelet_gui_addmessage, addtext='Data saved!'
        endif else begin
          res = dialog_message(["Python 2.7 and IDL 8.3 or higher are needed to save .mat file", $
            "Do you want to continue?"], $
            dialog_parent=event.top, /question)
          if strcmp(res, "Yes") then begin
            ; set DLM_PATH:
            print, "Setting DLM_PATH..."
            !DLM_PATH = !DLM_PATH + ':' + guiblock.startpath + $
              '/python/third-party/slither/python27/linux_x86_64/'
            ;Save .mat file using Slither Python IDL Bridge
            nti_wavelet_gui_savemat, $
              filename = guiblock.savefile_path, expname = expname, shotnumber = shotnumber, $
              channels = channels, data_data = data, timeax = timeax, theta = theta, $
              phi = phi, data_history = data_history, coord_history = coord_history
            nti_wavelet_gui_addmessage, addtext='Data saved!'
          endif else begin
            nti_wavelet_gui_addmessage, addtext='Data is not saved!'
          endelse
        endelse
      endelse
      guiblock.savefile_path = 0
    endelse

    widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif


  ;*******************************
  ;* SELECT CHANNEL PAIRS button *
  ;*******************************

  if (event.ID eq nti_wavelet_gui_setup_pairselect_button_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0
      nti_wavelet_gui_addmessage, addtext='Select channel pairs!'
      ;Start the channel pairs select widget:
      nti_wavelet_gui_pairselect
  endif


;PROCESSING BLOCK
;================
;================

  ;******************************
  ;* LOAD PROCESSED DATA button *
  ;******************************

  if (event.ID eq nti_wavelet_gui_process_loadbutton_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0

    guiblock.loadfile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.sav'], /must_exist)

    if not keyword_set(guiblock.loadfile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No loadpath selected, cannot load data!'
    endif else begin	;keyword_set(guiblock.loadfile_path)

    datablock_names = tag_names(datablock)
    restore, guiblock.loadfile_path
      guiblock.loadfile_path = 0

    load_prdata_error = 0

    ;check existence of saved_datablock:
      if not nti_wavelet_defined(saved_datablock) then begin
	nti_wavelet_gui_addmessage, addtext='Error --- Structure of loaded data is not valid!'
	load_prdata_error = 1
      endif

    ;check names of loaded variable
      if not load_prdata_error then begin
	if not array_equal(datablock_names, tag_names(saved_datablock)) then begin
	  nti_wavelet_gui_addmessage, addtext='Error --- Structure of loaded data is not valid!'
	  load_prdata_error = 1
	endif
      endif

    ;CHECK LOADED DATA:
      if not load_prdata_error then begin
	if not nti_wavelet_defined(*SAVED_DATABLOCK.CHANNELS, /nullarray) then begin	;CHANNELS
	  nti_wavelet_gui_addmessage, addtext='ERROR --- CHANNELS variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(SAVED_DATABLOCK.COORD_HISTORY, /nullarray) then begin	;COORD_HISTORY
	  nti_wavelet_gui_addmessage, addtext='ERROR --- COORD_HISTORY variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(*SAVED_DATABLOCK.DATA, /nullarray) then begin	;DATA
	  nti_wavelet_gui_addmessage, addtext='ERROR --- DATA variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(SAVED_DATABLOCK.DATA_HISTORY, /nullarray) then begin	;DATA_HISTORY
	  nti_wavelet_gui_addmessage, addtext='ERROR --- DATA_HISTORY variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(SAVED_DATABLOCK.EXPNAME, /nullarray) then begin	;EXPNAME
	  nti_wavelet_gui_addmessage, addtext='ERROR --- EXPNAME variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(*SAVED_DATABLOCK.PHI) then begin	;PHI
	  nti_wavelet_gui_addmessage, addtext='ERROR --- PHI variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(SAVED_DATABLOCK.SHOTNUMBER) then begin	;SHOTNUMBER
	  nti_wavelet_gui_addmessage, addtext='ERROR --- SHOTNUMBER variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(*SAVED_DATABLOCK.THETA) then begin	;THETA
	  nti_wavelet_gui_addmessage, addtext='ERROR --- THETA variable is undefined!'
	  load_prdata_error = 1
	endif
	if not nti_wavelet_defined(*SAVED_DATABLOCK.TIME, /nullarray) then begin	;TIMEAX
	  nti_wavelet_gui_addmessage, addtext='ERROR --- TIMEAX variable is undefined!'
	  load_prdata_error = 1
	endif
      endif

	;CHECK DIMENSIONS:
	if not load_prdata_error then begin
	  ;Find out dimensions:
	  channels_d = size(*SAVED_DATABLOCK.CHANNELS, /dimensions)
	  res = where(*SAVED_DATABLOCK.CHANNELS_IND, channels_select_num)
	  channelpairs_select_num = SAVED_DATABLOCK.CHANNELPAIRS_SELECT_NUM
	  data_d = size(*SAVED_DATABLOCK.DATA, /dimensions)
	  phi_d = size(*SAVED_DATABLOCK.PHI, /dimensions)
	  theta_d = size(*SAVED_DATABLOCK.THETA, /dimensions)
	  timeax_d = size(*SAVED_DATABLOCK.TIME, /dimensions)
	  transf_timeax_d = size(*SAVED_DATABLOCK.TRANSF_TIMEAX, /dimensions)
	  transf_freqax_d = size(*SAVED_DATABLOCK.TRANSF_FREQAX, /dimensions)
	  transf_scaleax_d = size(*SAVED_DATABLOCK.TRANSF_SCALEAX, /dimensions)
	  transforms_d = size(*SAVED_DATABLOCK.TRANSFORMS, /dimensions)
	  smoothed_apsds_d = size(*SAVED_DATABLOCK.SMOOTHED_APSDS, /dimensions)
	  crosstransforms_d = size(*SAVED_DATABLOCK.CROSSTRANSFORMS, /dimensions)
	  smoothed_crosstransforms_d = size(*SAVED_DATABLOCK.SMOOTHED_CROSSTRANSFORMS, /dimensions)
	  coherences_d = size(*SAVED_DATABLOCK.COHERENCES, /dimensions)
	  transfers_d = size(*SAVED_DATABLOCK.TRANSFERS, /dimensions)
	  modenumbers_d = size(*SAVED_DATABLOCK.MODENUMBERS, /dimensions)
	  qs_d = size(*SAVED_DATABLOCK.QS, /dimensions)

	  ;Check input data:
	  size1 = [channels_d, data_d(1), phi_d, theta_d]
	  res = where((size1(0) ne size1), size1_count)
	  if (size1_count ne 0) then begin
	    nti_wavelet_gui_addmessage, addtext='ERROR --- Problem with dimensions of CHANNELS, DATA, PHI or THETA'
	    load_prdata_error = 1
	  endif

	  size2 = [data_d(0), timeax_d]
	  res = where((size2(0) ne size2), size2_count)
	  if (size2_count ne 0) then begin
	    nti_wavelet_gui_addmessage, addtext='ERROR --- Length of DATA and TIMEAX not equal!'
	    load_prdata_error = 1
	  endif
	endif

	;Check output data:
	if not load_prdata_error then begin
	  if nti_wavelet_defined(*saved_datablock.transforms, /nullarray) then begin
	    ;number of transforms:
	      if (transforms_d(0) ne channels_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of smoothed_apsds:
	  if nti_wavelet_defined(*saved_datablock.smoothed_apsds, /nullarray) then begin
	      if (smoothed_apsds_d(0) ne channels_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of smoothed apsds wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of cross-transforms:
	  if nti_wavelet_defined(*saved_datablock.crosstransforms, /nullarray) then begin
	      if (crosstransforms_d(0) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of smoothed cross-transforms:
	  if nti_wavelet_defined(*saved_datablock.smoothed_crosstransforms, /nullarray) then begin
	      if (smoothed_crosstransforms_d(0) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of smoothed cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of coherences:
	  if nti_wavelet_defined(*saved_datablock.coherences, /nullarray) then begin
	      if (coherences_d(0) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;number of transfers:
	  if nti_wavelet_defined(*saved_datablock.transfers, /nullarray) then begin
	      if (transfers_d(1) ne channelpairs_select_num) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of transfers wrong!'
		load_prdata_error = 1
	      endif
	  endif
	  if nti_wavelet_defined(*saved_datablock.transfers, /nullarray) then begin
	      if (transfers_d(0) ne 2) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Number of transfers wrong!'
		load_prdata_error = 1
	      endif
	  endif

	    ;timeax of transforms:
	  if nti_wavelet_defined(*saved_datablock.transforms, /nullarray) then begin
	      if (transforms_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of smoothed_apsds_d:
	  if nti_wavelet_defined(*saved_datablock.smoothed_apsds, /nullarray) then begin
	      if (smoothed_apsds_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of smoothed apsds wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of crosstransforms_d:
	  if nti_wavelet_defined(*saved_datablock.crosstransforms, /nullarray) then begin
	      if (crosstransforms_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of smoothed_crosstransforms_d:
	  if nti_wavelet_defined(*saved_datablock.smoothed_crosstransforms, /nullarray) then begin
	      if (smoothed_crosstransforms_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of smoothed cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of coherences_d:
	  if nti_wavelet_defined(*saved_datablock.coherences, /nullarray) then begin
	      if (coherences_d(1) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of transfers_d:
	  if nti_wavelet_defined(*saved_datablock.transfers, /nullarray) then begin
	      if (transfers_d(2) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of transfers wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of modenumbers_d:
	  if nti_wavelet_defined(*saved_datablock.modenumbers, /nullarray) then begin
	      if (modenumbers_d(0) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of modenumbers wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;timeax of qs_d:
	  if nti_wavelet_defined(*saved_datablock.qs, /nullarray) then begin
	      if (qs_d(0) ne transf_timeax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Time axis of qs wrong!'
		load_prdata_error = 1
	      endif
	  endif

	    ;freqax of transforms:
	  if nti_wavelet_defined(*saved_datablock.transforms, /nullarray) then begin
	      if (transforms_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of smoothed_apsds_d:
	  if nti_wavelet_defined(*saved_datablock.smoothed_apsds, /nullarray) then begin
	      if (smoothed_apsds_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of smoothed apsds wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of crosstransforms_d:
	  if nti_wavelet_defined(*saved_datablock.crosstransforms, /nullarray) then begin
	      if (crosstransforms_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of smoothed_crosstransforms_d:
	  if nti_wavelet_defined(*saved_datablock.smoothed_crosstransforms, /nullarray) then begin
	      if (smoothed_crosstransforms_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of smoothed cross-transforms wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of coherences_d:
	  if nti_wavelet_defined(*saved_datablock.coherences, /nullarray) then begin
	      if (coherences_d(2) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of transfers_d:
	  if nti_wavelet_defined(*saved_datablock.transfers, /nullarray) then begin
	      if (transfers_d(3) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of coherences wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of modenumbers_d:
	  if nti_wavelet_defined(*saved_datablock.modenumbers, /nullarray) then begin
	      if (modenumbers_d(1) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of modenumbers wrong!'
		load_prdata_error = 1
	      endif
	  endif
	    ;freqax of qs_d:
	  if nti_wavelet_defined(*saved_datablock.qs, /nullarray) then begin
	      if (qs_d(1) ne transf_freqax_d) then begin
		nti_wavelet_gui_addmessage, addtext='ERROR --- Frequency axis of qs wrong!'
		load_prdata_error = 1
	      endif
	  endif
      endif

      ;IF NO ERROR, CONTINUE:
      if not load_prdata_error then begin
      datablock = saved_datablock

      ;HANDLE SENSITIVITY
      ;------------------

	widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

	;TRAMSFROMS
	if keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;CROSS-TRAMSFROMS
	if keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;SMOOTHED APSDS
	if keyword_set(*datablock.smoothed_apsds) then begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 0
	endelse

	;SMOOTHED CROSS-TRANSFORMS
	if keyword_set(*datablock.smoothed_crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 0
	endelse

	;COHERENCES
	if keyword_set(*datablock.coherences) then begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;TRANSFER FUNCTIONS
	if keyword_set(*datablock.transfers) then begin
	  widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 0
	endelse

	;MODENUMBERS
	if keyword_set(*datablock.modenumbers) then begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.green_indicator
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;OTHER
	  widget_control, nti_wavelet_gui_process_pairselect_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_setup_pairselect_selectednum_widg, set_value="Num. of Sel. Ch. Pairs: "+string(datablock.channelpairs_select_num)
	  ;SET FREQUENCY RANGE OF PLOTS:
	    datablock.plot_gen_freq_min = datablock.proc_transf_freq_min
	    widget_control, nti_wavelet_gui_visual_genset_freqrange_min_widg, set_value = datablock.plot_gen_freq_min
	    datablock.plot_gen_freq_max = datablock.proc_transf_freq_max
	    widget_control, nti_wavelet_gui_visual_genset_freqrange_max_widg, set_value = datablock.plot_gen_freq_max

	;SELECT PAIR CHANNELS BUTTON
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

      ;SET KEYWORDS FROM LOADED DATA AND HANDLE SENSITIVITY
      ;-----------------------------

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

	nti_wavelet_gui_sens, /processing, /datapoints
	nti_wavelet_gui_writeconfig, /processing

      ;Replot infos from shot:
      ;-----------------------
	;Experiment name:
	  widget_control, nti_wavelet_gui_expname_widg, set_value="Experiment: "+datablock.expname
	;Shotnumber:
	  widget_control, nti_wavelet_gui_shotnumber_widg, set_value="Shotnumber: "+string(datablock.shotnumber)
	;Timerange:
	  widget_control, nti_wavelet_gui_timerange_widg,$
	    set_value="Timerange: "+string(datablock.timerange[0])+" s - "+string(datablock.timerange[1])+" s"
	;Sample Frequency:
	  widget_control, nti_wavelet_gui_sfreq_widg, set_value="Sample Frequency: "+string(datablock.samplefreq)+" kHz"
	;Number of Channels:
	  widget_control, nti_wavelet_gui_numchannels_widg, set_value="Number of channels: "+string(datablock.numofchann)
	;Number of Data points:
	    string_datapoints = (strsplit(datablock.datapoints,'.',/extract))(0)
	    widget_control, nti_wavelet_gui_numdatapoints_widg, set_value="Number of data points: "+string(string_datapoints)

	;Data_histrory:
	  widget_control, nti_wavelet_gui_setup_history_data_widg, set_value = string(datablock.data_history)
	;Coord_histrory:
	  widget_control, nti_wavelet_gui_setup_history_coord_widg, set_value = string(datablock.coord_history)

      ;Write message:
      nti_wavelet_gui_addmessage, addtext = "Processed Data loaded!"

      ;CALCULATE USED MEMORY:
      nti_wavelet_gui_calcmemory

      endif else begin	;not load_prdata_error
	nti_wavelet_gui_addmessage, addtext = "Processed Data loading failed!"
      endelse	;not load_prdata_error
    endelse		;(keyword_set(guiblock.loadfile_path)

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_process_loadbutton_widg)


  ;***********************
  ;* VERSION INFO button *
  ;***********************

    if (event.ID eq nti_wavelet_gui_process_versioninfo_button_widg) then begin
      res = dialog_message($
	[ 'Versions of Processed Data', $
	'', $	
	'Transforms:     ' + datablock.transf_version, $
	'Cross-transforms:     ' + datablock.crosstr_version, $
	'Coherences:     ' + datablock.coh_version, $
	'Modenumbers:     ' + datablock.mode_version ] $
	, dialog_parent=event.top, /information, Title="Versions of Processed Data")
    endif


  ;*********************************
  ;* FREQUENCY RANGE MAXIMUM FIELD *
  ;*********************************

    if (event.ID eq nti_wavelet_gui_process_freqrange_max_widg) then begin
      ;Set pre-event indicator to 1
	guiblock.pre_events = 1
	guiblock.pre_event_freq_max = 1
    endif

  ;*********************************
  ;* FREQUENCY RANGE MINIMUM FIELD *
  ;*********************************

    ;For CWT the possible minimum value is determined by the transfrorm parameters, so GUI
    ;shows actual value of minimum frequency of wavelet transforms prior to calculation

    ;FREQUENCY RANGE MINIMUM FIELD
      if (event.ID eq nti_wavelet_gui_process_freqrange_min_widg) then begin
	;Set pre-event indicator to 1
	  guiblock.pre_events = 1
	  guiblock.pre_event_freq_min = 1
      endif


    ;CWT_ORDER AND COH_AVG FIELDS
      ;Actually FREQUENCY RANGE MINIMUM FIELD will be changed here, more details in #577
      if ((event.ID eq nti_wavelet_gui_process_transf_cwt_order_widg) OR $
	(event.ID eq nti_wavelet_gui_process_coh_avg_widg)) then begin
	nti_wavelet_gui_sens, /set_minimum_frequency
      endif

  ;*********************
  ;* COHERENCE AVERAGE *
  ;*********************

    ;For CWT the possible minimum value is determined by the transform parameters, the 
    ;order of the wavelet and the number of averages used for coherence calculation. If
    ;number of the averages is changed after calculating the transforms, it should be 
    ;indicated. So in this case a pop-window will appear, which makes recalculation of
    ;the transforms possible, with the new parameter.

    if (event.ID eq nti_wavelet_gui_process_coh_avg_widg) then begin
      widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = is_cwt
      if (is_cwt AND nti_wavelet_defined(*datablock.transforms, /nullarray)) then begin
      ;Only in the case of CWT and if transforms are already calculated.
	;Set pre-event indicator to 1
	  guiblock.pre_events = 1
	  guiblock.pre_event_coh_avg = 1
      endif
    endif

  ;******************************
  ;* PROCESS BLOCK's selections *
  ;******************************

    ;TRANSFORMS:
    if (event.ID eq nti_wavelet_gui_process_transf_select_widg) then begin
      widget_control, nti_wavelet_gui_process_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	;Handling indicators:
	if keyword_set(*datablock.transforms) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Transforms deleted!"
	      datablock.transf_version = '-'
	    if (nti_wavelet_defined(*datablock.crosstransforms, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Cross-transforms deleted!"
	      datablock.crosstr_version = '-'
	    endif
	    if (nti_wavelet_defined(*datablock.coherences, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Coherences deleted!"
	      datablock.coh_version = '-'
	    endif
	    if (nti_wavelet_defined(*datablock.modenumbers, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
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
	    *datablock.transfers = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transf_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
	    ;CROSS-TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 0
	      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 0
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	    ;TRANSFER FUNCTIONS
	      widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transfer_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0
	endif

	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 0

	widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 0

	widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 0

	widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0

      endelse
    endif

    ;CROSS-TRANSFORMS
    if (event.ID eq nti_wavelet_gui_process_crosstr_widg) then begin
      widget_control, nti_wavelet_gui_process_crosstr_widg, get_value = crosstr_select_index
      if keyword_set(crosstr_select_index) then begin
	;Handling indicators:
	if keyword_set(*datablock.crosstransforms) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Cross-transforms deleted!"
	      datablock.crosstr_version = '-'
	    if (nti_wavelet_defined(*datablock.coherences, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Coherences deleted!"
	      datablock.coh_version = '-'
	    endif
	    if (nti_wavelet_defined(*datablock.modenumbers, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	    endif
	  ;Reset calculated values:
	    *datablock.crosstransforms = 0
	    *datablock.smoothed_crosstransforms = 0
	    *datablock.coherences = 0
	    *datablock.transfers = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;CROSS-TRAMSFROMS
	      widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 0
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	    ;TRANSFER FUNCTIONS
	      widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transfer_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

	if not keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
	endif
	
  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 1
  if guiblock.cross_phase_correction_indic then begin
    widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 1
  endif else begin
    widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
  endelse
      endif else begin
  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 0
  widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
  
	widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 0

	widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0
      endelse
    endif

    ;COHERENCES:
    if (event.ID eq nti_wavelet_gui_process_coh_widg) then begin
      widget_control, nti_wavelet_gui_process_coh_widg, get_value = coh_select_index
      if keyword_set(coh_select_index) then begin
	;Handling indicators:
	if keyword_set(*datablock.coherences) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Coherences deleted!"
	      datablock.coh_version = '-'
	    if (nti_wavelet_defined(*datablock.modenumbers, /nullarray)) then begin
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	    endif
	  ;Reset calculated values:
	    *datablock.coherences = 0
	    *datablock.transfers = 0
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;COHERENCES
	      widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
	    ;TRANSFER FUNCTIONS
	      widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_transfer_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 0
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

	if not keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
	endif
	if not keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 1
	    if guiblock.cross_phase_correction_indic then begin
        widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 1
      endif else begin
        widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
      endelse
	endif

	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 0

	widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0
      endelse
    endif

    ;MODENUMBERS:
    if (event.ID eq nti_wavelet_gui_process_mode_select_widg) then begin
      widget_control, nti_wavelet_gui_process_mode_select_widg, get_value = mode_select_index
      if keyword_set(mode_select_index) then begin
	;Handling indicators:
	if keyword_set(*datablock.modenumbers) then begin
	  ;Print messages to status block, about deleting data
	      nti_wavelet_gui_addmessage, addtext = "Modenumbers deleted!"
	      datablock.mode_version = '-'
	  ;Reset calculated values:
	    *datablock.modenumbers = 0
	    *datablock.qs = 0
	  ;Set indicators color:
	    ;MODENUMBERS
	      widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	      widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	      widget_control, nti_wavelet_gui_visual_mode_select_widg, set_value = 0
	      widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
	endif

	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 1
	widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 1
	

	if not keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transfparam_widg, sensitive = 1
	endif
	if not keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 1
	  if guiblock.cross_phase_correction_indic then begin
      widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 1
    endif else begin
      widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
    endelse
	endif
	if not keyword_set(*datablock.coherences) then begin
	  widget_control, nti_wavelet_gui_process_coh_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_coh_avg_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_help_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_transfer_base, sensitive = 1
	endif
      endif else begin
	widget_control, nti_wavelet_gui_process_mode_type_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filter_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_help_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_filterparam_widg, sensitive = 0
	widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0
      endelse
    endif


  ;*************************
  ;* TRANSFORMS CWT SELECT *
  ;*************************

    if (event.ID eq nti_wavelet_gui_process_transf_cwt_widg) then begin
      widget_control, nti_wavelet_gui_process_transf_cwt_widg, get_value = cwt_select
	if cwt_select then begin
	  widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 0
	  widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_quick_buttons_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_quick_help_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, sensitive = 1
	  nti_wavelet_gui_sens, /set_minimum_frequency
	endif else begin
	  widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_stft_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_quick_buttons_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, sensitive = 0
	endelse
    endif


  ;**************************
  ;* TRANSFORMS STFT SELECT *
  ;**************************

    if (event.ID eq nti_wavelet_gui_process_transf_stft_widg) then begin
      widget_control, nti_wavelet_gui_process_transf_stft_widg, get_value = stft_select
	if stft_select then begin
	  widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_quick_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 0
	  widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_quick_buttons_widg, sensitive = 1
	  ;Set minimum frequency to 0
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = 0
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, sensitive = 0
	endif else begin
	  widget_control, nti_wavelet_gui_process_transf_stft_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_cwt_widg, set_value = 1
	  widget_control, nti_wavelet_gui_process_transf_cwt_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_quick_buttons_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_freqrange_min_widg, sensitive = 1
	endelse
    endif
    
    
  ;**************************
  ;* QUICK AND DIRTY BUTTON *
  ;**************************
  
  if (event.ID eq nti_wavelet_gui_process_quick_buttons_widg) then begin
    ;TRANSFORM STFT LENGTH:
    widget_control, nti_wavelet_gui_process_freqrange_max_widg, get_value = freqrange_max
    opt_len = 0.5 ;ms
    opt_win_length_point = floor(2*opt_len*freqrange_max)
    widget_control, nti_wavelet_gui_process_transf_stft_length_widg, set_value = max([opt_win_length_point,1])
    ;TRANSFORM STFT FRES: (least 400)
    widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = max([4*opt_win_length_point,400])
    ;TRANSFORM STFT STEP: (least 1)
    widget_control, nti_wavelet_gui_process_transf_stft_step_widg, set_value = max([floor(datablock.proc_transf_freq_resdatapoints/1200.),1])
    ;CORRECTION OF CROSSTRANSFORMS
    if guiblock.cross_phase_correction_indic then begin
      widget_control, nti_wavelet_gui_process_crosstr_correction_widg, set_value = 1
    endif
  endif
   
   
  ;**************************
  ;*    EXACT TIME AXIS     *
  ;**************************
  
  if (event.ID eq nti_wavelet_gui_process_exact_time_widg) then begin
    widget_control, nti_wavelet_gui_process_exact_time_widg, get_value = exact_timeax
      if exact_timeax then begin
         guiblock.exact_timeax = 1
      endif else begin
        if datablock.datapoints ge guiblock.exact_limit then begin
          guiblock.exact_timeax = 0
        endif
      endelse
  endif
  

  ;**************************
  ;* CROSS-PHASE CORRECTION *
  ;**************************

    if (event.ID eq nti_wavelet_gui_process_crosstr_correction_widg) then begin
      widget_control, nti_wavelet_gui_process_crosstr_correction_widg, get_value = cross_phase_select
      if cross_phase_select then begin
        nti_wavelet_crossphase_correction, $
          expname = datablock.expname, startpath = guiblock.startpath, $
          channel_pairs = *datablock.channelpairs, ind_channel_pairs = *datablock.channelpairs_ind, $
          /check_correction_indicator, correction_indicator = correction_indicator, $
          non_existing_chpairs = non_existing_chpairs
        if not (size(non_existing_chpairs, /type) eq 2) then begin
          num = n_elements(non_existing_chpairs(0, *))
          merged_non_existing_chpairs = strarr(num)
          for i = 0, num - 1 do begin
            merged_non_existing_chpairs(i) = (non_existing_chpairs)(0, i) + '-' + (non_existing_chpairs)(1, i)
          endfor
          res = dialog_message(['The cross-phase correction cannot be applied on the following channel-pairs:', $
            merged_non_existing_chpairs], $ 
            dialog_parent=event.top, title='Cross-phase correction')
        endif
      endif
    endif


  ;*****************************
  ;* OPTIMIZED MODECALCULATION *
  ;*****************************
  
    if (event.ID eq nti_wavelet_gui_process_mode_optimized_widg) then begin
      widget_control, nti_wavelet_gui_process_mode_optimized_widg, get_value = mode_optimized
      if mode_optimized then begin
        guiblock.optimized_modenumber_indic = 1
        nti_wavelet_gui_addmessage, addtext='may consume a lot of memory!'
        nti_wavelet_gui_addmessage, addtext='Using optimized modenumber calculations '
        nti_wavelet_gui_addmessage, addtext='ATTENTION!'
      endif else begin
        guiblock.optimized_modenumber_indic = 0
      endelse
    endif
    

  ;****************************
  ;* START CALCULATION button *
  ;****************************

  if (event.ID eq nti_wavelet_gui_process_buttons_start_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0

  ;READ CONFIGURATION:
    nti_wavelet_gui_readconfig, /processing

      ;INITIALIZE CHANNEL POSITION:
	case datablock.proc_mode_type of
	  'Toroidal': begin
	    chpos = (*datablock.phi)(where(*datablock.channels_ind))
	  end
    'Poloidal': begin
      chpos = (*datablock.theta)(where(*datablock.channels_ind))
    end
    'Combined': begin
      chpos = [[(*datablock.phi)(where(*datablock.channels_ind))],[(*datablock.theta)(where(*datablock.channels_ind))]]
    end
  endcase

      ;INITIALIZE STFT FREQUENCY RESOLUTION POSITION:
	stft_fres = datablock.proc_transf_stft_fres

      ;SET FREQUENCY RANGE OF PLOTS:
	if not nti_wavelet_defined(*datablock.transforms, /nullarray) then begin
	  datablock.plot_gen_freq_min = datablock.proc_transf_freq_min
	  widget_control, nti_wavelet_gui_visual_genset_freqrange_min_widg, set_value = datablock.plot_gen_freq_min
	  datablock.plot_gen_freq_max = datablock.proc_transf_freq_max
	  widget_control, nti_wavelet_gui_visual_genset_freqrange_max_widg, set_value = datablock.plot_gen_freq_max
	endif

;CALCULATE DATA:

      widget_control, nti_wavelet_gui_widg, sensitive = 1

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 0
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 0
      widget_control, nti_wavelet_gui_process_widg, sensitive = 0
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 0

      nti_wavelet_gui_addmessage, addtext='Calculate data, it can take a lot of time!'
      nti_wavelet_gui_addmessage, addtext='Working ...'

      ;SET PROCESSED DATA VERSION
	;TRANSFROMS
	if not nti_wavelet_defined(*datablock.transforms, /nullarray) then begin
	  datablock.transf_version = guiblock.version
	endif
	;CROSS-TRANSFROMS
	if not nti_wavelet_defined(*datablock.crosstransforms, /nullarray) then begin
	  datablock.crosstr_version = guiblock.version
	endif
	;COHERENCES
	if not nti_wavelet_defined(*datablock.coherences, /nullarray) then begin
	  datablock.coh_version = guiblock.version
	endif
	;MODENUMBERS
	if not nti_wavelet_defined(*datablock.modenumbers, /nullarray) then begin
	  datablock.mode_version = guiblock.version
	endif
	
	   ;SET EXACT OR NON EXACT TIME AXIS
   if guiblock.exact_timeax then begin
     data_range_max = datablock.datapoints-1
   endif else begin
     data_range_max = long64(datablock.datapoints)
     while max(nti_wavelet_prime_factor(data_range_max)) gt guiblock.prime_limit do begin
       data_range_max-=1
     endwhile
     data_range_max-=1
   endelse
   print, 'Number of data points for calculation: ', floor(data_range_max+1)
nti_wavelet_main,$
  ;INPUT:
    data=(*datablock.data)(0:data_range_max,where(*datablock.channels_ind)), dtimeax=(*datablock.time)(0:data_range_max), chpos=chpos,$
    expname=datablock.expname, shotnumber=datablock.shotnumber, timerange=datablock.timerange,$
    channels=(*datablock.channels)(where(*datablock.channels_ind)),$
    channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)),$
    transf_selection=datablock.proc_transf_selection, cwt_selection=datablock.proc_transf_cwt_selection,$
    cwt_family=datablock.proc_transf_cwt_family, cwt_order=datablock.proc_transf_cwt_order,$
    cwt_dscale=datablock.proc_transf_cwt_dscale, stft_selection=datablock.proc_transf_stft_selection,$
    stft_window=datablock.proc_transf_stft_window, stft_length=datablock.proc_transf_stft_length,$
    stft_step=datablock.proc_transf_stft_step,$
    freq_min=datablock.proc_transf_freq_min, freq_max=datablock.proc_transf_freq_max,$
    prime_limit=guiblock.prime_limit, exact_limit=guiblock.exact_limit,$
    crosstr_selection=datablock.proc_crosstr_selection,$
    crosstr_correction_selection = datablock.proc_crosstr_correction_selection, coh_selection=datablock.proc_coh_selection,$
    coh_avr=datablock.proc_coh_avg, transfer_selection=datablock.proc_transfer_selection,$
    mode_selection=datablock.proc_mode_selection, mode_type=datablock.proc_mode_type, mode_optimized=guiblock.optimized_modenumber_indic,$
    mode_filter=datablock.proc_mode_filter, mode_steps=datablock.proc_mode_steps, mode_min=datablock.proc_mode_min,$
    mode_max=datablock.proc_mode_max, startpath=guiblock.startpath,$
  ;OUTPUT
    timeax=*datablock.transf_timeax, freqax=*datablock.transf_freqax, scaleax=*datablock.transf_scaleax, transforms=*datablock.transforms,$
    smoothed_apsds=*datablock.smoothed_apsds, crosstransforms=*datablock.crosstransforms,$
    smoothed_crosstransforms=*datablock.smoothed_crosstransforms, coherences=*datablock.coherences,$
    transfers=*datablock.transfers, modenumbers=*datablock.modenumbers, qs=*datablock.qs, $
  ;INPUT - OUTPUT
    stft_fres=stft_fres

      ;STORE STFT FREQUENCY RESOLUTION POSITION:
	datablock.proc_transf_stft_fres = stft_fres
	widget_control, nti_wavelet_gui_process_transf_stft_freq_widg, set_value = datablock.proc_transf_stft_fres

  widget_control, nti_wavelet_gui_process_freqrange_min_widg, set_value = datablock.proc_transf_freq_min
  nti_wavelet_gui_calcmemory

      ;HANDLE SENSITIVITY
      ;------------------

	widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

	;TRAMSFROMS
	if keyword_set(*datablock.transforms) then begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_transf_select_widg, set_value = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfmain_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_transf_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;CROSS-TRAMSFROMS
	if keyword_set(*datablock.crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_crosstr_widg, set_value = 0
	  widget_control, nti_wavelet_gui_process_crosstr_correction_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_correction_help, sensitive = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_crosstr_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;SMOOTHED APSDS
	if keyword_set(*datablock.smoothed_apsds) then begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transf_param_smooth_widg, sensitive = 0
	endelse

	;SMOOTHED CROSS-TRANSFORMS
	if keyword_set(*datablock.smoothed_crosstransforms) then begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 1
	endif else begin
	  widget_control, nti_wavelet_gui_visual_crosstr_param_smooth_widg, sensitive = 0
	endelse

	;COHERENCES
	if keyword_set(*datablock.coherences) then begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_coh_widg, set_value = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_coh_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_coh_inidic_widg, set_value = guiblock.red_indicator
	endelse

	;TRANSFER FUNCTIONS
	if keyword_set(*datablock.transfers) then begin
	  widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 1
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_transfer_base_widg, sensitive = 0
	endelse

	;MODENUMBERS
	if keyword_set(*datablock.modenumbers) then begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 1
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.green_indicator
	  widget_control, nti_wavelet_gui_process_mode_select_widg, set_value = 0
	  widget_control, nti_wavelet_gui_process_mode_optimized_widg, sensitive = 0
	  nti_wavelet_gui_sens, /processing
	endif else begin
	  widget_control, nti_wavelet_gui_visual_mode_base_widg, sensitive = 0
	  widget_control, nti_wavelet_gui_process_mode_inidic_widg, set_value = guiblock.red_indicator
	endelse

      ;ACTIVATE GUI
      nti_wavelet_gui_addmessage, addtext='Ready'
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 1
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 1
      widget_control, nti_wavelet_gui_process_widg, sensitive = 1
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif

  ;******************************
  ;* SAVE PROCESSED DATA button *
  ;******************************

  if (event.ID eq nti_wavelet_gui_process_buttons_save_widg) then begin
      widget_control, nti_wavelet_gui_widg, sensitive = 0

  ;READ CURRENT SETUPS
  ;-------------------
  nti_wavelet_gui_readconfig, /processing

    guiblock.savefile_path = 0
    guiblock.savefile_path = dialog_pickfile(dialog_parent=event.top, /fix_filter, filter=['*.sav'],$
      path="./save_data", /overwrite_prompt, /write,$
      file=string(datablock.expname)+"_"+strcompress(string(datablock.shotnumber), /remove_all)+"_"+$
      strcompress(string(datablock.data_history), /remove_all)+"_processed.sav", default_extension = "sav")

    if not keyword_set(guiblock.savefile_path) then begin
      nti_wavelet_gui_addmessage, addtext='No savepath selected, cannot save data!'
    endif else begin	;keyword_set(guiblock.savefile_path)

      extracted_filepath = strsplit(guiblock.savefile_path,'.',/extract)
      extension = extracted_filepath(n_elements(extracted_filepath)-1)
      if not strcmp(extension, "sav") then begin
	nti_wavelet_gui_addmessage, addtext='Cannot save data, wrong extension!'
	res = dialog_message("You can save only files with .sav extension!", dialog_parent=event.top, Title="Wrong extension!")
      endif else begin

      file_mkdir, file_dirname(guiblock.savefile_path, /mark_directory)

      saved_datablock = datablock
      save, saved_datablock, filename = guiblock.savefile_path
      nti_wavelet_gui_addmessage, addtext='Data saved!'

      guiblock.savefile_path = 0
      endelse
    endelse

      widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif		;(event.ID eq nti_wavelet_gui_process_buttons_save_widg)


  ;******************************
  ;* CALCULATE MEMORY *
  ;******************************

    calcmemory_events = [ $
	nti_wavelet_gui_menu_widg, $
	nti_wavelet_gui_process_transf_select_widg, $
	nti_wavelet_gui_process_transf_cwt_widg, $
	nti_wavelet_gui_process_transf_cwt_order_widg, $
	nti_wavelet_gui_process_transf_cwt_dscale_widg, $
	nti_wavelet_gui_process_transf_stft_widg, $
	nti_wavelet_gui_process_transf_stft_length_widg, $
	nti_wavelet_gui_process_transf_stft_freq_widg, $
	nti_wavelet_gui_process_transf_stft_step_widg, $
	nti_wavelet_gui_process_freqrange_min_widg, $
	nti_wavelet_gui_process_freqrange_max_widg, $
	nti_wavelet_gui_process_quick_buttons_widg, $
	nti_wavelet_gui_process_crosstr_widg, $
	nti_wavelet_gui_process_coh_widg, $
	nti_wavelet_gui_process_coh_avg_widg, $
	nti_wavelet_gui_process_coh_transfer_widg, $
	nti_wavelet_gui_process_mode_select_widg, $
	nti_wavelet_gui_process_mode_optimized_widg, $
	nti_wavelet_gui_process_mode_filterparam_steps_widg, $
	nti_wavelet_gui_process_mode_filterparam_range_min_widg, $
	nti_wavelet_gui_process_mode_filterparam_range_max_widg]

      if (where(calcmemory_events eq event.ID) ne -1) then begin
	nti_wavelet_gui_calcmemory
      endif

;VISUALIZATION BLOCK
;===================
;===================

  ;************************************
  ;* VISUALIZATION BLOCK's selections *
  ;************************************

    ;TRANSFORMS:
    if (event.ID eq nti_wavelet_gui_visual_transf_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_transf_select_widg, get_value = transf_select_index
      if keyword_set(transf_select_index) then begin
	widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_transf_param_widg, sensitive = 0
      endelse
    endif

    ;CROSS-TRANSFORMS
    if (event.ID eq nti_wavelet_gui_visual_crosstr_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_crosstr_select_widg, get_value = crosstr_select_index
      if keyword_set(crosstr_select_index) then begin
	widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_crosstr_param_widg, sensitive = 0
      endelse
    endif

    ;COHERENCES:
    if (event.ID eq nti_wavelet_gui_visual_coh_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_coh_select_widg, get_value = coh_select_index
      if keyword_set(coh_select_index) then begin
	widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 1
	widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_coh_param_widg, sensitive = 0
	widget_control, nti_wavelet_gui_visual_coh_param_help_widg, sensitive = 0
      endelse
    endif

    ;TRANSFER FUNCTIONS:
    if (event.ID eq nti_wavelet_gui_visual_transfer_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_transfer_select_widg, get_value = transfer_select_index
      if keyword_set(transfer_select_index) then begin
	widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_transfer_param_widg, sensitive = 0
      endelse
    endif

    ;MODENUMBERS:
    if (event.ID eq nti_wavelet_gui_visual_mode_select_widg) then begin
      widget_control, nti_wavelet_gui_visual_mode_select_widg, get_value = mode_select_index
      if keyword_set(mode_select_index) then begin
	widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 1
      endif else begin
	widget_control, nti_wavelet_gui_visual_mode_param_widg, sensitive = 0
      endelse
    endif

  ;*************************
  ;* START PLOTTING button *
  ;*************************

  if (event.ID eq nti_wavelet_gui_visual_buttons_start_widg) then begin

  ;READ VISUALIZATION BLOCK CONFIGURATION:
    nti_wavelet_gui_readconfig, /visualization

      ;INACTIVATE GUI
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 0
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 0
      widget_control, nti_wavelet_gui_process_widg, sensitive = 0
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 0

      nti_wavelet_gui_addmessage, addtext='Plot data, it can take a lot of time!'
      nti_wavelet_gui_addmessage, addtext='Working ...'

;PLOTTER PROGRAM
nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=*datablock.transf_timeax, freqax=*datablock.transf_freqax, scaleax=*datablock.transf_scaleax,$
    transforms=*datablock.transforms, smoothed_apsds=*datablock.smoothed_apsds, crosstransforms=*datablock.crosstransforms,$
    smoothed_crosstransforms=*datablock.smoothed_crosstransforms, coherences=*datablock.coherences,$
    transfers=*datablock.transfers, modenumbers=*datablock.modenumbers, qs=*datablock.qs,$
  ; Inputs - processing parameters
    expname=datablock.expname, shotnumber=datablock.shotnumber,data_history=datablock.data_history,$
    coord_history=datablock.coord_history,channels=(*datablock.channels)(where(*datablock.channels_ind)),$
    channelpairs_used=(*datablock.channelpairs)(*, where(*datablock.channelpairs_ind)) ,$
    cwt_selection=datablock.proc_transf_cwt_selection, cwt_family=datablock.proc_transf_cwt_family,$
    cwt_order=datablock.proc_transf_cwt_order, cwt_dscale=datablock.proc_transf_cwt_dscale,$
    stft_selection=datablock.proc_transf_stft_selection, stft_window=datablock.proc_transf_stft_window,$
    stft_length=datablock.proc_transf_stft_length, stft_fres=datablock.proc_transf_stft_fres,$
    stft_step=datablock.proc_transf_stft_step, freq_min=datablock.plot_gen_freq_min,$
    freq_max=datablock.plot_gen_freq_max, coh_avr=datablock.proc_coh_avg,$
    mode_type=datablock.proc_mode_type, mode_filter=datablock.proc_mode_filter,$
    mode_steps=datablock.proc_mode_steps, mode_min=datablock.proc_mode_min, mode_max=datablock.proc_mode_max, $
  ; Inputs - visualization parameters
    transf_selection=datablock.plot_transf_selection, transf_smooth=datablock.plot_transf_smooth,$
    transf_energy=datablock.plot_transf_energy, transf_phase=datablock.plot_transf_phase,$
    transf_cscale=datablock.plot_transf_cscale, crosstr_selection=datablock.plot_crosstr_selection,$
    crosstr_smooth=datablock.plot_crosstr_smooth, crosstr_energy=datablock.plot_crosstr_energy,$
    crosstr_phase=datablock.plot_crosstr_phase, crosstr_cscale=datablock.plot_crosstr_cscale,$
    coh_selection=datablock.plot_coh_selection, coh_all=datablock.plot_coh_all, coh_avg=datablock.plot_coh_avg,$
    coh_min=datablock.plot_coh_min, transfer_selection=datablock.plot_transfer_selection,$
    transfer_cohlimit=datablock.plot_transfer_cohlimit, transfer_powlimit=datablock.plot_transfer_powlimit,$
    transfer_cscale = datablock.plot_transfer_cscale, mode_selection=datablock.plot_mode_selection,$
    mode_cohlimit=datablock.plot_mode_cohlimit, mode_powlimit=datablock.plot_mode_powlimit,$
    mode_qlimit=datablock.plot_mode_qlimit, linear_freqax=datablock.plot_linear_freqax,$
    poster=datablock.plot_poster, $
  ; Save path
    savepath=datablock.plot_savepath,$
  ; Other
    startpath=guiblock.startpath, version=guiblock.version

      ;ACTIVATE GUI
      nti_wavelet_gui_addmessage, addtext='Ready'
      widget_control, nti_wavelet_gui_menu_widg, sensitive = 1
      widget_control, nti_wavelet_gui_setup_widg, sensitive = 1
      widget_control, nti_wavelet_gui_process_widg, sensitive = 1
      widget_control, nti_wavelet_gui_visual_widg, sensitive = 1

  endif


  ;************************
  ;* SET SAVE PATH button *
  ;************************

  if (event.ID eq nti_wavelet_gui_visual_buttons_save_widg) then begin
    widget_control, nti_wavelet_gui_widg, sensitive = 0

    plot_savepath = dialog_pickfile(dialog_parent=event.top, title = "Select directory!", /directory)
    if keyword_set(plot_savepath) then begin
      datablock.plot_savepath = plot_savepath
      file_mkdir, datablock.plot_savepath
      widget_control, nti_wavelet_gui_visual_buttons_save_path_widg, set_value = datablock.plot_savepath
    endif
    widget_control, nti_wavelet_gui_widg, sensitive = 1
  endif

endif

end