;+
; Name: pg_gen_win
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2002.07.15.
; Rewritten by: Gergo Pokol (pokol@reak.bme.hu) 2003.03.24
;
; Purpose: Return window of specified shape and length and unit norm.
;
; Calling sequence:
;	win = pg_gen_win( windowsize [,masksize] [,windowname] [,/plot] [,/print] [,/double] )
;
; Inputs:
;	windowsize: length of window (standard deviation *2 for Gauss window)
;	masksize (optional): length of mask vector for infinit support windows; default: all nonzero values
;	windowname (optional): shape of the window (available: 'Gauss','Rectangle','Hanning','Hamming','Burst'); default: 'Gauss'
;	/double (optional): double precision
;	/plot (optional): Plot window
;
; Output:
;	win: 1D vector of non-zero coefficients of the uniformly sampled window function
;
; Modified:
;	Gergo Pokol 2003.12.16. : Correct masksize for Gauss window
;	Gergo Pokol 2004.02.11. : Modify to L2 norm
;-


function pg_gen_win, windowsize, masksize=masksize, windowname=windowname, $
	double=double, plot=plot, print=print

compile_opt defint32 ; 32 bit integers

; Set defaults
double=keyword_set(double)
plot=keyword_set(plot)
print=keyword_set(print)
if not(keyword_set(masksize)) then masksize=windowsize*40
if not(keyword_set(windowname)) then windowname='Gauss'

; Generate grid, initialize win
if (double) then begin
	win=dblarr(masksize)
	x=dindgen(masksize)-(masksize-1)/2d
	windowsize=double(windowsize)
endif else begin
	win=fltarr(masksize)
	x=findgen(masksize)-(masksize-1)/2.
endelse

; Generate window
if windowname EQ 'Gauss' then begin
	win=exp(-(x^2)/(2*(windowsize/2.)^2))
	m=min(abs(((masksize-1)/2.)-(where(ceil(win)-1)>0)))
	win=win[((masksize-1)/2.)-m:((masksize-1)/2.)+m]
;	win=win[(masksize/2)-m+lindgen(2*m)]
endif
if windowname EQ 'Rectangle' then begin
	win[0:windowsize]=1
	win=win[where(win)]
endif
if windowname EQ 'Hanning' then begin
	win[0:windowsize]=HANNING(windowsize+1)
	win=win[where(win)]
endif
if windowname EQ 'Hamming' then begin
	win[0:windowsize]=HANNING(windowsize+1,alpha=0.54)
	win=win[where(win)]
endif
if windowname EQ 'Burst' then begin
;	win[0:windowsize-1]=(2^(reverse(findgen(windowsize)/(windowsize-1)*96.730024)*0.1)- $
;		0.035*2^(reverse(findgen(windowsize)/(windowsize-1)*96.730024)*0.15))/121
	win[masksize-windowsize:masksize-1]=(2^(reverse(findgen(windowsize)/(windowsize-1)*96.730024)*0.1)- $
		0.035*2^(reverse(findgen(windowsize)/(windowsize-1)*96.730024)*0.15))/121
	center=where(win EQ max(win))
	center=center[0]
	m=masksize-1-center
	win=win[center-m:center+m]
;	win=win[where(win)]
endif


; Norm window
win=win/norm(win)

; Plot window
if plot then begin
	pg_initgraph,print=print
	title=windowname+' window of length '+nti_wavelet_i2str(windowsize)
	if print then device,filename=pg_filename(title) else window,/free
	plot,win,xstyle=1
endif

if print then device,/close

return, win

end
