;********************************************************************************************************
; Name: hgmc2sav.pro
;
; PURPOSE
; =======
; This program converts data from HGMC .h5 to .sav output for given modenumber-pairs and within a pre-defined 
; radial location applying a weighting by 1/(1.1-r) to simulate a magnetic measurement
;
; INPUTS
; =======
; file_path_name (optional):      Name of file to convert with path; default: Input from dialog box
; mode_pairs (optional):          Modes to consider (2D, with 1 digit numbers!); default: [[2,2],[3,2],[4,2],[5,2],[6,2],[7,2]]
; radial_pos (optional):          Radial position to integrate through (1D); default: [0.0,1.0]
; noise_lebel (optional):         Relative power of added Gaussian noise; default: 0,0005
; repeat_data (optional):         Number of repeats of data to extend signal length; default: 0
;
; OUTPUT
; =======
; .sav file in a format cmpatible with NWT
; 
; USAGE
; =======
; hgmc2sav, file_path_name='A:\3programs\NTI_Wavelet_Tools\trunk\save_data\HMGC\2017_greg_n145_coupling.h5', mode_pairs=[[0,0],[1,0],[1,2],[3,2],[4,2],[5,2],[6,2],[7,2]], radial_pos=[0.6,0.7], noise_level=0.5
; hgmc2sav, file_path_name='A:\3programs\NTI_Wavelet_Tools\trunk\save_data\HMGC\2017_greg_n145_coupling.h5', mode_pairs=[[0,0],[1,0],[1,1],[2,1],[3,4],[4,4],[4,5],[5,4],[5,5],[6,4],[6,5],[7,4],[7,5],[8,4],[8,5],[9,5]], radial_pos=[0.6,0.7], noise_level=0.5
;********************************************************************************************************
pro hgmc2sav, file_path_name=file_path_name, mode_pairs=mode_pairs, radial_pos=radial_pos, noise_level=noise_level, repeat_data=repeat_data

  if not nti_wavelet_defined(file_path_name) then begin
    file_path_name = dialog_pickfile(title='Select HDF5 File HGMC', filter='*.h5', /fix_filter)
  endif
  nti_wavelet_default, mode_pairs, [[2,2],[3,2],[4,2],[5,2],[6,2],[7,2]]
  nti_wavelet_default, radial_pos, [0.0,1.0]
  nti_wavelet_default, noise_level, 0.0005
  nti_wavelet_default, repeat_data, 0
  
  print, 'File was read from: ', file_path_name
  ;create file to be opened ID
  fileID = H5F_OPEN(file_path_name)
  
  dataPath = 'data/var1d/field/phi/'

  ;create variable ID
  normCoordID = H5D_OPEN(fileID, dataPath+'coord')
  
  timeID = H5D_OPEN(fileID, dataPath+'time')
  
  modeID = indgen((size(mode_pairs))(2),/long)
  for i=0, (size(mode_pairs))(2)-1 do begin
    modeName='im0'+pg_num2str(mode_pairs(0,i))+'n0'+pg_num2str(mode_pairs(1,i))
    print, 'read mode pairs: ', modeName
    modeID(i)= H5D_OPEN(fileID, dataPath+modeName)
  endfor
  
  ;Create data and add them for multiple (m,n) and to a given radial localization
  normCoord = H5D_READ(normCoordID)
  
  timeax_segment = H5D_READ(timeID)
  ;integrate modewise
  data_segment = dblarr(n_elements(normCoord),n_elements(timeax_segment))
  for i=0, (size(mode_pairs))(2)-1 do begin
    data_segment+= H5D_READ(modeID(i))
  endfor
  ;integrate radially
  radInd0 = where(abs(normCoord-radial_pos(0)) eq min(abs(normCoord-radial_pos(0))))
  radInd1 = where(abs(normCoord-radial_pos(1)) eq min(abs(normCoord-radial_pos(1))))
  data_segment = reform(mean(data_segment(radInd0:radInd1,*)/(1.1-normCoord(radInd0:radInd1)#(fltarr(n_elements(timeax_segment))+1)), dimension=1)); Weighting by 1/(1.1-r)
  data = data_segment
  timeax = timeax_segment
  ; repeate data
  i=0
  break_length = n_elements(data)/4.
  while i LT repeat_data do begin
    random_length = break_length * randomu(seed, 1)
    data = [data, dblarr(random_length), data_segment]
    timeax = [timeax, timeax_segment[0:random_length-1]+timeax[-1]] ; Assumes timeax_segment to begin from 0
    timeax = [timeax, timeax_segment+timeax[-1]]    
    i+=1
  endwhile
  ; add some noise
  noiseAmpl = sqrt(noise_level*mean(abs(data)^2))
  data+=noiseAmpl*randomn(seed,n_elements(data)); Add noise
  
  ;Create data to be saved
  ;what is the temporal resolution >> major radius devided by onaxis Alfvenic velocity
  ;AUG >  B ~ 3T,   R ~1.65 m,  n ~1e20,  dt ~2.5e-7
  timeax=timeax*5d-7 ; Time step is chosen to fit observed frequency
  channels=modeName+'_'+pg_num2str(normCoord(radInd0),length=3)+'-'+pg_num2str(normCoord(radInd1),length=3)
  coord_history='Normalized radial pos: '+pg_num2str(normCoord(radInd0),length=3)+'-'+pg_num2str(normCoord(radInd1),length=3)
  data_history='HGMC-hdf5'
  phi=0
  theta=0
  shotnumber=2102120
  expname='HGMC-hdf5'
  
  ;close opened file
  for i=0, (size(mode_pairs))(2)-1 do begin
    H5D_CLOSE, modeID(i)
  endfor
  H5D_CLOSE, timeID
  H5D_CLOSE, normCoordID
  H5F_CLOSE, fileID
  
  ;save file
  save, data, timeax, phi, theta,$
    shotnumber, mode_pairs, radial_pos,$
    expname, channels, coord_history, data_history,$
    filename=file_path_name+'.sav'
    
  print, 'HGMC data written to ' + file_path_name+'.sav'

end