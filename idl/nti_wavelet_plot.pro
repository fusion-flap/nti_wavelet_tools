;+
;
;NAME: nti_wavelet_plot
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2011.07.25.
;
; PURPOSE: Plot scalograms (or spectrograms), cross/transforms, coherences and mode numbers
;       on the time-frequency plane, as calculated by nti_wavelet_main.pro.
;
; CALLING SEQUENCE: 
;    nti_wavelet_plot, timeax, freqax, scaleax, transforms, smoothed_apsds,$
;    crosstransforms, smoothed_crosstransforms, coherences, transfers, modenumbers, qs $
;    [,expname] [,shotnumber] [,channels] [, channelpairs_used] $
;    [,cwt_selection] [,cwt_family] [,cwt_order] [,cwt_dscale] $
;    [,stft_selection] [,stft_window] [,stft_length] [,stft_fres] $
;    [,stft_step] [,freq_min] [,freq_max] [,coh_avr] $
;    [,mode_type] [,mode_filter] $
;    [,mode_steps] [,mode_min] [,mode_max] $
;    [,transf_selection] [,transf_smooth] [,transf_energy] $
;    [,transf_phase] [,transf_cscale] $
;    [,crosstr_selection] [,crosstr_smooth] [,crosstr_energy] $
;    [,crosstr_phase] [,crosstr_cscale] $
;    [,coh_selection] [,coh_all] [,coh_avg] [,coh_min] $
;    [,transfer_selection] [,transfer_selection] [,transfer_cohlimit] [,transfer_powlimit] [,transfer_cscale]$
;    [,mode_selection] [,mode_cohlimit] [,mode_powlimit] $
;    [,mode_qlimit] [,linear_freqax] [,poster] $
;    [,startpath] [,savepath] [,version]
;
;
; INPUTS:
;    timeax: time axis
;    freqax: frequency axis
;    scaleax: scale axis (for CWT)
;    transforms: the transformated values
;    smooth_apsds: the smoothed APSD (auto power density)
;    crosstransforms: the cross-transform values
;    smoothed_cosstransforms: the smoothed cross-transform values
;    coherences: the calculated coherences
;    transfers: the calculated transfer functions
;    modenumbers: the calculated mode numbers
;    qs: the calculated q fitting parameter values
;    ridges: plot ridge (1D vector) on STFT spectrograms
;  Processing parameters:
;    expname: name of the experiment (for example: SXR, MHA)
;    shotnumber: shot number
;    data_history: Data history string; default: 'Not available'
;    coord_history: Coordinate history string; default: 'Not available'
;    timerange: timerange to view in s, 2 element vector; default: the start and the end of the time axis
;    channels: channel names
;    channelpairs_used: the used channel pairs
;    transf_selection: selecting to calculate transforms 
;    cwt_selection: selecting CWT as transformation
;    cwt_family: wavelet family
;    cwt_order: order of wavelet
;    cwt_dscale: fraction of diadic scaling
;    stft_selection: selecting STFT as transformation
;    stft_window: window type
;    stft_length: the length of the window
;    stft_fres: the frequency resolution of STFT
;    stft_step: length of time steps of STFT
;    freq_min: Minimum frequency will be plotted
;    freq_max: Maximum frequency will be plotted
;    crosstr_selection: selecting to calculate cross-transforms 
;    coh_selection: selecting to calculate coherences 
;    coh_avr: number of averages
;    transfer_selection: selecting to calculate transfer functions
;    mode_selection: selecting to calculate mode numbers 
;    mode_type: type of the mode number
;    mode_filter: type of the mode filter
;    mode_steps: steps between the calculated mode numbers OR margin for monotonization
;    mode_min: the minimum mode number
;    mode_max: the maximum mode number
;  Visualisation parameters:
;    transf_selection: boolean, if 1, plots transformed values
;    transf_smooth: if 1, plots smoothed transform values
;    transf_energy: if 1, plots the energy-density distribution
;    transf_phase: if 1, plots the phase
;    transf_cscale: color scale for transform-plots; default: 0.4
;    crosstr_selection: if 1, plots cross-transformes
;    crosstr_smooth: if 1, plots smoothed cross-transforms
;    crosstr_energy: if 1, plots CPSD
;    crosstr_phase: if 1, plots cross-phase
;    crosstr_cscale: color scale for cross-transform plots; default: 0.4
;    coh_selection: if 1, plots coherences
;    coh_all: if 1, plots all coherence between the channel pairs
;    coh_avg: if 1, plots the average coherence of the channel pairs
;    coh_min: if 1, plots the minimum coherence of the channel pairs
;    transfer_selection: if 1, plots transfer functions
;    transfer_cohlimit: transfer functions will be plotted where the coherence is above this value; default: 0.
;    transfer_powlimit: transfer functions will be plotted where the energy density is above this value; default: 0.
;    transfer_cscale: color scale for transfer functions plots; default: 0.4
;    mode_selection: if 1, plots mode numbers
;    mode_cohlimit:  mode numbers will be plotted where the coherence is above this value; default: 0.
;    mode_powlimit: mode numbers will be plotted where the energy density is above this value; default: 0.
;    mode_qlimit: mode numbers will be plotted where the q fitting parameter is above this value; default: 100.
;    linear_freqax: if 1, all plots are made with linear frequency axis
;    poster: plots will be suitable for direct publication
;  Paths
;    startpath: start path; default: current directory
;    savepath: save path; default: current directory
;    version: version number; default: 'Unidentified version'
;
;-

