;********************************************************************************************************
; Name: ELMcreateParameterStruct.pro
;
; PURPOSE
; =======
; This program generates parameter struct which contains parameters of 
;
; USAGE
; =======
; parameterStruct=ELMcreateParameterStruct(singleBlockSize,timeAxis,channelName,shotNo,expname)
;
; INPUTS
; =======
; singleBlockSize:            blocksize of a single window (int)
; timeAxis:                   time axis (1D)
; channelName:                name of channel
; shotNo                      number of discharge
; expname                     name of experiment
; maxFreq                     maximal frequency to plot
; optScale                    exponential for rescaling plot colortable
; type                        bicoherence/confidence/filteredBicoherence
;
; OUTPUT
; =======
; createParameterStruct:      randomized bicoherence density function
;********************************************************************************************************
function ELMcreateParameterStruct, singleBlockSize, timeAxis, channelName, shotNo, expname, maxFreq, optScale, ELMselect, type
  ELMLevel=ELMselect
  date=systime()
  ID = strtrim(string(round(1000*systime(1),/L64)),2)
  ;
  blockNumber = floor(n_elements(timeAxis)/singleBlockSize)
  if blockNumber EQ 0 then begin
    singleBlockSize = n_elements(timeAxis)
    blockNumber = 1
  endif
 
  dt = (max(timeAxis)-min(timeAxis))/(n_elements(timeAxis)-1)
  freqNiquist=1./(dt)/2./1000. ;kHz
  if maxFreq GT freqNiquist then maxFreq = freqNiquist
  
  parameterStruct = {$
    expName:        expname,$
    channelName:    channelName,$
    shotnumber:     shotNo,$
    timeRange:      [min(timeAxis),max(timeAxis)],$
    blockSize:      singleBlockSize,$
    blockNumber:    blockNumber,$
    niqFrequency:   freqNiquist,$
    maxFrequency:   maxFreq,$
   ELMselect:      ELMLevel,$
    optScale:       optScale,$
    type:           type,$
    date:           date,$
    fileID:         ID $
  }
  return, parameterStruct
end