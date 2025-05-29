;+
; NAME: nti_wavelet_bandpower_correlation
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2018.08.09.
;
; PURPOSE: Calculate and save 2 bandpowers and corresponding correlation functions 
; derived from time-frequency cross-transforms at given time and frequency coordinates 
; for processed data from NTI Wavelet Tools GUI
;
; CALLING SEQUENCE:
; nti_wavelet_bandpower_correlation, saved_datablock, bands=bands, [tranges], [f_downsample], [ID],$
;              [ccf_mean],[ccf_err],[t_c],[bp_save]
;
; INPUTS:
;   saved_datablock: Processed data structure from NTI Wavelet Tools GUI
;   bands: Band limits: [b1_lower,b1_upper,b2_lower,b2_upper]
;   tranges (optional): Time ranges to calculate the CCFs for 
;   f_downsample (optional): Downsampling frequency of the correlation functions; default: no downsampling
;   ID (optional): ID of run; default: time stamp
;
; OUTPUT:
;   ccf_mean (optional): mean CCF
;   ccf_err (optional): standard deviation of CCF
;   t_c (optional): time axis of CCF
;   bp_save (optional): save bandpowers
;   
;
; EXAMPLE:
;    restore,'test_processed.sav'
;    IDL> nti_wavelet_bandpower_correlation, saved_datablock, bands=[20,30,40,50]
;-

forward_function pg_ccorr, pg_num2str, nti_wavelet_i2str, gp_cohphasef, nti_wavelet_default, pg_anal2, gp_where

pro nti_wavelet_bandpower_correlation, saved_datablock, bands=bands, tranges=tranges,$
              f_downsample=f_downsample,ID=ID,$
              ccf_mean=ccf_mean,ccf_err=ccf_err,t_c=t_c,bp_save=bp_save

; Set defaults
nti_wavelet_default,fft_analyser,0
nti_wavelet_default,ID,nti_wavelet_i2str(1000*systime(1))
nti_wavelet_default,tranges,(transpose([[saved_datablock.timerange],[saved_datablock.timerange]]))(0,*)

; Read data from saved_datablock
shot=saved_datablock.shotnumber
channels=*saved_datablock.channels
stfts=*saved_datablock.transforms
windowsize=saved_datablock.proc_transf_stft_length
timeax=*saved_datablock.transf_timeax
freqax=*saved_datablock.transf_freqax
fmax=max(freqax)

winlength=1000.*windowsize*(timeax(2)-timeax(1))

dt=tranges(0,1)-tranges(0,0)
trange_number=n_elements(tranges[*,0])
channels_number = n_elements(channels)
if channels_number EQ 1 then message, $
  'nti_wavelet_bandpower_correlation cannot be called with single channel!'
segment_number = trange_number * channels_number

print,'Calculating and printing bandpowers...'
trange_index = 0
trange2=tranges[trange_index,*]
timeax2=timeax
channel_index=0
channel1=channels(channel_index)
stft=reform(stfts(channel_index,*,*))
pg_anal2,stft,bands,plot=3,/print,bp=bp,timeax=timeax2,freqax=freqax,trange=trange2,ID=ID
bpv=dblarr(2,n_elements(bp[0,*]),segment_number)
bp_timeaxes=dblarr(n_elements(timeax),segment_number)
bpv[*,*,0]=bp
bp_timeaxes[*,0]=timeax2

for trange_index=0,trange_number-1 do begin
  for channel_index=0,channels_number-1 do begin
    trange2=tranges[trange_index,*]
    timeax2=timeax
    channel1=channels(channel_index)
    stft=reform(stfts(channel_index,*,*))
    pg_anal2,stft,bands,plot=3,/print,bp=bpt,timeax=timeax2,freqax=freqax,trange=trange2,ID=ID
    bp_index=trange_index*trange_number+channel_index
    bpv[*,*,bp_index]=bpt
    bp_timeaxes[*,bp_index]=timeax2
  endfor
endfor

;resampling to get rid of the effect of stft windowing
if nti_wavelet_defined(f_downsample) then begin
  bpv_orig=bpv
  timeax_temp=bp_timeaxes[*,0]
  q=bpv_orig[0,*,0]
  gp_resample,q,timeax_temp2,f_downsample
  bpv=dblarr(2,n_elements(q),segment_number)
  timeax_temp2=timeax_temp
  for i=0,1 do begin
     for bp_index=0,segment_number-1 do begin
        timeax_temp=bp_timeaxes[*,0]
        q=bpv_orig[i,*,bp_index]
        gp_resample,q,timeax_temp,f_downsample
        bpv[i,*,bp_index]=q
        bp_timeaxes[*,bp_index]=timeax_temp
     endfor
  endfor
endif
nti_wavelet_default,f_downsample,fmax


c=dblarr(n_elements(reform(bpv[0,*,0])),segment_number)
impv12=c
impv21=c
t_c=lindgen(n_elements(c(*,0)))-ceil(n_elements(c(*,0))/2.)+1
t_c=t_c*(bp_timeaxes[2,0]-bp_timeaxes[1,0])*1000;in ms