pro nti_wavelet_plot, $
  ; Inputs - calculation results
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs, ridges = ridges,$
  ; Inputs - processing parameters
    expname=expname, shotnumber=shotnumber, data_history=data_history, coord_history=coord_history,$
    channels=channels, channelpairs_used=channelpairs_used,$
    cwt_selection=cwt_selection, cwt_family=cwt_family, cwt_order=cwt_order, cwt_dscale=cwt_dscale,$
    stft_selection=stft_selection, stft_window=stft_window, stft_length=stft_length, stft_fres=stft_fres,$
    stft_step=stft_step, freq_min=freq_min, freq_max=freq_max, coh_avr=coh_avr,$
    mode_type=mode_type, mode_filter=mode_filter,$
    mode_steps=mode_steps, mode_min=mode_min, mode_max=mode_max, $
  ; Inputs - visualization parameters
    transf_selection=transf_selection, transf_smooth=transf_smooth, transf_energy=transf_energy,$
    transf_phase=transf_phase, transf_cscale=transf_cscale,$
    crosstr_selection=crosstr_selection, crosstr_smooth=crosstr_smooth, crosstr_energy=crosstr_energy,$
    crosstr_phase=crosstr_phase, crosstr_cscale=crosstr_cscale,$
    coh_selection=coh_selection, coh_all=coh_all, coh_avg=coh_avg, coh_min=coh_min,$
    transfer_selection=transfer_selection, transfer_cohlimit=transfer_cohlimit,$
    transfer_powlimit=transfer_powlimit, transfer_cscale=transfer_cscale,$
    mode_selection=mode_selection, mode_cohlimit=mode_cohlimit, mode_powlimit=mode_powlimit,$
    mode_qlimit=mode_qlimit, linear_freqax=linear_freqax, poster=poster,$
  ; Paths
    startpath=startpath, savepath=savepath, version=version

compile_opt defint32 ; 32 bit integers

; Set defaults
nti_wavelet_default,data_history,'Not available'
nti_wavelet_default,coord_history,'Not available'
nti_wavelet_default,transf_selection,0
nti_wavelet_default,transf_smooth,0
nti_wavelet_default,transf_energy,0
nti_wavelet_default,transf_phase,0
nti_wavelet_default,transf_cscale,0.4
nti_wavelet_default,crosstr_selection,0
nti_wavelet_default,crosstr_smooth,0
nti_wavelet_default,crosstr_energy,0
nti_wavelet_default,crosstr_phase,0
nti_wavelet_default,crosstr_cscale,0.4
nti_wavelet_default,coh_selection,0
nti_wavelet_default,coh_all,0
nti_wavelet_default,coh_avg,0
nti_wavelet_default,coh_min,0
nti_wavelet_default,transfer_selection,0
nti_wavelet_default,transfer_cohlimit,0
nti_wavelet_default,transfer_powlimit,0
nti_wavelet_default,transfer_cscale,0.4
nti_wavelet_default,mode_selection,0
nti_wavelet_default,mode_cohlimit,0
nti_wavelet_default,mode_powlimit,0
nti_wavelet_default,mode_qlimit,100
nti_wavelet_default,linear_freqax,0
nti_wavelet_default,poster,0
if not(nti_wavelet_defined(savepath)) then cd, current=savepath
if not(nti_wavelet_defined(startpath)) then cd, current=startpath
nti_wavelet_default,version,'Unidentified version'

