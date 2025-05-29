function filterConfidence, bicoherenceMatrix, confidenceMatrix, critConfLevel
  
  filteredBicohMatrix = bicoherenceMatrix
  for i=0, n_elements(bicoherenceMatrix(*,0))-1 do begin
    for j=0, n_elements(bicoherenceMatrix(0,*))-1 do begin
      if confidenceMatrix(i,j) LT critConfLevel then begin
        filteredBicohMatrix(i,j) = 0
      endif
    endfor
  endfor

  return, filteredBicohMatrix
end