;+
; NAME:
; NTI_WAVELET_remove_collectorID
;
; PURPOSE:
; This procedure removes collector id like 'MHA' or 'MHI'
; from channelpairs arrays
;
; INPUT:
;   channel_pairs_id: channelpairs id like ['MHA-B31-14','MHA-B31-12'] 2xn string array
;
; OUTPUT:
;   strArray: corrected array without string before the first '-'
;-
function nti_wavelet_remove_collectorID, channel_pairs_id
  numpairs = n_elements(channel_pairs_id(0,*))
  ;strArray = strarr(2,numpairs)
  strArray = channel_pairs_id
  for i = 0, numpairs - 1 do begin
    split = strsplit(channel_pairs_id(0,i),'-', /extract, count = numHyphen)
    if numHyphen GE 2 then $
      strArray(0,i) = strjoin(split(1:n_elements(split)-1), '-')
    split = strsplit(channel_pairs_id(1,i),'-', /extract, count = numHyphen)
    if numHyphen GE 2 then $
      strArray(1,i) = strjoin(split(1:n_elements(split)-1), '-')
  endfor
  return, strArray
end