pro run_chirp_analysis_correction

; Experiment:
; ###########
  expname = 'AUGD'
  shotnumber = 28881
  trange = [0.600, 0.699]

; STFT resolution:
; ###############
  ; High resolution, narrow window
  resample = 200
  stft_lengths = [100, 120, 140, 160, 180, 200]
  stft_fres = long(8000)
  stft_step = 2

; Ridge parameters:
; -----------------
  start_x = 0.650
  bandwidth = 2
  ; Interpolation:
  tdens = 2
  fdens = 15

; Channels:
; ---------
  ; J-054:
  channels = ['SX_-J_054']

; Input parameters:
; ----------------
  maxorder = 1
    


; Run chirp_analysis_amplitudes:
channel = channels
stft_length = stft_lengths(0)

chirp_analysis_amplitudes, $ 
; STFT parameters:
  expname = expname, shotnumber = shotnumber, channel = channel, $
  trange = trange, stft_length = stft_length, stft_fres = stft_fres, $
  stft_step = stft_step, resample = resample, $
; Ridge following parameters:
  start_x = start_x, bandwidth = bandwidth, $
; Interpolation:
  tdens = tdens, fdens = fdens, $
; Inputs:
  maxorder = maxorder, $
; Outputs:
  itimeax = itimeax, iridge = iridge, $
  amplitudes = amplitudes, noises = noises, sigma = sigma

amps = dblarr(n_elements(stft_lengths), maxorder + 1, n_elements(itimeax))
amps(0, *, *) = amplitudes
  
for i = 1, n_elements(stft_lengths) - 1 do begin

  stft_length = stft_lengths(i)
  
  ; Run chirp_analysis_amplitudes:
  chirp_analysis_amplitudes, $ 
  ; STFT parameters:
    expname = expname, shotnumber = shotnumber, channel = channel, $
    trange = trange, stft_length = stft_length, stft_fres = stft_fres, $
    stft_step = stft_step, resample = resample, $
  ; Ridge following parameters:
    start_x = start_x, bandwidth = bandwidth, $
  ; Interpolation:
    tdens = tdens, fdens = fdens, $
  ; Inputs:
    maxorder = maxorder, $
  ; Outputs:
    itimeax = itimeax, iridge = iridge, $
    amplitudes = amplitudes, noises = noises

  amps(i, *, *) = amplitudes

endfor

; Info for plots:
info = $
  '!Cshot: ' + expname + ' ' + nti_wavelet_i2str(shotnumber) + $
  '!Cwinsize: ' + nti_wavelet_i2str(stft_length) + '!C ' + pg_num2str(2*sigma) + 's' + $
  '!Cfres: ' + nti_wavelet_i2str(stft_fres) + $
  '!Cstep: ' + nti_wavelet_i2str(stft_step)

; Use time points where all of the amplitude values are valid (>0):
valid = intarr(n_elements(itimeax))
for i = 0, n_elements(itimeax) - 1 do $
  if min(amps(*, 0, i)) ne 0 then valid(i) = 1

vtimeax = itimeax(where(valid))
vamps = amps(*, *, where(valid))

; Plot 0th amplitudes:
nti_wavelet_plot_1d, vtimeax, reform(vamps(*, 0, *)), $
  xrange = [0.6494, 0.6525], yrange = [0, 6], legend = pg_num2str(stft_lengths), $
  title = 'Amplitudes', xtitle = 'Time [s]', $
  ytitle = 'Amplitude [a. u.]', $
  psym = 0, name = 'amp0', info = info

; Plot 1th amplitudes:
nti_wavelet_plot_1d, vtimeax, reform(vamps(*, 1, *)), $
  xrange = [0.6494, 0.6525], yrange = [0, 6], legend = pg_num2str(stft_lengths), $
  title = 'Amplitudes', xtitle = 'Time [s]', $
  ytitle = 'Amplitude [a. u.]', $
  psym = 0, name = 'amp1', info = info

end