for bp_index=0,segment_number-1 do begin
  pg_initgraph,/print
  c[*,bp_index]=pg_ccorr(reform(bpv[0,*,bp_index]),reform(bpv[1,*,bp_index]),/fast)
  gp_imp,reform(bpv[0,*,bp_index]),reform(bpv[1,*,bp_index]),imp12=imp12,imp21=imp21
  impv12[*,bp_index]=imp12
  impv21[*,bp_index]=imp21
  device,filename='./save_data/'+ID+'_'+pg_num2str(bp_index)+'_ccf.eps'
  plot,t_c,c[*,bp_index],title=ID+': '+pg_num2str(bp_index)+'_ccf',thick=3,charthick=3,charsize=2,$
       xtitle='Time delay (ms)',xstyle=1
  device,/close
endfor

save,bpv,tranges,bp_timeaxes,channels,filename='./save_data/'+ID+'_bp.sav'


ccf_mean=dblarr(n_elements(c[*,0]))
ccf_err=dblarr(n_elements(c[*,0]))
imp12_mean=ccf_mean
imp21_mean=imp12_mean
imp12_err=imp12_mean
imp21_err=imp12_mean

datas_prog='!C'+$
            'shot: '+pg_num2str(shot)+', tranges: '+pg_num2str(tranges(0),length=4)+'s - '+$
              pg_num2str(tranges(1),length=4)+'s'+$
           '!CID: '+ID+$
           '!CDate: '+systime()

datas='Ch: '+strjoin(channels,',')+$
      '!CWin: '+nti_wavelet_i2str(windowsize)+' ('+pg_num2str(winlength,length=4)+'ms), f_max: '+$
        pg_num2str(fmax)+$
      '!CFqs: '+nti_wavelet_i2str(bands(0))+'-'+nti_wavelet_i2str(bands(1))+' & '+$
        nti_wavelet_i2str(bands(2))+'-'+nti_wavelet_i2str(bands(3))+' (kHz), Length: '+$
        pg_num2str(dt,length=5)+'s'+$
      '!CAverages: '+nti_wavelet_i2str(segment_number)+', f_d: '+pg_num2str(f_downsample)+'kHz, ccf_dt: '+$
      pg_num2str(t_c[1]-t_c[0],length=5)+'ms '+'N: '+nti_wavelet_i2str(n_elements(c[*,0]))

;ccf_title=ID+': ccf-average (#'+nti_wavelet_i2str(shot)+', '+pg_num2str(trange(0),length=4)+'s-'+pg_num2str(trange(1),length=4)+'s)'
ccf_title=ID+': ccf-average'


for i=0,n_elements(ccf_mean)-1 do ccf_mean(i)=mean(c(i,*))
for i=0,n_elements(ccf_err)-1 do ccf_err(i)=stdev(c(i,*))
device,filename='./save_data/'+ID+'_ccf-average.eps'
plot,t_c,ccf_mean,title=ccf_title,thick=4,charthick=3,charsize=2,$
     yrange=[min(ccf_mean-ccf_err),max(ccf_mean+ccf_err)],ystyle=1,xtitle='Time delay (ms)',$
     xstyle=1

oplot,t_c,(ccf_mean-1.96*ccf_err/sqrt(segment_number)),linestyle=5,thick=4
oplot,t_c,(ccf_mean+1.96*ccf_err/sqrt(segment_number)),linestyle=5,thick=4
xyouts,0.99,0.12,datas,/normal,orientation=90,charsize=1.3,charthick=2
xyouts,0.99,0.63,datas_prog,/normal,orientation=90,charsize=1.3,charthick=2
device,/close

for i=0,n_elements(imp12_mean)-1 do imp12_mean(i)=mean(impv12(i,*))
for i=0,n_elements(imp21_mean)-1 do imp21_mean(i)=mean(impv21(i,*))
for i=0,n_elements(imp12_err)-1 do imp12_err(i)=stdev(impv12(i,*))
for i=0,n_elements(imp21_err)-1 do imp21_err(i)=stdev(impv21(i,*))

device,filename='./save_data/'+ID+'_imp12-average.eps'
plot,t_c,imp12_mean,title=ID+': imp12-average',thick=4,charthick=3,charsize=2,$
     xstyle=1,ystyle=1,xtitle='Time delay (ms)',$
     yrange=[min(imp12_mean-imp12_err),max(imp12_mean+imp12_err)]

oplot,t_c,(imp12_mean-imp12_err),linestyle=5,thick=4
oplot,t_c,(imp12_mean+imp12_err),linestyle=5,thick=4
device,/close

device,filename='./save_data/'+ID+'_imp21-average.eps'
plot,t_c,imp21_mean,title=ID+': imp21-average',thick=4,charthick=3,charsize=2,$
     xstyle=1,ystyle=1,xtitle='Time delay (ms)';,$
     yrange=[min(imp21_mean-imp21_err),max(imp21_mean+imp21_err)]

oplot,t_c,(imp21_mean-imp21_err),linestyle=5,thick=4
oplot,t_c,(imp21_mean+imp21_err),linestyle=5,thick=4
device,/close

save,impv12,impv21,filename='./save_data/'+ID+'_imp.sav'

pg_initgraph

end
