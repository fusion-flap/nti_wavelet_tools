;+
;NAME: pg_plot4
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2004.12.07.
;
; PURPOSE: Visualize a 2D matrix
;
; CALLING SEQUENCE:
;	pg_plot4, matrix [,ct] [,xrange] [,yrange] [,y2range] [,zrange] [,/intz] [,data] [,xtitle] [,ytitle] $
;		[,y2title] [,title] [,cscale_axis_title] [,opt] [,/ylog] [,/zlog] [,/original] [,/nearest] [,/poster]
;
; INPUTS:
;	matrix: 2D matrix to be visualized
;	ct (optional): Color table index (Built-in color tables)
;	xrange (optional): Range of x axis; default: matrix x-dimension
;	yrange (optional): Range of y axis; default: matrix y-dimension
;	y2range (optional): Range of 2nd y axis; default: no 2nd axis
;	zrange (optional): Range of colorscale; default: matrix value range
;	data (optional): Extra data to be written on graph
;	ridge (optional): Plot ridge (1D vector) on graph
;	xtitle (optional): Title of x axis
;	ytitle (optional): Title of y axis
;	y2title (optional): Title of 2nd y axis
;	title (optional): Title of the plot
; cscale_axis_title: (optional): Axis-title of the colorscale
;	opt (optional): Exponent for opimized scale visualization
;	/ylog (optional): Logarithmic 1st y axis
;	/zlog (optional): Logarithmic color scale
;	/intz (optional): Plot discrete colorscale at integer values (and skip color code 255)
;	/original (optonal): Do not resize matrix
;	/nearest (optional): Use nearest neibourghood resampling
;	/poster (optional): Print in poster form
;
; OUTPUT: -
;
; MODIFICATION HISTORY:
;   Automatic resize of matrix in pg_otv (Gergo Pokol, 2007.02.23)
;-

pro pg_plot4, matrix, ct=ct, xrange=xrange, yrange=yrange, y2range=y2range, zrange=zrange, intz=intz,$
	data=data, ridge=ridge, xtitle=xtitle, ytitle=ytitle, y2title=y2title, title=title, cscale_axis_title=cscale_axis_title,$
	ylog=ylog, zlog=zlog,	opt=opt, original=original, nearest=nearest, poster=poster

; Set defaults
msize=size(matrix)
ylog=keyword_set(ylog)
zlog=keyword_set(zlog)
interp=keyword_set(interp)
poster=keyword_set(poster)
yax2=keyword_set(y2range)
intz=keyword_set(intz)
if not(keyword_set(xrange)) then xrange=[0,msize[1]-1]
if not(keyword_set(yrange)) then yrange=[0,msize[2]-1]
if not(keyword_set(zrange)) then zrange=[min(min(matrix)),max(max(matrix))]
if not(keyword_set(data)) then data=''
if not(keyword_set(xtitle)) then xtitle=''
if not(keyword_set(ytitle)) then ytitle=''
if not(keyword_set(title)) then title=''
if not(keyword_set(opt)) then opt=1
if not(keyword_set(cscale_axis_title)) then cscale_axis_title='!3Magnitude' else cscale_axis_title = '!3' + cscale_axis_title

; Measure screen
if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	!x.margin=[0,0]
	!y.margin=[0,0]
	plot,xrange,yrange,/nodata,xstyle=1,ystyle=1
	px=!d.x_vsize
	py=!d.y_vsize
endif

; Color scale
cscale=fltarr(2,256)
cscale[0,*]=findgen(256)/255
cscale[1,*]=findgen(256)/255

; Apply zrange
zrangest=zrange
matrix2=zrange[0] > matrix < zrange[1]
cscale=zrange[0]+cscale*(zrange[1]-zrange[0])
axis=cscale[0,*]

; Log scale
if zlog then begin
	matrix2=matrix2+zrange[0]+10.01
	cscale=cscale+zrange[0]+10.01
	matrix2=alog10(temporary(matrix2))
	cscale=alog10(temporary(cscale))
endif

; Optimized scale
matrix2=(temporary(matrix2))^opt
cscale=(temporary(cscale))^opt

; Norm matrix2
minm=min(min(cscale))
maxm=max(max(cscale))
matrix2=temporary(matrix2)-minm ; Set minimum to 0
matrix2=(temporary(matrix2)/(maxm-minm))*255 ; Scale maximum to 255
if intz then begin
  cscale=float(round(cscale))
  axis=float(round(axis))
  minm=min(min(cscale))
  maxm=max(max(cscale))
  cscale=temporary(cscale)-minm ; Set minimum to 0
  cscale=(temporary(cscale)/(maxm-minm))*254 ; Scale maximum to 254 (skip 255)
endif else begin
  cscale=temporary(cscale)-minm ; Set minimum to 0
  cscale=(temporary(cscale)/(maxm-minm))*254 ; Scale maximum to 254 (skip 255)
endelse

; Load color table
if keyword_set(ct) then loadct,ct

; Set system variables for matrix2
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


; Plot matrix2 as bitmap
pg_otv,matrix2,original=original,nearest=nearest
; Plot ridge if needed
if nti_wavelet_defined(ridge) then begin
  xaxis = (findgen(n_elements(ridge))/(n_elements(ridge)-1)*(xrange(1)-xrange(0))) + xrange(0)
  oplot, xaxis, ridge, color = 0
endif

if (!d.name eq 'PS' and poster) then begin
	!P.THICK=1
	device, font_size=11
endif

!x.range=[0,1]
!x.ticklen=0
!x.title=''
!x.tickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ']
!y.range=[min(axis),max(axis)]
!y.title=cscale_axis_title
!p.title='Color scale'
!P.NOERASE=1
if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	!x.margin=[px/7/5*4.85+max([10,px/7/10]),10]
	!y.margin=[py/10/2,10]
endif
if (!d.name eq 'PS') then begin
	!x.margin=[107,7]
	!y.margin=[30,5]
	if poster then begin
	  !x.margin=[77,5]
	  !y.margin=[18,6]
	endif
endif

; Plot axes
plot,axis,[0,1],/nodata,xstyle=1,ystyle=1

; Plot color scale as bitmap
nti_wavelet_otv,cscale,interp=(not intz)

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

end
