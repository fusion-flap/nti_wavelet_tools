;+
; NAME:
; NTI_WAVELET_PLOT_1D
;
; PURPOSE:
; This procedure is plotting one dimensional data into file.
;
; CALLING SEQUENCE:
; NTI_WAVELET_PLOT_1D, xaxis, data, $
;   [,error] $
;   [,xdouble] [,ydouble], [,edouble] $
;   [,xrange] [,yrange] $
;   [,title] [,xtitle] [,ytitle] $
;   [,psym] [,xtickname] $
;   [,name] [,info] [,legend] [,path]
;
; INPUTS:
; xaxis:    x axis of plotted data.
; data:     Input data array. The dimensions of the data array must be [i, j] where
;           i is the number of data vectors and j equals to the length of xaxis.
;           The routine automatically plot all data vectors in different colors.
; error (optional):     error has the same dimensions as data and values are plotted
;                       on graph as error bars.
; errstyle (optional):  if errstyle equals to 1 the errorbar is plotted with 
;                       dashed line. (only if xdouble is not defined)
; xdouble (optional):   xdouble is the x axis of an additional data array. These
;                       curves plotted on the graph in the same color as data, but
;                       with dashed lines.
; ydouble (optional):   ydouble is the array of the additional data. These curves
;                       plotted on the graph in the same color as data, but with
;                       dashed lines.
; edouble(optional):    edouble constains the error of the additional data which is
;                       plotted on graph as error bars. These curves plotted on the
;                       graph in the same color as data, but with dashed lines.
; xrange(optional):     Range of x axis. The behaviour and the default value is the
;                       same as in the IDL built-in PLOT function.
; yrange (optional):    Range of y axis. The behaviour and the default value is the
;                       same as in the IDL built-in PLOT function.
; title (optional):     Title of the plot. The behaviour and the default value is
;                       the same as in the IDL built-in PLOT function.
; xtitle (optional):    Title of x axis. The behaviour and the default value is the
;                       same as in the IDL built-in PLOT function.
; ytitle (optional):    Title of y axis. The behaviour and the default value is the
;                       same as in the IDL built-in PLOT function.
; psym (optional):      The symbol used to mark each data point. The behaviour and
;                       the default value is the same as in the IDL built-in
;                       PLOT function.
; xtickname (optional): A string array of up to 30 elements that controls the
;                       annotation of each tick mark. The behaviour is the same
;                       as in the IDL built-in PLOT function.
; name (optional):      The filename of the output.
; info (optional):      A string which is printed out next to the graph.
; legend (optional):    It places a legend on the graph. The type of this parameter
;                       must be a string array which contains short description of
;                       each data vector.
; path (optional):      Path can be given where output files will be saved
;                       (default: ./save_data)
;
;-

pro nti_wavelet_plot_1d, $
  xaxis, data, $
  error = error, errstyle = errstyle, $
  xdouble = xdouble, ydouble = ydouble, edouble = edouble, $
  xrange = xrange, yrange = yrange, $
  title = title, xtitle = xtitle, ytitle = ytitle, $
  psym = psym, xtickname = xtickname, $
  name = name, info = info, legend = legend, path = path
  
;Calculate number of vectors
;---------------------------
numofvec = n_elements(data(*,0))

;Setting defaults
;----------------
nti_wavelet_default, xaxis, findgen(n_elements(data(0,*)))
nti_wavelet_default, name, '1D_plot'
nti_wavelet_default, info, ''
nti_wavelet_default, legend, pg_num2str(findgen(numofvec), length = 1)
nti_wavelet_default, path, './save_data/'
if nti_wavelet_defined(xdouble) then begin
  errstyle = 0
endif else begin
  nti_wavelet_default, errstyle, 0
endelse

;Setting path and name
;---------------------
date = systime()
file_mkdir, path

;Setting printing parameters
;---------------------------
colors = {value:intarr(8), name:strarr(8)}
colors.value = [0, 255, 64, 160, 208, 228, 25, 112]
colors.name = ['black', 'red', 'blue', 'green', 'yellow', 'orange', 'purple', 'cyan']

pg_initgraph, /print
loadct, 13
!P.FONT=0
device, bits_per_pixel = 8, font_size = 8, /portrait, /color, /cmyk
device, filename = pg_filename(name, dir = path, ext = '.ps')

;Printing
;--------

; Plot first data vector:
plot, xaxis, data(0,*), xrange = xrange, yrange = yrange, color = colors.value(0), $
  title = title, xtitle = xtitle, ytitle = ytitle, psym = psym, xtickname = xtickname, $
  thick = 2, charsize = 2, xthick = 3, ythick = 3, charthick = 3, $
  xstyle = 1, ystyle = 1, xmargin = [10,16], ymargin = [5,3]
; Plot error bars on first data vector (if set):
if nti_wavelet_defined(error) then begin
  if not errstyle then begin
    errplot, xaxis, data(0,*) - error(0,*), data(0,*) + error(0,*), $
      color = colors.value(0)
  endif else begin
    oplot, xaxis, data(0,*) - error(0,*), color = colors.value(0), /linestyle
    oplot, xaxis, data(0,*) + error(0,*), color = colors.value(0), /linestyle
  endelse
endif
; Plot first vector of additional data (if set):
if nti_wavelet_defined(xdouble) then begin
  oplot, xdouble, ydouble(0,*), color = colors.value(0), /linestyle, psym = psym
  ; Plot error bars on first vector of additional data (if set):
  if nti_wavelet_defined(edouble) then begin
    errplot, xdouble, ydouble(0,*) - edouble(0,*), ydouble(0,*) + edouble(0,*), $
      color = colors.value(0)
  endif
endif
; Plot further data vectors:
for i = 1,numofvec-1 do begin
  oplot, xaxis, data(i,*), thick = 2, color = colors.value(i mod 8), psym = psym
  ; Plot error bars on further data vectors (if set):
  if nti_wavelet_defined(error) then begin
    if not errstyle then begin
      errplot, xaxis, data(i,*) - error(i,*), data(i,*) + error(i,*), $
        color = colors.value(i mod 8)
    endif else begin
      oplot, xaxis, data(i,*) - error(i,*), color = colors.value(i mod 8), /linestyle
      oplot, xaxis, data(i,*) + error(i,*), color = colors.value(i mod 8), /linestyle
    endelse
  endif
  ; Plot further vectors of additional data (if set):
  if nti_wavelet_defined(xdouble) then begin
    oplot, xdouble, ydouble(i,*), color = colors.value(i mod 8), /linestyle, $
      psym = psym
    ; Plot error bars on further vectors of additional data (if set):
    if nti_wavelet_defined(edouble) then begin
      errplot, xdouble, ydouble(i,*) - edouble(i,*), ydouble(i,*) + edouble(i,*), $
        color = colors.value(i)
    endif
  endif
endfor

;Plot xyouts:
xyouts, 0.83, 0.10, date + '!C' + info, /normal, orientation = 90, $
  charsize = 1.4, charthick = 1.8

;Plot legends:
xylegend = legend(0) + ': ' + colors.name(0)
for i = 1,numofvec-1 do begin
  xylegend = xylegend + '!C' + legend(i) + ': ' + colors.name(i mod 8)
endfor
xyouts, 0.78, 0.80, xylegend, /normal, orientation = 0, $
  charsize = 1.4, charthick = 1.8

;Restore printing parameters:
device, /close
!P.FONT = -1
pg_initgraph

end
