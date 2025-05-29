;+
;NAME: nti_wavelet_plot_3d
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2015.06.03.
;
; PURPOSE: Visualize non-negative 3D data fields, the matrix dimensions being plotted as x and y axis and color hue. 
; At each grid point the "strongest" data (with highest matrix value) is displayed with the appropriate (inverse) color lightness.
; One example is a set of mode numbers on the time-frequency plane with the confidence value also plotted.
;
; CALLING SEQUENCE:
;	nti_wavelet_plot_3d, matrix [,xrange] [,yrange] [,y2range] [,wrange] [,zrange] [,data] [,xtitle] [,ytitle] $
;		[,y2title] [,title] [,cscale_hue_title] [,cscale_lightness_title] [,/ylog] [,/poster]
;
; INPUTS:
;	matrix: vector of 2D matrixes to be visualized
; field_titles (optional): Titles of the data fields
;	xrange (optional): Range of x axis; default: matrix x-dimension
;	yrange (optional): Range of y axis; default: matrix y-dimension
;	y2range (optional): Range of 2nd y axis; default: no 2nd axis
; wrange (optional): Range of color hue axis; default: matrix w-dimension
;	zrange (optional): Range of color lightness axis; default: matrix value range
;	data (optional): Extra data to be written on graph
;	ridge (optional): Plot ridge (1D vector) on graph
;	xtitle (optional): Title of x axis
;	ytitle (optional): Title of y axis
;	y2title (optional): Title of 2nd y axis
;	title (optional): Title of the plot
; cscale_hue_title: (optional): Axis-title of the hue axis of colorscale
; cscale_lightness_title: (optional): Axis-title of the lightness axis of colorscale
; /ylog (optional): Logarithmic 1st y axis
;	/poster (optional): Print in poster form
;
; OUTPUT: -
;
;-

pro nti_wavelet_plot_3d, matrix, xrange=xrange, yrange=yrange, y2range=y2range, wrange=wrange, zrange=zrange,$
	data=data, ridge=ridge, xtitle=xtitle, ytitle=ytitle, y2title=y2title, title=title, scale_hue_title=scale_hue_title,$
	cscale_lightness_title=cscale_lightness_title, ylog=ylog, poster=poster

; Set defaults
psdim=[600,600] ;Set resolution for plotting to ps file
msize=size(matrix)
;stop
ylog=keyword_set(ylog)
poster=keyword_set(poster)
yax2=keyword_set(y2range)
if not(keyword_set(xrange)) then xrange=[0,msize[2]-1]
if not(keyword_set(yrange)) then yrange=[0,msize[3]-1]
if not(keyword_set(wrange)) then wrange=[0,msize[1]-1]
if not(keyword_set(zrange)) then zrange=[min(matrix),max(matrix)]
if not(keyword_set(data)) then data=''
if not(keyword_set(xtitle)) then xtitle=''
if not(keyword_set(ytitle)) then ytitle=''
if not(keyword_set(title)) then title=''
if not(keyword_set(cscale_hue_title)) then cscale_hue_title='!3Value' else cscale_hue_title = '!3' + cscale_hue_title
if not(keyword_set(cscale_lightness_title)) then cscale_lightness_title='!3Magnitude' else cscale_lightness_title = '!3' + cscale_lightness_title

; Measure screen, set resolution for the image plotted
if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	!x.margin=[0,0]
	!y.margin=[0,0]
	plot,xrange,yrange,/nodata,xstyle=1,ystyle=1
	px=!d.x_vsize
	py=!d.y_vsize
endif else begin
	px=psdim(0)
  py=psdim(1)	
endelse
pic_size_x = min([msize[2],px])
pic_size_y = min([msize[3],py])
print,'Image size: '+pg_num2str(pic_size_x)+'x'+pg_num2str(pic_size_y)

; Apply zrange
zrangest=zrange
matrix2=zrange[0] > matrix < zrange[1]

; Build image
saturation=fltarr(msize[2],msize[3])+1 ;Set maximum saturation for each point
resized_saturation = congrid(saturation,pic_size_x,pic_size_y) ;Resize saturation prior to plotting

;Select hue value based on location of "strongest" data
hue=fltarr(msize[2],msize[3])
lightness=fltarr(msize[2],msize[3])
for i=0,msize[2]-1 do begin
  for j=0,msize[3]-1 do begin
    lightness(i,j)=max(reform(matrix(*,i,j)),w_max,dimension=1) ;Select "strongest" data (with highest matrix value) at each x-y grid point, store location in w_max
;stop
    hue(i,j)=max(float(w_max)) ; Set hue based on location of "strongest" data in a safe way
; max felesleges. w_max egy skalár
  endfor
