;+
; Name: pg_stft
;
; Written by: Gergo Pokol (lokop@uze.net) 2002.07.15.
;
; Purpose: Return the Short Time Fourier Transform of a 1D data vector with zero padding
;
; Calling sequence:
;	stft = pg_stft( data [,errdata] [,windowsize] [,masksize] [,windowname] [,step] [,freqres] [,/dc] [,/double] $
;		[,/error] [,abs_err=abs_err] [,phase_err=phase_err])
;
; Inputs:
;	data: 1D vector of data
;	windowsize (optional): length of window (standard deviation *2 for Gauss window); default: length of data / 10
;	masksize (optional): length of mask vector for infinite support windows; default: all nonzero values
;	windowname (optional): shape of the window (available: see in pg_gen_win.pro)
;	step (optional): time steps of FFT; default: 1
;	freqres (optional): frequency resolution (*2); default: length of data
;	errdata (optional): error on the input signal
;	/dc (optional): without mean subtraction
;	/double (optional): double precision
;	/error (optional): calculate error on stft
;
; Output:
;	stft: nxn matrix of the Short Time Fourier Transform of the input data
;	abs_err (optional): error on the absolute value of the STFT
;	phase_err (optional): error on the phase of the STFT
;
; Modification:
;	Gergo Pokol 2002.07.17: Introduction of step variable
;	Gergo Pokol 2003.03.25: Changes in the use of pg_gen_win
;	Gergo Pokol 2003.03.27: Repares to allow odd length windows
;	Gergo Pokol 2003.04.08: Optional mean subtraction added
;	Gergo Pokol 2003.04.15: Frequency resolution added
;	Gergo Pokol 2004.02.11: FFT norming factor added
;
;-


function pg_stft, data, windowsize=windowsize, masksize=masksize,$
	windowname=windowname, step=step, freqres=freqres, errdata = errdata, $
	dc=dc, double=double, error = error, abs_err = abs_err, phase_err = phase_err

compile_opt defint32 ; 32 bit integers

; Set defaults
data_size=n_elements(data)
double=keyword_set(double)
dc=keyword_set(dc)
if not(keyword_set(windowsize)) then windowsize=long(data_size/100)
if not(keyword_set(step)) then step=1
if not(keyword_set(freqres)) then freqres=data_size
nti_wavelet_default, error, 0

; Mean subtraction
if dc NE 1 then data=data-mean(data)

; Get the window
win=pg_gen_win(windowsize,masksize=masksize,windowname=windowname,double=double)
win_size=n_elements(win)

; Zero pad the data vector
padding=freqres ; this is the length of the mask to be applied
if (double) then begin
  padded_data=[dblarr(padding),double(data),dblarr(padding)]
  padded_errdata=[dblarr(padding),double(errdata),dblarr(padding)]
endif else begin
  padded_data=[fltarr(padding),data,fltarr(padding)]
  padded_errdata=[fltarr(padding),errdata,fltarr(padding)]
endelse
padded_size=data_size+2*padding

; Initialize STFT array
if (double) then begin
	stft=dcomplexarr(data_size/step,freqres)
	if error then begin
	  stft_abs_err=dblarr(data_size/step,freqres)
	  stft_phase_err=dblarr(data_size/step,freqres)
	endif
endif else begin
	stft=complexarr(data_size/step,freqres)
	if error then begin
	  stft_abs_err=fltarr(data_size/step,freqres)
	  stft_phase_err=fltarr(data_size/step,freqres)
	endif
endelse

; Initialize progress indicator
T=systime(1)

; Compute STFT
for i=0,floor(data_size/step)-1 do begin
	
  ; Zero the mask vector
  if (double) then begin
    mask=dblarr(padded_size)
  endif else begin
    mask=fltarr(padded_size)
  endelse
  
	; Create a mask with a window shifted to the right time step
	center=padding+i*step
	first=center-floor(double(win_size)/2.) ; begining of the support of the window
	last=center+ceil(double(win_size)/2.)-1 ; end of the support of the window
	mask[first:last]=win ; This is practically zero padding
	windoweddata=padded_data*mask
	if error then begin
	  windowederrdata=padded_errdata*mask
	end

	; Cut windoweddata to freqres size - this determines the frequency resolution
  first=center-floor(double(freqres)/2.) ; begining of the support of the windoweddata
  last=center+ceil(double(freqres)/2.)-1 ; end of the support of the windoweddata
	windoweddata=windoweddata(first:last)
	if error then begin
	  windowederrdata=windowederrdata(first:last)
	endif

  ; Calculate STFT elements with FFT for each time step
	stft[i,*]=fft(windoweddata, double = double)
	;Phase correction for positive frequencies
	  stft[i,0:floor(0.5*freqres)] = exp(dcomplex(0,1)*!dpi*dindgen(floor(0.5*freqres)+1)*(1.-1./freqres))* $
	      stft[i,0:floor(0.5*freqres)]
	;Phase correction for negative frequencies
	  stft[i,floor(0.5*freqres)+1:freqres-1] = exp(-dcomplex(0,1)*!dpi*reverse(dindgen(floor(0.5*freqres))+1)*(1.-1./freqres))* $
	      stft[i,floor(0.5*freqres)+1:freqres-1]

  ; Calculate error of STFT(FFT) for each time step
	if error then begin
	  fft_error_propagation, fourier = stft[i,*], td_err = windowederrdata, win = 1, $
	    filtered_abs_err = filtered_abs_err, filtered_phase_err = filtered_phase_err, $
	    crit_ratio = 5

  ; Normalize error
	  stft_abs_err[i,*] = filtered_abs_err*sqrt(n_elements(windoweddata))
	  stft_phase_err[i,*] = filtered_phase_err
	endif

  ; Normalize STFT
	stft[i,*]=stft[i,*]*sqrt(n_elements(windoweddata))

	; Progress indicator
	if floor(systime(1)-T) GE 5 then begin
		print, pg_num2str(double(i)/data_size*step*100)+' % done'
		T=systime(1)
		wait,0.1
	endif

endfor

;Return variables
if error then begin
  abs_err = stft_abs_err
  phase_err = stft_phase_err
endif

return, stft

end
