;+
; NAME:
; NTI_WAVELET_RIDGE_FOLLOWER
;
; PURPOSE:
; This procedure is following ridge in input matrix.
;
; CALLING SEQUENCE:
; NTI_WAVELET_RIDGE_FOLLOWER, matrix $
; [,xrange_index] [,xaxis] [,xrange_unit] $
; [,start_index_x] [,start_x] $
; [,start_index_y] [,yaxis] [,start_y] $
; [,bandwidth] [,index_bandwidth] $
; [,ridge_treshold] [,ridge_index] [,ridge_unit]
;
; INPUTS:
; matrix: 2 dimensional matrix which will be investigated
; xrange_index: indices of the investigated range on the x axis,
;       a two elements array (optional)
; xaxis:  x axis (optional)
; xrange_unit:  investigated range on the x axis in terms of the unit
;       of xaxis, a two elements array (optional)
; start_index_x:  the index of the point on the x axis where the finding
;       procedure starts. If this parameter is used, the ridge following
;       is performed in each directions (optional)
; start_x:  point on the x axis in terms of the unit of xaxis where the
;       finding procedure starts. If this parameter is used, the ridge
;       following is performed in each directions (optional)
; start_index_y:  the indices of the range on the y axis where the
;       finding procedure starts (optional)
; yaxis:  y axis (optional)
; start_y:  range on the y axis in terms of the unit of yaxis where
;       the finding procedure starts (optional)
; bandwidth:  ridge is serached between the twice of this bandwidth
;       in terms of the unit of yaxis (optional)
; index_bandwidth:  size of bandwidth in datapoints (optional)
; ridge_treshold: ridge follower stops if amplitude falls below
;       the saved peak value times this treshold (optional)
; noise:  ridge follower stops if amplitude falls below 
;       the given noise level (optional)
;
; OUTPUTS:
; ridge_index:  results in indices
; ridge_unit: results in terms of the unit of yaxis
;
; EXAMPLE:
;   restore, './AUGD_23824_Loaded-with-MTR_processed.sav'
;   ctrans = *saved_datablock.crosstransforms
;   matrix = reform(abs(ctrans(5,*,*)))
;   nti_wavelet_ridge_follower, matrix, xaxis = timeax, yaxis = freqax, $
;     xrange_unit = [1.28,1.3], start_index_y = [120,130], $
;     bandwidth = 5, ridge_index=ridge_index, ridge_unit=ridge_unit
;
;-

pro nti_wavelet_ridge_follower, $
  ;Inputs:
    matrix, $
  ;Optional inputs:
    xrange_index = xrange_index, xaxis = xaxis, xrange_unit = xrange_unit, $
    start_index_x = start_index_x, start_x = start_x, $
    start_index_y = start_index_y, yaxis = yaxis,  start_y = start_y, $
    bandwidth = bandwidth, index_bandwidth = index_bandwidth, $
    ridge_treshold = ridge_treshold, noise = noise, $
  ;Outputs:
    ridge_index = ridge_index, ridge_unit = ridge_unit

;Setting defaults
;----------------
; (if parameters are in the unit of the given axes, it is required
; to calculate the equivalent indices)

  ; Starting parameters of x axis:
  if nti_wavelet_defined(xaxis) then begin
    if nti_wavelet_defined(xrange_unit) then begin
      xrange_index = $
        [where( min(xaxis - xrange_unit(0), /abs) eq (xaxis - xrange_unit(0)) ), $
        where( min(xaxis - xrange_unit(1), /abs) eq (xaxis - xrange_unit(1)) )]
    endif else begin
      nti_wavelet_default, xrange_index, [0, (size(matrix))(1)-1]
    endelse
    if nti_wavelet_defined(start_x) then begin
      start_index_x = (where( min(xaxis - start_x, /abs) eq (xaxis - start_x) ))(0)
    endif
  endif else begin
    nti_wavelet_default, xrange_index, [0, (size(matrix))(1)-1]
  endelse

  ; Starting parameters of y axis:
  if nti_wavelet_defined(yaxis) then begin
    if nti_wavelet_defined(start_y) then begin
      start_index_y = $
        [where( min(yaxis - start_y(0), /abs) eq (yaxis - start_y(0)) ), $
        where( min(yaxis - start_y(1), /abs) eq (yaxis - start_y(1)) )]
    endif else begin
     nti_wavelet_default, start_index_y, [0, (size(matrix))(2) - 1]
    endelse
  endif else begin
    nti_wavelet_default, start_index_y, [0, (size(matrix))(2) - 1]
  endelse
  
  ; Bandwidth:
  if nti_wavelet_defined(bandwidth) then begin
    dy =  (yaxis(n_elements(yaxis) - 1) - yaxis(0))/(n_elements(yaxis) - 1)
    index_bandwidth = round(bandwidth/dy)
  endif else begin
    nti_wavelet_default, index_bandwidth, floor(start_index_y(1) - start_index_y(1))
  endelse
  
  ; Others:
  nti_wavelet_default, ridge_treshold, 0
  
