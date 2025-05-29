;Written by Gergely PAPP, papp@reak.bme.hu, 2009.01.08.
;Calculate impulse-response with FFT



pro gp_imp, data1,data2,imp12=imp12,imp21=imp21,dc=dc

dc=keyword_set(dc)

; Mean subtraction
if dc NE 1 then begin
   data1=data1-mean(data1)
   data2=data2-mean(data2)
endif
datasize=n_elements(data1)

zeropad=fltarr(datasize)
data1=reform(data1)
;data1fft=FFT([data1,zeropad],-1) ;FFT
data1fft=FFT(data1,-1)
data2=reform(data2)
;data2fft=FFT([data2,zeropad],-1) ;FFT
data2fft=FFT(data2,-1)
apsd1=float(data1fft*conj(data1fft))
apsd2=float(data2fft*conj(data2fft))
i=where(apsd1 EQ 0)
j=where(apsd2 EQ 0)

if i NE -1 then begin
   print,'Division by zero is avoided manually!'
   apsd1[i]=1e-36
endif

if j NE -1 then begin
   print,'Division by zero is avoided manually!'
   apsd2[j]=1e-36
endif

imp12=FFT((data2fft*conj(data1fft)/apsd1),1) ;IFFT
imp21=FFT((data1fft*conj(data2fft)/apsd2),1) ;IFFT

;imp12=FFT((data2fft*conj(data1fft)),1) ;IFFT
;imp21=FFT((data1fft*conj(data2fft)),1) ;IFFT


imp12=float(imp12) ;Imaginary part is computation noise
imp21=float(imp21) ;Imaginary part is computation noise

;imp12=shift(imp12,datasize) ;Shift to center
;imp21=shift(imp21,datasize) ;Shift to center

imp12=shift(imp12,floor(datasize/2d)) ;Shift to center
imp21=shift(imp21,floor(datasize/2d)) ;Shift to center


;imp12=imp12[floor(datasize/2d)+1:datasize+floor(datasize/2d)] ;Cut to original length
;imp21=imp21[floor(datasize/2d)+1:datasize+floor(datasize/2d)] ;Cut to original length



end
