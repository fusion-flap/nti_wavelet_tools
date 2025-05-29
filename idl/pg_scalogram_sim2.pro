;+
; NAME: pg_scalogram_sim2
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.06.14.
;
; PURPOSE: Plot the Scalogram or the Phase of the Continous Wavelet Transform of a 1D data vector
;
; CALLING SEQUENCE:
;	cwt=pg_scalogram_sim2(data, time [,shot] [,channel] [,trange] [,family] [,order] [,dscale] [,start_scale] [,nscale]  $
;		[,plot] [,/print] [,/poster] [,/pad] [,/log] [,opt] [,/double] [,freqax=freqax] [,scaleax=scaleax])
;
; INPUTS:
;	data: signal
;	timeax: time axis
;	shot (optional): shot number
;	channel (optional): channel number
;	trange (optional): timerange to view, 2 element vector; default: whole range
;	fmax (optional): frequency maximum of spectrogram (in kHz), resampled with pg_resample, Downsamples time axis!
;	family (optional): wavelet family to use (available: 'Morlet'); default: 'Morlet'
;	order (optional): order of the wavelet; default: default of the family
;	dscale (optional): fraction of diadic scaling; default:0.25
;	start_scale (optional): starting scale (has no effect on CWT using Morlet wavelets; default:2
;	nscale (optional): total number of scale values; default:log2(N/start_scale)/dscale+1
;	plot (optional): display mode (available: 0:All, 1:Scalogram(log), 2:Phase,
;					3:Scalogram(lin+log) (for Morlet wavelets only), 
;         4:Scalogram(lin with forced 0 freq. scale + log) (for Morlet wavelets only),
;         other:None; default: 0
;	opt (optional): exponent for opimized scale visualization
;	/print (optional): Print to file instead of plotting
;	/poster (optional): Print in poster form
;	/pad (optional): use zero padding instead of cutting the data vector to 2^x length
;	/log (optional): visualize on log scale (except for Phase)
;	/double (optional): double precision
;
; OUTPUT:
;	cwt: CWT of signal
;	freqax (optional): frequency axis
;	scaleax (optional): scale axis
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;  Gergo Pokol (pokol@reak.bme.hu) 2004.12.08. (frequency axis added)
;-


function pg_scalogram_sim2, data, timeax, shot=shot, channel=channel, trange=trange, family=family, order=order, dscale=dscale,$
	start_scale=start_scale, nscale=nscale, plot=plot, print=print, poster=poster, pad=pad, log=log, opt=opt, $
	double=double, freqax=freqax, scaleax=scaleax, fmax=fmax, ID=ID

compile_opt defint32 ; 32 bit integers


; Set defaults
size=n_elements(data)
double=keyword_set(double)
print=keyword_set(print)
poster=keyword_set(poster)
log=keyword_set(log)
if not(keyword_set(shot)) then shot=0
if not(keyword_set(channel)) then channel='SIMULATED'
if not(keyword_set(order)) then order=6
if not(keyword_set(family)) then family='Morlet'
if not(keyword_set(plot)) then plot=0
if not(keyword_set(opt)) then opt=1

; Read data
if not(keyword_set(trange)) then trange=[min(timeax),max(timeax)]
ind=where((timeax ge trange(0)) and (timeax le trange(1)))
timeax=timeax(ind)
data=data(ind)

; Zeropad data where abscent
repeat begin
	timesize=n_elements(timeax)
	dts=timeax(1+findgen(timesize-1))-timeax(findgen(timesize-1))
	ind=where(abs(dts-dts(1)) GT dts(1))
	if max(ind) NE -1 then begin
		place=ind(0)
		timeax=[timeax(findgen(place)),(findgen(fix(dts(place)/dts(1)-1))+1)*dts(1)+timeax(place),$
			timeax(place+1+findgen(timesize-place-1))]
		data=[data(findgen(place)),findgen(fix(dts(place)/dts(1)-1))*0,$
			data(place+1+findgen(timesize-place-1))]
	endif
endrep until max(ind) EQ -1

;resampling data if set
if keyword_set(fmax) then begin
   print,'Resampling data to get f_max: '+pg_num2str(fmax)+' kHz (original f_s was: '+pg_num2str(0.001/(timeax(1)-timeax(0)))+' kHz)'
   print,'Original time axis is: '+pg_num2str(timeax(0))+' - '+pg_num2str(timeax(n_elements(timeax)-1))
   oldsize = n_elements(data)
   newsize=floor((timeax(n_elements(timeax)-1)-timeax(0))*2d3*fmax)
   data=pg_resample(data,newsize)
   freq_max = 5d-4/((timeax(oldsize - 1) - timeax(0))/(oldsize - 1))/oldsize*newsize  ; 5e-4 = 1/1000/2
   timeax = timeax(0) + dindgen(newsize)/(freq_max*2d3)
   print,'Resampled data, new timeax is: '+pg_num2str(timeax(0))+' - '+pg_num2str(timeax(n_elements(timeax)-1))+', f_max is: '+pg_num2str(0.0005/(timeax(1)-timeax(0)))+' kHz'
endif

; Cut data vector to 2^x length if zero padding is not set
sizedata=N_ELEMENTS(data)
if not(keyword_set(pad)) then begin
	newsize=2^floor(alog(sizedata)/alog(2))
	data=data[0:newsize-1]
	timeax=timeax[0:newsize-1]
endif

; Subtract mean
data=data-mean(data)

; Set start_scale to meet the sampling criteria when using Morlet wavelet
if family EQ 'Morlet' then start_scale=order/!PI

; Compute CWT
cwt = pg_cwt(data, family, order, SCALE=scale, dscale=dscale, start_scale=start_scale, nscale=nscale, $
	pad=pad, double=double)

;Compute frequency axis
dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)
freqax=order/scale/dt/1000/2/!PI

; Initialize graphics
pg_initgraph,print=print, /portrait
title0=' of shot: '+pg_num2str(shot)+' '+channel+'  using wavelet family: '+family+$
		'  order: '+pg_num2str(order)+' fraction of dyadic scaling: '+pg_num2str(dscale)

print_data='shot: '+nti_wavelet_i2str(shot)+$
	'!C'+channel+$
	'!Ctrange:!C '+pg_num2str(timeax[0],length=4)+' s - '+$
		pg_num2str(timeax[n_elements(timeax)-1],length=4)+' s'+$
	'!Cfamily: '+family+$
	'!Corder: '+nti_wavelet_i2str(order)+$
	'!Cdscale: '+pg_num2str(dscale,length=5)+$
	'!Cstart scale: '+pg_num2str(start_scale,length=5)+$
	'!Cnscale: '+nti_wavelet_i2str(nscale)

;papp@reak.bme.hu, 2008.12.09. Adding 'ID' string to datas for easier identification
if keyword_set(ID) then print_data='ID='+ID+'!C'+print_data

;title0=' of shot: '+pg_num2str(shot) ; Poster
;!P.CHARSIZE=3.0 ; Poster
;!P.THICK=4. ; Poster
;!P.CHARTHICK=3. ; Poster

; Plot the results
if (plot EQ 0) OR (plot EQ 1) OR (plot EQ 3) then begin ; Scalogram (log)

	;Compute Power Density Distribution
	plotted=reverse(abs(cwt)^2,2)

	;Plot
	title='Scalogram_'+title0
	if print then device,filename=pg_filename(title) else window,/free
	pg_plot4,plotted,ct=5,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
		,/ylog,y2range=[min(-pg_log2(scale)),max(-pg_log2(scale))]$
		,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
		,title=title,zlog=log,opt=opt,data=print_data, poster=poster

endif
if (plot EQ 0) OR (plot EQ 2) then begin ; Phase (log)

	;Compute Phase
	plotted=reverse(atan(imaginary(cwt),float(cwt)),2)

	;Plot
	title='CWT phase'+title0
	if print then device,filename=pg_filename(title) else window,/free
	pg_plot4,plotted,ct=0,xrange=[min(timeax),max(timeax)],yrange=[min(freqax),max(freqax)]$
		,/ylog,y2range=[min(-pg_log2(scale)),max(-pg_log2(scale))]$
		,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
		,title=title,data=print_data, poster=poster

endif
if ((plot EQ 0) OR (plot EQ 3)) AND (family EQ 'Morlet') then begin ; Scalogram (lin)

  ;Compute Power Density Distribution
  plotted=abs(cwt)^2


  ;Plot
  title='Linear axis scalogram'+title0
  if print then device,filename=pg_filename(title) else window,/free
  loadct,5
  colors_scale_exponent=1/opt
  levels=findgen(60)^colors_scale_exponent
  levels=levels/max(levels)*(max(plotted)-min(plotted))+min(plotted)
  CONTOUR, plotted, timeax, freqax, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
     levels=levels,title=title

endif

if ((plot EQ 0) OR (plot EQ 4)) AND (family EQ 'Morlet') then begin ; Scalogram (lin with forced 0 freq. axis)

  ;Compute Power Density Distribution
  plotted=abs(cwt)^2
  plottedsize=size(plotted)
  plottedplus=fltarr(plottedsize(1),plottedsize(2)+2)
  plottedplus(*,0:plottedsize(2)-1)=plotted
  freqaxplus=[freqax,max([min(freqax)-1e-6,0.]),0.]
  

  ;Plot
  title='Linear axis scalogram'+title0
  if print then device,filename=pg_filename(title) else window,/free
  loadct,5
  colors_scale_exponent=1/opt
  levels=findgen(60)^colors_scale_exponent
  levels=levels/max(levels)*(max(plottedplus)-min(plottedplus))+min(plottedplus)
  CONTOUR, plottedplus, timeax, freqaxplus, /FILL, XSTYLE=1, YSTYLE=1, XTITLE='Time', YTITLE='Frequency (kHz)',$
     levels=levels,title=title

endif

if print then device,/close

freqax=freqax
scaleax=scale

return, cwt

;!P.CHARSIZE=1.0 ; Poster
;!P.THICK=1. ; Poster
;!P.CHARTHICK=1. ; Poster

end
