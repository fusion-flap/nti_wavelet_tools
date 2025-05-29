;+
;
;NAME: nti_wavelet_main
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2011.07.25.
;
; PURPOSE: Calculate scalograms (or spectrograms), cross/transforms, coherences and mode numbers
;       on the time-frequency plane.
;
; CALLING SEQUENCE (optional variables marked by []): 
;    nti_wavelet_main, data [,errdata] [,error] [,dtimeax] [,chpos] [,expname] [,shotnumber] [,timerange] $
;      [,channels] [,channelpairs_used] [,transf_selection] $
;      [,cwt_selection] [,cwt_family] [,cwt_order] [,cwt_dscale] $
;      [,stft_selection] [,stft_details] [,stft_window] [,stft_length] [,stft_fres] [,stft_step] $
;      [,freq_min] [,freq_max] $
;      [,crosstr_selection] [,coh_selection] [,coh_avr] [,transfer_selection]$
;      [,mode_selection] [,mode_type] [,mode_filter] $
;      [,mode_steps] [,mode_min [,mode_max] [,mode_optimized] [,startpath] $
;      [,timeaxg [,freqax] [,scaleax] [,transforms] [,smoothed_apsds] $
;      [,crosstransforms] [,smoothed_crosstransforms] $
;      [,coherences] [,transfers] [,modenumbers] [,qs] [,chi2]$
;      [,abs_errs] [,phase_errs] [,bicoh_selection] [,bispectrums] [,bicoherences]
;
; INPUTS:
;    data: data vectors, Float[number of data points, number of channels]
;    errdata: error on the data vectors, Float[number of data points, number of channels]
;    error: selecting to calculate error on STFT, Int; default: 0
;    dtimeax: time axis of data vectors in s, Double[number of data points]
;    chpos: for 1D mode number determination (IDL): channel positions in radian, Double[number of channels]
;           for 2D mode number determination (Python): [phi,theta] channel positions in radian, Double[2,number of channels]
;    expname: name of the experiment, String (for example: SXR, MHA); default: 'General'
;    shotnumber: shot number, Long; default: 0
;    timerange: timerange to view in s, Double[2]; default: the start and the end of the time axis
;    channels: channel names, String[number of channels]; default: integer indexes
;    channelpairs_used: the used channel pairs, String[2,number of selected channel pairs]; default: all possible pairs
;    transf_selection: selecting to calculate transforms, Int; default: 1
;    cwt_selection: selecting CWT as transformation, Int; default: 1
;    cwt_family: wavelet family, String; default: 'Morlet'
;    cwt_order: order of wavelet, Long; range: 3 - 24; default: 6 
;    cwt_dscale: fraction of diadic scaling, Double, default: 0.1
;    stft_selection: selecting STFT as transformation. Presently unused, not(cwt_selection) is used.
;    stft_details: if set, detailed_transforms and detailed_crosstransforms are calculated
;    stft_window: window type, String; default: 'Gauss'
;    stft_length: the length of the window in number os data points, Double; default: 50
;    stft_fres: number of frequency samlpes of STFT in number of frequency points, Long; default: 1000
;    stft_step: length of time steps of STFT in number of data points, Long; default: 1
;    freq_min: minimum frequency in kHz, Double; default for STFT: 0, for CWT: the possibly smallest frequency
;    freq_max: maximum frequency in kHz, Double; default: the half of the sampling rate (Nyquist-frequency)
;    prime_limit: in case of non exact time axis, the biggest prime number in the factorization of the datalength
;    exact_limit: the smallest number of datapoints, where non-exact time axis can be used
;    crosstr_selection: selecting to calculate cross-transforms, Int; default: 1
;    coh_selection: selecting to calculate coherences, Int; default: 1 
;    coh_avr: number of averages, Long; default: 5
;    transfer_selection: selecting to calculate transfer functions, Int; default: 1 
;    mode_selection: selecting to calculate mode numbers, Int; default: 1 
;    mode_type: type of the mode number, Srting; default: 'Toroidal'
;    mode_filter: type of the mode filter, String; default: 'Rel. pos.'
;    mode_steps: steps between the calculated mode numbers, Double/Int; default: 1
;    mode_min: minimum mode number, Double/Int; default: -6
;    mode_max: maximum mode number, Double/Int; default: 6
;    mode_optimized: calculate mode numbers with matrix products (high memory consumption!)
;    startpath: start path, String; default: current directory
;
;    bicoh_selection: selecting to calculate (STFT) bicoherence, Int; default: 0
;    bicoh_avr: number of averages of bicoherence, Long; default: coh_avr
;
; OUTPUTS:
;    timeax: time axis of transforms in s, Float[number of points in the time axis of the transform]
;    freqax: frequency axis in kHz, Float[number of points in the frequency axis of the transform]
;    scaleax: scale axis (for CWT), Float[number of points in the frequency axis of the transform]
;    transforms: the transformated values, 
;      Complex[number of channels, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    smooth_apsds: the smoothed APSD (auto power density),
;      Float[number of channels, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    crosstransforms: the cross-transform values,
;      Complex[number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    smoothed_cosstransforms: the smoothed cross-transform values,
;      Complex[number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    coherences: the calculated coherences
;      Float[number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    transfers: the calculated transfer functions
;      Complex[2,number of selected channel pairs, number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    modenumbers: the calculated mode numbers
;      Float[number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    qs: the calculated q fitting parameter values
;      Float[number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    chi2: the calculated chi2 values for most fitting mode at each time-frequency point
;      Float[number of points in the time axis of the transform,number of points in the frequency axis of the transform]
;    detailed_transforms: structure containing data calculated from STFT transforms and their errors (if set)
;	detailed_transforms.abs.value: absolute value of the STFT
;	detailed_transforms.abs.error: error on the absolute value of the STFT
;	detailed_transforms.phase.value: phase of the STFT
;	detailed_transforms.phase.error: error on the phase of the STFT
;	detailed_transforms.ed.value: energy density caluclated from STFT
;	detailed_transforms.ed.error: error on the energy density
;    detailed_crosstransforms: structure containing data calculated from STFT cross-transforms and their errors (if set)
;	detailed_crosstransforms.abs.value: absolute value of the crosstransforms
;	detailed_crosstransforms.abs.error: error on the absolute value of the crosstransforms
;	detailed_crosstransforms.phase.value: phase of the crosstransforms
;	detailed_crosstransforms.phase.error: error on the phase of the crosstransforms
;
;    bispectrums: the values of (STFT) bispectrum
;    bicoherences: the values of (STFT) bicoherence
;
;-

pro nti_wavelet_main,$
  ; Input
    data=data, errdata=errdata, error=error, dtimeax=dtimeax, chpos=chpos, expname=expname, shotnumber=shotnumber, $
    timerange=timerange, channels=channels, channelpairs_used=channelpairs_used, transf_selection=transf_selection,$
    cwt_selection=cwt_selection, cwt_family=cwt_family, cwt_order=cwt_order, cwt_dscale=cwt_dscale,$
    stft_selection=stft_selection, stft_details=stft_details, stft_window=stft_window, stft_length=stft_length, $
    stft_fres=stft_fres, stft_step=stft_step, freq_min=freq_min, freq_max=freq_max, $
    prime_limit=prime_limit, exact_limit=exact_limit, $
    crosstr_selection=crosstr_selection, crosstr_correction_selection = crosstr_correction_selection, $
    coh_selection=coh_selection, coh_avr=coh_avr, transfer_selection=transfer_selection, $
    mode_selection=mode_selection, mode_type=mode_type, mode_filter=mode_filter,$
    mode_steps=mode_steps, mode_min=mode_min, mode_max=mode_max, mode_optimized = mode_optimized, startpath=startpath,$
    bicoh_selection = bicoh_selection, bicoh_avr = bicoh_avr, $
  ; Output
    timeax=timeax, freqax=freqax, scaleax=scaleax, transforms=transforms, smoothed_apsds=smoothed_apsds,$
    crosstransforms=crosstransforms, smoothed_crosstransforms=smoothed_crosstransforms,$
    coherences=coherences, transfers=transfers, modenumbers=modenumbers, qs=qs, chi2=chi2, $
    detailed_transforms=detailed_transforms, detailed_crosstransforms=detailed_crosstransforms, $
    bispectrums = bispectrums, bicoherences = bicoherences

compile_opt defint32 ; 32 bit integers

; Set defaults and constants
datasize=size(data) ; First index is time, second is channel
nti_wavelet_default,expname,'General'
nti_wavelet_default,shotnumber,0
nti_wavelet_default,timerange,[min(dtimeax),max(dtimeax)]
nti_wavelet_default,channels,string(indgen(datasize(2)))
if not(nti_wavelet_defined(channelpairs_used)) then begin
  channelpairs_used=strarr(2, (datasize(2)*(datasize(2)-1)/2))
  k=0
  for i=0L,datasize(2)-1 do begin
    for j=i+1,datasize(2)-1 do begin
      channelpairs_used(0,k)=channels(i)
      channelpairs_used(1,k)=channels(j)
      k=k+1
    endfor
  endfor
endif
nti_wavelet_default,transf_selection,1
nti_wavelet_default,cwt_selection,1
nti_wavelet_default,cwt_family,'Morlet'
nti_wavelet_default,cwt_order,6
nti_wavelet_default,cwt_dscale,0.1
stft_selection = not(cwt_selection)
nti_wavelet_default,stft_window,'Gauss'
nti_wavelet_default,stft_length,50
nti_wavelet_default,stft_fres,1000
nti_wavelet_default,stft_step,1
nti_wavelet_default,prime_limit,1000
nti_wavelet_default,exact_limit,5000
if not(nti_wavelet_defined(freq_min)) then freq_min=0 else freq_min=double(freq_min)
if not(nti_wavelet_defined(freq_max)) then freq_max=1.0e32 else freq_max=double(freq_max)
nti_wavelet_default,crosstr_selection,1
nti_wavelet_default,coh_selection,1
nti_wavelet_default,coh_avr,5
nti_wavelet_default,transfer_selection,1
nti_wavelet_default,mode_selection,1
nti_wavelet_default,mode_type,'Toroidal'
nti_wavelet_default,mode_filter,'Rel. pos.'
nti_wavelet_default,mode_steps,1
nti_wavelet_default,mode_min,-6
nti_wavelet_default,mode_max,6
nti_wavelet_default,mode_optimized,0
nti_wavelet_default,error,0
nti_wavelet_default, stft_details, 0
;stft_details is necessary to estimate errors
if error then stft_details = 1
nti_wavelet_default,errdata,0*data
if not(nti_wavelet_defined(startpath)) then begin 
	cd, current=startpath
	startpath = startpath + '/'
endif
nti_wavelet_default, bicoh_selection, 0
nti_wavelet_default, bicoh_avr, coh_avr

print, mode_type

;Set size of channelpairs_used:
size_channelpairs_used = size(channelpairs_used)
if (size_channelpairs_used(0) eq 1) then begin
  channelpairs_used = reform(channelpairs_used, 2, 1)
endif

channelsize=n_elements(channels)
crosssize=(size(channelpairs_used))(2)
down_timeax=dtimeax
oldsize=n_elements(down_timeax)

; Downsampling to freq_max
if down_timeax(oldsize-1)-down_timeax(0) LT (oldsize-1)/(freq_max*1000*2) then begin
  print,'Downsampling data'
  timesize=floor((down_timeax(oldsize-1)-down_timeax(0))*freq_max*1000*2)

  while max(nti_wavelet_prime_factor(timesize)) gt prime_limit do begin
    timesize+=1
  endwhile
  nti_wavelet_gui_addmessage, addtext='Optimized frequency range: ' + pg_num2str(timesize/2./1000./(down_timeax(oldsize-1)-down_timeax(0))) + ' kHz'
  ; Resample data
  data_resampled=fltarr(timesize,channelsize)
  for i=0,channelsize-1 do begin
    data_resampled(*,i)=pg_resample(reform(data(*,i)),timesize)
  endfor
  data=data_resampled
  ; Resample errdata (if neecessary)
  if error then begin
    errdata_resampled=fltarr(timesize,channelsize)
    for i=0,channelsize-1 do begin
      errdata_resampled(*,i)=pg_resample(reform(errdata(*,i)),timesize)
    endfor
    errdata=errdata_resampled
  endif
  datasize=size(data)
  freq_max = 5d-4/((down_timeax(oldsize - 1) - down_timeax(0))/(oldsize - 1))/oldsize*timesize  ; 5e-4 = 1/1000/2
  down_timeax=down_timeax(0)+dindgen(timesize)/(freq_max*1000*2) ; New time axis
  timesize=n_elements(down_timeax)
endif

; Calculate energy-density distributions
if transf_selection then begin
  if cwt_selection then begin
    ; Calculate minimum frequency for CWT
    dt=double(down_timeax(n_elements(down_timeax)-1)-down_timeax(0))/double(n_elements(down_timeax)-1)
    freq_min=max([freq_min*1000,max([1,coh_avr])*cwt_order*2/(down_timeax(n_elements(down_timeax)-1)-down_timeax(0))]) ; in Hz
    start_scale=cwt_order/!PI
    max_scale=cwt_order/freq_min/2/!PI/dt
    nscale=ceil(pg_log2(max_scale/start_scale)/cwt_dscale)+1 ; Calculate nscale from minimum frequency
    freq_min=freq_min/1000. ; Conver to kHz and return
    
  	print,'CWT for '+nti_wavelet_i2str(shotnumber)+channels(0)
  	time=down_timeax ; Load original time axis for new data
  	transform=pg_scalogram_sim2(data(*,0),time,shot=shotnumber,channel=channels(0),trange=timerange,family=cwt_family,order=cwt_order,dscale=cwt_dscale,$
  		start_scale=start_scale, nscale=nscale, plot=-1, /pad,	freqax=freqax, scaleax=scaleax, /double)
	  time = float(time)
	  freqax = float(freqax)
	  scaleax = float(scaleax)
  	transformsize=size(transform)
  	transforms=complexarr(channelsize,transformsize(1),transformsize(2))
  	transforms(0,*,*)=transform
  	for i=1,channelsize-1 do begin
  		print,'CWT for '+nti_wavelet_i2str(shotnumber)+channels(i)
  		time=down_timeax ; Load original time axis for new data
  		transforms(i,*,*)=pg_scalogram_sim2(data(*,i),time,shot=shotnumber,channel=channels(i),trange=timerange,family=cwt_family,order=cwt_order,dscale=cwt_dscale,$
  			start_scale=start_scale, nscale=nscale, plot=-1, /pad,	freqax=freqax, scaleax=scaleax, /double)
  	endfor
	  time = float(time)
	  freqax = float(freqax)
	  scaleax = float(scaleax)
  endif else begin
  	print,'STFT for '+nti_wavelet_i2str(shotnumber)+channels(0)
  	freqres=stft_fres*2-1
  	masksize=stft_fres*2-1
  	time=down_timeax ; Load original time axis for new data
  	transform=pg_spectrogram_sim(data(*,0),time,shot=shotnumber,channel=channels(0),trange=timerange,windowname=stft_window, $
  		windowsize=stft_length,masksize=masksize,step=stft_step, freqres=freqres, plot=-1, freqax=freqax, /double, $
		errdata=errdata(*,0), abs_err=abs_err, phase_err=phase_err, error=error)
	  time = float(time)
	  freqax = float(freqax)
  	transformsize=size(transform)
  	transformsize(2)=transformsize(2)/2+1 ;Store for positive frequencies only
  	transforms=complexarr(channelsize,transformsize(1),transformsize(2))
  	transforms(0,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
	if stft_details then begin
	  ;Create detailed_transforms structure
	  detailed_transforms={abs:{value:fltarr(channelsize,transformsize(1),transformsize(2)),error:fltarr(channelsize,transformsize(1),transformsize(2))},$
			phase:{value:fltarr(channelsize,transformsize(1),transformsize(2)),error:fltarr(channelsize,transformsize(1),transformsize(2))},$
			ed:{value:fltarr(channelsize,transformsize(1),transformsize(2)),error:fltarr(channelsize,transformsize(1),transformsize(2))}}
	  if error then begin
	    detailed_transforms.abs.error=fltarr(channelsize,transformsize(1),transformsize(2))
	    detailed_transforms.abs.error(0,*,*)=abs_err(*,0:transformsize(2)-1) ;Store for positive frequencies only
	    detailed_transforms.phase.error=fltarr(channelsize,transformsize(1),transformsize(2))
	    detailed_transforms.phase.error(0,*,*)=phase_err(*,0:transformsize(2)-1) ;Store for positive frequencies only
	  endif
	endif
  	for i=1,channelsize-1 do begin
  		print,'STFT for '+nti_wavelet_i2str(shotnumber)+channels(i)
  		time=down_timeax ; Load original time axis for new data
  		transform=pg_spectrogram_sim(data(*,i),time,shot=shotnumber,channel=channels(i),trange=timerange,windowname=stft_window, $
  			windowsize=stft_length,masksize=masksize,step=stft_step, freqres=freqres, plot=-1, freqax=freqax, /double, $
			errdata=errdata(*,i), abs_err=abs_err, phase_err=phase_err, error=error)
  		transforms(i,*,*)=transform(*,0:transformsize(2)-1) ;Store for positive frequencies only
		if error then begin
		  detailed_transforms.abs.error(i,*,*)=abs_err(*,0:transformsize(2)-1) ;Store for positive frequencies only
		  detailed_transforms.phase.error(i,*,*)=phase_err(*,0:transformsize(2)-1) ;Store for positive frequencies only
		endif

  	endfor
	  time = float(time)
	  freqax = float(freqax)
	  stft_fres = ceil(freqres/2.)
	;Calculate detailed_transforms
	  if stft_details then begin
	    ;Absolute value
	    detailed_transforms.abs.value=abs(transforms)
	    ;Phase
	    detailed_transforms.phase.value=atan(transforms, /phase)
	    ;Energy density
	    detailed_transforms.ed.value=2*(abs(transforms)^2)
	    if error then begin
	      detailed_transforms.ed.error=4*abs(transforms)*detailed_transforms.abs.error
	    endif
	  endif

  endelse
  timeax=time ;Set new time axis
  timesize=n_elements(timeax)
endif

;Calculate transformsize again:
  transformsize=size(reform(transforms(0,*,*)))

if crosstr_selection then begin
  ; Create arrays for crosstransforms
  crosstransforms=complexarr(crosssize,transformsize(1),transformsize(2))

  ;Create detailed_crosstransforms structure
  if error then begin
    detailed_crosstransforms={abs:{value:fltarr(crosssize,transformsize(1),transformsize(2)),error:fltarr(crosssize,transformsize(1),transformsize(2))},$
			phase:{value:fltarr(crosssize,transformsize(1),transformsize(2)),error:fltarr(crosssize,transformsize(1),transformsize(2))}}
  endif

  ;Calculate crosstransforms
  for i=0,crosssize-1 do begin
  	print,'Crosstransforms for '+nti_wavelet_i2str(shotnumber)+channelpairs_used(*,i)
  	wait,0.1
  	temp_=(where(channels EQ channelpairs_used(0,i)))(0)
  	transform1=reform(transforms(temp_,*,*))
  	temp_=(where(channels EQ channelpairs_used(1,i)))(0)
  	transform2=reform(transforms(temp_,*,*))
  	crosstransforms(i,*,*)=conj(transform1)*transform2 ; Calculate cross-transform

	;Calculate detailed_crosstransforms
	if error then begin
	  ;Absolute value
	  detailed_crosstransforms.abs.value(i,*,*)=abs(crosstransforms(i,*,*))
	  errtransform1=reform(detailed_transforms.abs.error(where(channels EQ channelpairs_used(0,i)),*,*))
	  errtransform2=reform(detailed_transforms.abs.error(where(channels EQ channelpairs_used(1,i)),*,*))
	  detailed_crosstransforms.abs.error(i,*,*)=sqrt((abs(transform1)*errtransform2)^2+(abs(transform2)*errtransform1)^2)
	  ;Phase
	  detailed_crosstransforms.phase.value(i,*,*)=atan(crosstransforms(i,*,*), /phase)
	  errtransform1=reform(detailed_transforms.phase.error(where(channels EQ channelpairs_used(0,i)),*,*))
	  errtransform2=reform(detailed_transforms.phase.error(where(channels EQ channelpairs_used(1,i)),*,*))
	  detailed_crosstransforms.phase.error(i,*,*)=sqrt(errtransform1^2+errtransform2^2)
	endif
  endfor
  
  ;Calculate cross-phase correction:
  if crosstr_correction_selection then begin
    nti_wavelet_crossphase_correction, $
      expname = expname, startpath = startpath, channelpairs_used = channelpairs_used, $
      timeax = timeax, freqax = freqax, $
      crosstransforms = crosstransforms, /calculate_correction
    ;Modify detailed_crosstransforms using the corrected data:
    if error then begin
      detailed_crosstransforms.phase.value=atan(crosstransforms, /phase)
    endif
  endif
  
endif

if coh_selection then begin
  ; Create array for coherences
  coherences=fltarr(crosssize,transformsize(1),transformsize(2))

  ; Create array for transfer functions
  if transfer_selection then begin
  transfers=complexarr(2,crosssize,transformsize(1),transformsize(2))
  endif
  
  ; Calculate smoothed energy density distributions
   if (coh_avr GT 0) then begin
    print,'Smoothing energy density distributions'
    wait,0.1
    smoothed_apsds=fltarr(channelsize,transformsize(1),transformsize(2))
    for i=0,channelsize-1 do begin
      if cwt_selection then begin
        ; Time intergration
        for k=0,transformsize(2)-1 do begin
          inttime=ceil(scaleax(k)*coh_avr*2.)
          if inttime GT transformsize(1) then begin
            print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
            inttime=transformsize(1)
          endif
          smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,inttime, /EDGE_TRUNCATE)
        endfor
      endif else begin
        inttime=coh_avr*stft_length/stft_step
        if inttime GT transformsize(1) then begin
          print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
          inttime=transformsize(1)
        endif
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_apsds(i,*,k)=smooth(abs(reform(transforms(i,*,k)))^2,inttime, /EDGE_TRUNCATE)
      endelse
    endfor
    
    ; Calculate smoothed cross-transforms
    print,'Smoothing cross-transforms'
    wait,0.1
    smoothed_crosstransforms=complexarr(crosssize,transformsize(1),transformsize(2))
    for i=0,crosssize-1 do begin
      if cwt_selection then begin
        ; Time intergration
        for k=0,transformsize(2)-1 do begin
          inttime=ceil(scaleax(k)*coh_avr*2.)
          if inttime GT transformsize(1) then begin
            print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
            inttime=transformsize(1)
          endif
          smoothed_crosstransforms(i,*,k)=smooth(reform(crosstransforms(i,*,k)),inttime, /EDGE_TRUNCATE)
        endfor
      endif else begin
        inttime=coh_avr*stft_length/stft_step
        if inttime GT transformsize(1) then begin
          print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
          inttime=transformsize(1)
        endif
        ; Time intergration
        for k=0,transformsize(2)-1 do $
          smoothed_crosstransforms(i,*,k)=smooth(reform(crosstransforms(i,*,k)),inttime, /EDGE_TRUNCATE)
      endelse
    endfor
  endif else begin
    smoothed_apsds=abs(transforms)^2
    smoothed_crosstransforms=crosstransforms
  endelse
  
  ;Calculate coherence
  print,'Calculate coherences'
  for i=0,crosssize-1 do begin
    smoothed_apsd1=reform(smoothed_apsds(where(channels EQ channelpairs_used(0,i)),*,*))
    smoothed_apsd2=reform(smoothed_apsds(where(channels EQ channelpairs_used(1,i)),*,*))
    coherences(i,*,*)=float(abs(reform(smoothed_crosstransforms(i,*,*)))/sqrt(smoothed_apsd1*smoothed_apsd2))
  endfor

  ;Calculate transfer function
  if transfer_selection then begin
    print,'Calculate transfer functions'
    for i=0,crosssize-1 do begin
      transfers(0,i,*,*)=complex(reform(smoothed_crosstransforms(i,*,*))/smoothed_apsd1)
      transfers(1,i,*,*)=complex(reform(smoothed_crosstransforms(i,*,*))/smoothed_apsd2)
    endfor
  endif
endif

if mode_selection then begin
  ; Calculate mode numbers on the time-frequency plane
  print,'Mode numbers for '+nti_wavelet_i2str(shotnumber)
  wait,0.1
  ; Create array for mode numbers
  modenumbers=fltarr(transformsize(1),transformsize(2))+1000 ; Initialize mode number arraz with 1000 standing for undefined
  qs=fltarr(transformsize(1),transformsize(2))
  chi2=fltarr(transformsize(1),transformsize(2))
  if (size(smoothed_crosstransforms))(0) LT 2 then $ ; Calculate cross-phase
    cphases=atan(imaginary(crosstransforms),float(crosstransforms))$
    else $
    cphases=atan(imaginary(smoothed_crosstransforms),float(smoothed_crosstransforms))
    
  if (size(chpos))(0) EQ 1 then begin ; In case of 1D chpos array, determine mode numbers in IDL
    ; Fill 2D chpos array
    chpos2D=fltarr(2,crosssize)
    for i=0,1 do begin
      for j=0,crosssize-1 do begin
        chpos2D(i,j)=chpos((where(channels EQ channelpairs_used(i,j)))(0))
      endfor
    endfor
    if mode_optimized eq 0 then begin
      T=systime(1) ; Initialize progress indicator
      for i=0,transformsize(1)-1 do begin
        for j=0,transformsize(2)-1 do begin
          case mode_filter of 
            'Rel. pos.': begin
              ; Filter Rel. Pos.: positive-negative mode numbers from relative positions
              ; (linear fit with weighting 1)
              m0=pg_modefilter_fitrel(reform(cphases(*,i,j)),chpos2D,$
                modestep=mode_steps, moderange=[mode_min,mode_max],qs=qs_all,ms=ms_all,chi2=chi2_all)
              if NOT(m0 EQ 1000) then begin
                modenumbers(i,j)=m0
                qs(i,j)=min(qs_all)
                chi2(i,j)=chi2_all(where(ms_all EQ m0))
              endif
            end
            'Monotonic': begin
              ; Filter Monotonic: trying to arrange monotonic phase diagram withi a tolerance by adding +-2*pi-s
              m0=pg_modefilter_monoton(reform(cphases(*,i,j)),chpos,$
                marginfraction=mode_steps, moderange=[mode_min,mode_max],ms=ms_all)
              if NOT(m0 EQ 1000) then begin
                modenumbers(i,j)=m0
                ; Fill matrixes with zeros for contingency
                qs_all=ms_all*0
                qs(i,j)=min(qs_all)
                chi2_all=qs_all
                chi2(i,j)=chi2_all(where(ms_all EQ m0))
              endif
            end
          endcase
          ; Progress indicator
          if floor(systime(1)-T) GE 10 then begin
            print, pg_num2str(double(i)/double(transformsize(1))*100.)+' % done'
            T=systime(1)
            wait,0.1
          endif
        endfor
      endfor
    endif else begin
    ; Calculate mode number in an optimezed way (matrix products):
      print, 'Optimized modenumber calculations'
      case mode_filter of 
        'Rel. pos.': begin
          ; Filter Rel. Pos.: positive-negative mode numbers from relative positions
          ; (linear fit with weighting 1)
          modenumbers=nti_wavelet_modefilter_fitrel_matrix(cphases,chpos2D,$
            modestep=mode_steps, moderange=[mode_min,mode_max],qs=qs,chi2=chi2)
        end
        'Monotonic': begin
          ; Not available
          nti_wavelet_gui_addmessage, addtext='Optimized calculation not available for Monotonic filter.'
          nti_wavelet_gui_addmessage, addtext='Mode numbers NOT calculated!'
        end
      endcase
    endelse
  endif else begin ; In case of 2D chpos array, send data to python routine for combined (n,m) analysis
    if check_idl_python_bridge(startpath) then begin
       mode_number_module = Python.Import('python.mode_number.mode_number_fit')
       fit_result = mode_number_module.fit_mode_number(chpos, cphases, $
          [mode_min,mode_max], [mode_min,mode_max], mode_steps, mode_steps)
       modenumbers = fit_result([0,1],*,*)
       qs = fit_result(2,*,*)
       print, 'Plotting of 2D mode number analysis results not available in GUI!'
    endif else begin
       print, '2D mode number analysis not available due to error in the IDL-Python bridge!'
    endelse
  endelse
endif

;Calculate bicoherence
if bicoh_selection then begin
  if stft_selection then begin
  	print,'Bicoherence for '+nti_wavelet_i2str(shotnumber)+channels(0)
	trsize = size(transforms)	;dimension of transforms array
  	length = trsize(2)	;number of time points
  	bispectrum = dcomplexarr(trsize(2), trsize(3), ceil(0.5*trsize(3)))
  	normfactor1 = dblarr(trsize(2), trsize(3), ceil(0.5*trsize(3)))
  	normfactor2 = dblarr(trsize(2), trsize(3), ceil(0.5*trsize(3)))

  	bispectrumsize=size(bispectrum)
  	bispectrums=dcomplexarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
  	normfactor1s=dcomplexarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
  	normfactor2s=dcomplexarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
  	for k=0,channelsize-1 do begin
  		print,'Bicoherence for '+nti_wavelet_i2str(shotnumber)+channels(k)
		;Calculate bispectrum
		;--------------------
		  for i = 0L, length-1 do begin
		    ;Transforms value of frequency_1:
		    freq1 = dcomplex(reform(transforms(k, i, *)))
		    ;Transforms value of frequency_2:
		    freq2 = dcomplex(reform(transforms(k, i, 0:ceil(0.5*trsize(3))-1)))
		    ;Transforms value of frequency_1 + frequency_2:
		    freq12 = dcomplexarr(trsize(3), ceil(0.5*trsize(3)))
		      endloop = ceil(0.5*trsize(3))-1	; end of for loop
		    for j = 0L, endloop do begin
		      freq12(*,j) = shift(freq1,-j)
		    endfor
		    for j = 1L, endloop do begin
		      freq12(0:j-1,j) = dcomplex(0)
		      freq12(trsize(3)-j:trsize(3)-1,j) = dcomplex(0)
		    endfor
		    ;Bispectrum:
		    bispectrum(i,*,*) = conj(freq12) * (freq2 ## freq1)
		;Calculate norm factor1
		;----------------------
		    normfactor1(i,*,*) = (abs(freq2 ## freq1))^2
		    for j = 1L, endloop do begin
		      normfactor1(i,0:j-1,j) = dcomplex(1)
		      normfactor1(i,trsize(3)-j:trsize(3)-1,j) = dcomplex(1)
		    endfor
		;Calculate norm factor2
		;----------------------
		    normfactor2(i,*,*) = (abs(freq12))^2
		    for j = 1L, endloop do begin
		      normfactor2(i,0:j-1,j) = dcomplex(1)
		      normfactor2(i,trsize(3)-j:trsize(3)-1,j) = dcomplex(1)
		    endfor
		  endfor
		;--------------------
		bispectrums(k,*,*,*) = bispectrum
		normfactor1s(k,*,*,*) = normfactor1
		normfactor2s(k,*,*,*) = normfactor2
  	endfor
  	
  	;Calculate bicoherence (smoothing)
  	;---------------------------------
  	smoothed_bispectrums = dcomplexarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
  	smoothed_normfactor1s = dblarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
  	smoothed_normfactor2s = dblarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
  	bicoherences = dblarr(channelsize,bispectrumsize(1),bispectrumsize(2),bispectrumsize(3))
	for i=0,channelsize-1 do begin
	  inttime=bicoh_avr*stft_length/stft_step
	  if inttime GT trsize(2) then begin
	    print,'Smoothing with kernel longer than the time vector not possible, kernel size reduced!'
	    inttime=trsize(2)
	  endif
	  ; Time intergration
	    endloop = ceil(0.5*trsize(3))-1
	  for k = 0, trsize(3)-1 do begin
	    for l = 0, endloop do begin
	      smoothed_bispectrums(i,*,k,l)=smooth(reform(bispectrums(i,*,k,l)), inttime, /EDGE_TRUNCATE)
	      smoothed_normfactor1s(i,*,k,l)=smooth(reform(normfactor1s(i,*,k,l)), inttime, /EDGE_TRUNCATE)
	      smoothed_normfactor2s(i,*,k,l)=smooth(reform(normfactor2s(i,*,k,l)), inttime, /EDGE_TRUNCATE)
	    endfor
	  endfor
	endfor
	bicoherences = abs(smoothed_bispectrums)/sqrt(smoothed_normfactor1s*smoothed_normfactor2s)
  endif else begin
    print, 'Bicoherence calculation is only available in the case of STFT'
  endelse
endif

end