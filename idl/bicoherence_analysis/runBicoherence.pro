
pro runBicoherence
  path='A:\3programs\NTI_Wavelet_Tools\trunk\save_data\HMGC\'
  filename='2017_greg_n145_coupling_x100.sav'
  filename='2017_greg_n145_no_coupling_x100.sav'
  filename='2017_greg_n145_coupling_x10_noisy_weighted.sav'
  filename='2017_greg_n145_no_coupling_x10_noisy_weighted.sav'
  path='A:\3programs\NTI_Wavelet_Tools\trunk\save_data\'
  filename='mode_100_66_33_res_free.sav'
  filename='mode_100_66_33_f.sav'
  filename='mode_100_66_33_f_00005.sav'
  filename='mode_100_66_33_res_free_00005.sav'

  restore, path+filename

  blocksize=1024
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=200
  numOfSamples=2000
  confLevel=0.997
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  ;stop
  return
  ;=======================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_34184_Loaded-with-MTR_065_070.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=170
  numOfSamples=2000
  confLevel=0.997
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\AUGD_34185_Loaded-with-MTR_070_075.sav'
  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=200
  numOfSamples=5000
  confLevel=0.99
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  length = 60000.
  timeax = findgen(length)/(length-1.)
  data = randomn(seed,length)
  blocksize=512
  chName='whitenoise'
  maxFreq=1500000
  numOfSamples=2000
  confLevel=0.997
  optScale=0.7
  expname = 'whitenoisetest'
  shotnumber=1
  
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_33873_Loaded-with-MTR_050_055.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=150
  numOfSamples=2000
  confLevel=0.997
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\'
  filename='AUGD_32388_Loaded-with-MTR.sav'
  restore, path+filename
  
  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=250
  numOfSamples=2000
  confLevel=0.997
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    'periodic_chirp_0.2noise_n2_m_2-7.sav'
  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=1d-4
  numOfSamples=2000
  confLevel=0.99
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\AUGD_34186_Loaded-with-MTR.sav'
  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=170
  numOfSamples=500
  confLevel=0.99
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    'periodic_chirp_0.2noise_n2_m_2-7.sav'
  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=170
  numOfSamples=500
  confLevel=0.99
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================  
  path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_34185_Loaded-with-MTR_070_075.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=170
  numOfSamples=500
  confLevel=0.99
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_34184_Loaded-with-MTR_065_070.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=170
  numOfSamples=500
  confLevel=0.95
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\NTI_WaveletTools\trunk\feature-devel\bicoherence_analysis\test_signals\'+$
    'Synthetic_10264.sav'

  blocksize=1024
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=220
  numOfSamples=500
  confLevel=0.997
  optScale=0.7
  APSD='a'

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize,APSD=APSD)
  plotBicoherence, bicoherence, parameters
  ;stop

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  ;restore, 'C:\Users\poloskei\Desktop\work\FUSION\'+$path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_34184_Loaded-with-MTR_063_0665.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=220
  numOfSamples=1000
  confLevel=0.95
  optScale=0.7
  APSD='a'
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize,APSD=APSD)
  plotBicoherence, bicoherence, parameters
  ;stop

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_34184_Loaded-with-MTR_063_0665.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=220
  numOfSamples=1000
  confLevel=0.95
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\svn_repo\writings\2017_masterThesis\dataAnalysis\rawSignals\'
  filename='AUGD_34186_Loaded-with-MTR.sav'
  restore, path+filename

  blocksize=512
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=220
  numOfSamples=1000
  confLevel=0.95
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
    maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  path='C:\Users\poloskei\Desktop\work\FUSION\'
  filename='AUGD_32388_Loaded-with-MTR.sav'
  restore, path+filename

  blocksize=1024
  data=reform(data(*,0))
  chName=channels(0)
  maxFreq=220
  numOfSamples=1000
  confLevel=0.95
  optScale=0.7

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, blockSize, numOfSamples)
  confidence = calculateConfidence(RBDF,bicoherence)
  optScale=1.1
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'confidence')
  plotBicoherence, confidence, parameters
  
  filtered = filterConfidence(bicoherence,confidence,confLevel)
  optScale=0.7
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname,$
     maxFreq ,optScale, 'filtered_at_'+pg_num2str(confLevel, length=5))
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\NTI_WaveletTools\trunk\feature-devel\bicoherence_analysis\test_signals\'+$
    'Synthetic_10264.sav'

  blocksize=1024
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 200
  optScale = 0.6

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters
  stop
  RBDF=generateRBDF(data, timeax, blockSize, 200)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters
  stop
  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\'+$
    'AUGD_32388_Loaded-with-MTR.sav'

  blocksize=1024
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 220
  optScale = 0.6

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters
  stop
  RBDF=generateRBDF(data, timeax, blockSize, 600)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters
  stop
  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    'periodic_chirp_0.2noise_n2_m_2-7.sav'

  blocksize=1024
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 1e-4
  optScale = 1

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters
  stop
  RBDF=generateRBDF(data, timeax, blockSize, 300)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters
  stop
  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\NTI_WaveletTools\trunk\feature-devel\bicoherence_analysis\test_signals\'+$
    'Synthetic_10263.sav'

  blocksize=1024
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 200
  optScale = 0.3

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax, blockSize, 300)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    '2017_multi_n234_2017EP4_IDIS2_ENHSNI0d004.h5_im04n04_0.6-0.7.sav'

  blocksize=512
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 400
  optScale = 1.

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax, blockSize, 500)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    '2017_multi_n_n2_2017EP4_IDIS2_ENHSNI0d006_eps0d18_thermal_iumax2_field.h5_im07n02_0.6-0.7.sav'

  blocksize=512
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 400
  optScale = 1.

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax, blockSize, 500)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    '2017_multi_n_n2_2017EP4_IDIS2_ENHSNI0d006_eps0d18_thermal_iumax2_field.h5_im03n02_0.6-0.7.sav'

  blocksize=512
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 400
  optScale = 1.

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax, blockSize, 500)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  stop
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\personal\playground\'+$
    '2_IBTest_nonlinear_case.sav'

  blocksize=1024
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 0.6
  optScale = 1.