;Set size of channelpairs_used:
size_channelpairs_used = size(channelpairs_used)
if (size_channelpairs_used(0) eq 1) then begin
  channelpairs_used = reform(channelpairs_used, 2, 1)
endif

channelsize=n_elements(channels)
crosssize=(size(channelpairs_used))(2)
transformsize=size(transforms)
dt=double(timeax(n_elements(timeax)-1)-timeax(0))/double(n_elements(timeax)-1)

; Initialize graphics
pg_initgraph, /print, /portrait

shot_printdatas=$
  'version: '+version+$
  '!Cshot: '+expname+' '+nti_wavelet_i2str(shotnumber)+$
  '!Cdata history: '+strjoin(strsplit(data_history,'+',/extract),'!C  ')+$
  '!Ccoord. history: '+strjoin(strsplit(coord_history,'+',/extract),'!C  ')
if cwt_selection then begin
  transf_printdatas=$
		'!Cfamily: '+cwt_family+$
		'!Corder: '+nti_wavelet_i2str(cwt_order)+$
		'!Cdscale: '+pg_num2str(cwt_dscale,length=5)
endif else begin
  transf_printdatas=$
		'!Cwindow: '+stft_window+$
		'!Cwinsize: '+nti_wavelet_i2str(stft_length)+'!C '+pg_num2str(dt*stft_length/stft_step)+'s'+$
		'!Cfres: '+nti_wavelet_i2str(stft_fres)+$
		'!Cstep: '+nti_wavelet_i2str(stft_step)
endelse

; Initialize plotted frequency range
freq_min_override=0
freq_max_override=0
if (nti_wavelet_defined(freq_min) and nti_wavelet_defined(freq_max)) then begin
  ;Find where is freq_min in the freqax vector:
  freq_min_index = where(freqax-freq_min eq min(freqax-freq_min, /ABSOLUTE))
  ;Find where is freq_max in the freqax vector:
  freq_max_index = where(freqax-freq_max eq min(freqax-freq_max, /ABSOLUTE))
  ;Create a vector for the two value calculated just before:
  freq_index = [freq_min_index,freq_max_index]
  ;Calculate the new frequency axis:
  plotted_freqax = freqax(min(freq_index):max(freq_index))
  ;Calculate the new scale axis:
  if nti_wavelet_defined(scaleax, /nullarray) then begin
    plotted_scaleax = scaleax(min(freq_index):max(freq_index))
  endif
  ; Extend frequency axis to start from input minimum frequency
  if freq_min LT min(freqax) then begin
    ; This works only for liear axis CWT plots
    if cwt_selection AND linear_freqax then begin 
      freq_min_override=1 ; This is a switch that makes the plotting routines extend the plotted matrices to fit the dimensions of the extended frequency axis
      extra_freq=max([exp(2*alog(plotted_freqax(n_elements(plotted_freqax)-1))-$ 
        alog(plotted_freqax(n_elements(plotted_freqax)-2))),$ 
        (plotted_freqax(n_elements(plotted_freqax)-1)-freq_min)/2.]) ; Maximum of logarithmically extrapolated element of frequency axis and arithmetic mean of last frequency point and input minimum frequency
      plotted_freqax=[plotted_freqax,extra_freq,freq_min] ; Extend frequency axis with input minimum frequency and a suitable frequency value in-between
    endif else begin
      print, 'Error in setting plotted frequency range! Calculated range will be used!'
    endelse
  endif
    
    
  
end

