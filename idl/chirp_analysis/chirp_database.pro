; Run STFT:
; --------
  filename = 'AUGD_25506_ball_tor_0.0s-1.0s.sav'
  trange = [0.400, 0.499]

  filename = 'AUGD_28881_ball_tor_0.6s-0.7s.sav'
  trange = [0.600, 0.699]

  filename = 'AUGD_28881_SXR_H-I-J_0.6s-0.7s_OK.sav'
  trange = [0.600, 0.699]
  
  filename = 'AUGD_28881_SXR_J_0.8s-1.05s_OK.sav'
  trange = [0.800, 1.049]
  
  filename = 'AUGD_28884_SXR_J_0.6s-0.7s_OK.sav'
  trange = [0.600, 0.699]

  filename = 'AUGD_28884_magnetic_0.4-1.2.sav'
  trange = [0.600, 0.749]

  filename = 'AUGD_30950_MHA_0.0s-1.0s.sav'
  trange = [0.700, 0.799]
  
  filename = 'AUGD_30950_SXR_J53-60_0.0s-1.0s.sav'
  trange = [0.700, 0.699]

  filename = 'AUGD_30951_MHA_0.0s-1.0s.sav'
  trange = [0.570, 0.670]
  
  filename = 'AUGD_30951_SXR_G_0.0s-1.0s.sav'
  trange = [0.570, 0.670]

  filename = 'AUGD_30951_SXR_F_0.0s-1.0s.sav'
  trange = [0.570, 0.670]

  filename = 'AUGD_31213_SXR_J_middle_0.0s-2.0s.sav'
  trange = [0.750, 0.900]

  filename = 'AUGD_31213_ball_tor_0.0s-2.0s.sav'
  trange = [0.750, 0.900]
  
  filename = 'AUGD_31213_SXR_H_middle_0.0s-1.0s.sav'
  trange = [0.750, 0.900]

  
; STFT resolution:
; ###############
  ; High resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(16000)
  stft_step = 1
  ; High resolution, wide window
  resample = 200
  stft_length = 200
  stft_fres = long(16000)
  stft_step = 1
  ; Low resolution, narrow window
  resample = 200
  stft_length = 100
  stft_fres = long(5000)
  stft_step = 1
  ; Low resolution, wide window
  resample = 200
  stft_length = 200
  stft_fres = long(5000)
  stft_step = 1


; Experiment:
; ###########
  expname = 'AUGD'
  shotnumber = 25506
  trange = [0.400, 0.499]

  expname = 'AUGD'
  shotnumber = 28881
  trange = [0.600, 0.699]

  expname = 'AUGD'
  shotnumber = 28881
  trange = [0.870, 0.969]

  expname = 'AUGD'
  shotnumber = 28884
  trange = [0.600, 0.699]

  expname = 'AUGD'
  shotnumber = 28884
  trange = [0.600, 0.749]
  
  expname = 'AUGD'
  shotnumber = 30951
  trange = [0.570, 0.670]

  expname = 'AUGD'
  shotnumber = 31213
  trange = [0.750, 0.900]

  expname = 'AUGD'
  shotnumber = 31216
  trange = [0.450, 0.600]
  
  expname = 'AUGD'
  shotnumber = 31233
  trange = [0.800, 0.899]

