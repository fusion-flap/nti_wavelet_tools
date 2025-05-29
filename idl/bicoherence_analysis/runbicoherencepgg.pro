pro runBicoherencepgg
;cut and selected by PorG from Poloskei's program
  ;path='/afs/ipp-garching.mpg.de/home/p/pog/porg/2017/december20/save_data/'
  ;filename='AUGD_34549_Loaded-with-MTR.sav'
  
  
  totalfilename=DIALOG_PICKFILE(/READ, FILTER='*.sav')
  
  
  path_a=FILEPATH(totalfilename)
print,path_a
print,totalfilename

  restore, totalfilename

  blocksize=1024
  print, channels
  read, chsorsz, prompt='enter the ch number: '
  ;chsorsz=2
  data=reform(data(*,chsorsz))
  chName=channels(chsorsz)
  read, maxFreq, prompt='enter max frequency in kHz: ' ;maxFreq=50
  read, numOfSamples, prompt='enter mintaszam min 20 max 500: ' ;numOfSamples=32
  read, confLevel, prompt='enter confidence level:  '   ;confLevel=0.95
  optScale=0.7


  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  ;parameterhez hozzaadom az ELMlevel-t
  
  read, ELMLevel, prompt='enter ELM level:  '
   ELMszint=string(ELMlevel)
;   parameters=parameters+'ELMlevel='+ELMszint
  
  bicoherence = ELMcalculateBicoherence(data,blocksize,ELMlevel)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
;  parameters=parameters+'ELMlevel='+ELMszint
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
 ;   parameters=parameters+'ELMlevel='+ELMszint
  plotBicoherence, filtered, parameters
  stop
  return
  end