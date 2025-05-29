pro run_chirp_analysis_ridge

; Experiment:
; ###########
  expname = 'SYNTH'
  shotnumber = 201702l
  trange = [0.600, 0.699]

; STFT resolution:
; ----------------
  ; Low resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(16000)
  stft_step = 1

; Ridge parameters:
; -----------------
  ; #28881 #2 - magnetics
  start_x = 0.650
  start_freq = [70., 80.]
  bandwidth = 1
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [50., 65.]
  ; Interpolation:
  tdens = 10
  fdens = 50

; Channels:
; ---------
  ; MHA-B31-14:
;   channels = ['MHA-B31-14']
;   ; J camera BAE:
;   channels = ['SX_-J_050', 'SX_-J_051', 'SX_-J_052', 'SX_-J_053', $
;     'SX_-J_054', 'SX_-J_055']
;   ; J camera EGAM:
;   channels = ['SX_-J_049', 'SX_-J_050', 'SX_-J_051', $
;     'SX_-J_054', 'SX_-J_055', 'SX_-J_056']
channels = ['CH1']

    
;   external_ridge = $
;   'AUGD_28881_Ridge-0.655_MHA-31-14_t0.600-0.699_r200_l100_f5000_s1_rb1_td1_fd10.sav'

; Run chirp_analysis_ridge:
for i = 0, n_elements(channels) - 1 do begin

  channel = channels(i)

  ; Run chirp_analysis_ridge:
  chirp_analysis_ridge, $
    ; STFT parameters:
      expname = expname, shotnumber = shotnumber, channel = channel, $
      trange = trange, stft_length = stft_length, stft_fres = stft_fres, $
      stft_step = stft_step, resample = resample, $
    ; Ridge following parameters:
      start_x = start_x, start_freq = start_freq, bandwidth = bandwidth, $
      external_ridge = external_ridge, xrange_unit = xrange_unit, $
    ; Noise:
      noisetime = noisetime, noisefreq = noisefreq, $
    ; Interpolation:
      tdens = tdens, fdens = fdens

endfor

end
