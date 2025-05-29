pro run_chirp_analysis_stft

; Run STFT:
; --------
  filename = '201702_synthetic.sav'
  trange = [0.600, 0.699]

; STFT resolution:
; ----------------
  ; Low resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(16000)
  stft_step = 1

; Run chirp_analysis_stft:
chirp_analysis_stft, $
    filename = filename, trange = trange, $
    stft_length = stft_length, stft_fres = stft_fres, stft_step = stft_step, $
    resample = resample, chind = [1, 0, 0, 0, 0, 0]

end