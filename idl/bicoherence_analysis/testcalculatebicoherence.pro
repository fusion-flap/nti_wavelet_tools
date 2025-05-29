pro testCalculateBicoherence
  ;test  with random noise
  blockLength = 1024
  timeaxis = findgen(60000)/(2e6)
  signal = 80*sin(2*!Pi*2.5e3*timeaxis) + 80*sin(2*!Pi*2.5e3*timeaxis)+ 100*sin(2*!Pi*5e3*timeaxis) +1*randomn(seed,60000)
  tic
  bicoherence2 = calculateBicoherence(signal,timeaxis,blockLength)
  toc
;********************************************************************************************************
; test plotBicoherence
  parameters = createParameterStruct(blockLength, timeaxis, 'Test-channel', 42, 'TestMachine', 50, 2)
  plotBicoherence, bicoherence2, parameters

;plot_bicoherence, signal, timeaxis, 1024
;********************************************************************************************************
; test RBDF
;tic
  ;RBDF=generateRBDF(signal,timeaxis,blockLength,200)
;toc
  ;significance = calculateSignificance(RBDF,bicoherence2)
  ;plotBicoherence, significance, parameters
end