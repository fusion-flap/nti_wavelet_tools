;********************************************************************************************************
; Name: windowSignal.pro
;
; PURPOSE
; =======
; Cut signal to proper parts with
; overlapping (50%) hann windowing
; not overlapping hann windowing
;
; USAGE
; =======
; signalParts = windowSignal(rawSignal,512,how='not_overlapping_hanning')
; INPUTS
; =======
; raWsignal             (1d vector)
; signleBlockSize       int (e.g.:512)
; how                   type of windowing, if no 'how' setted it will return 0.s
; OUTPUT
; =======
; windowedSignal containing N piece of windows (N x singleBlockSize size matrix)
;********************************************************************************************************
function windowSignal, rawSignal, singleBlockSize, how=how
  ;not overlapping block number
  blockNumber = floor(n_elements(rawSignal)/singleBlockSize)
  if blockNumber EQ 0 then begin
    singleBlockSize = n_elements(rawSignal)
    blockNumber = 1
  endif
  ;check that is how variable defined?
  if nti_wavelet_defined(how) then begin

    ;Case of not overlapping hanning
    if how EQ 'not_overlapping_hanning' then begin
      windowedSignal = dblarr(blockNumber,singleBlockSize)
      for i=0d, blockNumber-1 do begin
        windowedSignal(i,*) = hanning(singleBlockSize)*(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)-$
                                mean(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)))
      endfor
      return, windowedSignal
    endif

    ;Case of 50% overlapping hanning
    if how EQ 'overlapping_hanning' then begin
      windowedSignal = dblarr(2*blockNumber-1,singleBlockSize)
        for i=0d, 2*blockNumber-2 do begin
          windowedSignal(i,*) = hanning(singleBlockSize)*(rawSignal(i*singleBlockSize/2.:i*singleBlockSize/2.+singleBlockSize-1.)-$
                                  mean(rawSignal(i*singleBlockSize/2.:i*singleBlockSize/2.+singleBlockSize-1.)))
        endfor
        return, windowedSignal
    endif

  endif

  return, 0
end