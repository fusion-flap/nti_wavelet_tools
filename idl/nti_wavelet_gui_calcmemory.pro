;+
; NAME:
;	NTI_WAVELET_GUI_CALCMEMORY
;
; PURPOSE:
;	This procedure predicts the memory to be used for the calculations,
;	and prints out to NTI Wavelet Tools Graphical User Interface.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GUI_CALCMEMORY
;
;		THIS ROUTINE CALLED BY NTI_WAVELET_GUI.PRO.
;		DO NOT CALL THIS ROUTINE ALONE!
;
; COMMON BLOCKS:
;	NTI_WAVELET_GUI_COMMON:	It contains widget ids and structures of datas.
;
;-


pro nti_wavelet_gui_calcmemory
@nti_wavelet_gui_common.pro

floatsize=4 ; Bytes
complexsize=2*floatsize ; Bytes

nti_wavelet_gui_readconfig, /processing

temp=where(*datablock.channels_ind, channel_num); Calculate number of used channels and store it in channel_num
time_num=n_elements(*datablock.time)/(0.5*datablock.samplefreq/datablock.proc_transf_freq_max) ; Calculate elements of time vector

if datablock.proc_transf_cwt_selection then begin ; Memory needed for one CWT as stored in the array
  freq_min=1d3*datablock.proc_transf_freq_min
  start_scale=datablock.proc_transf_cwt_order/!PI
  max_scale=datablock.proc_transf_cwt_order/freq_min/2/!PI*datablock.samplefreq*1000
  nscale=ceil(pg_log2(max_scale/start_scale)/datablock.proc_transf_cwt_dscale)+1 ; Calculate nscale from minimum frequency
  transform_memory=complexsize*time_num*nscale ; Bytes
endif else begin ; Memory needed for one STFT as stored in the array
  transform_memory=complexsize*time_num/float(datablock.proc_transf_stft_step)*datablock.proc_transf_stft_fres ; Bytes
endelse

memory=0
if datablock.proc_transf_selection OR nti_wavelet_defined(*datablock.transforms, /nullarray) then $ ; If transform calculation is selected or they are loaded
  memory=memory+transform_memory*(channel_num+2*2); Memory needed for the transform arrays
  ;(transforms, transform)
if datablock.proc_crosstr_selection OR nti_wavelet_defined(*datablock.crosstransforms, /nullarray) then $ ; If crosstransform calculation is selected or they are loaded
  memory=memory+transform_memory*(datablock.channelpairs_select_num+2) ; Memory needed for the crosstransform array
  ;(crosstransforms, transform1, transform2)
if datablock.proc_coh_selection OR nti_wavelet_defined(*datablock.coherences, /nullarray) then $ ; If coherence calculation is selected or they are loaded
  memory=memory+transform_memory/2.*(2*datablock.channelpairs_select_num+channel_num+2) ; Memory needed for the coherence arrays
  ;(coherences, smoothed_crosstransforms, smoothed_apsds, smoothed_apsd1, smoothed_apsd2)
if (datablock.proc_coh_selection AND datablock.proc_transfer_selection) OR nti_wavelet_defined(*datablock.transfers, /nullarray) then $ ; If transfer function calculation is selected or they are loaded
  memory=memory+2*transform_memory*datablock.channelpairs_select_num ; Memory needed for the transfer function array
  ;(transfers)
if datablock.proc_mode_selection OR nti_wavelet_defined(*datablock.modenumbers, /nullarray) then $ ; If mode number calculation is selected or they are loaded
  memory=memory+transform_memory/2.*(datablock.channelpairs_select_num+2) ; Memory needed for the mode number arrays
  ;(cphases, modenumbers, qs)
if datablock.proc_mode_selection AND datablock.proc_mode_optimized then begin ; If mode number calculation is selected and optimized calculation is switched on
  nmode = ceil((datablock.proc_mode_max-datablock.proc_mode_min+1)/float(datablock.proc_mode_steps)) ; Number of fitted mode values
  memory=memory+transform_memory/2.*(datablock.channelpairs_select_num)*nmode*6 ; Memory needed for optimized mode number calculation
  ;6 matrices of (cphases*modes) dimensions
  endif


;ROUNDING VALUE OF MEMEORY
  ;convert value to GB:
    memory=memory/(2D^30)
  ;round to two decimal:
    memory=100*memory
    memory=round(memory)
    memory=1D-2*memory
  ;convert to string:
    memory = string(memory)
  ;search position of decimal:
    pos = strpos(memory, '.')
  ;cut the zeros from the end of string
    memory = strmid(memory, 0, pos+3)

widget_control, nti_wavelet_gui_process_buttons_memory_widg, set_value = memory

end