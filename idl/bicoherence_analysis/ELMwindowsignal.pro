;********************************************************************************************************
; Name: ELMwindowSignal.pro
; 
; PURPOSE
; =======
; Cut signal to proper parts
; 
; USAGE
; =======
; INPUTS
; =======
; OUTPUT
; =======
;********************************************************************************************************
function ELMwindowSignal, rawSignal, singleBlockSize,ELMlevel, how=how
  ;not overlapping block number
  blockNumber = floor(n_elements(rawSignal)/singleBlockSize)
  if blockNumber EQ 0 then begin
    singleBlockSize = n_elements(rawSignal)
    blockNumber = 1
  endif
  ;check that is how variable defined?
 ; if isa(how) then begin
    ; Before we make the windowing we filter out those block, whihc bolongs to ELM
    ; We use the total absolute value of blocks
    maxit=0.0
    print, 'maxit',maxit
    ;wait,1
    
    meret=size(rawSignal)
    print, 'rawSignalsize=', meret
    
    ;Just to prepare the signal
    ;if how EQ 'not_overlapping_hanning' then begin
      newSignal = dblarr(blockNumber,singleBlockSize)
      for i=0L, blockNumber-1L do begin
        newSignal(i,*) = hanning(singleBlockSize)*(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)-$
          mean(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)))
      endfor
     ; return, windowedSignal
    ;endif
    
    
    
    fftSignal = fft(newSignal,dimension=2,-1)
    APSD=abs(fftSignal)
    print, 'APSD size',size(APSD)
    meret=size(fftSignal)
    print, 'fftSignalsize=', meret
    ;Only keep positive frequency part
    fftSignal = reform(fftSignal(*,0:singleBlockSize/2-1))
    meret=size(fftSignal)
    print, 'reformfftSignalsize=', meret
    
;   contour, abs(fftSignal),levels=[0.0001,0.001,0.01,0.1,1.0,10.],/fill 
  ; print, 'size of abs(fftSignal) for countour plot',size(abs(fftSignal))
 ;   wait, 1
    
    For i=0L, blockNumber-1 DO BEGIN
 ;     mmm=max(abs(fftSignal(i,0:singleBlocksize/2-1)))
  ;    APDfunction=histogram(abs(fftSignal(i,0:singleBlocksize/2-1)),MIN=mmm/10,MAX=mmm,bin=mmm/10)
  ;    result=MAX(APDfunction,maxsubs)
   ;   print,'APDof block',i
    ;  plot, APDfunction
     ; wait,1
     upperfreqintegral=total(abs(fftSignal(i,singleBlocksize/4-1:singleBlocksize/2-1)))
      if upperfreqintegral GT maxit THEN maxit=upperfreqintegral
    endfor
    
    
   print, 'maxit:',maxit 
    
    
    ;for i=0, blockNumber-1 do begin
     ; if maxit lt total(abs(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1))) then maxit=total(abs(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)))
     ;;;;;;;;if maxit lt total(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)^2) then maxit=total(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)^2)
      ;print, i, '  ',maxit, total(abs(cutSignal(i,0:singleBlockSize/2-1)))
      ;wait,1
;;;;;;;;; sqrt(total(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)^2))  it is not really different
    ;endfor
    
    ;read, ELMLevel, prompt='enter ELM level:  '
    ;ELMszint=string(ELMlevel)
    
    levag=ELMlevel
    ;levag=1.0
    print, 'levag=',levag
    print, 'blockNumber ELM előtt', blockNumber
    
    For i=0l, blockNumber-1L Do Begin
  ;    APDfunction=histogram(abs(fftSignal(i*singleBlocksize:(i+1)*singleBlocksize)))
   ;   result=MAX(APDfunction,maxsubs)
   upperfreqintegral=total(abs(fftSignal(i,singleBlocksize/4-1:singleBlocksize/2-1)))
   
      if upperfreqintegral GT  levag*maxit THEN Begin
        print, i, 'ELM'
        for j=0L, singleBlockSize-1L do begin
          
          rawSignal(i*singleBlockSize+j)=0.0
          ;print, cutSignal(i,j)
        endfor
      endif      
      
          print,'5.elem nullázás után', i, rawSignal(i*singleBlockSize), rawSignal(i*singleBlockSize+5), rawSignal(i*singleBlockSize+singleblockSize-1)
    Endfor;i
;print, 'rawsignal 25-50',rawSignal[25:50]
 
 print,'where elott', size(rawSignal)
  
    ;rawFilteredSignal=rawSignal(where(rawSignal,/L64))
     index=where(rawSignal,count)
     if count NE 0 THEN rawFilteredSignal=rawSignal[index]   ;to avoid case when all elements of array are zero
    ;print, 'zero at index',index
    print, 'count=',count
;print, 'rawFilteredsignal 25-50',rawFilteredSignal[25:50]
    
    alig= size(rawFilteredSignal)
    print,'size of rawFilteredSignal',alig
    blockNumber = floor(n_elements(rawFilteredSignal)/singleBlockSize)
    print, 'blockNumber rawFilteredSignal ELM után', blockNumber; 
   
   rawSignal=rawFilteredSignal
   print, 'where után size',Size(rawSignal)
    ; ha ezt a csonkolás után is végre lehet hajtani akkor kivágtuk a nullákat a rawsingalból????
  blockNumber = floor(n_elements(rawSignal)/singleBlockSize)
    print, 'blockNumber rawSignal ELM után', blockNumber; 
    ; 
    ;Case of not overlapping hanning
    if how EQ 'not_overlapping_hanning' then begin
      windowedSignal = dblarr(blockNumber,singleBlockSize)    
      for i=0d, blockNumber-1L do begin
        windowedSignal(i,*) = hanning(singleBlockSize)*(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)-$
                                mean(rawSignal(i*singleBlockSize:(i+1)*singleBlockSize-1)))
      endfor
      return, windowedSignal
    endif
  
    ;Case of 50% overlapping hanning
    if how EQ 'overlapping_hanning' then begin
      windowedSignal = dblarr(2*blockNumber-1,singleBlockSize)
        for i=0d, 2*blockNumber-2L do begin
          windowedSignal(i,*) = hanning(singleBlockSize)*(rawSignal(i*singleBlockSize/2.:i*singleBlockSize/2.+singleBlockSize-1.)-$
                                  mean(rawSignal(i*singleBlockSize/2.:i*singleBlockSize/2.+singleBlockSize-1.)))
       
       ;plot, abs(fft(windowedSignal(i,*))) ; porgabor
       ;wait, 1
       
        endfor
        return, windowedSignal
    endif
    
  ;endif
  
  return, 0
end