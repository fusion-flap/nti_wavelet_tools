pro ecei_avg, $
  shotno = shotno, trange = trange, freqrange = freqrange

; Initialize parameters:
parameters = create_parameter_struct(shotno)


; nti_wavelet_main input:
; Hard-wired:
  transf_selection = 1
  crosstr_selection = 0
  coh_selection = 0
  mode_selection = 0
; Input from parameters:
  stft_selection = parameters.stft.selection
  stft_length = parameters.stft.length
  stft_fres = parameters.stft.fres
  stft_step = parameters.stft.step
  cwt_selection = parameters.cwt.selection
  cwt_order = parameters.cwt.order
  cwt_dscale = parameters.cwt.dscale
  crosstr_correction_selection = parameters.crosstr.correction
  coh_avr = parameters.coherence.avr
  mode_type = parameters.mode.type
  mode_steps = parameters.mode.steps
  mode_min = parameters.mode.min
  mode_max = parameters.mode.max
  mode_optimized = parameters.mode.optimized
  freq_min = parameters.freq.min
  freq_max = parameters.freq.max
  startpath = parameters.startpath
; Input from raw_data:
  data = parameters.raw_data.data
  dtimeax = parameters.raw_data.dtimeax
  chpos = parameters.raw_data.chpos
  expname = parameters.raw_data.expname
  shotnumber = parameters.raw_data.shotnumber
  channels = parameters.raw_data.channels

; Check channels:
if not file_test('./' + pg_num2str(shotno) + '_ECEI_ind.sav') then begin
  num = n_elements(data(0, *))
  ind = intarr(num)
  big = ceil(num/16.)
  for i = 0, big - 1 do begin
    !P.MULTI = [0, 4, 4]
    k = 0
    for k = 0, 15 do begin
      plot, dtimeax, data(*, 16*i + k), $
        xtitle = 'Time [s]', title = 'ECEI ' + channels(16*i + k), charsize = 2
    endfor
    ; Define answer as a string before reading: 
    answer = ''  
    ; Read input from the terminal: 
    read, answer, prompt = 'Do you want to use all of this channels? (y/n): '
    case answer of
      'y': ind(16*i:16*i + 15) = 1
      'n': begin
        j = 0
        for j = 0, 15 do begin
          !P.MULTI = 0
          plot, dtimeax, data(*, 16*i + j), $
            xtitle = 'Time [s]', title = 'ECEI ' + channels(16*i + j), charsize = 2
          ; Define answer as a string before reading: 
          answer = ''  
          ; Read input from the terminal: 
          read, answer, prompt = 'Do you want to use this channel? (y/n): ' 
          case answer of
            'y': ind(16*i + j) = 1
            'n': ind(16*i + j) = 0
            else: begin
              j = j - 1
              print, 'Please choose y or n!'
            end
          endcase
        endfor
      end
      else: begin
        i = i - 1
        print, 'Please choose y or n!'
      end
    endcase
  endfor
  save, filename = pg_num2str(shotno) + '_ECEI_ind.sav', ind
endif else begin
  restore, pg_num2str(shotno) + '_ECEI_ind.sav'
endelse

; Cut ROI:
start = (where(dtimeax ge trange(0)))(0)
ending = (where(dtimeax ge trange(1)))(0)
data = data(start:ending - 1, where(ind))
dtimeax = dtimeax(start:ending - 1)
chpos = chpos(where(ind))
channels = channels(where(ind))

; Run calculation:
nti_wavelet_main,$
  ; Input
    ; Data:
    data = data, dtimeax = dtimeax, chpos = chpos, expname = expname, $
    shotnumber = shotnumber, channels = channels, $
    channelpairs_used = channelpairs_used, $
    ; Transform:
    transf_selection = transf_selection, cwt_selection = cwt_selection, $
    cwt_family = cwt_family, cwt_order = cwt_order, cwt_dscale = cwt_dscale, $
    stft_selection = stft_selection, stft_length = stft_length,  $
    stft_fres = stft_fres, stft_step = stft_step, $
    stft_window = stft_window, freq_min = freq_min, freq_max = freq_max, $
    ; Coherence:
    crosstr_selection = crosstr_selection, $
    crosstr_correction_selection = crosstr_correction_selection, $
    coh_selection = coh_selection, coh_avr = coh_avr, $
    ; Modenumber:
    mode_selection = mode_selection, mode_type = mode_type, $
    mode_filter = mode_filter, $
    mode_steps = mode_steps, mode_min = mode_min, mode_max = mode_max, $
    mode_optimized = mode_optimized, $
    ; Others:
    startpath = startpath, $
    ; Output
    timeax = timeax, freqax = freqax, scaleax = scaleax, $
    transforms = transforms, crosstransforms = crosstransforms, $
    coherences = coherences, modenumbers = modenumbers, qs = qs


avg_transform = total(abs(transforms)^2, 1)


; Plot averaged spectrogram:
; Initialize graphics:
pg_initgraph, /print, /portrait
loadct, 5
device, filename = './save_data/' + nti_wavelet_i2str(1000*systime(1)) + $
  '_' + pg_num2str(shotno) + '_avg_ECEI_spectrogram.ps'

; Info for plots:
info = $
  '!Cshot: ' + expname + ' ' + nti_wavelet_i2str(shotno) + $
  '!Cwinsize: ' + nti_wavelet_i2str(stft_length) + $
  '!Cfres: ' + nti_wavelet_i2str(stft_fres) + $
  '!Cstep: ' + nti_wavelet_i2str(stft_step)

; Find where is freq_min in the freqax vector:
freq_min_index = where(freqax - freqrange(0) eq min(freqax - freqrange(0), /ABSOLUTE))
; Find where is freq_max in the freqax vector:
freq_max_index = where(freqax - freqrange(1) eq min(freqax - freqrange(1), /ABSOLUTE))
; Calculate the new frequency axis:
plotted_freqax = freqax(freq_min_index:freq_max_index)
; Find where is time_min in the timeax vector:
time_min_index = where(timeax - trange(0) eq min(timeax - trange(0), /ABSOLUTE))
; Find where is time_max in the timeax vector:
time_max_index = where(timeax - trange(1) eq min(timeax - trange(1), /ABSOLUTE))
; Calculate the new frequency axis:
plotted_timeax = timeax(time_min_index:time_max_index)
; Create matrix to plot:
plotted = reform(abs(avg_transform(time_min_index:time_max_index $
  , freq_min_index:freq_max_index))^2)*2
; Create plot:
pg_plot4, plotted, xrange = [min(plotted_timeax), max(plotted_timeax)], $
  yrange = [min(plotted_freqax), max(plotted_freqax)], $
  xtitle = 'Time (s)', ytitle = 'Frequency (kHz)', $
  title = '#' + pg_num2str(shotno) + ' Averaged ECEI Spectrogram', $
  opt = 0.2, data = info, poster = 1
; Reset graphic parameters:
device, /close
pg_initgraph

end