; Plot transforms
if transf_selection then begin
  print,'Plotting transforms'
  if transf_energy then begin
    loadct,5,file=startpath+'nti_wavelet_colors.tbl'
    if transf_smooth then begin
      for i=0,channelsize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannel: '+channels(i)+$
          transf_printdatas+$
          '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
          '!Ccolor scale opt: '+pg_num2str(transf_cscale, length=4)
        plotted=reform(smoothed_apsds(i,*,min(freq_index):max(freq_index)))
        if cwt_selection then begin
          title='Smoothed scalogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Smoothed scalogram of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
          if linear_freqax then begin
            if freq_min_override then begin
              temp=plotted
              plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
              plotted(*,0:(n_elements(plotted_freqax)-3))=temp
            endif
      	    resolution = min([600, n_elements(plotted_freqax)])
      	    plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	    pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
      	      ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas,poster=poster
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=transf_cscale,data=printdatas,poster=poster
          endelse
        endif else begin
          title='Smoothed spectrogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Smoothed spectrogram of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas,poster=poster
        endelse
      endfor
    endif else begin
      for i=0,channelsize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannel: '+channels(i)+$
          transf_printdatas+$
          '!Ccolor scale opt: '+pg_num2str(transf_cscale, length=4)
        plotted=reform(abs(transforms(i,*,min(freq_index):max(freq_index)))^2)*2
        if cwt_selection then begin
          title='Scalogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          if linear_freqax then begin
            if freq_min_override then begin
              temp=plotted
              plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
              plotted(*,0:(n_elements(plotted_freqax)-3))=temp
            endif
      	    resolution = min([600, n_elements(plotted_freqax)])
      	    plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	    pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
      	      ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas,poster=poster
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=transf_cscale,data=printdatas,poster=poster
          endelse
        endif else begin
          title='Spectrogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
	  ;Plot ridge
	  if nti_wavelet_defined(ridges) then begin
	    ridge = reform(ridges(i,*))
	  endif
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transf_cscale,data=printdatas,poster=poster,ridge=ridge
        endelse
      endfor      
    endelse
  endif
  if transf_phase then begin
    loadct,0,file=startpath+'nti_wavelet_colors.tbl'
    for i=0,channelsize-1 do begin
      printdatas=shot_printdatas+$
        '!Cchannel: '+channels(i)+$
        transf_printdatas
      plotted=reform(atan(imaginary(transforms(i,*,min(freq_index):max(freq_index))),float(transforms(i,*,min(freq_index):max(freq_index)))))
      if cwt_selection then begin
        title='CWT phase of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
        filename=pg_filename(title,dir=savepath)
        device,filename=filename
        printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
        if linear_freqax then begin
          if freq_min_override then begin
            temp=plotted
            plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
            plotted(*,0:(n_elements(plotted_freqax)-3))=temp
          endif
      	  resolution = min([600, n_elements(plotted_freqax)])
      	  plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	  pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
      	    ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster     
        endif else begin
          pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
            ,title=title,data=printdatas,poster=poster
        endelse
      endif else begin
        title='STFT phase of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channels(i)
        filename=pg_filename(title,dir=savepath)
        device,filename=filename
        printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
        pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster     
      endelse
    endfor      
  endif
endif

