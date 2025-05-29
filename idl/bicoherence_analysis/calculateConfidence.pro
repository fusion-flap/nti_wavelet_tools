;********************************************************************************************************
; Name: calculateconfidence.pro
;
; PURPOSE
; =======
; This program calculates confidence matrix from Randomized Bicoherence Density function 
; and from the measured bicoherence matrix
;
; USAGE
; =======
; confidenceMatrix=calculateconfidence(RBDF,bicoherenceMatrix)
;
; INPUTS
; =======
; RBDF:                       randomized bicoherence density function matrix (3D)
; bicoherenceMatrix:          bicoherence matrix (2D)
;
; OUTPUT
; =======
; confidence:               confidence matrix (2D)
;********************************************************************************************************
function calculateConfidence, RBDF, bicoherenceMatrix
  dimensions = size(RBDF)
  numOfSamples = dimensions[1]
  numOfXAxis = dimensions[2]
  
  confidence = dblarr(numOfXAxis,numOfXAxis)
  for i=0, numOfXAxis-1 do begin
    for j=0, numOfXAxis-1 do begin
      confidence(i,j) = n_elements(where(RBDF(*,i,j) LT bicoherenceMatrix(i,j)))/(0.+numOfSamples)
    endfor
  endfor
  return, confidence
end