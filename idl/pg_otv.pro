;+
; Name: pg_otv
;
; Written by: Sandor Zoletnik ?
; Rewritten by: Gergo Pokol (pokol@reak.bme.hu) 2007.02.23.
;
; Purpose: Plot array as bitmap (after shrinking with cubic reasmpling)
;
; Calling sequence:
;	pg_otv,q [,/original] [,/nearest]
;
; Inputs:
;		q: Array to be plotted
;		/original (optional): Plot original size
;		/nearest (optional): Use nearest neibourghood resampling
;-

pro pg_otv,q,original=original,nearest=nearest

; Set defaults
original=keyword_set(original)
nearest=keyword_set(nearest)
qsize=size(q)
true=qsize(0) EQ 3
psdim=[600,600]

if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	px=!x.window*!d.x_vsize
	py=!y.window*!d.y_vsize
	sx=px(1)-px(0)-1
	sy=py(1)-py(0)-1
	tv,congrid(q,sx,sy),px(0)+1,py(0)+1,true=true
endif

if (!d.name eq 'PS') then begin
	px=!x.window
	py=!y.window
	if original then begin
		tv,q,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal,true=true
	endif else begin
		sx=(size(q))(1)<psdim(0)
		sy=(size(q))(2)<psdim(1)
		if nearest then tv,congrid(q,sx,sy),px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal,true=true $
			else tv,congrid(q,sx,sy,/center,cubic=-0.5),px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal,true=true
	endelse
endif

end
