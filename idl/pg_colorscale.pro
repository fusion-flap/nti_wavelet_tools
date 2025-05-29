;+
; Name: pg_colorscale
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.12.04.
;
; Purpose: Plot colorscale
;
; Calling sequence:
;	pg_colorscale [,range] [,/print] [,/ct]
;
; Input:
;	range (optional): range of scale
;	ct (optional): Color table index (Built-in color tables)
;	/print (optional): Produce ps files
;
; Output: -
;-

pro pg_colorscale, range=range, print=print, ct=ct


; Set defaults, constants
print=keyword_set(print)
if not(keyword_set(ct)) then ct=5
if not(keyword_set(range)) then range=[0,1]

; Initialize graphics
pg_initgraph,print=print

axis=fltarr(2,256)
axis[0,*]=findgen(256)/255
axis[1,*]=findgen(256)/255
title='Color scale'
if print then device,filename=pg_filename(title) else window,/free

; Load color table
loadct,ct

; Set system variables
!x.range=[range[0],range[1]]
!x.ticklen=-0
!x.title=''
!x.margin=[10,3]
!y.range=[min(axis),max(axis)]
!y.ticklen=-0.01
!y.title='Magnitude'
!y.margin=[5,3]
!p.title=title

; Plot axes
plot,axis,[0,1],/nodata,xstyle=1,ystyle=1

; Plot matrix as bitmap
nti_wavelet_otv,axis*255,/interp

; Set default system variables
!x.range=[0,0]
!x.ticklen=0
!x.title=''
!x.margin=[10,3]
!y.range=[0,0]
!y.ticklen=0
!y.title=''
!y.margin=[4,2]
!p.title=''

if print then device,/close

end

