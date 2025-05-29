;+
;
; NAME:
;	NTI_WAVELET_GRIDDATA
;
; PURPOSE:
;	This function interpolates irregulary grided data values to a regular grid using
;	nearest neighbor interpolation method. The function can be used when
;	x axis is regular and y axis is irregular. Y axis must be monoton.
;	The start and the end point of the regular and irrgular y axes will be the same.
;
; CALLING SEQUENCE:
;	NTI_WAVELET_GRIDDATA, matrix, xaxis, yaxis, resolution
;
; INPUTS:
;	matrix: 2D matrix to be interpolated
;	xaxis: Regular x axis of the matrix
;	yaxis: Irregular y axis of the matrix
;	resolution: The number of datapints in the new, regular y axis
;
;-

function nti_wavelet_griddata, matrix, xaxis, yaxis, resolution

;Initializing time, to measure the running time of the function
time =  systime(1)

;Initializing the length of the axes
xaxislength = n_elements(xaxis)
yaxislength = n_elements(yaxis)

newyaxis = findgen(resolution)
newyaxis = newyaxis/max(newyaxis)               
newyaxis = newyaxis*(max(yaxis)-min(yaxis))+min(yaxis)

grid = fltarr(xaxislength, resolution)

;Interpolate data using nearest neighbor interpolation method
for i = 0,xaxislength-1 do begin
  for j=0,long(resolution-1) do begin
    grid(i,j) = matrix(i,(where(yaxis-newyaxis(j) EQ min(yaxis-newyaxis(j), /ABSOLUTE))))
  endfor
end

;Print the running time of the program
print, 'Running time: ',  systime(1)-time

;Return result
return, grid


end