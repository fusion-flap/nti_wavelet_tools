;********************************************************************************************************
; Name: calculateBicoherence.pro
;
; PURPOSE
; =======
; This program calculates the bicoherence matrix of a data vector, with Hann windowing.
;
; USAGE
; =======
; bicoherenceMatrix=calculateBicoherence(rawSignal,singleBlockSize)
;
; INPUTS
; =======
; rawSignal:                  input data vector (1D)
; singleBlockSize:            blocksize of a single window (int)
;
; OUTPUT
; =======
; bicoherence:                bicoherence matrix of the input data vector
; APSD(optional):             autospectrum of the signal
;********************************************************************************************************
function calculateBicoherence, rawSignal, singleBlockSize, APSD=APSD
  ;Make the parity of the blocksize EVEN
  if ((singleBlockSize mod 2) EQ 1) then singleBlockSize+=+1
;  blockNumber = floor(n_elements(rawSignal)/singleBlockSize)
;  if blockNumber EQ 0 then begin
;    singleBlockSize = n_elements(rawSignal)
;    blockNumber = 1
;  endif

  cutSignal = windowSignal(rawSignal,singleBlockSize,how='overlapping_hanning')
  blockNumber = n_elements(cutSignal[*,0])

  fftSignal = fft(cutSignal,dimension=2,-1)
  ;Only keep positive frequency part
  fftSignal = reform(fftSignal(*,0:singleBlockSize/2-1))

  ;Create matrices for further calculations (fftCrossTerm=X(f_1)*X(f_2))
  fftCrossTerm = dcomplexarr(blockNumber,singleBlockSize/2,singleBlockSize/2)
  for i=0, blockNumber-1 do begin
    fftCrossTerm(i,*,*) = transpose(fftSignal(i,*))#fftSignal(i,*)
  endfor

  ;(fftShiftTerm=X(f_1+f_2))
  fftShiftTerm = dcomplexarr(blockNumber,singleBlockSize/2,singleBlockSize/2)
  for i=0, blockNumber-1 do begin
    for j=0, singleBlockSize/2-1 do begin
      fftShiftTerm(i,j,*) = shift(reform(fftSignal(i,*)),-(j+1))
    endfor
  endfor

  ;Calculate bispectrum and normalization factors for bicoherence
  bispectrum = mean(fftCrossTerm*conj(fftShiftTerm));,dimension=1)
  normCrossTerm = sqrt(mean(abs(fftCrossTerm)^2));,dimension=1))
  normShiftTerm = sqrt(mean(abs(fftShiftTerm)^2));,dimension=1))

  ;Calculate APSD if APSD variable set
  if keyword_set(APSD) then $
    APSD = mean(abs(fftSignal)^2);,dimension=1)

  bicoherence = abs(bispectrum)/normCrossTerm/normShiftTerm
  return, bicoherence
end