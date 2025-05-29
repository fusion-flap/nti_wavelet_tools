pro run_chirp_analysis_amplitudes

; Experiment:
; ###########
  expname = 'AUGD'
  shotnumber = 28881
  trange = [0.600, 0.699]

; STFT resolution:
; ###############
  ; Low resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(5000)
  stft_step = 1

; Ridge parameters:
; -----------------
  ; #28881 #2 - SXR
  start_x = 0.636
  bandwidth = 1
  ; Interpolation:
  tdens = 1
  fdens = 10


; #28881 EPS @1
; AUGD:FPP28881.0, rho, t=0.63499999-0.63800001 s
start_x = 0.636
timepoints = [0.6356, 0.63605, 0.6367, 0.6370, 0.6373]
rho = [+0.231597, +0.144820, +0.0485137, -0.0486055, -0.154727, -0.263274]

; ; #28881 EPS @2
; ; AUGD:FPP28881.0, rho, t=0.64899999-0.65300000 s
; start_x = 0.650
; timepoints = [0.6493, 0.6500, 0.6505, 0.6510, 0.6515, 0.6520]
; rho = [+0.234195, +0.149670, +0.0551692, -0.0424668, -0.146960, -0.252934]

; ; #28881 EPS @3
; ; AUGD:FPP28881.0, rho, t=0.65399998-0.65700001 s
; start_x = 0.655
; timepoints = [0.6543, 0.6545, 0.6550, 0.6555, 0.6560, 0.6565]
; rho = [+0.234195, +0.149670, +0.0551692, -0.0424668, -0.146960, -0.252934]



; EGAM 31213 micdu:EQB
; rho = [0.247108, 0.183250, 0.116241]  ; J49, J50, J51
; rho = [-0.107648, -0.192217, -0.282828]  ; J54, J55, J56

; rho = [0.339392, 0.256766, 0.165597]  ; 0.511, #31216, AUGD:FPP31216, rho, 0.510-0.512
; rho = [0.356480, 0.274702, 0.183101]  ; 0.841, #31233, AUGD:FPP31233, rho, 0.840-0.842

; Channels:
; ---------
;   ; MHA-B31-14:
;   channels = ['MHA-B31-14']
;   ; J camera BAE:
  channels = ['SX_-J_050', 'SX_-J_051', 'SX_-J_052', 'SX_-J_053', $
    'SX_-J_054', 'SX_-J_055']
; ;   ; J camera EGAM:
;   channels = ['SX_-J_049', 'SX_-J_050', 'SX_-J_051', $
;     'SX_-J_054', 'SX_-J_055', 'SX_-J_056']
;   channels = ['SX_-J_049', 'SX_-J_050', 'SX_-J_051']
;   channels = ['SX_-J_054', 'SX_-J_055', 'SX_-J_056']

    
; Input parameters:
; ----------------
  maxorder = 1
    


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

; Info for plots:
info = $
  '!Cshot: ' + expname + ' ' + nti_wavelet_i2str(shotnumber) + $
  '!Cwinsize: ' + nti_wavelet_i2str(stft_length) + '!C ' + pg_num2str(2*sigma) + 's' + $
  '!Cfres: ' + nti_wavelet_i2str(stft_fres) + $
  '!Cstep: ' + nti_wavelet_i2str(stft_step) + $
  '!Cmaxorder: ' + nti_wavelet_i2str(maxorder)

amps = dblarr(n_elements(channels), n_elements(itimeax))
errors = dblarr(n_elements(channels), n_elements(itimeax))

amps(0, *) = amplitudes(maxorder, *)
errors(0, *) = noises(maxorder, *)
  
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

  amps(i, *) = amplitudes(maxorder, *)
  errors(i, *) = noises(maxorder, *)

endfor


; Use time points where all of the amplitude values are valid (>0):
valid = intarr(n_elements(itimeax))
for i = 0L, n_elements(itimeax) - 1 do $
  if min(amps(*, i)) ne 0 then valid(i) = 1

vtimeax = itimeax(where(valid))
vridge = iridge(where(valid))
vamps = amps(*, where(valid))
verrors = errors(*, where(valid))

; Shorten name of channels
for i = 0, n_elements(channels) - 1 do begin
  channels(i) = strmid(channels(i), 4)
endfor


; Plot amplitudes:
; ----------------

nti_wavelet_plot_1d, vtimeax, vamps, $
  error = verrors, /errstyle, $
;   yrange = [0, 10], $
  yrange = [0, max(vamps + verrors)], $
  legend = channels, $
  title = 'Amplitudes', xtitle = 'Time [s]', $
  ytitle = 'amplitudes', $
  psym = 0, name = 'amps', info = info

; Smooth amplitudes:
; ------------------
dt = (vtimeax(n_elements(vtimeax)-1)-vtimeax(0))/(n_elements(vtimeax)-1)
; ; Smooth 1.25 ms
; smoothing = round(12.5d-4/dt)
; Smooth 0.5 ms
smoothing = round(5d-4/dt)
print, 'Smoothing: ', smoothing
vamps = smooth(vamps, [0, smoothing], /edge_truncate)

; Plot smoothed amplitudes:
; -------------------------

