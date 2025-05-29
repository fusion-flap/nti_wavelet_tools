pro chirp_analysis_amplitudes, $ 
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

; Imaginary unit:
imag = dcomplex(0, 1)
; Existence of the (interpolated) ridge:
iind = where(iridge ne 0)

if (maxorder eq 0) then begin

  ; Calculate amplitude
  amplitudes = dblarr(maxorder + 1, n_elements(itimeax))
  amplitudes(0, iind) = sqrt(2)*abs(itransform(iind))/(sqrt(sqrt(!dpi))*sqrt(sigma))
  ; Calculate noise:
  noises = dblarr(maxorder + 1, n_elements(itimeax))
  noises(0, iind) = sqrt(2)*bknoise/(sqrt(sqrt(!dpi))*sqrt(sigma))

endif else begin

  ; Calculate dt of itimeax
  idt = (itimeax(n_elements(itimeax) - 1) - itimeax(0))/(n_elements(itimeax) - 1)

  ; Initialize arrays
  allfreq = dblarr(maxorder, n_elements(itimeax))
  allamp = dblarr(maxorder, n_elements(itimeax))
  noises = dblarr(maxorder + 1, n_elements(itimeax))
  
  ; Calculate noise:
  noises(*, iind) = sqrt(2)*bknoise/(sqrt(sqrt(!dpi))*sqrt(sigma))

  ; Calculate derivatives of frequency (where ridge exists):
  allfreq(0, iind) = deriv(itimeax(iind), 1d3*iridge(iind)) ; Frequency in Hz
  for i = 1, maxorder - 1 do begin
    allfreq(i, iind) = deriv(itimeax(iind), allfreq(i - 1, iind)) ; Frequency in Hz
  endfor

  ; Calculate derivatives of amplitude (where ridge exists):
  iamp = 0d*iridge
  iamp(iind) = sqrt(2)*abs(itransform(iind))/(sqrt(sqrt(!dpi))*sqrt(sigma))
  allamp(0, iind) = deriv(itimeax(iind), iamp(iind))
  for i = 1, maxorder - 1 do begin
    allamp(i, iind) = deriv(itimeax(iind), allamp(i - 1, iind))
  endfor

  ; Calculate corrected amplitudes:
  amplitudes = dblarr(maxorder + 1, n_elements(itimeax))
  amplitudes(0, *) = iamp
  for order = 1, maxorder do begin

    for k = 0, n_elements(iind) - 1 do begin
      u = k + iind(0)

      ; sumamp
      sumamp = 0d*itimeax
      for n = 1, order do begin
        sumamp = sumamp + allamp(n - 1, u)*(itimeax - itimeax(u))^n/factorial(n)
      endfor

      ; sumphase
      sumphase = 0d*itimeax
      for n = 2, order + 1 do begin
        sumphase = sumphase + $
          2*!dpi*allfreq(n - 2, u)*(itimeax - itimeax(u))^n/factorial(n)
      endfor

      ; int1
      int1 = exp(imag*atan(itransform(u), /phase))* $
        total( sumamp*exp(imag*sumphase)*exp(-(itimeax - itimeax(u))^2d/2d/sigma^2) )* $
        idt

      ; int2
      int2 = exp(imag*atan(itransform(u), /phase))* $
        total( exp(imag*sumphase)*exp(-(itimeax - itimeax(u))^2d/2d/sigma^2) )* $
        idt

      ; amplitudes
      amplitudes(order, u) = abs((2d*sqrt(sqrt(!dpi)*sigma)*itransform(u) - int1)/int2)

    endfor
  
  endfor

endelse

end