;stop
  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax, blockSize, 200)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.99)
  parameters.type='filtered at confLev'+pg_num2str(0.99)
  plotBicoherence, filtered, parameters
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\personal\playground\'+$
    '1_IBTest_linear_case.sav'

  blocksize=1024
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 0.6
  optScale = 1.

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax, blockSize, 200)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.99)
  parameters.type='filtered at confLev'+pg_num2str(0.99)
  plotBicoherence, filtered, parameters
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\work\FUSION\ASDEX_bicoherence\2017_IPP\'+$
    '2017_multi_n234_2017EP4_IDIS2_ENHSNI0d004.h5_im04n04_0.6-0.7.sav'

  blocksize=256
  data = reform(data(*,0))
  chName = channels(0)
  maxFreq = 400
  optScale = 1.

  parameters = createParameterStruct(blocksize, timeax, chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax,blocksize)
  plotBicoherence, bicoherence, parameters
  
  RBDF=generateRBDF(data, timeax, blockSize, 5000)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.95)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  return
  ;=======================================================================
  restore, 'C:\Users\poloskei\Desktop\'+$
    'AUGD_33873_Loaded-with-MTR_HFS_probes.sav'

  blocksize=2048
  data = reform(data(200000:300000,4))
  chName = channels(4)
  maxFreq = 150
  optScale = 1.

  parameters = createParameterStruct(blocksize, timeax(200000:300000), chName, shotnumber, expname, maxFreq ,optScale, 'bicoherence')
  bicoherence = calculateBicoherence(data,timeax(200000:300000),blocksize)
  plotBicoherence, bicoherence, parameters

  RBDF=generateRBDF(data, timeax(200000:300000), blockSize, 500)
  confidence = calculateConfidence(RBDF,bicoherence)
  parameters.type='confidence'
  plotBicoherence, confidence, parameters

  filtered = filterConfidence(bicoherence,confidence,0.9)
  parameters.type='filtered'
  plotBicoherence, filtered, parameters
  return
end

