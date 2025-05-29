pro chirp_analysis_plot_stft, $ 
; STFT parameters:
  expname = expname, shotnumber = shotnumber, channel = channel, $
  trange = trange, stft_length = stft_length, stft_fres = stft_fres, $
  stft_step = stft_step, resample = resample, $
; Ridge following parameters:
  start_x = start_x, bandwidth = bandwidth, $
; Interpolation:
  tdens = tdens, fdens = fdens, $
; Input:
  time_min = time_min, time_max = time_max, $
  freq_min = freq_min, freq_max = freq_max, $
  noridge = noridge

; Set defaults:
nti_wavelet_default, noridge, 0

; Restore stft from database:
restore, './database/stft/' + $
    expname + '_' + $
    pg_num2str(shotnumber) + '_' + $
    channel + '_' + $
    't' + pg_num2str(trange(0), length = 5) + '-' + $
      pg_num2str(trange(1), length = 5) + '_' + $
    'r' + pg_num2str(resample) + '_' + $
    'l' + pg_num2str(round(stft_length)) + '_' + $
    'f' + pg_num2str(stft_fres) + '_' + $
    's' + pg_num2str(stft_step) + '.sav'

if not noridge then begin
  ; Restore ridge from database:
  restore, './database/ridge/' + $
      expname + '_' + $
      pg_num2str(shotnumber) + '_' + $
      'Ridge-' + pg_num2str(start_x, length = 5) + '_' + $
      channel + '_' + $
      't' + pg_num2str(trange(0), length = 5) + '-' + $
        pg_num2str(trange(1), length = 5) + '_' + $
      'r' + pg_num2str(resample) + '_' + $
      'l' + pg_num2str(round(stft_length)) + '_' + $
      'f' + pg_num2str(stft_fres) + '_' + $
      's' + pg_num2str(stft_step) + '_' + $
      'rb' + pg_num2str(bandwidth) + '_' + $
      'td' + pg_num2str(tdens) + '_' + $
      'fd' + pg_num2str(fdens) + '.sav'
endif

; Plot spectrogram:
; Initialize graphics:
pg_initgraph, /print, /portrait
loadct, 5
device, filename = './save_data/' + nti_wavelet_i2str(1000*systime(1)) + $
  '_' + channel + '_spectrogram.ps'

; Info for plots:
info = $
  '!Cshot: ' + expname + ' ' + nti_wavelet_i2str(shotnumber) + $
  '!Cwinsize: ' + nti_wavelet_i2str(stft_length) + '!C ' + pg_num2str(2*sigma) + 's' + $
  '!Cfres: ' + nti_wavelet_i2str(stft_fres) + $
  '!Cstep: ' + nti_wavelet_i2str(stft_step)

; Find where is freq_min in the freqax vector:
freq_min_index = where(freqax - freq_min eq min(freqax - freq_min, /ABSOLUTE))
; Find where is freq_max in the freqax vector:
freq_max_index = where(freqax - freq_max eq min(freqax - freq_max, /ABSOLUTE))
; Calculate the new frequency axis:
plotted_freqax = freqax(freq_min_index:freq_max_index)
; Find where is time_min in the timeax vector:
time_min_index = where(timeax - time_min eq min(timeax - time_min, /ABSOLUTE))
; Find where is time_max in the timeax vector:
time_max_index = where(timeax - time_max eq min(timeax - time_max, /ABSOLUTE))
; Calculate the new frequency axis:
plotted_timeax = timeax(time_min_index:time_max_index)
; Create matrix to plot:
plotted = reform(abs(transform(time_min_index:time_max_index $
  , freq_min_index:freq_max_index))^2)*2
; Create plot:
if not noridge then ridge = freqax(ridges(time_min_index:time_max_index))
pg_plot4, plotted, xrange = [min(plotted_timeax), max(plotted_timeax)], $
  yrange = [min(plotted_freqax), max(plotted_freqax)], $
  xtitle = 'Time (s)', ytitle = 'Frequency (kHz)', $
  title = 'Spectrogram ' + channel, $
  opt = 0.2, data = info, poster = 1, $
  ridge = ridge
; Reset graphic parameters:
device, /close
pg_initgraph

end