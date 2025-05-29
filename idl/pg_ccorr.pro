;+
; Name: pg_ccorr
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.04.08.
;
; Purpose: Calculate crosscorrelation using FFT
;
; Calling sequence:
;	ccorr=pg_ccorr(data1, data2 [,/fast] [,/dc] [,/nonorm])
;
; Input:
;	data1: 1D data vector
;	data2: 1D data vector of the same length
;	/fast (optional): Calculate with fast circular convolution
;	/dc (optional): without mean subtraction
;	/nonorm (optional): Does not norm with ACF(0) - returned
;                                                       function is
;the covariance function
;
; Output:
;	acorr: Crosscorrelation vector (positive delay shows the delay of data1 with respect to data2)
;
; Modifications:
;	Gergo Pokol 2003.12.16. : Zero padding added to fast convolution
;       Gergely Papp 2008.12.16.: Added normalize switch - correct norm
;       
;-                                                 

function pg_ccorr, data1, data2, fast=fast, dc=dc, nonorm=nonorm, normalize=normalize

; Set defaults
fast=keyword_set(fast)
dc=keyword_set(dc)
nonorm=keyword_set(nonorm)
normalize=keyword_set(normalize)

datasize=n_elements(data1)

; Mean subtraction
if dc NE 1 then begin
	data1=data1-mean(data1)
	data2=data2-mean(data2)
endif

if fast then begin
	zeropad=fltarr(datasize)
	data1=reform(data1)
	data1fft=FFT([data1,zeropad],-1) ;FFT
	data2=reform(data2)
	data2fft=FFT([data2,zeropad],-1) ;FFT
	ccorr=FFT(data2fft*conj(data1fft),1) ;IFFT
	ccorr=float(ccorr) ;Imaginary part is computation noise
;	ccorr=shift(ccorr,floor(n_elements(ccorr)/2)) ;Shift to center
	ccorr=shift(ccorr,datasize) ;Shift to center
	ccorr=ccorr[floor(datasize/2d)+1:datasize+floor(datasize/2d)] ;Cut to original length
        ;Multiplying with 2 to compensate zeropad's effect
        ccorr=ccorr*2
endif else begin
	ccorr=dblarr(datasize)
	for i=0l,floor(datasize/2d) do begin
           for j=0l,datasize-i-1 do ccorr[i+ceil(datasize/2d)-1]=ccorr[i+ceil(datasize/2d)-1]+data1[j]*data2[j+i]
           ;ccorr[i+ceil(datasize/2d)-1]=ccorr[i+ceil(datasize/2d)-1]/(datasize-i)
           ccorr[i+ceil(datasize/2d)-1]=ccorr[i+ceil(datasize/2d)-1]/datasize
	endfor
	for i=1l,ceil(datasize/2d)-1 do begin
           for j=0l,datasize-i-1 do ccorr[-i+ceil(datasize/2d)-1]=ccorr[-i+ceil(datasize/2d)-1]+data1[j+i]*data2[j]
           ;ccorr[-i+ceil(datasize/2d)-1]=ccorr[-i+ceil(datasize/2d)-1]/(datasize-i)
           ccorr[-i+ceil(datasize/2d)-1]=ccorr[-i+ceil(datasize/2d)-1]/datasize
	endfor
endelse

if normalize then begin
   	for i=1l,ceil(datasize/2d)-1 do begin
           ccorr[-i+ceil(datasize/2d)-1]=ccorr[-i+ceil(datasize/2d)-1]*datasize/(datasize-i)
        endfor
	for i=0l,floor(datasize/2d) do begin
           ccorr[i+ceil(datasize/2d)-1]=ccorr[i+ceil(datasize/2d)-1]*datasize/(datasize-i)
        endfor
end



if NOT nonorm then begin
	;acorr1=pg_acorr(data1,fast=fast,/nonorm)
	;acorr2=pg_acorr(data2,fast=fast,/nonorm)
	;;ccorr=ccorr/sqrt(acorr1[floor(n_elements(acorr1)/2.)]*acorr2[floor(n_elements(acorr2)/2.)]) ;Rossz: parosra -1
	;ccorr=ccorr/sqrt(max(acorr1)*max(acorr2))
         ccorr=ccorr/sqrt((total(data1*data1)/datasize)*(total(data2*data2)/datasize))
endif

return, ccorr

end
