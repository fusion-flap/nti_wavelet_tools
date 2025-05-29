;********************************************************************************************************
; Name: runBicoherenceH5.pro
;
; PURPOSE
; =======
; This program will run the necessary subprogram to evaluate the bicoherence from .sav data files transferred from .h5.
;
; INPUTS
; =======
;
; OUTPUT
; =======
; Plots at directory named after the date
;
; USAGE
; =======
;interactive, widget for searching *.h5 file.
;after reading the file you will be asked, which one from several signas you want to select.
;
;********************************************************************************************************
pro runBicoherenceH5  
  
  totalfilename=DIALOG_PICKFILE(/READ, FILTER='*.sav')
    
  path_a=FILEPATH(totalfilename)
  restore, totalfilename
  print,'Data read from ' + totalfilename

  blocksize=512; 1024; here you may change block_size
  print, channels
  chsorsz=0
  data=reform(data[*,chsorsz]); Transform to 1D data
  chName=channels(chsorsz)
  read, maxFreq, prompt='Enter max frequency in kHz for final plot (e.g. 1e9): '
  read, numOfSamples, prompt='Enter number of samples for statistics, higher is better, but too high needs more memory and time (e.g. 500): '
  read, confLevel, prompt='Enter confidence level (e.g. 0.95):  '   ;confLevel=0.95

  optScale=0.7; Plot clolor scale
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  
  ELMLevel=1.0 ; Set this to <1.0, if you want to discard those block whihc contain spurious spikes  
  bicoherence = ELMcalculateBicoherence(data,blocksize,ELMlevel)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=0.7; Plot clolor scale
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7; Plot clolor scale
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  
  end