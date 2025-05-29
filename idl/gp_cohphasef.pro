;**************************************************************************************************
; SHORT MANUAL
; ============
;
; function gp_cohphasef, data1, data2, blocksize, $
;			filter=filter, hann=hann, error=error,$
;    			meanapsd1=meanapsd1, meanapsd2=meanapsd2, meancpsd=meancpsd,$
;    			errapsd1=errapsd1,errapsd2=errapsd2,errcpsd=errcpsd
;
;	The gp_cohphasef function is the main function of coherence and phase calculations.
;    	This function calculates the coherence and phase between two data vectors, returns a matrix
;       with the two vectors included.
;   	
;	Started: 2004_10
;   	author: Gergely Papp, papp@reak.bme.hu
;
; USAGE
; =====
;
;  Program needs two data vectors and a window/blocksize to run
;  The return value of the function is a two-dimensional vector: cohphase=[[coh],[phase]] which means
;  that the first part of the result is the coherence vector, and the second part is the phase vector.
;
;   Arguements:
;   -----------
;   data1,2:	the two input vectors
;   blocksize:	the blocksize of windowing. No default value is set yet: 256 recommended.
;   meanapsd1,2: returns the mean apsd values for the two vectors.   
;   meancpsd:	as it can be guessed.
;   errors: 	the same.
;
;
;   Switches:
;   ---------
;   filter: 	Enables filtering data, which means reduction of 2PI jumps in the phase diagram
;   hann  : 	The default windowing type is the Hanning windowing. Boxcar can be enabled by typing hann=0
;   error  : 	Chooses error estimation method: 0=empirical, 1=theoretical;
;
; NEEDED PROGRAMS:
; ================
;   none
;
; HISTORY:
; ========
; 
;   2006_09_12, papp@reak.bme.hu
;     -(hopefully) final commenting and ajusting
;     -rewriting filename to gp_
;     
;*****************************************************************************************************************

function gp_cohphasef,  data1, data2, blocksize, $
			filter=filter, hann=hann, error=error,$
    			meanapsd1=meanapsd1,meanapsd2=meanapsd2,meancpsd=meancpsd,$
    			errapsd1=errapsd1,errapsd2=errapsd2,errcpsd=errcpsd,treshold=treshold


;setting default values: keywords, hanning time windowing, smoothing parameter
;------------------------------------------------------------------------------------------
filter=keyword_set(filter)
if not keyword_set(error) then error=0
nti_wavelet_default, hann, 1

;parameter to control the sensitivity of the smoothing filter
filter_param=2


;Calculating APSD and CPSD
;===========================================================================================

;starting the program with the hanning-windowing method
;-------------------------------------------------------------------------------------------
if (hann) then begin

  blocksize=long(blocksize)
  blockn=2*floor((n_elements(data1)/blocksize))-1

  APSD1=dblarr(blockn,blocksize)
  APSD2=dblarr(blockn,blocksize)
  CPSD12=complexarr(blockn,blocksize)

  for i=0L, blockn-1 do begin

    F1=FFT(HANNING(blocksize)*(data1[i*blocksize/2:(i+2)*blocksize/2-1]-mean(data1[i*blocksize/2:(i+2)*blocksize/2-1])),-1)
    F2=FFT(HANNING(blocksize)*(data2[i*blocksize/2:(i+2)*blocksize/2-1]-mean(data2[i*blocksize/2:(i+2)*blocksize/2-1])),-1)

    APSD1[i,*]=conj(F1)*F1
    APSD2[i,*]=conj(F2)*F2
    CPSD12[i,*]=conj(F1)*F2

  endfor

  
;The part of the program which will run ih hann=0 is adjusted - boxcar window
;-------------------------------------------------------------------------------------------
endif else begin

  print,'Using boxcar window...'
  blockn=floor((n_elements(data1)/blocksize))
  blocksize=long(blocksize)

  APSD1=dblarr(blockn,blocksize)
  APSD2=dblarr(blockn,blocksize)
  CPSD12=complexarr(blockn,blocksize)

  for i=0,blockn-1 do begin


    F1=FFT(data1[i*blocksize:(i+1)*blocksize-1]-mean(data1[i*blocksize:(i+1)*blocksize-1]),-1)
    F2=FFT(data2[i*blocksize:(i+1)*blocksize-1]-mean(data2[i*blocksize:(i+1)*blocksize-1]),-1)


    APSD1[i,*]=conj(F1)*F1
    APSD2[i,*]=conj(F2)*F2
    CPSD12[i,*]=conj(F1)*F2

  endfor
endelse

;Calculating coherence, phase and errors
;===========================================================================================


;defining the error matrices
meanapsd1=dblarr(blocksize)
meanapsd2=dblarr(blocksize)
meancpsd=complexarr(blocksize)
errapsd1=dblarr(blocksize)
errapsd2=dblarr(blocksize)
errcpsd=complexarr(blocksize)
coh=dblarr(blocksize)
phase=dblarr(blocksize)

;calculating the coherence and phase vectors
;-------------------------------------------------------------------------------------------
for i=0.,blocksize-1 do begin

  meanapsd1(i)=mean(APSD1(*,i))
  meanapsd2(i)=mean(APSD2(*,i))
  meancpsd(i)=mean(CPSD12(*,i))
 
  if ((error eq 0) AND (blockn GT 1)) then begin
    errapsd1(i)=stdev(APSD1(*,i))/sqrt(blockn)
    errapsd2(i)=stdev(APSD2(*,i))/sqrt(blockn)
    errcpsd(i)=stdev(CPSD12(*,i))/sqrt(blockn)
  endif
  
  coh(i)=abs(meancpsd(i))/SQRT(meanapsd1(i)*meanapsd2(i))
  phase(i)=atan(imaginary(meancpsd(i)),float(meancpsd(i)))

endfor

if error eq 1 then begin
    errapsd1=meanapsd1/sqrt(blockn)
    errapsd2=meanapsd2/sqrt(blockn)
    errcpsd=meancpsd/sqrt(blockn)
endif

;filtering
;----------------------------------------------------------------------------------------------
if (filter) then begin
  for i=0,blocksize-2 do begin
    if (abs(phase(i)-phase(i+1)) GT abs(phase(i)-(phase(i+1)+2*!PI))) AND $
      (abs(phase(i)-(phase(i+1)+2*!PI)) LT filter_param) then phase(i+1)=phase(i+1)+2*!PI
    if (abs(phase(i)-phase(i+1)) GT abs(phase(i)-(phase(i+1)-2*!PI))) AND $
      (abs(phase(i)-(phase(i+1)-2*!PI)) LT filter_param) then phase(i+1)=phase(i+1)-2*!PI
  endfor
endif

;merging the values to be returned simply as a matrix
cohphase=[[coh],[phase]]
return, cohphase

end
