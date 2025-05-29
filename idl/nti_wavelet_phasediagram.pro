;+
; NAME: nti_wavelet_phasediagram
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2018.07.30.
;
; PURPOSE: Plot phasediagrams derived from time-frequency cross-transforms at given time and frequency coordinates 
; for processed data from NTI Wavelet Tools GUI
;
; CALLING SEQUENCE:
; pg_phasediagram, cphases, chpos, timeax, freqax, time, freq [,shot] [,channels] [,filters] [,/print]$
;    [,filterparam1] [,filterparam2] [,cpows=cpows] [,cohs=cohs] [,cphaserr=cphaserr]
;
; INPUTS:
;   saved_datablock: Processed data structure from NTI Wavelet Tools GUI
;   time: Time of phase diagram
;   frequency: Frequency of phase diagram
;   mode_direction (optional): 'toroidal' (default) or 'poloidal'
;   filters (optional): As described in pg_phasediagram.pro (Only filters with no weighting are available!)
;   filterparam1 (optional): As described in pg_phasediagram.pro
;   filterparam2 (optional): As described in pg_phasediagram.pro
;   /print (optional): Print to file instead of plotting
;
; OUTPUT: As described in pg_phasediagram.pro
;
; EXAMPLE:
;    restore,'test_processed.sav'
;    nti_wavelet_phasediagram, saved_datablock, 3.3225, 6, filters=[1,8], filterparam2=[-6,6], /print
;-

pro nti_wavelet_phasediagram, saved_datablock, time, frequency, filters=filters, mode_direction=mode_direction, $
   filterparam1=filterparam1, filterparam2=filterparam2, print=print

compile_opt defint32 ; 32 bit integers

; Set defaults
if NOT(keyword_set(mode_direction)) then mode_direction='toroidal'

; Check time and frequency in range
if (time LT min(*saved_datablock.transf_timeax)) OR (time GT max(*saved_datablock.transf_timeax)) then $
  message, 'nti_wavelet_phasediagram called with time out of range: [' + $
    pg_num2str(min(*saved_datablock.transf_timeax)) + ',' + $
    pg_num2str(max(*saved_datablock.transf_timeax)) + '] s!'
  if (frequency LT min(*saved_datablock.transf_freqax)) OR (time GT max(*saved_datablock.transf_freqax)) then $
    message, 'nti_wavelet_phasediagram called with time out of range: [' + $
    pg_num2str(min(*saved_datablock.transf_freqax)) + ',' + $
    pg_num2str(max(*saved_datablock.transf_freqax)) + '] kHz!'

; Prepare input for pg_phasediagram.pro
cphases=atan(imaginary(*saved_datablock.crosstransforms),float(*saved_datablock.crosstransforms))
if mode_direction EQ 'toroidal' then chpos=*saved_datablock.phi*!radeg 
if mode_direction EQ 'poloidal' then chpos=*saved_datablock.theta*!radeg
if NOT(isa(chpos)) then message, 'nti_wavelet_phasediagram called with misprinted mode_direction!'

; Call pg_phasediagram.pro
pg_phasediagram, cphases, chpos, *saved_datablock.transf_timeax, *saved_datablock.transf_freqax, $
  time, frequency, shot=saved_datablock.shotnumber, channels=*saved_datablock.channels, $
  filters=filters, filterparam1=filterparam1, filterparam2=filterparam2, print=print

end