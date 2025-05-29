pro chirp_analysis_stft, $
    filename = filename, trange = trange, $
    stft_length = stft_length, stft_fres = stft_fres, stft_step = stft_step, $
    resample = resample, chind = chind

; Restore data from NTI WT .sav file:
restore, './database/raw_data/' + filename

; Choose requried channels
if nti_wavelet_defined(chind) then begin
  channels = channels(where(chind))
  data = data(*, where(chind))
endif

; Store timeax and data:
rawtimeax = timeax
rawdata = data

; Number of channels:
num = n_elements(channels)

; Calculate and save STFT:
for i = 0, num - 1 do begin
  data = rawdata(*, i)
  timeax = rawtimeax
  channel = channels(i)
  freqres = stft_fres*2 - 1
  transform = pg_spectrogram_sim(data, timeax, shot = shotnumber, $
    trange = trange, windowname = 'Gauss', fmax = resample, $
    windowsize = stft_length, masksize = stft_fres*2 - 1, step = stft_step, $
    freqres = freqres, plot = -1, freqax = freqax, errdata = 0*data, /double)
  stft_fres = (freqres + 1)/2

  ; Store for positive frequencies only:
  transformsize = size(transform)
  transformsize(2) = transformsize(2)/2 + 1
  transform = temporary(transform(*, 0:transformsize(2)-1))
  
  ; Calculate sigma in sec:
  dt = (timeax(n_elements(timeax)-1)-timeax(0))/(n_elements(timeax)-1)
  sigma = 0.5d*stft_length*dt/stft_step
  
  ; Save stft to database:
  save, filename = './database/stft/' + $
      expname + '_' + $
      pg_num2str(shotnumber) + '_' + $
      channels(i) + '_' + $
      't' + pg_num2str(trange(0), length = 5) + '-' + $
        pg_num2str(trange(1), length = 5) + '_' + $
      'r' + pg_num2str(resample) + '_' + $
      'l' + pg_num2str(round(stft_length)) + '_' + $
      'f' + pg_num2str(stft_fres) + '_' + $
      's' + pg_num2str(stft_step) + '.sav', $
    expname, shotnumber, channel, trange, $
    rawtimeax, data, $
    timeax, freqax, transform, $
    resample, stft_length, stft_fres, stft_step, sigma
endfor

end