; Ridge parameters:
; -----------------

  ; #28881 #1 - magnetics
  start_x = 0.636
  start_freq = [75., 80.]
  bandwidth = 1
  xrange_unit = [0.6352, 0.650]
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [50., 65.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #28881 #1 - SXR
  start_x = 0.636
  start_freq = [75., 80.]
  bandwidth = 1
  xrange_unit = [0.6352, 0.650]
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [90., 100.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #28881 #2 - magnetics
  start_x = 0.650
  start_freq = [70., 80.]
  bandwidth = 1
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [50., 65.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #28881 #2 - SXR
  start_x = 0.650
  start_freq = [70., 80.]
  bandwidth = 1
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [90., 100.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #28881 #3 - magnetics
  start_x = 0.655
  start_freq = [70., 80.]
  bandwidth = 1
  xrange_unit = [0.654, 0.660]
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [50., 65.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #28881 #3 - SXR
  start_x = 0.655
  start_freq = [70., 80.]
  bandwidth = 1
  ; Noise:
  noisetime = [0.630, 0.660]
  noisefreq = [90., 100.]
  ; Interpolation:
  tdens = 0
  fdens = 0
  
  ; #30951 nice one
  start_x = 0.638
  start_freq = [80., 90.]
  bandwidth = 2
  ; Noise:
  noisetime = [0.641, 0.649]
  noisefreq = [75., 95.]
  ; Interpolation:
  tdens = 0
  fdens = 0
  
  ; #30951 other one
  start_x = 0.621
  start_freq = [70., 100.]
  bandwidth = 2
  ; Noise:
  noisetime = [0.624, 0.634]
  noisefreq = [75., 95.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #31213 EGAM 1
  start_x = 0.824
  start_freq = [50., 60.]
  xrange_unit = [0.8217, 0.8600]
  bandwidth = 1
  ; Noise:
  noisetime = [0.820, 0.850]
  noisefreq = [60., 80.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #31213 EGAM 2
  start_x = 0.834
  start_freq = [50., 60.]
  xrange_unit = [0.8315, 0.8600]
  bandwidth = 1
  ; Noise:
  noisetime = [0.820, 0.850]
  noisefreq = [60., 80.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #31213 EGAM 3
  start_x = 0.844
  start_freq = [50., 60.]
  xrange_unit = [0.8415, 0.8600]
  bandwidth = 1
  ; Noise:
  noisetime = [0.820, 0.850]
  noisefreq = [60., 80.]
  ; Interpolation:
  tdens = 0
  fdens = 0

  ; #31233 EGAM
  start_x = 0.841
  start_freq = [70., 80.]
  xrange_unit = [0.8382, 0.8600]
  bandwidth = 1
  ; Noise:
  noisetime = [0.820, 0.880]
  noisefreq = [90., 110.]
  ; Interpolation:
  tdens = 1
  fdens = 10

  ; #31216 EGAM
  start_x = 0.511
  start_freq = [60., 70.]
  xrange_unit = [0.5093, 1.0]
  bandwidth = 1
  ; Noise:
  noisetime = [0.49, 0.53]
  noisefreq = [75., 95.]
  ; Interpolation:
  tdens = 1
  fdens = 10
  
  ; #25506
  start_x = 0.474


; Channels:
; ---------
  ; F camera:
  channels = ['SX_-F_010', 'SX_-F_011', 'SX_-F_012', 'SX_-F_013', $
    'SX_-F_014', 'SX_-F_015', 'SX_-F_016', 'SX_-F_017', $
    'SX_-F_018', 'SX_-F_019', 'SX_-F_020', 'SX_-F_021', $
    'SX_-F_022', 'SX_-F_023', 'SX_-F_024', 'SX_-F_025', $
    'SX_-F_026', 'SX_-F_027']
  ; G camera:
  channels = ['SX_-G_009', 'SX_-G_010', 'SX_-G_011', 'SX_-G_012', $
    'SX_-G_013', 'SX_-G_014', 'SX_-G_015', 'SX_-G_016', $
    'SX_-G_017', 'SX_-G_018', 'SX_-G_019', 'SX_-G_020', $
    'SX_-G_021', 'SX_-G_022', 'SX_-G_023', 'SX_-G_024', $
    'SX_-G_025', 'SX_-G_026', 'SX_-G_027', 'SX_-G_028']
  ; H, I, J camera OK:
  channels = ['SX_-H_052', 'SX_-H_053', 'SX_-H_054', 'SX_-H_055', $
    'SX_-I_051', 'SX_-I_052', 'SX_-I_054', 'SX_-J_050', $
    'SX_-J_051', 'SX_-J_052', 'SX_-J_053', 'SX_-J_054', $
    'SX_-J_055']
  ; H camera middle:
  channels = ['SX_-H_046', 'SX_-H_047', 'SX_-H_048', 'SX_-H_049', $
    'SX_-H_050', 'SX_-H_051', 'SX_-H_052', 'SX_-H_053', $
    'SX_-H_054', 'SX_-H_055', 'SX_-H_056', 'SX_-H_057', $
    'SX_-H_058', 'SX_-H_059', 'SX_-H_060']
  ; J camera OK:
  channels = ['SX_-J_050', 'SX_-J_051', 'SX_-J_052', 'SX_-J_053', $
    'SX_-J_054', 'SX_-J_055']
  ; J camera OK 2:
  channels = ['SX_-J_053', 'SX_-J_054', 'SX_-J_055', 'SX_-J_056', $
    'SX_-J_057', 'SX_-J_058', 'SX_-J_059', 'SX_-J_060']
  ; J camera middle:
  channels = ['SX_-J_046', 'SX_-J_047', 'SX_-J_048', 'SX_-J_049', $
    'SX_-J_050', 'SX_-J_051', 'SX_-J_052', 'SX_-J_053', $
    'SX_-J_054', 'SX_-J_055', 'SX_-J_056', 'SX_-J_057', $
    'SX_-J_058', 'SX_-J_059', 'SX_-J_060']
  ; J camera middle OK:
  channels = ['SX_-J_049', 'SX_-J_050', 'SX_-J_051', $
    'SX_-J_054', 'SX_-J_055', 'SX_-J_056']
  ; J camera middle 2:
  channels = ['SX_-J_048', 'SX_-J_049', 'SX_-J_050', 'SX_-J_051', $
    'SX_-J_054', 'SX_-J_055', 'SX_-J_056', 'SX_-J_057', 'SX_-J_058']
  ; I camera middle:
  channels = ['SX_-I_043', 'SX_-I_044', 'SX_-I_045', $
    'SX_-I_046', 'SX_-I_047', 'SX_-I_048', 'SX_-I_049', $
    'SX_-I_050', 'SX_-I_051', 'SX_-I_052', 'SX_-I_053', $
    'SX_-I_054', 'SX_-I_055', 'SX_-I_056', 'SX_-I_057', $
    'SX_-I_058', 'SX_-I_059', 'SX_-I_060', $
    'SX_-I_061', 'SX_-I_062', 'SX_-I_063', 'SX_-I_064']
    ; J-054:
  channels = ['SX_-J_054']
  ; MHA-B31-14:
  channels = ['MHA-B31-14']

; Eigenfunction
; -------------

; #30951 other one SXR F
; ASDEX Upgrade, #30951, SX_, F, AUGD:FPP30951.0, rho, t=0.61500001-0.62500000 s
start_x = 0.621
timepoints = [0.6205]
rho = [-1.00804, -0.968552, -0.903924, -0.810776, $
  -0.693017, -0.540272, -0.356068, -0.150921, $
  +0.0620586, +0.260404, +0.437501, +0.584972, $
  +0.703071, +0.797595, +0.873437, +0.931504, $
  +0.972738, +0.998905]
  
; #30951 other one SXR G
; ASDEX Upgrade, #30951, SX_, G, AUGD:FPP30951.0, rho, t=0.61500001-0.62500000 s
start_x = 0.621
timepoints = [0.6205]
rho = [-1.01115, -1.00777, -0.967968, -0.902825, -0.809316, $
  -0.691102, -0.537961, -0.353443, -0.148135, +0.0646618, $
  +0.262845, +0.439580, +0.586661, +0.704402, +0.798681,$
  +0.874217, +0.932029, +0.973004, +0.998958, +1.00408]

; #30951 nice one SXR F
; ASDEX Upgrade, #30951, SX_, F, AUGD:FPP30951.0, rho, t=0.63000000-0.64999932 s
start_x = 0.638
timepoints = [0.6380]
rho = [-1.00917, -0.972328, -0.907990, -0.815262, -0.697978, $
  -0.545060, -0.360074, -0.153643, +0.0608956, +0.260554, $
  +0.438644, +0.586651, +0.704880, +0.799307, +0.874907, $
  +0.932832, +0.974044, +1.00008]

; #30951 nice one SXR G
; ASDEX Upgrade, #30951, SX_, G, AUGD:FPP30951.0, rho, t=0.63000000-0.64999932 s
start_x = 0.638
timepoints = [0.6380]
rho = [-1.01174, -1.00927, -0.971744, -0.906894, -0.813810, $
  -0.696061, -0.542744, -0.357436, -0.150838, +0.0635125, $
  +0.263009, +0.440732, +0.588343, +0.706213, +0.800390, $
  +0.875684, +0.933354, +0.974308, +1.00013, +1.00427]

; #28881 EPS @1
; AUGD:FPP28881.0, rho, t=0.63499999-0.63800001 s
start_x = 0.636
timepoints = [0.6356, 0.63605, 0.6367, 0.6370, 0.6373]
rho = [+0.231597, +0.144820, +0.0485137, -0.0486055, -0.154727, -0.263274]

; EPS @2
; AUGD:FPP28881.0, rho, t=0.64899999-0.65300000 s
start_x = 0.650
timepoints = [0.6493, 0.6500, 0.6505, 0.6510, 0.6515, 0.6520]
rho = [+0.234195, +0.149670, +0.0551692, -0.0424668, -0.146960, -0.252934]

; EPS @3
; AUGD:FPP28881.0, rho, t=0.65399998-0.65700001 s
start_x = 0.655
timepoints = [0.6543, 0.6545, 0.6550, 0.6555, 0.6560, 0.6565]
rho = [+0.234195, +0.149670, +0.0551692, -0.0424668, -0.146960, -0.252934]

; #31213 EGAM@1
; AUGD:FPP31213.0, rho, t=0.81500000-0.82999998 s
start_x = 0.824
timepoints = [0.822, 0.8225, 0.823, 0.8235, 0.824] ;EGAM@1
rho = [+0.522733, +0.468159, +0.406643, +0.337432, +0.258821, +0.170010, $
+0.0733129, -0.0262651, -0.134586, -0.245342, -0.351757, -0.452883, $
-0.548220, -0.637025, -0.718184]
; micdu:EQB
rho = [0.247108, 0.183250, 0.116241]  ; J49, J50, J51
rho = [-0.107648, -0.192217, -0.282828]  ; J54, J55, J56

; #31213 EGAM@2
; AUGD:FPP31213.0, rho, t=0.81500000-0.82999998 s
start_x = 0.834
timepoints = [0.822, 0.8225, 0.823, 0.8235, 0.824] + 0.01035 ;EGAM@2
rho = [+0.522733, +0.468159, +0.406643, +0.337432, +0.258821, +0.170010, $
+0.0733129, -0.0262651, -0.134586, -0.245342, -0.351757, -0.452883, $
-0.548220, -0.637025, -0.718184] ; adopted from EGAM@1

; #31213 EGAM@3
; AUGD:FPP31213.0, rho, t=0.81500000-0.82999998 s
start_x = 0.844
timepoints = [0.822, 0.8225, 0.823, 0.8235, 0.824] + 0.02045 ;EGAM@3
rho = [+0.522733, +0.468159, +0.406643, +0.337432, +0.258821, +0.170010, $
+0.0733129, -0.0262651, -0.134586, -0.245342, -0.351757, -0.452883, $
-0.548220, -0.637025, -0.718184] ; adopted from EGAM@1

; #31216 EGAM
; ASDEX Upgrade, #31216, SX_, J, AUGD:FPP31216.0, rho, t=0.50500000-0.51499999 s
start_x = 0.511
timepoints = [0.5100, 0.5105, 0.5110, 0.5115]
rho = [+0.352535, +0.267990, +0.174809, +0.0723971, -0.0336835, $
  -0.145588, -0.258181, -0.366043]
  
; #25506
; ASDEX Upgrade, #25506, SX_, J, AUGD:FPP25506.0, rho, t=0.47299999-0.47499999 s
start_x = 0.474
timepoints = [0.4733, 0.4735, 0.4737, 0.4739]
rho = [+0.438743, +0.342868, +0.234850, -0.257337, -0.369754, -0.473466]

; #31233
; ASDEX Upgrade, #31233, SX_, J, AUGD:FPP31233.0, rho, t=0.83700001-0.84700000 s
start_x = 0.841
timepoints = [0.840, 0.8405, 0.841, 0.8415, 0.842, 0.8425, 0.843]
rho = [+0.369481, +0.286278, +0.192552, -0.137135, -0.254456, -0.366484]
channels = ['SX_-J_049', 'SX_-J_050', 'SX_-J_051', 'SX_-J_054', 'SX_-J_055', 'SX_-J_056']