; Plot cross-transforms
if crosstr_selection then begin
  print,'Plotting cross-transforms'
  if crosstr_energy then begin
    loadct,5,file=startpath+'nti_wavelet_colors.tbl'
    if crosstr_smooth then begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas+$
          '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
          '!Ccolor scale opt: '+pg_num2str(crosstr_cscale, length=4)
        plotted=reform(abs(smoothed_crosstransforms(i,*,min(freq_index):max(freq_index))))
        if cwt_selection then begin
          title='Smoothed cross-scalogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Smoothed cross-scalogram of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          if linear_freqax then begin
            if freq_min_override then begin
              temp=plotted
              plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
              plotted(*,0:(n_elements(plotted_freqax)-3))=temp
            endif
        	  resolution = min([600, n_elements(plotted_freqax)])
        	  plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
            pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=crosstr_cscale,data=printdatas,poster=poster      
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=crosstr_cscale,data=printdatas,poster=poster
          endelse
        endif else begin
          title='Smoothed cross-spectrogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Smoothed cross-spectrogram of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=crosstr_cscale,data=printdatas,poster=poster      
        endelse
      endfor
    endif else begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas+$
          '!Ccolor scale opt: '+pg_num2str(crosstr_cscale, length=4)
        plotted=reform(abs(crosstransforms(i,*,min(freq_index):max(freq_index))))
        if cwt_selection then begin
          title='Cross-scalogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Cross-scalogram of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          if linear_freqax then begin
            if freq_min_override then begin
              temp=plotted
              plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
              plotted(*,0:(n_elements(plotted_freqax)-3))=temp
            endif
      	    resolution = min([600, n_elements(plotted_freqax)])
      	    plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	    pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
      	      ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=crosstr_cscale,data=printdatas,poster=poster
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,opt=crosstr_cscale,data=printdatas,poster=poster
          endelse
        endif else begin
          title='Cross-spectrogram of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Cross-spectrogram of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=crosstr_cscale,data=printdatas,poster=poster
        endelse
      endfor      
    endelse
  endif
  if crosstr_phase then begin
    loadct,0,file=startpath+'nti_wavelet_colors.tbl'
    if crosstr_smooth then begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas+$
          '!Caverages: '+nti_wavelet_i2str(coh_avr)
        plotted=reform(atan(imaginary(smoothed_crosstransforms(i,*,min(freq_index):max(freq_index))),float(smoothed_crosstransforms(i,*,min(freq_index):max(freq_index)))))
        if cwt_selection then begin
          title='Smoothed cross-CWT phases of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Smoothed cross-CWT phases of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          if linear_freqax then begin
            if freq_min_override then begin
              temp=plotted
              plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
              plotted(*,0:(n_elements(plotted_freqax)-3))=temp
            endif
      	    resolution = min([600, n_elements(plotted_freqax)])
      	    plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	    pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
      	      ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,data=printdatas,poster=poster
          endelse
        endif else begin
          title='Smoothed cross-STFT phases of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Smoothed cross-STFT phases of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
        endelse
      endfor
    endif else begin
      for i=0,crosssize-1 do begin
        printdatas=shot_printdatas+$
          '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
          transf_printdatas
        plotted=reform(atan(imaginary(crosstransforms(i,*,min(freq_index):max(freq_index))),float(crosstransforms(i,*,min(freq_index):max(freq_index)))))
        if cwt_selection then begin
          title='Cross-CWT phases of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Cross-CWT phases of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          if linear_freqax then begin
            if freq_min_override then begin
              temp=plotted
              plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
              plotted(*,0:(n_elements(plotted_freqax)-3))=temp
            endif
      	    resolution = min([600, n_elements(plotted_freqax)])
      	    plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	    pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
      	      ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster 
          endif else begin
            pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
              ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
              ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
              ,title=title,data=printdatas,poster=poster
          endelse
        endif else begin
          title='Cross-STFT phases of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          filename=pg_filename(title,dir=savepath)
          device,filename=filename
          printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
          title='Cross-STFT phases of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
          pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster 
        endelse
      endfor      
    endelse
  endif
endif

; Plot coherences
if coh_selection then begin
  print,'Plotting coherences'
  loadct,5,file=startpath+'nti_wavelet_colors.tbl'
  if coh_all then begin
    for i=0,crosssize-1 do begin
      printdatas=shot_printdatas+$
        '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
        transf_printdatas+$
        '!Caverages: '+nti_wavelet_i2str(coh_avr)
      plotted=reform(coherences(i,*,min(freq_index):max(freq_index)))
      if cwt_selection then begin
        title='Coherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
        filename=pg_filename(title,dir=savepath)
        device,filename=filename
        printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
        if linear_freqax then begin
          if freq_min_override then begin
            temp=plotted
            plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
            plotted(*,0:(n_elements(plotted_freqax)-3))=temp
          endif
      	  resolution = min([600, n_elements(plotted_freqax)])
      	  plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	  pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)],zrange=[0,1]$
      	    ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
        endif else begin
          pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
            ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))],zrange=[0,1]$
            ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
            ,title=title,data=printdatas,poster=poster
        endelse
      endif else begin
        title='Coherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
        filename=pg_filename(title,dir=savepath)
        device,filename=filename
        printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
        pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)],zrange=[0,1]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
      endelse
    endfor
  endif 
  if coh_avg then begin
    printdatas=shot_printdatas+$
      transf_printdatas+$
      '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
      '!Cchannel pairs: '+nti_wavelet_i2str(crosssize)
    for i=0,crosssize-1 do printdatas=printdatas+'!C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
    
    plotted=total(coherences(*,*,min(freq_index):max(freq_index)),1)/crosssize ;Calculating average coherence
    
    if cwt_selection then begin
      title='Average coherence of '+expname+' '+nti_wavelet_i2str(shotnumber)
      filename=pg_filename(title,dir=savepath)
      device,filename=filename
      printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
      if linear_freqax then begin
        if freq_min_override then begin
          temp=plotted
          plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
          plotted(*,0:(n_elements(plotted_freqax)-3))=temp
        endif
      	resolution = min([600, n_elements(plotted_freqax)])
      	plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)],zrange=[0,1]$
      	  ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
      endif else begin
        pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
          ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))],zrange=[0,1]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
          ,title=title,data=printdatas,poster=poster
      endelse
    endif else begin
      title='Average coherence of '+expname+' '+nti_wavelet_i2str(shotnumber)
      filename=pg_filename(title,dir=savepath)
      device,filename=filename
      printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)],zrange=[0,1]$
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
    endelse
  endif 
  if coh_min then begin
    printdatas=shot_printdatas+$
      transf_printdatas+$
      '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
      '!Cchannel pairs: '+nti_wavelet_i2str(crosssize)
    for i=0,crosssize-1 do printdatas=printdatas+'!C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)

    plotted=min(coherences(*,*,min(freq_index):max(freq_index)),dimension=1)
    if cwt_selection then begin
      title='Minimum coherence of '+expname+' '+nti_wavelet_i2str(shotnumber)
      filename=pg_filename(title,dir=savepath)
      device,filename=filename
      printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
      if linear_freqax then begin
        if freq_min_override then begin
          temp=plotted
          plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
          plotted(*,0:(n_elements(plotted_freqax)-3))=temp
        endif
      	resolution = min([600, n_elements(plotted_freqax)])
      	plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)],zrange=[0,1]$
      	  ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
      endif else begin
        pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
          ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))],zrange=[0,1]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
          ,title=title,data=printdatas,poster=poster
      endelse
    endif else begin
      title='Minimum coherence of '+expname+' '+nti_wavelet_i2str(shotnumber)
      filename=pg_filename(title,dir=savepath)
      device,filename=filename
      printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)],zrange=[0,1]$
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas,poster=poster
    endelse
  endif 
