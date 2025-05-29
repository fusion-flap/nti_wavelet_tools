;+
; Name: pg_retrigger
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2004.09.30.
;
; Purpose: Shift signal in time with a fraction of the sample time
;
; Calling sequence:
;	xx=pg_retrigger(x, fraction)
;
; Input:
;	x: data vector
;	fraction: time2=time1-fraction*sampletime
;
; Output:
;	xx: timeshifted data vector
;
;-

function pg_retrigger, xfix, fractionfix

x=xfix
fraction=fractionfix
xsize=n_elements(x)

type = size(x, /type)

case type of 
    4: double = 0
    5: double = 1
    else: begin
      print, "Invalid type of argument!'
    end
endcase

;CHECK PRIME FACTORS OF VECTORS's LENGTH:
  sum_prime_factors = total(nti_wavelet_prime_factor(n_elements(x)))
  if ((sum_prime_factors ge 5d4) and (sum_prime_factors lt 1d5)) then begin
    print, "--- WARNING! ---"
    print, "Retriggering can run even 2 minutes, because the large prime factors of data vector's length!"
    print, "The prime factors of data vector's length:"
    print, nti_wavelet_prime_factor(n_elements(x))
    print, "Working ..."
  endif
  if (sum_prime_factors ge 1d5) then begin
    print, "--- WARNING! ---"
    print, "Retriggering can run at least 2 minutes, even several hours because the large prime factors of data vector's length!"
    print, "The prime factors of data vector's length:"
    print, nti_wavelet_prime_factor(n_elements(x))
    print, "Working ..."
  endif

xfft=fft(x,-1, double = double)

fftbw=xsize/2d

phase=dblarr(xsize)

phase[0:ceil(fftbw)-1]=fraction*dindgen(ceil(fftbw))/(floor(fftbw))*!PI
phase[xsize-floor(fftbw):xsize-1]=fraction*(dindgen(floor(fftbw))-floor(fftbw))/floor(fftbw)*!PI

xxfft=xfft*exp(-1*dcomplex(0,phase))

if double then begin
  xx=double(fft(xxfft,1, double = double))
endif else begin
  xx=float(fft(xxfft,1, double = double))
endelse

return, xx

end
