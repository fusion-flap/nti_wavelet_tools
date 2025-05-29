pro load_ELM0runBicoherencepgg
;cut and selected by PorG from Poloskei's program
  ;path='/afs/ipp-garching.mpg.de/home/p/pog/porg/2017/december20/save_data/'
  ;filename='AUGD_34549_Loaded-with-MTR.sav'
  
  ; Select a text file and open for reading
  file = DIALOG_PICKFILE(FILTER='*.*')
  OPENR, lun, file, /GET_LUN
  ; Read one line at a time, saving the result into array
  array1 = ''
  line = ''
  WHILE NOT EOF(lun) DO BEGIN & $
    READF, lun, line & $
    array1 = [array1, line] & $
  ENDWHILE
; Close the file and free the file unit
FREE_LUN, lun
data=Double(array1)

chName=file_basename(file)
  
  
  
; Select a text file and open for reading
file2 = DIALOG_PICKFILE(FILTER='Tt*.*')
OPENR, lun, file2, /GET_LUN
; Read one line at a time, saving the result into array
axa = ''
line = ''
WHILE NOT EOF(lun) DO BEGIN & $
  READF, lun, line & $
  axa = [axa, line] & $
ENDWHILE
; Close the file and free the file unit
FREE_LUN, lun  

timeax=Double(axa)
dtt=timeax(2)-timeax(1)
dtt2=2*dtt
fmax2=1/dtt2

;stop
  blocksize=1024;128;1024;2048;256; 1024
;  print, channels
;  read, chsorsz, prompt='enter the ch number: '
  ;chsorsz=2
;  data=reform(data(*,chsorsz))
  
  ;read, maxFreq, prompt='enter max frequency in kHz: ' ;maxFreq=50
  maxFreq=fmax2
  read, blocksize, prompt='enter blocksize:'
  read, numOfSamples, prompt='enter mintaszam min 20 max 500: ' ;numOfSamples=32
  read, confLevel, prompt='enter confidence level:  '   ;confLevel=0.95
  optScale=0.7
  read, ELMLevel, prompt='enter ELM level:  '
  ELMszint=string(ELMlevel)
  ELMselect=ELMlevel


shotnumber=11
expname='ORB'
optScale=22

  parameters = ELMcreateParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale,ELMselect, 'bicoherence  '+'at ELM0level='+ELMszint)
  
  
  bicoherence = ELM0calculateBicoherence(data,blocksize,ELMlevel)
  plot0Bicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=0.7
  parameters = ELMcreateParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, ELMselect, 'confidence'+'at ELM0level= '+ELMszint)
  ;parameters=parameters+'ELMlevel='+ELMszint
  plot0Bicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = ELMcreateParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale,ELMselect, 'filtered_at_'+pg_num2str(confLevel)+' ELM0level='+ELMszint)
;    parameters=parameters+'ELMlevel='+ELMszint
  plot0Bicoherence, filtered, parameters
  
  ;APSD for ELMfiltered signal
    ;parameters = ELMcreateParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
   ; maxFreq ,optScale,ELMselect, 'filtered_at_'+pg_num2str(confLevel, length=5)+'ELMlevel='+ELMszint)
; APSDabra = ELMcalculateBicoherence(data,blocksize,ELMlevel, APSD)
; freqAxis = createFreqAxis(plotParameters.niqFrequency,plotParameters.blockSize)
; plot, freqAxis, APSDabra
  ;    parameters=parameters+'ELMlevel='+ELMszint
  ;plotBicoherence, filtered, parameters
  
  
  stop
  return
  end