pro nti_wavelet_otv,q,interp=interp

if ((!d.name eq 'X') or (!d.name eq 'WIN')) then begin
	px=!x.window*!d.x_vsize
	py=!y.window*!d.y_vsize
	sx=px(1)-px(0)-1
	sy=py(1)-py(0)-1
	tv,congrid(q,sx,sy,interp=interp),px(0)+1,py(0)+1
endif 

if (!d.name eq 'PS') then begin
  px=!x.window
  py=!y.window
	if (keyword_set(interp)) then begin 
	  ;#########################################
	  sx=(size(q))(1)>200
	  sy=(size(q))(2)>300
	  ;unused lines
	  ;#########################################
    tv,congrid(q,300,300,interp=interp),px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal
	endif else begin
    tv,q,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal
	endelse	
endif	

end