endfor
hue=hue/float(wrange(1)-wrange(0)+1)*300. ;Normalize hue to fit well within the 360 scale
resized_hue = congrid(hue,pic_size_x,pic_size_y) ;Resize hue prior to plotting
lightness=1-lightness/max(lightness) ;Normalize lightness
lightness=lightness*0.9 ;Reduce maximal lightness value
resized_lightness = congrid(lightness,pic_size_x,pic_size_y) ;Resize lightness prior to plotting
image_hls=fltarr(3,pic_size_x,pic_size_y) ;Produce HLS image
image_hls(0,*,*)=resized_hue
image_hls(1,*,*)=resized_lightness
image_hls(2,*,*)=resized_saturation
image_rgb = fltarr(3,pic_size_x,pic_size_y) ; Create array for RGB image
color_convert,image_hls,image_rgb,/HLS_RGB ;Convert image to RGB

; Set system variables for image plotting
!x.range=xrange
!x.ticklen=-0.01
!x.thick=2.
!x.title=xtitle
!y.range=yrange
!y.ticklen=-0.01
!y.thick=2.
!y.title=ytitle
!p.title=title
!p.thick=2
!P.NOERASE=0
if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	!x.margin=[10,px/7/5]
	!y.margin=[5,3]
endif
if (!d.name eq 'PS') then begin
	!P.FONT=0
	!x.margin=[10,30]
	!y.margin=[5,4]
	if poster then begin
	  !x.margin=[10,23]
	  !y.margin=[5,4]
	endif
endif
if (!d.name eq 'PS' and poster) then begin
	device, font_size=14
	!X.THICK=3.5
	!Y.THICK=3.5
endif

; Plot axes
if NOT yax2 then begin
  plot,xrange,yrange,/nodata,xstyle=1,ystyle=1,ylog=ylog
endif
if yax2 then begin ; Plot 2nd y-axis
  plot,xrange,yrange,/nodata,xstyle=1,ystyle=9,ylog=ylog
  axis,yaxis=1,ystyle=1,yrange=y2range,ytitle=y2title,ylog=0
endif

; Plot image_rgb as bitmap
pg_otv,image_rgb,/original

; Plot ridge if needed
if nti_wavelet_defined(ridge) then begin
  xaxis = (findgen(n_elements(ridge))/(n_elements(ridge)-1)*(xrange(1)-xrange(0))) + xrange(0)
  oplot, xaxis, ridge, color = 0
endif

if (!d.name eq 'PS' and poster) then begin
	!P.THICK=1
	device, font_size=11
endif

;Build color scale
n=2000.
saturation=fltarr(msize[1],n)+1 ;Set maximum saturation for each point
hue=(findgen(msize[1]))/(msize[1]-1)#(fltarr(n)+1)*300. ;Produce hue matrix
;stop
lightness = (fltarr(msize[1],n))
for i=0, msize[1]-1 do lightness(i,*) = reverse(findgen(n))/n
;stop
;lightness=(findgen(msize[1]))/(msize[1]-1)#(fltarr(100)+1) ;Produce lightness matrix
;stop
cscale_hls=fltarr(3,msize[1],n)

cscale_hls(0,*,*)=hue
cscale_hls(1,*,*)=lightness
cscale_hls(2,*,*)=saturation

color_convert,cscale_hls,cscale_rgb,/HLS_RGB
;stop
; Set system variables for color scale plotting
!x.range=[wrange(0),wrange(1)]
!x.ticklen=0
!x.title=cscale_hue_title
!y.range=[zrange(0),zrange(1)]
!y.title=cscale_lightness_title
!p.title='Color scale'
!P.NOERASE=1
if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	!x.margin=[px/7/5*4.85+max([10,px/7/10]),10]
	!y.margin=[py/10/2,10]
endif
if (!d.name eq 'PS') then begin
	!x.margin=[57,7]
	!y.margin=[30,5]
	if poster then begin
	  !x.margin=[100,2]
	  !y.margin=[18,6]
	endif
endif

; Plot color scale axes
plot,wrange,zrange,/nodata,xstyle=1,ystyle=1

; Plot color cscale as bitmap
pg_otv,cscale_rgb,/original

; Set font size for data writing
if (!d.name eq 'PS' and poster) then begin
  device, font_size=8
endif

; Write data
xyouts, 0.82,0.30, data, /normal, charsize = 0.6, charthick = 1


; Set default system variables
!x.range=[0,0]
!x.ticklen=0
!x.thick=1.
!x.title=''
!x.margin=[10,3]
!x.tickname=''
!y.range=[0,0]
!y.ticklen=0
!y.thick=1.
!y.title=''
!y.margin=[4,2]
!p.title=''
!P.NOERASE=0
!P.CHARSIZE=1.0
!P.THICK=1.
!P.FONT=-1
!P.CHARTHICK=1.

pg_initgraph
end
