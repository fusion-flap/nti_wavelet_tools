pro run_chirp_analysis_plot_stft

; Experiment:
; ###########
  expname = 'SYNTH'
  shotnumber = 201702l
  trange = [0.600, 0.699]

; STFT resolution:
; ###############
  ; Low resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(16000)
  stft_step = 1

; Ridge parameters:
; -----------------
  ; #28881 #1 - magnetics
  start_x = 0.650
  bandwidth = 1
  ; Interpolation:
  tdens = 5
  fdens = 20

; Channels:
; ---------
;   ; J camera OK:
;   channels = ['SX_-J_050', 'SX_-J_051', 'SX_-J_052', 'SX_-J_053', $
;     'SX_-J_054', 'SX_-J_055']
;   ; MHA-B31-14:
;   channels = ['MHA-B31-14']
;   channels = ['SX_-J_055']
;   channels = ['SX_-J_049', 'SX_-J_050', 'SX_-J_051', 'SX_-J_054', $
;     'SX_-J_055', 'SX_-J_056']
  channels = ['CH1']

; Plot parameters:
; ---------------
  time_min = 0.645
  time_max = 0.660
  freq_min = 60
  freq_max = 100
  noridge = 0



; Run run_chirp_analysis_plot_stft
for i = 0, n_elements(channels) - 1 do begin

  channel = channels(i)
  
  ; Run chirp_analysis_amplitudes:
  chirp_analysis_plot_stft, $ 
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

endfor

end