;********************************************************************************************************
; Name: ELMcalculateBicoherence.pro
; 
; PURPOSE
; =======
; This program calculates the bicoherence matrix of a data vector, with Hann windowing.
; with stopping for plot
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
function ELMcalculateBicoherence, rawSignal, singleBlockSize,ELMlevel, APSD=APSD
  ;Make the parity of the blocksize EVEN
  if ((singleBlockSize mod 2) EQ 1) then singleBlockSize+=+1
;  blockNumber = floor(n_elements(rawSignal)/singleBlockSize)
;  if blockNumber EQ 0 then begin
;    singleBlockSize = n_elements(rawSignal)
;    blockNumber = 1
;  endif
  
  cutSignal = ELMwindowSignal(rawSignal,singleBlockSize,ELMlevel, how='not_overlapping_hanning')
  blockNumber = n_elements(cutSignal[*,0])

; 
  fftSignal = fft(cutSignal,dimension=2,-1)
  
  meret=size(fftSignal)
  print, 'fftSignalsize=', meret
  ;Only keep positive frequency part
  fftSignal = reform(fftSignal(*,0:singleBlockSize/2-1))  
  meret=size(fftSignal)
  print, 'reformfftSignalsize=', meret
  ; probaFFTplot
;  apsdmax=max(fftSignal)
 ; apsdmin=min(fftSignal)
  ;delta=apsdmax-apsdmin
 ; s1=apsdmin+5*delta/10000
 ; s2=s1+delta/1000
 ; s3=s2+delta/100
 ; s4=s3+delta/10
 ; contour, fftSignal, C_Colors=[s1,s2,s3,s4], /FILL
 ; contour, abs(fftSignal),levels=[0.0001,0.001,0.01,0.1,1.0,10.],/fill  
;wait, 150
  blockNumber = n_elements(fftSignal[*,0])
  print, 'blockNumber=',blocknumber
;  plot, abs(fftSignal)
 ;wait, 120
  
  ;Create matrices for further calculations (fftCrossTerm=X(f_1)*X(f_2))
  fftCrossTerm = dcomplexarr(blockNumber,singleBlockSize/2,singleBlockSize/2)
  for i=0L, blockNumber-1 do begin
    fftCrossTerm(i,*,*) = transpose(fftSignal(i,*))#fftSignal(i,*)
  endfor
  
  ;(fftShiftTerm=X(f_1+f_2))
  fftShiftTerm = dcomplexarr(blockNumber,singleBlockSize/2,singleBlockSize/2)
  for i=0L, blockNumber-1L do begin
    for j=0L, singleBlockSize/2-1 do begin
      fftShiftTerm(i,j,*) = shift(reform(fftSignal(i,*)),-(j+1))
    endfor
  endfor
  
  ;Calculate bispectrum and normalization factors for bicoherence
  bispectrum = mean(fftCrossTerm*conj(fftShiftTerm),dimension=1)
  normCrossTerm = sqrt(mean(abs(fftCrossTerm)^2,dimension=1))
  normShiftTerm = sqrt(mean(abs(fftShiftTerm)^2,dimension=1))
  
  ;Calculate APSD for checking,,,,,,,,if APSD variable set
  if keyword_set(APSD) then $
    APSD = mean(abs(fftSignal)^2,dimension=1)
;  freqAxis = createFreqAxis(plotParameters.niqFrequency,plotParameters.blockSize)
  ;plot, APSD
  
  
  bicoherence = abs(bispectrum)/normCrossTerm/normShiftTerm
  return, bicoherence
end