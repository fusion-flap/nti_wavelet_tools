;********************************************************************************************************
; Name: ELM0plotBicoherence.pro
;
; PURPOSE
; =======
; This program plots bicoherence like matrices (eg.: average bicoherence, minimum bicoherence, significance etc.)
;
; USAGE
; =======
; significanceMatrix=calculateSignificance(RBDF,bicoherenceMatrix)
;
; INPUTS
; =======
; bicoherenceMatrix:          bicoherence matrix (2D)
; plotParameters:             structure containing parameters of plotting, and signal
;                             parameters
; 
; OUTPUT
; =======
;********************************************************************************************************

;Support routines
;Revert colortable
pro reverse_CT
  tvlct, r,g,b, /get
  tvlct, reverse(r),reverse(g),reverse(b)
end
;*************************

;Generate frequency axis
function createFreqAxis, freqNiquist, singleBlockSize
  freqAxis = dindgen(singleBlockSize/2)/(singleBlockSize/2-1)*freqNiquist
  return, freqAxis
end
;*************************

;Create plot text
function createPlotText, plotParameters
  xy_date='Date'
  xy_blocksize='Blocksize'
  xy_blockn='Blockn'
  xy_program='Program'
  xy_shotnumber='Shotnumber'
  xy_channelname='Channelname'
  xy_timerange='Time range'
  xy_freqres='Frequency resolution'
  plotText =$
    xy_date+': '+plotParameters.date+$
    '!C'+xy_blocksize+': '+string(plotParameters.blockSize)+'    '+$
    xy_blockn+': '+strtrim(string(plotParameters.blockNumber),2)+$
    '!C'+xy_shotnumber+': '+strtrim(string(plotParameters.shotnumber),2)+$
    '!C'+xy_channelname+': '+plotParameters.channelName+$
    '!C'+xy_timerange+': '+'['+strtrim(string(plotParameters.timeRange[0]),2)+$
    ', '+strtrim(string(plotParameters.timeRange[1]),2)+' ]s'+$
    '!C'+xy_freqres+' : '+strtrim(string(plotParameters.niqFrequency/plotParameters.blockSize),2)+' kHz'
  return, plotText
end
;*************************

;Cut matrix to obtain the inner triangle
function cutMatrix, matrix, freqAxis, maxFreq
  maxFreqIndex = max(where(freqAxis le maxFreq))
  axisLength = n_elements(matrix(0,*))

  returnMatrix = matrix

  for i=0, axisLength-1 do begin
    for j=0, i-1 do begin ;??
      returnMatrix(j,i)=0
      returnMatrix(axisLength-1-j,i)=0
    endfor
  endfor

  returnMatrix = reform(returnMatrix(0:maxFreqIndex-1,*))
  if maxFreq lt max(freqAxis)/2. then begin
    yCutFreqIndex = maxFreqIndex
  endif else begin
    yCutFreqIndex = axisLength/2
  endelse
  returnMatrix = reform(returnMatrix(*,0:yCutFreqIndex))
  return, returnMatrix
end
;*************************

;Search for startpath of plotBicoherence.pro
function whereIsStartpath
  routineStartpath=routine_filepath()
  startpath=strmid(routinestartpath,0,strpos(routinestartpath,'plotBicoherence.pro'))
  return, startpath
end
;*************************

;Generate optimized colorscale
function optimizeColorScale, array, opt
  return_array = array^opt
  return, return_array
end
;********************************************************************************************************

pro ELM0plotBicoherence, bicoherenceMatrix, plotParameters

  freqAxis = createFreqAxis(plotParameters.niqFrequency,plotParameters.blockSize)
  bicoherenceMatrix2Plot = cutMatrix(bicoherenceMatrix,freqAxis,plotParameters.maxFrequency)
  
  startpath = whereIsStartpath()
  path2plot=startpath+'/figs/' + strjoin(strtrim(string((bin_date(plotParameters.date))[0:2]),2),'-') + '/'
  file_mkdir,path2plot
  
  plotName=plotParameters.fileID+$
    '_'+strtrim(string(plotParameters.shotnumber),2)+$
    '_'+plotParameters.type+'.eps'
  
  !P.FONT = 0
  pg_initgraph,/print
  device,bits_per_pixel=8,font_size=8,/portrait,/color,/encapsulated,/bold,/cmyk,/preview
  device, filename=path2plot+plotName

    ;plot matrix axes
    loadct,5
    if plotParameters.maxFrequency lt plotParameters.niqFrequency/2. then begin
      yMaxFrequency = plotParameters.maxFrequency
    endif else begin
      yMaxFrequency = plotParameters.niqFrequency/2
    endelse
    plot,[min(freqAxis),plotParameters.maxFrequency],[min(freqAxis),yMaxFrequency],/ISOTROPIC,$
      xmargin=[10.5,4.5],ymargin=[10,3],$
      xstyle=1,ystyle=1,xticklen=-0.03,yticklen=-0.03,xthick=3,ythick=3,$
      charsize=2,charthick=3,$
      title=plotParameters.type+' at '+plotParameters.expName,xtitle='Frequency1 [kHz]',ytitle='Frequency2 [kHz]',$
      /nodata

    ;plot bicoherence matrix
    loadct,5
    reverse_CT
    px=!x.window
    py=!y.window
    tv,255*optimizeColorScale(bicoherenceMatrix2Plot,plotParameters.optScale),$
      px(0),py(0),xsize=1.0*(px(1)-px(0)),ysize=1.0*(py(1)-py(0)),/normal
    
    ;plot border for matrix
    loadct,5
    oplot,freqAxis,freqAxis
    oplot,freqAxis,-freqAxis+max(freqAxis)

    ;initialize color scale
    cscale=fltarr(256,2)
    cscale[*,0]=findgen(256)
    cscale[*,1]=findgen(256)
    axis=cscale[*,0]/255
    
    ;plot axes of color scale
    loadct,5
    plot,[0,1],axis,$
      xmargin=[14,51],ymargin=[5,34],$
      xrange=[min(axis),max(axis)],yrange=[0,1],$
      xstyle=1,ystyle=1,yticklen=0,xthick=3,ythick=3,$
      ytickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '],$
      title='Colorscale',xtitle=plotParameters.type,ytitle='',$
      charsize=1.3,charthick=2,$
      /nodata,$
      NOERASE=1

    ;plot color scale
    loadct,5
    reverse_CT
    px=!x.window
    py=!y.window
    tv,255*optimizeColorScale(cscale/255.,plotParameters.optScale),$
      px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal
    
    loadct,5
    plotText = createPlotText(plotParameters)
    xyouts,0.62,0.19,plotText,/normal,charsize=1.2,charthick=1.8
  device, /close
  pg_initgraph
end
