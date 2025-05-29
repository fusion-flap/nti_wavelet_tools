pro nti_wavelet_stft_interpol, $
  transform = transform, timeax = timeax, freqax = freqax, $
  stft_length = stft_length, stft_step = stft_step, $
  newtransform = newtransform, newtimeax = newtimeax, newfreqax = newfreqax, $
  cutoff = cutoff, timeintrange = timeintrange, freqintrange = freqintrange

; Set default parameters:
nti_wavelet_default, cutoff, 5

; Imaginary unit:
imag = dcomplex(0, 1)

; Convert input to double precision:
timeax = double(timeax)
freqax = double(freqax)
newtimeax = double(newtimeax)
newfreqax = double(newfreqax)
transform = dcomplex(transform)

; Calculate time and frequency resolution:
dt = (timeax(n_elements(timeax) - 1) - timeax(0))/(n_elements(timeax) - 1)
dw = 2d3*!dpi*(freqax(n_elements(freqax)-1) - freqax(0))/(n_elements(freqax) - 1)

; Calculate window length both in time and frequency:
sigma_t = 0.5d*stft_length*dt/stft_step
sigma_w = 1d/sigma_t

; Calculate the cutoff limits of the integral:
cutoff_t = round(cutoff*sigma_t/dt)
cutoff_f = round(cutoff*sigma_w/dw)

; Calculate parameters of newtransform array:
maxt = n_elements(newtimeax)
maxf = n_elements(newfreqax)
newtransform = dcomplexarr(maxt, maxf)

for t = 0, maxt - 1 do begin

; Calculate timepoint:
  time = newtimeax(t)

  for f = 0, maxf - 1 do begin

    ; Calculate frequency point:
    freq = 2d3*!dpi*newfreqax(f)

    ; Calculate parameters of integral range:
    tind = lonarr(2)
    find = lonarr(2)
    if (nti_wavelet_defined(timeintrange) and $
      nti_wavelet_defined(freqintrange)) then begin
      ; Calculate constant range of integral
      tind(0) = timeintrange(0)
      tind(1) = timeintrange(1)
      find(0) = freqintrange(0)
      find(1) = freqintrange(1)
    endif else begin
      ; Calculate indices of closest time-frequency point:
      tind(0) = (where((timeax - time) eq min(timeax - time, /abs)))(0)
      tind(1) = tind(0)
      find(0) = (where((2d3*!dpi*freqax - freq) eq $
        min(2d3*!dpi*freqax - freq, /abs)))(0)
      find(1) = find(0)
    endelse

    ; Cut required part of time and frequency (angular frequency in Hz) axes:
    timecoords = timeax(tind(0) - cutoff_t:tind(1) + cutoff_t)
    freqcoords = 2d3*!dpi*freqax(find(0) - cutoff_f:find(1) + cutoff_f)

    ; Cut required values from STFT transform:
    values = $
      transform(tind(0) - cutoff_t:tind(1) + cutoff_t, $
        find(0) - cutoff_f:find(1) + cutoff_f)
    ; Calculate kernel:
    kernel = (exp(-((sigma_t*(freqcoords - freq))/(2d))^2d) ## $
      exp(-((timecoords - time)/(2d*sigma_t))^2d))*$
      exp(-imag*((freqcoords + freq) ## (timecoords - time))*0.5d)
    ; Calculate values of the interpolated transform:
    newtransform(t, f) = 1d/(2d*!dpi)*total(values*kernel)*dt*dw

  endfor

endfor

end