endif

;Plot transfer functions:
if transfer_selection then begin
!P.COLOR = 255
  loadct,43,file=startpath+'nti_wavelet_colors.tbl'
  print,'Plotting transfer functions'

  ; Filter out results with low coherence
  if transfer_cohlimit NE 0. then begin
    transfer_cohlimit=float(transfer_cohlimit)/100.
    ; Calculate minimum coherence for coherence limit filtering
    limcoh=min(coherences,dimension=1)
    ; Do filtering
    notplotted=where(limcoh LT transfer_cohlimit)
  endif
  ; Filter out results with low power
  if transfer_powlimit NE 0. then begin
    transfer_powlimit=float(transfer_powlimit)/100.
    ; Calculate average cross energy density for power limit filtering
    limpow=fltarr(transformsize(2),n_elements(plotted_freqax))
    if (size(smoothed_crosstransforms))(0) LT 2 then begin
      for i=0,transformsize(2)-1 do begin
        for j=0,transformsize(3)-1 do begin
          limpow(i,j)=mean(abs(crosstransforms(*,i,j))^2)
        endfor
      endfor
    endif else begin
      for i=0,transformsize(2)-1 do begin
        for j=0,transformsize(3)-1 do begin
          limpow(i,j)=mean(abs(smoothed_crosstransforms(*,i,j))^2)
        endfor
      endfor
    endelse
    limpow=limpow/max(limpow)
    ; Do filtering
    notplotted=where(limpow LT transfer_powlimit)
  endif

;Plot 1st direction:
  for i=0,crosssize-1 do begin
    plotted=reform(abs(transfers(0,i,*,*)))
  if transfer_cohlimit NE 0. then begin
    if max(notplotted) GT -1 then plotted(notplotted)=0.
  endif
  if transfer_powlimit NE 0. then begin
    if max(notplotted) GT -1 then plotted(notplotted)=0.
  endif

  ;Set plotted frequency range
  plotted = plotted(*,min(freq_index):max(freq_index))

    printdatas=shot_printdatas+$
      '!Cchannels: !C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)+$
      transf_printdatas+$
      '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
      '!CCoherence limit: '+nti_wavelet_i2str(100*transfer_cohlimit)+' %'+$
      '!CPower limit: '+nti_wavelet_i2str(100*transfer_powlimit)+' %'+$
      '!Ccolor scale opt: '+pg_num2str(transfer_cscale, length=4)
    if cwt_selection then begin
     title='Transfer function of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
      filename=pg_filename(title,dir=savepath)
      device,filename=filename
      printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
     title='Transfer function of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
      if linear_freqax then begin
        if freq_min_override then begin
          temp=plotted
          plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
          plotted(*,0:(n_elements(plotted_freqax)-3))=temp
        endif
      	resolution = min([600, n_elements(plotted_freqax)])
      	plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)], $
      	  xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transfer_cscale,data=printdatas, /nearest,poster=poster
     endif else begin
        pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
          ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
          ,title=title,opt=transfer_cscale,data=printdatas, /nearest,poster=poster
      endelse
    endif else begin
     title='Transfer function of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
     filename=pg_filename(title,dir=savepath)
     device,filename=filename
     printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
     title='Transfer function of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
     pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)], $
     xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transfer_cscale,data=printdatas, /nearest,poster=poster
    endelse
  endfor

