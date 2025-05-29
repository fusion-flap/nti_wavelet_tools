;+
; NAME:
; NTI_WAVELET_CROSSPHASE_CORRECTION
;
; PURPOSE:
; This procedure correct cross-phases of cross-transforms if
; the correc factors are available in fil.
;
; INPUT:
;   expname:  The name of the experiment which from the signals are coming.
;   startpath:  The path where the correction factors are stored.
;   timeax: The time axis.
;   freqax: The frequency axis.
;   crosstransforms:  Cross-transforms to be modified  (same as OUTPUT)
;   channel_pairs:  String array containing the avialable channel pairs.
;   ind_channel_pairs:  Indices of selected channel pairs.
;   channelpairs_used: String array containing the used channel pairs.
;   check_correction_indicator:  Set to 1 to check availability of correction factors.
;   calculate_correction:  Set to 1 to perform correction.
;
; OUTPUT:
;   correction_indicator: Indicate whether the correction factors are avaialbe or not.
;   non_existing_chpairs: Return the name of channel pairs for which the 
;     correction factors are not available.
;   crosstransforms: The modified crosstransforms (same as INPUT)
;
;-

pro nti_wavelet_crossphase_correction, $
  expname = expname, startpath = startpath, $
  channel_pairs = channel_pairs, ind_channel_pairs = ind_channel_pairs, $
  check_correction_indicator = check_correction_indicator, correction_indicator = correction_indicator, $
  non_existing_chpairs = non_existing_chpairs, $
  channelpairs_used = channelpairs_used, timeax = timeax, freqax = freqax, $
  crosstransforms = crosstransforms, calculate_correction = calculate_correction


; Name of experiments for which the cross-phase correction factors are available:
available_experiments = ["AUGD"]

; Check the availability of correction factors:
if nti_wavelet_defined(check_correction_indicator, /nullarray) then begin

  ; Check whether the correction factors are available for the experiment or not:
  if where(available_experiments eq expname) ne -1 then begin
  
    ; Load correction factors from file:
    restore, startpath + expname + "_cross_phase_correction.sav"

    ; Choose selected channelpairs:
    selected_channel_pairs = channel_pairs(*, where(ind_channel_pairs))
    selected_channel_pairs = nti_wavelet_remove_collectorID(selected_channel_pairs)
    phasecorr_pair_id = nti_wavelet_remove_collectorID(phasecorr_pair_id)
    ; Merging name of channel pairs into one string:
      ; Channelpairs which has cross-phase correction:
      numcorr = n_elements(phasecorr_pair_id(0, *))
      merged_phasecorr_channel_pairs = strarr(numcorr)
      for i = 0, numcorr - 1 do begin
        merged_phasecorr_channel_pairs(i) = $
          (phasecorr_pair_id)(0, i) + '-' + (phasecorr_pair_id)(1, i)
      endfor
      ; Selected channelpairs:
      numsel = n_elements(selected_channel_pairs(0, *))
      merged_channel_pairs_selected = strarr(numsel)
      for i = 0, numsel - 1 do begin
        merged_channel_pairs_selected(i) = $
          selected_channel_pairs(0, i) + '-' + selected_channel_pairs(1, i)
      endfor

    ; Check existence of cross-phase correction:
    corrind_channel_pairs_selected = intarr(n_elements(merged_channel_pairs_selected))
    for i = 0, numsel - 1 do begin
      tmp = where(merged_channel_pairs_selected(i) eq merged_phasecorr_channel_pairs)
      if tmp ne -1 then begin
        ; if channel_pair can be found in the list:
        corrind_channel_pairs_selected(i) = 1
      endif
    endfor
    
    ; If there is not any channel_pair which is available in the list:
    tmp = where(corrind_channel_pairs_selected, count)
    if count ne 0 then begin
      correction_indicator = 1
    endif else begin
      correction_indicator = 0
    endelse
    
    ; Create string array which contains the name of channel_pairs not avaialbe in the list:
    tmp = where(corrind_channel_pairs_selected eq 0)
    ; If all channel_pairs are available:
    if tmp(0) eq -1 then begin
      non_existing_chpairs = 0
    endif else begin
      non_existing_chpairs = selected_channel_pairs(*, where(corrind_channel_pairs_selected eq 0))
      ; If only one channel_pair is not available (IDL indexing issue):
      if n_elements(tmp) eq 1 then begin
        non_existing_chpairs = reform(non_existing_chpairs, 2, 1)
      endif
    endelse
    
  endif else begin
  
    ; When the correction factors are not available for the experiment:
    correction_indicator = 0
    
  endelse

endif


; Correct cross-phases:
if nti_wavelet_defined(calculate_correction, /nullarray) then begin

  ; Define imaginary unit:
  unit = complex(0,1)

  ; Load correction factors from file:
  restore, startpath + expname + "_cross_phase_correction.sav"
  phasecorr_pair_id = nti_wavelet_remove_collectorID(phasecorr_pair_id)
  ; Merging name of channel pairs into one string:
    ; Channelpairs which has cross-phase correction:
    numcorr = n_elements(phasecorr_pair_id(0, *))
    merged_phasecorr_channel_pairs = strarr(numcorr)
    for i = 0, numcorr - 1 do begin
      merged_phasecorr_channel_pairs(i) = $
        (phasecorr_pair_id)(0, i) + '-' + (phasecorr_pair_id)(1, i)
    endfor
    ; Channelpairs used:
    corrected_chp_used = nti_wavelet_remove_collectorID(channelpairs_used) 
    num = n_elements(corrected_chp_used(0, *))
    merged_channelpairs_used = strarr(num)
    for i = 0, num - 1 do begin
      merged_channelpairs_used(i) = $
        (corrected_chp_used)(0, i) + '-' + (corrected_chp_used)(1, i)
    endfor
     
    ; Calculate dimensions:
    n_corr_freqax = n_elements(phasecorr_freqax)
    n_channels = n_elements(crosstransforms(*, 0, 0))
    n_freqax = n_elements(crosstransforms(0, 0, *))
    n_time = n_elements(crosstransforms(0, *, 0))
    ; Initialize array:
    correction = fltarr(n_channels, n_corr_freqax)
    ; +1 is needed to generate complex values with 0 phase by default:
    itp_corr = complexarr(n_channels, n_freqax) + 1.

    ; Rename variable containing correction factors:
    corr = phasecorr_rel_transfer

    ; Calculate cross-phases by interpolating the frequency axis
    for i = long(0), n_channels - 1 do begin
      ind = where(merged_channelpairs_used(i) eq merged_phasecorr_channel_pairs)
      if ind(0) ne -1 then begin
        correction(i, *) = - atan(corr(ind, *), /phase)
        itp_corr(i, *) = interpol(correction(i, *), phasecorr_freqax, freqax)
        itp_corr(i, *) = exp(unit*itp_corr(i, *))
      endif
    endfor

    ; Perform correction on crosstransforms:
    for i = long(0), n_channels - 1 do begin ; channels
      for j = long(0), n_time - 1 do begin ; time points
        crosstransforms(i, j, *) = crosstransforms(i, j, *)*itp_corr(i, *)
      endfor
    endfor

endif

end