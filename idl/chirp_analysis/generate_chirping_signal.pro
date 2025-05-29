pro generate_chirping_signal

; Time interval of chirp:
tchirp = [0.649, 0.653]
; Create timeax:
timeax = 0.1*dindgen(2d5 + 1)/2d5 + 0.6
; Initialize data vector:
data = 0*timeax

; Calculate shortened timeax during the chirp
ftime = timeax(where((timeax GE tchirp(0)) AND (timeax LE tchirp(1))))
; Calculate frequency
freq = 10*(exp(-1d3*(ftime-ftime(0))) + 7)
; Calculate amplitude
amplitude = -(exp(5d2*(ftime-ftime(0)))) + 10
; Calculate signal
signal = amplitude*sin(2*!pi*1d4*(1/(-1d3)*exp(-1d3*(ftime-ftime(0))) + 1/(-1d3) + 7*(ftime-ftime(0))))

; Save signal
data(where((timeax GE tchirp(0)) AND (timeax LE tchirp(1)))) = signal
; Noise:
data = data + 0.01*randomn(seed, n_elements(timeax))
; data = 25.4*randomn(seed, n_elements(timeax))
channels = ['CH1']
expname = 'SYNTH'
shotnumber = 201702l
save, filename = './database/raw_data/201702_synthetic.sav', $
  timeax, data, channels, expname, shotnumber

end

; 201701: no noise
; 201702: 0.01 noise