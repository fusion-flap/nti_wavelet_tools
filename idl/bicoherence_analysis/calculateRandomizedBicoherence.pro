;********************************************************************************************************
; Name: calculateRandomizedBicoherence.pro
;
; PURPOSE
; =======
; This program calculates the randomized bicoherence matrix of a data vector, with Hann windowing.
;
; USAGE
; =======
; bicoherenceMatrix=calculateRandomizedBicoherence(rawSignal,singleBlockSize, randomSeed)
;
; INPUTS
; =======
; rawSignal:                  input data vector (1D))
; singleBlockSize:            blocksize of a single window (int)
; randomSeed:                 seed for the random numbers (num)
;
; OUTPUT
; =======
; randomizedBicoherence:      randomized bicoherence matrix of the input data vector
;********************************************************************************************************
function calculateRandomizedBicoherence, rawSignal, singleBlockSize, randomMarker

  if ((singleBlockSize mod 2) EQ 1) then singleBlockSize=singleBlockSize+1

  cutSignal = windowSignal(rawSignal,singleBlockSize,how='overlapping_hanning')
  blockNumber = n_elements(cutSignal[*,0])

  fftSignal = fft(cutSignal,dimension=2,-1)
  fftSignal = reform(fftSignal(*,0:singleBlockSize/2-1))
  
  absFFT = abs(fftSignal)
  randomSeed=randomMarker
  randomPhaseFFT = 2*!Pi*randomu(randomSeed,blockNumber,singleBlockSize/2) 
  complexUnit = complex(0,1)
  fftSignal = absFFT*exp(complexUnit*randomPhaseFFT) 
  
  fftCrossTerm = dcomplexarr(blockNumber,singleBlockSize/2,singleBlockSize/2)
  for i=0, blockNumber-1 do begin
    fftCrossTerm(i,*,*) = transpose(fftSignal(i,*))#fftSignal(i,*)
  endfor

  fftShiftTerm = dcomplexarr(blockNumber,singleBlockSize/2,singleBlockSize/2)
  for i=0, blockNumber-1 do begin
    for j=0, singleBlockSize/2-1 do begin
      fftShiftTerm(i,j,*) = shift(reform(fftSignal(i,*)),-(j+1))
    endfor
  endfor

  bispectrum = mean(fftCrossTerm*conj(fftShiftTerm),dimension=1)
  normCrossTerm = sqrt(mean(abs(fftCrossTerm)^2,dimension=1))
  normShiftTerm = sqrt(mean(abs(fftShiftTerm)^2,dimension=1))

  randomizedBicoherence = abs(bispectrum)/normCrossTerm/normShiftTerm
  return, randomizedBicoherence
end