;Plot 2nd direction:
  for i=0,crosssize-1 do begin
    plotted=reform(abs(transfers(1,i,*,*)))
  if transfer_cohlimit NE 0. then begin
    if max(notplotted) GT -1 then plotted(notplotted)=0.
  endif
  if transfer_powlimit NE 0. then begin
    if max(notplotted) GT -1 then plotted(notplotted)=0.
  endif

  ;Set plotted frequency range
  plotted = plotted(*,min(freq_index):max(freq_index))

    printdatas=shot_printdatas+$
      '!Cchannels: !C '+channelpairs_used(1,i)+'--'+channelpairs_used(0,i)+$
      transf_printdatas+$
      '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
      '!CCoherence limit: '+nti_wavelet_i2str(100*transfer_cohlimit)+' %'+$
      '!CPower limit: '+nti_wavelet_i2str(100*transfer_powlimit)+' %'+$
      '!Ccolor scale opt: '+pg_num2str(transfer_cscale, length=4)
    if cwt_selection then begin
      title='Transfer function of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(1,i)+'--'+channelpairs_used(0,i)
      filename=pg_filename(title,dir=savepath)
      device,filename=filename
      printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
      title='Transfer function of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(1,i)+'--'+channelpairs_used(0,i)
      if linear_freqax then begin
        if freq_min_override then begin
          temp=plotted
          plotted=fltarr(transformsize(2),n_elements(plotted_freqax))
          plotted(*,0:(n_elements(plotted_freqax)-3))=temp
        endif
      	resolution = min([600, n_elements(plotted_freqax)])
      	plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      	pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)], $
      	  xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transfer_cscale,data=printdatas, /nearest,poster=poster
      endif else begin
        pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)]$
          ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))]$
          ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale'$
          ,title=title,opt=transfer_cscale,data=printdatas, /nearest,poster=poster
      endelse
    endif else begin
     title='Transfer function of '+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(1,i)+'--'+channelpairs_used(0,i)
     filename=pg_filename(title,dir=savepath)
     device,filename=filename
     printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
     title='Transfer function of!C'+expname+' '+nti_wavelet_i2str(shotnumber)+'-'+channelpairs_used(1,i)+'--'+channelpairs_used(0,i)
     pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)], $
     xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,opt=transfer_cscale,data=printdatas, /nearest,poster=poster
    endelse
  endfor

!P.COLOR = 0
endif

