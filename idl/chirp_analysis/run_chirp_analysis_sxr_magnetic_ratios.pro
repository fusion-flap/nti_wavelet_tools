pro run_chirp_analysis_sxr_magnetic_ratios

; Experiment:
; ###########
  expname = 'AUGD'
  shotnumber = 31213
  trange = [0.750, 0.900]

; STFT resolution:
; ###############
  ; Low resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(5000)
  stft_step = 1

; Ridge parameters:
; -----------------
  start_x = 0.844
  bandwidth = 2
  ; Interpolation:
  tdens = 0
  fdens = 0

; Channels:
; ---------
  channels = ['SX_-J_056', 'MHA-B31-14']

; Input parameters:
; ----------------
  maxorder = 0
    


; Run chirp_analysis_amplitudes:
channel = channels(0)

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

amps = dblarr(n_elements(channels), n_elements(itimeax))
errors = dblarr(n_elements(channels), n_elements(itimeax))

amps(0, *) = amplitudes(0, *)
errors(0, *) = noises(0, *)
  
for i = 1, n_elements(channels) - 1 do begin

  channel = channels(i)
  
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

  amps(i, *) = amplitudes(0, *)
  errors(i, *) = noises(0, *)

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
  if min(amps(*, i)) ne 0 then valid(i) = 1

vtimeax = itimeax(where(valid))
vamps = amps(*, where(valid))
verrors = errors(*, where(valid))

; Shorten name of channels
for i = 0, n_elements(channels) - 1 do begin
  channels(i) = strmid(channels(i), 4)
endfor


; Plot all ratios:
; ----------------

chs = n_elements(channels)
pairs = chs - 1
ratios = dblarr(pairs, n_elements(vtimeax))
errs = dblarr(pairs, n_elements(vtimeax))
legend = strarr(pairs)

i = 0
for ch1 = 0, chs - 2 do begin
  ch2 = ch1 + 1
  ratios(i, *) = reform(vamps(ch1, *)/vamps(ch2, *))
  errs(i, *) = $
    reform(verrors(ch1, *)/vamps(ch2, *) + vamps(ch1, *)/vamps(ch2, *)^2*verrors(ch2, *))
  legend(i) = channels(ch1) + '---' + channels(ch2)
  i = i + 1
endfor


; Plot amplitudes:
nti_wavelet_plot_1d, vtimeax, vamps, $
  error = verrors, /errstyle, $
  yrange = [0, max(vamps + verrors)], legend = channels, $
  title = 'amplitudes', xtitle = 'Time [s]', $
  ytitle = 'amplitudes', $
  psym = 0, name = 'amps', info = info


; Plot Ratios:
nti_wavelet_plot_1d, vtimeax, ratios, $
  error = errs, /errstyle, $
  yrange = [0, max(ratios + errs)], legend = legend, $
  title = 'Ratio', xtitle = 'Time [s]', ytitle = 'Ratio', $
  psym = 0, name = 'ratios', info = info



; Plot smoothed stuffs:
; ---------------------

vamps = smooth(vamps, [0, 500], /edge_truncate)

i = 0
for ch1 = 0, chs - 2 do begin
  ch2 = ch1 + 1
  ratios(i, *) = reform(vamps(ch1, *)/vamps(ch2, *))
  legend(i) = channels(ch1) + '---' + channels(ch2)
  i = i + 1
endfor


; Plot amplitudes:
nti_wavelet_plot_1d, vtimeax, vamps, $
  yrange = [0, max(vamps)], legend = channels, $
  title = 'Smoothed amplitudes', xtitle = 'Time [s]', $
  ytitle = 'amplitudes', $
  psym = 0, name = 'samps', info = info


; Plot Ratios:
nti_wavelet_plot_1d, vtimeax, ratios, $
  yrange = [0, max(ratios)], legend = legend, $
  title = 'Smoothed Ratios', xtitle = 'Time [s]', ytitle = 'Smoothed Ratio', $
  psym = 0, name = 'sratios', info = info


end