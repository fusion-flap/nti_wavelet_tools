;+
; NAME:
;	NTI_WAVELET_READ_ECE
;
; PURPOSE:
;	This procedure read ECE data from AUG using the
;       fastECE pthon library and Slither 3.0 to link
;       Python and IDL. It saves the data into a NTI
;       Wavelet Tools .sav file. It also reads the
;       coordinates of the channels in the middle of
;       the requested time range.
;
; CALLING SEQUENCE:
;       NTI_WAVELET_READ_ECE [,shotnumber] [,trange]
;
; INPUTS:
;	shotnumber:  requested shotnumber
;       trange:      requested time range
;
; EXAMPLE:
;       NTI_WAVELET_READ_ECE, shotnumber = 30416, $
;         trange = [2.65, 2.78]
;
; ADDITIONAL REMARK:
;       Use a qa machine on AUG (qa01-qa14).
;       Run the following commands:
;         setenv PYTHONPATH /afs/ipp/aug/ads-diags/common/python/lib
;         setenv PYTHONPATH <the/path/where/fastECE.py/is/stored>:$PYTHONPATH
;         module load intel
;         module load python27/basic
;         module load idl
;         setenv LD_LIBRARY_PATH /afs/ipp-garching.mpg.de/tok/soft/python27/python/2.7.3/amd64_sles11.old/lib:$LD_LIBRARY_PATH
;       
;-

pro nti_wavelet_read_ece, $
   shotnumber = shotnumber, trange = trange

; Set defautls:
nti_wavelet_default, trange, [-1.0, 12.0]

; Load fastECE python library:
fastECE = pyimport('fastECE')

; Create a new instance of fastECE class:
ECE = fastECE->fastECE()
; Load shotfile:
tmp = ECE->Load(shotnumber, tBegin = trange(0), tEnd = trange(1))

; Read data:
data = ECE->__call__(tBegin = trange(0), tEnd = trange(1))
; Read time axis:
timeax = ECE->getTime(tBegin = trange(0), tEnd = trange(1))
; Read position coordinates in the middle
; of the requested time range:
  tmid = 0.5*(trange(1) - trange(0))
  ; Read R coordinate:
  R = ECE->getR(tmid)
  ; Read z coordinate:
  z = ECE->getZ(tmid)
  ; Read rho coordinate:
  rho = ECE->MapToRhop(tmid)

; Save results to a NTI Wavelet Tools .sav file:
  ; Set R as channelname:
  channels = pg_num2str(R, length = 6)
  channels = 'ECE_R=' + channels + 'm'
  ; Set coordinate history:
  coord_history = 'phi=R and theta=rho'
  ; Set data:
  data = transpose(data)
  ; Set data histort:
  data_history = 'Python fastECE library'
  ; Set expname:
  expname = 'AUGD'
  ; Set phi:
  phi = R
  ; Shotnumber is OK
  ; Set theta:
  theta = rho
  ; Time axis is OK

  ; Save data:
  save, $
    channels, coord_history, data, data_history, $
    expname, phi, shotnumber, theta, timeax, $
    filename = expname + '_' + pg_num2str(shotnumber) + $
      '_ECE_' + pg_num2str(trange(0), length = 5) + '-' + $
      pg_num2str(trange(1), length = 5) + 's.sav'

end
