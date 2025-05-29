;+
; NAME:
;  NTI_WAVELET_PLOT_STFT_BICOH
;
; PURPOSE:
;  This program plots the loaded STFT bicoherence data: 
;  2D frequency1-frequency2 plots for given time points
;  and time-frequency2 plots for given frequency1 values.
;
; CALLING SEQUENCE:
;   NTI_WAVELET_PLOT_STFT_BICOH, [,bicoherences] [,timeax] $
;   [,times] [,freqs] $
;   [,expname] [,shotnumber] [,channels] $
;   [,stft_window] [,stft_length] [,stft_fres] [,stft_step] $
;   [,bicoh_avr] [,opt=opt]
;
; INPUTS:
;   bicoherences:   This array contains the STFT bicoherence matrices given by
;                   nti_wavelet_main.pro.
;   timeax:         The time axis of the STFT bicoherences given by
;                   nti_wavelet_main.pro.
;   freqax:         The frequency axis of the STFT bicoherences given by
;                   nti_wavelet_main.pro.
;   times:          Array containing the time points where 2D frequency1-frequency2
;                   bicoherence plots will be created.
;   freqs:          Array containing the frequency1 values for time-frequency2 
;                   bicoherence plots.
;   expname:        Name of the experiment from which the signals originate.
;   shotnumber:     Number of the shot from which the signals originate.
;   channels:       Name of the channels.
;   stft_window:    The type of the window used to calculate STFT.
;                   (given by nti_wavelet_main.pro)
;   stft_length:    The length of the window used to calculate STFT.
;                   (given by nti_wavelet_main.pro)
;   stft_fres:      The frequency resolution of STFT.
;                   (given by nti_wavelet_main.pro)
;   stft_step:      Length of time steps of STFT.
;                   (given by nti_wavelet_main.pro)
;   bicoh_avr:      The number of averages of bicoherence.
;                   (given by nti_wavelet_main.pro)
;   opt:            Color scale optimization factor for plots.
;
;-

pro nti_wavelet_plot_stft_bicoh, bicoherences=bicoherences, timeax=timeax, freqax=freqax, $
    times=times, freqs=freqs, $
    expname=expname, shotnumber=shotnumber, channels=channels, $
    stft_window=stft_window, stft_length=stft_length, $
    stft_fres=stft_fres, stft_step=stft_step, $
    bicoh_avr=bicoh_avr, opt=opt

; Setting defautls
; ----------------
  ; Input parameters:
  nti_wavelet_default,times,[0]
  nti_wavelet_default,freqs,[0]
  nti_wavelet_default,expname,'-'
  nti_wavelet_default,shotnumber,'-'
  nti_wavelet_default,channels,'-'
  nti_wavelet_default,revision,0
  nti_wavelet_default,opt,1

  ; Plot parameters:
  bicoh_title='Bicoherence'
  bicoh_xtitle='Frequency 1 [kHz]'
  bicoh_ytitle='Frequency 2 [kHz]'
  cs_xtitle='Bicoherence'

; Read revision
; -------------
  svn_data=strarr(5)
  svn_path='./.svn/entries'
  ; .svn directory found, but can we open it?
  openr,unit,svn_path,/get_lun,error=error
  if error ne 0 then begin 
    print, 'Subversion file could not be opened at '+svn_path
  endif else begin
    readf,unit,svn_data
  endelse
  revision=fix(svn_data[3])
  
