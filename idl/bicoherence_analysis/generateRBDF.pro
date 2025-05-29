;********************************************************************************************************
; Name: generateRBDF.pro
;
; PURPOSE
; =======
; This program generates Randomized Bicoherence Density Function
;
; USAGE
; =======
; RBDF=generateRBDF(rawSignal,timeAxis,singleBlockSize)
;
; INPUTS
; =======
; rawSignal:                  input data vector (1D)
; singleBlockSize:            blocksize of a single window (int)
; numOfSamples:               number of random realization (int)
;
; OUTPUT
; =======
; RBDF:                       randomized bicoherence density function
;********************************************************************************************************
function generateRBDF, rawSignal, singleBlockSize, numOfSamples
  
  if ((singleBlockSize mod 2) EQ 1) then singleBlockSize=singleBlockSize+1
  
  print, 'Starting RBDF calculations!'
  print, 'Number of samples: ', numOfSamples
  print, 'Time needed approx: ', pg_num2str(1.5*(double(singleBlockSize)^2)*numOfSamples/90000./60.,length=4), ' minute(s).'
  print, 'Now go and have a coffee-break!'
  
  RBDF = dblarr(numOfSamples,singleBlockSize/2,singleBlockSize/2)

  for i=0, numOfSamples-1 do begin
     RBDF(i,*,*)=calculateRandomizedBicoherence(rawSignal,singleBlockSize,i)
     if i mod floor(numOfSamples/20.) EQ 0 then $
      print, pg_num2str(100.*i/numOfSamples,length=2), '% has been done!'
  endfor

  return, RBDF
end