;Finding ridge
;-------------

  ; Create vector to conain indices of ridge:
  ridge_index = dblarr(long(n_elements(matrix(*,0))))

  ; Define variables containg the index of ridge in two neighboring time instances:
  y1 = long(0)
  y2 = long(0)

  ; Define start point on the x axis:
  if nti_wavelet_defined(start_index_x) then begin
    startpoint = start_index_x
  endif else begin
    startpoint = xrange_index(0)
  endelse
  
  ; Find starting point on the y axis:
  y1 = (where(matrix(startpoint, start_index_y(0):start_index_y(1)) eq $
    max(matrix(startpoint, start_index_y(0):start_index_y(1)))))(0)
  y1 = start_index_y(0) + y1
  
  ; Set initial parameter of loop variable:
  i = long(startpoint)
  ; Initialize indicator of continuing:
  cont = 1
  ; Define variable to store maximum amplitude:
  peak = 0.
  ; Define variable to store treshold amplitude:
  if nti_wavelet_defined(noise) then begin
    peak_treshold = noise
  endif else begin
    peak_treshold = 0.
  endelse
  ; Define the direction of the searching (right = 1, left = -1):
  direction = 1

  ; Start finding maximum in each time instance:
  while cont do begin
  ; If cont parameter is true the ridge following algorith continues normally:
  ; Calculate the maximum value in the neighboring point:
    y2 = (where(matrix(i, (y1 - index_bandwidth):(y1 + index_bandwidth)) eq $
      max(matrix(i, (y1 - index_bandwidth):(y1 + index_bandwidth)))))(0)
    y2 = y1 - index_bandwidth + y2
    ; Save current point to ridge_index variable:
    ridge_index(i) = y2
    ; Shift variables:
    y1 = y2
    y2 = 0
    
    ; Save value of the current peak (save only if value is higher then before):
    if not nti_wavelet_defined(noise) then begin
      if (matrix(i, ridge_index(i)) gt peak) then begin
        peak = matrix(i, ridge_index(i))
        peak_treshold = ridge_treshold*peak
      endif
    endif
    
    ; If ampltiude falls below the saved peak_treshold parameter or
    ; reach the limits of the investigated range, the search is stopped:
    if direction eq 1 then begin
      if ((matrix(i, ridge_index(i)) lt peak_treshold) or $
        (i ge xrange_index(1))) then begin
        ; If start_index_x is defined (which means searching in both directions
        ; is required) and the current direction is 1 (right), 
        ; the searching continues in the direction -1 (left):
        if (nti_wavelet_defined(start_index_x) and (direction eq 1)) then begin
          cont = 1
          direction = -1
          ; Loop variable is set to the starting point:
          y1 = ridge_index(startpoint)
          i = startpoint
        endif else begin
          cont = 0
        endelse
      endif
    endif else begin
      if ((matrix(i, ridge_index(i)) lt peak_treshold) or $
        (i le xrange_index(0))) then begin
        ; Stop searching:
        cont = 0
      endif
    endelse

    ; New step of loop variable:
    i = i + direction

  endwhile

; Calculate ridge in term of yaxis:
if nti_wavelet_defined(yaxis) then begin
  ridge_unit = yaxis(ridge_index)
endif

end