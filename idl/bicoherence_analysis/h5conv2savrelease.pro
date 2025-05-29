;********************************************************************************************************
; Name: h5conv2savrelease.pro
;
; PURPOSE
; =======
; This program enables to interactively select one of the data from .h5 and save it in .sav format for bicoherence analysis 
;
; INPUTS
; =======
; file_path_name (optional):      Name of file to convert with path; default: Input from dialog box
;
; OUTPUT
; =======
; .sav file in a format compatible for bicoherence calcualtion only!
;
; USAGE
; =======
;interactive, widget for searching *.h5 file. 
;after reading the file you will be asked, which one from several signas you want to select. 
;
;********************************************************************************************************
pro h5conv2savrelease, file_path_name=file_path_name

  if not nti_wavelet_defined(file_path_name) then begin
    file_path_name = dialog_pickfile(title='Select a H5 File', filter='*.h5', /fix_filter)
  endif

  print, 'File was read from: ', file_path_name
  originalfile=file_basename(file_path_name)

  ;Start H5 utilities
  fileID = H5F_OPEN(file_path_name)
  
  H5_LIST, file_path_name

  Print, 'Here above is the list of data in h5 file'
  Print, 'first you must select the time axis data, which is usually /t'
  Print, 'if this correct enter that name, otherwise the real name of the time axis data'
  
  tim=''
  read, tim, PROMPT='Enter time axis name form the above list:    '
  data_t = H5_GETDATA(file_path_name, tim)
  tim_scale=''
  read, tim_scale, PROMPT='Enter sample time in s:    '
  dat='';
  read, dat, PROMPT='Enter the data name from the above list including / for example /Er    '
  databe=H5_GETDATA(file_path_name,dat)
  data=[[databe],[databe]]
  
  timeax=data_t*tim_scale;Scale time axis to secs
  
  theta=[0.0,0.0];for a while we neglect reading as:  theta=H5_GETDATA(file_path_name,'/chi_points')
  chpos=double(theta);
  phi=[0.0,0.0]
  shotnumber=fileID
  expname=originalfile
  channels=[dat,dat]
  coord_history='No coordinate information'
  data_history='Data read from HDF5 file: '+originalfile
   
  save, data, timeax, phi, chpos, theta,$
    shotnumber,$
    expname, channels, coord_history, data_history,$
    filename=file_path_name+'.sav'
  
  print, 'data written to ' + file_path_name+'.sav'

  end

 
 