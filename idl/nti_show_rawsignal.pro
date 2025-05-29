;+
;
;NAME: nti_show_rawsignal
;
;***********************************************************************
; show_rawsignal.pro                 S. Zoletnik    10.9.1997
;***********************************************************************
; Program to plot a signal (Li-beam channel # <channel> or signal name)
; Can also plot the sum of several channels if channels_in is an array.
; INPUT:
;   shot: shot number
;   channels_in: channel name or channel name array
;   errorproc: name of error processing routine to call on error
;   /nolegend: do not plot time and name of program
;   data_source: the data source code, see get_rawsignal
;   /nocalibrate: do not attempt to calibrate signal
;   inttime: integration time (in microsecond) to apply prior to plotting
;   subchannel: select subchannel (see get_rawsignal)
;***********************************************************************
;-

pro nti_show_rawsignal,shot,channels_in,errorproc=errorproc,$
         nolegend=nolegend,data_source=data_source,afs=afs,cdrom=cdrom,$
         trange=trange,title=tit,over=over,nointerpol=nointerpol,$
         linestyle=linestyle,yrange=yrange,color=color,nocalibrate=nocal,inttime=inttime,$
         subchannel=subchannel,ystyle=ystyle


nti_wavelet_default,data_source,0
nti_wavelet_default,channel_in,18
nti_wavelet_default,linestyle,0
nti_wavelet_default,color,!p.color
nti_wavelet_default,nocal,1
nti_wavelet_default,inttime,0
nti_wavelet_default,ystyle,1

;if ((data_source le 5) and (size(channel_in))(1) ne 7) then channel='Li-'+nti_wavelet_i2str(channel_in) else channel=string(channel_in)

for i=0,n_elements(channels_in)-1 do begin
  channel=channels_in[i]
  if nti_wavelet_defined(data_source) then data_source_w = data_source
  get_rawsignal,shot,channel,time_w,data_w,errorproc=errorproc,data_source=data_source_w,$
        afs=afs,cdrom=cdrom,trange=trange,data_names=data_names,nocalibrate=nocal,subchannel=subchannel,errormess=errormess
  if (not keyword_set(time_w) or not keyword_set(data_w)) then return 
  if (i  eq 0) then begin
    channel_tit = channel
  endif
  if ( i eq 1) then begin
    channel_tit = channel_tit+'...'
  endif    
  if (not nti_wavelet_defined(time)) then begin
    time = time_w
    data = data_w
  endif else begin
    if (n_elements(time) ne n_elements(time_w)) then begin
      errormess = 'Time vector of channels is different.'
      print,errormess
      return    
    endif
    ind = where(time ne time_w)
    if (ind[0] ge 0) then begin
      errormess = 'Time vector of channels is different.'
      print,errormess
      return
    endif
    data = data+data_w
  endelse      
endfor

        				 
nti_wavelet_default,trange,[min(time),max(time)]
ind=where((time ge trange(0)) and (time le trange(1)))
time=time(ind)
data=data(ind)

sampletime=(time(n_elements(time)-1)-time(0))/(n_elements(time)-1)
if (inttime/(sampletime/1e-6) gt 3) then begin
  ss=round(inttime/(sampletime/1e-6))
  data=smooth(float(data),ss)
endif  

if (not keyword_set(nointerpol)) then begin
  maxpoint=5000
  if ((size(time))(1) gt maxpoint) then begin
    time=interpol(time,maxpoint)
    data=interpol(data,maxpoint)
  endif
endif
											  
nti_wavelet_default,yrange,[min(data)<0,max(data)*1.05]
if (not keyword_set(over)) then begin
  erase
  if (not keyword_set(nolegend)) then time_legend,'nti_show_rawsignal.pro'
  if (not keyword_set(tit)) then begin
    tit=nti_wavelet_i2str(shot)
    tit=tit+'  Channel "'+channel_tit
	  if (keyword_set(subchannel)) then tit=tit+' subch '+nti_wavelet_i2str(subchannel)
    tit=tit+'"  ('+data_names(data_source_w)+')'
  endif
  plot,time,data,xtitle='Time [s]',xrange=trange,xstyle=1,$
    title=tit,yrange=yrange,ystyle=ystyle,ytitle='Signal [V]',$
    position=[0.1,0.1,0.8,0.8],/noerase,linestyle=linestyle,color=color
endif else begin
  oplot,time,data,linestyle=linestyle,color=color
endelse                
end