; Plot mode numbers
if mode_selection then begin
  print,'Plotting mode numbers'
  loadct,42,file=startpath+'nti_wavelet_colors.tbl'
  modescale=[mode_min,mode_max]
  printdatas=shot_printdatas+$
    transf_printdatas+$
    '!Caverages: '+nti_wavelet_i2str(coh_avr)+$
    '!Cfilter: '+nti_wavelet_i2str(mode_filter)+$
    '!Cmode steps / margin: '+pg_num2str(mode_steps,length=5)+$
    '!CCoherence limit: '+pg_num2str(mode_cohlimit)+' %'+$
    '!CPower limit: '+pg_num2str(mode_powlimit)+' %'+$    
    '!CQ limit: '+nti_wavelet_i2str(mode_qlimit)+' %'+$    
    '!Cchannel pairs: '+nti_wavelet_i2str(crosssize)
  for i=0,crosssize-1 do printdatas=printdatas+'!C '+channelpairs_used(0,i)+'--'+channelpairs_used(1,i)
  
  plotted=modenumbers
    
  ; Filter mode numbers
  ; Filter out modes out of plotted range
  notplotted=where((plotted LT modescale(0)) OR (plotted GT modescale(1)))
  if max(notplotted) GT -1 then plotted(notplotted)=1000
  ; Filter out modes with low coherence
  if mode_cohlimit NE 0. then begin
    mode_cohlimit=float(mode_cohlimit)/100.
    ; Calculate minimum coherence for coherence limit filtering
    limcoh=min(coherences,dimension=1)
    ; Do filtering
    notplotted=where(limcoh LT mode_cohlimit)
    if max(notplotted) GT -1 then plotted(notplotted)=1000
  endif
  ; Filter out modes with low power
  if mode_powlimit NE 0. then begin
    mode_powlimit=float(mode_powlimit)/100.
    ; Calculate average cross energy density for power limit filtering
    limpow=fltarr(transformsize(2),transformsize(3))
    if (size(smoothed_crosstransforms))(0) LT 2 then begin
      for i=0,transformsize(2)-1 do begin
        for j=0,transformsize(3)-1 do begin
          limpow(i,j)=mean(abs(crosstransforms(*,i,j))^2)
        endfor
      endfor
    endif else begin
      for i=0,transformsize(2)-1 do begin
        for j=0,transformsize(3)-1 do begin
          limpow(i,j)=mean(abs(smoothed_crosstransforms(*,i,j))^2)
        endfor
      endfor
    endelse
    limpow=limpow/max(limpow)
    ; Do filtering
    notplotted=where(limpow LT mode_powlimit)
    if max(notplotted) GT -1 then plotted(notplotted)=1000    
  endif
  ; Filter out modes with high fitting remainder
  if mode_qlimit NE 100. then begin
    mode_qlimit=float(mode_qlimit)/100.
    ; Calculate normalized Q matrix for Q limit filtering
    limq=qs/max(qs)
    ; Do filtering
    notplotted=where(limq GT mode_qlimit)
    if max(notplotted) GT -1 then plotted(notplotted)=1000        
  endif
  
  ; Set not defined mode numbers for plotting
  notplotted=where((plotted LT modescale(0)) OR (plotted GT modescale(1)))
  if max(notplotted) NE -1 then plotted(notplotted)=modescale(1)+(modescale(1)-modescale(0))/200.

  ;Set plotted frequency range
  plotted = plotted(*,min(freq_index):max(freq_index))
  
  ;Set if mode numbers should be integers on the colorscale
  if floor(mode_steps) EQ ceil(mode_steps) then integer_mode_scale = 1 else integer_mode_scale = 0

  if cwt_selection then begin
    title=mode_type+' mode numbers of '+expname+' '+nti_wavelet_i2str(shotnumber)
    filename=pg_filename(title,dir=savepath)
    device,filename=filename
    printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
    if linear_freqax then begin
      if freq_min_override then begin
        temp=plotted
        plotted=fltarr(transformsize(2),n_elements(plotted_freqax))+1000
        plotted(*,0:(n_elements(plotted_freqax)-3))=temp
      endif
      resolution = min([600, n_elements(plotted_freqax)])
      plotted = nti_wavelet_griddata(plotted, timeax, plotted_freqax, resolution)
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)] $
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
        ,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],intz=integer_mode_scale,poster=poster
    endif else begin
      pg_plot4,reverse(plotted,2),xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)] $
        ,/ylog,y2range=[min(-pg_log2(plotted_scaleax)),max(-pg_log2(plotted_scaleax))] $
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',y2title='-log base 2 of scale' $
        ,title=title,data=printdatas,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.] $
        ,intz=integer_mode_scale,poster=poster
    endelse
  endif else begin
    title=mode_type+' mode numbers of '+expname+' '+nti_wavelet_i2str(shotnumber)
    filename=pg_filename(title,dir=savepath)
    device,filename=filename
    printdatas='Time stamp: '+ nti_wavelet_time_id(filename)+'!C'+printdatas
      pg_plot4,plotted,xrange=[min(timeax),max(timeax)],yrange=[min(plotted_freqax),max(plotted_freqax)] $
        ,xtitle='Time (s)',ytitle='Frequency (kHz)',title=title,data=printdatas $
        ,/nearest,zrange=[modescale(0),modescale(1)+(modescale(1)-modescale(0))/200.],intz=integer_mode_scale,poster=poster
  endelse
endif

device,/close
pg_initgraph

end