nti_wavelet_plot_1d, vtimeax, vamps, $
  error = verrors, /errstyle, $
;   yrange = [0, 10], $
  yrange = [0, max(vamps + verrors)], $
  legend = channels, $
  title = 'Smoothed Amplitudes', xtitle = 'Time [s]', $
  ytitle = 'amplitudes', $
  psym = 0, name = 'samps', info = info


; ; Select time points:
; ; -------------------
; ; freqs = [52., 54., 56., 58.] ; 31213
; ; freqs = [60., 62., 64., 66.] ; 31216
; freqs = [60., 64., 68., 72.] ; 31233
; 
; 
; fts = fltarr(n_elements(freqs))
; for i = 0, n_elements(freqs) - 1 do begin
;   fts(i) = (where((vridge - freqs(i)) eq min(vridge - freqs(i), /abs)))(0)
; endfor
; 
; ; Normalize amplitudes:
; ; ---------------------
; 
; namps = 0d*vamps
; nerrors = 0d*verrors
; 
; for i = 0,  n_elements(channels) - 1 do begin
;   norm = vamps(i, fts(0))
;   namps(i, *) = vamps(i, *)/norm
;   nerrors(i, *) = verrors(i, *)/norm
; endfor
; 
; ; Plot normalized amplitudes:
; ; ----------------
; 
; nti_wavelet_plot_1d, vtimeax, namps, $
;   error = nerrors, /errstyle, $
;   yrange = [0, max(namps + nerrors)], $
;   legend = channels, $
;   title = 'Normalized amplitudes', xtitle = 'Time [s]', $
;   ytitle = 'amplitudes', $
;   psym = 0, name = 'namps', info = info
; 
; 
; ; Create radial map:
; ; ------------------
; 
; radmap = fltarr(n_elements(freqs), n_elements(channels))
; nradmap = fltarr(n_elements(freqs), n_elements(channels))
; for i = 0, n_elements(channels) - 1 do begin
;   radmap(*, i) = namps(i, fts)
;   nradmap(*, i) = nerrors(i, fts)
; endfor
; 
; 
; ; Plot eigenfunction:
; nti_wavelet_plot_1d, rho, $
; ; 	radmap, error = nradmap, $	; normal plot
; 	[radmap, nradmap], error = [nradmap, nradmap], $	; plot 'noise level'
;   yrange = [0, max(radmap) + max(nradmap)], $
; ;   xrange = [0.10, 0.26], $ ; 31213 above
; ;   xrange = [-0.30, -0.10], $ ; 31213 under
; ;   xrange = [0.15, 0.35], $ ;31216
;   xrange = [0.17, 0.36], $ ;31233
;   legend = pg_num2str([vtimeax(fts), vtimeax(fts)]), $
;   title = 'Radial Eigenfunction (smoothed)', xtitle = 'Normalized rho poloidal', ytitle = 'Amplitude', $
;   psym = 0, name = 'eigenfunction_smoothed', info = info
;   
; 
; print, 'THE END'
; stop
; 
; 



















; Plot noramlized eigenfunction
; -----------------------------

eigenfunction = dblarr(n_elements(timepoints), n_elements(channels))
neigenfunction = dblarr(n_elements(timepoints), n_elements(channels))
eigenferr = dblarr(n_elements(timepoints), n_elements(channels))
neigenferr = dblarr(n_elements(timepoints), n_elements(channels))
for i = 0, n_elements(timepoints) - 1 do begin
  timeind = (where((vtimeax - timepoints(i)) eq min((vtimeax - timepoints(i)), /abs)))(0)
  eigenfunction(i, *) = vamps(*, timeind)
  eigenferr(i, *) = verrors(*, timeind)
  norm = total(eigenfunction(i, *)/(eigenferr(i,*)^2))/total(1/(eigenferr(i,*)^2))
  neigenfunction(i, *) = eigenfunction(i, *)/norm
  neigenferr(i, *) = eigenferr(i, *)/norm
endfor

; Plot eigenfunction:
nti_wavelet_plot_1d, rho, eigenfunction, $
  error = eigenferr, $
;   yrange = [0, max(eigenfunction) + max(eigenferr)], $
  yrange = [0, 10], $
  xrange = [-0.3, 0.3], $
  legend = pg_num2str(timepoints), $
  title = 'Radial Eigenfunction (smoothed)', xtitle = 'Normalized rho poloidal', ytitle = 'Amplitude', $
  psym = 0, name = 'eigenfunction_smoothed', info = info

; Plot normalized eigenfunction:
nti_wavelet_plot_1d, rho, $
;   neigenfunction, error = neigenferr, $
  [neigenfunction, neigenferr], error = [neigenferr, neigenferr], $
  yrange = [0, max(neigenfunction) + max(neigenferr)], $
  xrange = [-0.3, 0.3], $
;   legend = pg_num2str(timepoints), $
  legend = pg_num2str([timepoints, timepoints]), $
  title = 'Normalized Radial Eigenfunction (smoothed)', xtitle = 'Normalized rho poloidal', ytitle = 'Normalized amplitude', $
  psym = 0, name = 'neigenfunction_smoothed', info = info

stop

end