; Create frequency1-frequency2 bicoherence plots
; ----------------------------------------------
if NOT (times EQ [0]) then begin
  ; Number of frequency1-frequency2 bicoherence plots:
  ntimes = n_elements(times)
  ; Create plot in each time point:
  for k = 0,ntimes-1 do begin
    ; Find timepoint:
    time = times(k)
    i = where(min(timeax - time, /abs) eq (timeax - time))
    time = timeax(i)

    ; Create plot for all channels:
    nchannels = n_elements(channels)
    for m = 0, nchannels-1 do begin
      ; Find bicoherence matrix:
      bicoh = reform(bicoherences(m,i,*,*))
      ; Create frequency axes:
        ; Frequency axes of x direction:
        xfreqax=freqax
        ; Frequency axes of y direction:
        yfreqax=freqax(0:n_elements(freqax)/2-1)
      ; Points out of domain set to 1:
      plot_bicoh=bicoh
      endloop = n_elements(yfreqax)-1; end of for loop
      length = n_elements(xfreqax)
      for j = 1L, endloop do begin
        plot_bicoh(0:j-1,j) = 1
        plot_bicoh(length-j:length-1,j) = 1
      endfor
  
      ; Plot bicoherence:
        ; Setting path and name:
        date=bin_date(systime())
        date=nti_wavelet_i2str(date[0])+'-'+nti_wavelet_i2str(date[1])+'-' $
          +nti_wavelet_i2str(date[2])
        path='./bicoherence_data/'
        file_mkdir,path
        name='Bicoherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+' ' $
          +channels(m)+' '+pg_num2str(timeax(i))+'s'
        filename=pg_filename(name,dir=path, ext='.eps')

        ; Initializing printing parameters:
        pg_initgraph,/print
        !P.FONT=0
        device,bits_per_pixel=8,font_size=8,/portrait,/color,$
          /encapsulated,/cmyk,/preview
        device, filename=filename

        ; Transform bicoherence matrix for plot:
          ; Color scale optimization:
          plot_bicoh = plot_bicoh^opt
          plot_bicoh=plot_bicoh*255

        ; Load color table:
        loadct,5

        ; Plot axes:
        plot,[min(xfreqax),max(xfreqax)],[min(yfreqax),max(yfreqax)], $
          xmargin=[10.5,4.5],ymargin=[10,3],title=bicoh_title, $
          xtitle=bicoh_xtitle,ytitle=bicoh_ytitle,/nodata, $
          xstyle=1,ystyle=1,xticklen=-0.01,yticklen=-0.01, $
          charsize=2,charthick=3,xthick=3,ythick=3

        ; Plot bicoherence matrix:
        px=!x.window
        py=!y.window
        tv,plot_bicoh,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal

        ; Initialize color scale:
        cscale=fltarr(256,2)
        cscale[*,0]=findgen(256)/255.
        cscale[*,1]=findgen(256)/255.
        axis=cscale[*,0]
        ; Color scale optimization:
        cscale = cscale^opt
        cscale = cscale*255.

        ; Plot axes of color scale:
        plot,[0,1],axis,/nodata,xstyle=1,ystyle=1,yrange=[0,1], $
          yticklen=0,ytitle='',xmargin=[14,51],ymargin=[5,34], $
          ytickname=[' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '], $
          xrange=[min(axis),max(axis)],xtitle=cs_xtitle, $
          NOERASE=1,xthick=3,ythick=3,charsize=1.3,charthick=2

        ; Plot color scale:
        px=!x.window
        py=!y.window
        tv,cscale,px(0),py(0),xsize=px(1)-px(0),ysize=py(1)-py(0),/normal

        ; Initialize xyouts:
        dt=double(timeax(n_elements(timeax)-1)-timeax(0))/$
          double(n_elements(timeax)-1)
        info='Date: '+systime()+$
          '!C'+'version: r'+pg_num2str(revision)+$
          '!C'+'window: '+pg_num2str(stft_window)+$
          '!C'+'winsize: '+pg_num2str(stft_length)+$
          '!C '+pg_num2str(dt*stft_length/stft_step)+' s'+$
          '!C'+'fres: '+pg_num2str(stft_fres)+$
          '!C'+'step: '+pg_num2str(stft_step)+$
          '!C'+'averages: '+pg_num2str(bicoh_avr)

        ; Plot xyouts:
        xyouts,0.62,0.19,info,/normal,charsize=1.2,charthick=1.8
        xyouts, 0.2, 0.83, pg_num2str(timeax(i))+' s',charsize=2, $
          charthick=2, /normal
        xyouts, 0.7, 0.83, expname+' #'+nti_wavelet_i2str(shotnumber)+ $
          '!C !C'+channels(m),charsize=2,charthick=2, /normal

        ; Close file:
        device, /close

        ; Restoring printing parameters:
        pg_initgraph
        !P.FONT=-1

    endfor  ;channels
  endfor  ;times
  
endif

; Create time-frequency2 bicoherence plots
; ----------------------------------------------
if NOT (freqs EQ [0]) then begin
  ; Points out of domain set to 1:
  plot_bicoh=bicoherences
  endloop = n_elements(yfreqax)-1; end of for loop
  length = n_elements(xfreqax)
  for j = 1L, endloop do begin
    plot_bicoh(*,*,0:j-1,j) = 1
    plot_bicoh(*,*,length-j:length-1,j) = 1
  endfor

  ; Number of time-frequency2 bicoherence plots:
  nfreqs = n_elements(freqs)
  ; Create plot for each frequency:
  for k = 0,nfreqs-1 do begin
    ; Find frequency:
    freq = freqs(k)
    i = where(min(freqax - freq, /abs) eq (freqax - freq))
    freq = freqax(i)
    
    ; Create plot for all channels:
    nchannels = n_elements(channels)
    for m = 0, nchannels-1 do begin
      ; Create matrix to be plotted:
      matrix = $
        [[reform(plot_bicoh(m,*,i,0:i))],$
        [reform(plot_bicoh(m,*,i+1:n_elements(freqax)-i-1,i))]]
      
      ; Plot matrix:
        ; Setting path and name:
        path='./bicoherence_data/'
        file_mkdir,path
        name = 'Bicoherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+' ' $
          +channels(i)+' '+pg_num2str(freq)+' kHz'
        filename=pg_filename(name,dir=path, ext='.eps')
        
        ; Initializing printing parameters:
        pg_initgraph, /print, /portrait
        device,bits_per_pixel=8,font_size=8,/portrait,/color, $
          /encapsulated,/cmyk,/preview
        device, filename=filename

        ; Initialize xyouts:
        dt=double(timeax(n_elements(timeax)-1)-timeax(0))/$
          double(n_elements(timeax)-1)
        transf_printdatas=$
          'version: r'+pg_num2str(revision)+$
          '!Cshot: '+expname+' '+pg_num2str(shotnumber)+$
          '!Cwindow: '+pg_num2str(stft_window)+$
          '!Cwinsize: '+pg_num2str(stft_length)+'!C ' $
            +pg_num2str(dt*stft_length/stft_step)+'s'+$
          '!Cfres: '+pg_num2str(stft_fres)+$
          '!Cstep: '+pg_num2str(stft_step)

        ; Plot matrix:
        title = 'Bicoherence of '+expname+' '+nti_wavelet_i2str(shotnumber)+ $
          ' '+channels(i)+'!C'+pg_num2str(freq)+' kHz'
        pg_plot4,matrix,xrange=[min(timeax),max(timeax)],yrange=[min(freqax), $
        freqax(n_elements(freqax)-i-1)],xtitle='Time (s)', $
        ytitle='Frequency (kHz)',title=title,opt=opt, zrange = [0,1], $
        poster=1, data=transf_printdatas

        ; Close file:
        device, /close

        ; Restoring printing parameters:
        pg_initgraph

    endfor  ;channels
  endfor  ;freqs

endif 

end