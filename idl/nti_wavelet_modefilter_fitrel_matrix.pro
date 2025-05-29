;+
; NAME: nti_wavelet_modefilter_fitrel_matrix
;
; PURPOSE: Select most fitting linear to the relative phases as a function of their relative position
;       The calculation is performed on the whole time-frequency plans by matrix products
;				(Can be used for a set of probes limited to a segment of the cross section)
;
; CALLING SEQUENCE:
;	modenum=nti_wavelet_modefilter_fitrel_matrix(cphases, chpos [,weights] [,moderange] [,modestep] $
;		[,qs=qs][,chi2=chi2])
;
; INPUTS:
;		cphases: relative cross-phases in radians
;		chpos: channel positions in radians 
;    If chpos is a 1D vector, a combination of all probes is implied, while a 2D chpos matrix implies 
;      pre/selected channel pairs. 
;		weights (optional): weights of the fit; default: ones; For chi2 probe 1/sigma^2 is to be given.
;		moderange (optional): vector of minimum and maximum modenumbers to be considered
;			default:[-channelssize,channelssize]
;		modestep (optional): modenumber steps to be considered; default: 1
;
; OUTPUT:
;		modenum: modenumber
;		qs (optional): Q_m values
;   chi2 (optional): chi2 values
;-

function nti_wavelet_modefilter_fitrel_matrix, cphases, chpos, weights=weights,$
	moderange=moderange, modestep=modestep, qs=qs, chi2=chi2

compile_opt defint32 ; 32 bit integers

; Set defaults
channelssize=n_elements(chpos)
if size(chpos, /n_dimensions) GT 1 then begin
  crosssize=channelssize/2 
  selected=1
endif else begin
  crosssize=channelssize*(channelssize-1)/2
  selected=0
endelse

if crosssize NE n_elements(cphases(*, 0, 0)) then begin
	print,'Wrong input data dimensions!'
	return,1000
endif

; Set defaults
if not(keyword_set(weights)) then weights=fltarr(crosssize)+1.
if not(keyword_set(modestep)) then modestep=1.
if not(keyword_set(moderange)) then moderange=[-channelssize,channelssize]
if not(keyword_set(qlim)) then qlim=0

; Normalize weights
weightsum=total(weights)
weights=weights/weightsum

if selected EQ 1 then begin ; Calculate relative channel positions for a combination of selected probe pairs
  cchpos=reform(chpos(1,*))-reform(chpos(0,*))
endif else begin ; Calculate relative channel positions for a combination of all probes
cchpos=fltarr(crosssize)
for i=0,channelssize-1 do begin
  for j=i+1,channelssize-1 do begin
    cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j)=chpos(j)-chpos(i)
  endfor
endfor
endelse

; Shift negative angles
negind=where(cchpos<0)
if negind(0) NE -1 then cchpos(negind)=2*!PI+cchpos(negind)

; Convert to Pi units
cchposfit=cchpos/!Pi
phasesfit=cphases/!Pi

; Length in the different dimensions:
crosssize = crosssize
ntime = n_elements(phasesfit(0, *, 0))
nfreq = n_elements(phasesfit(0, 0, *))

; Select most fitting mode number
; -------------------------------
; Mode number vector
m = findgen((moderange(1) - moderange(0))/modestep + 1)*modestep + moderange(0)
nmode = n_elements(m)
; m*cchposfit matrix (2D)
mchpos = cchposfit ## m
; sign(m) matrix (2D)
signm = 1.0*nti_wavelet_signum((fltarr(crosssize) + 1.) ## m)
; line coordinates (2D):
lin = (mchpos + signm) mod 2. - signm
; line coordinates + time + freq (4D):
lin = reform( ((fltarr(ntime*nfreq) + 1.) ## reform(lin, nmode*crosssize)), nmode, crosssize, ntime, nfreq)
; cross-phases (4D):
phasesfit = reform(reform(phasesfit, crosssize*ntime*nfreq) ## (fltarr(nmode) + 1.), nmode, crosssize, ntime, nfreq)
; calculate weights (4D):
ww = reform( (fltarr(ntime*nfreq) + 1.) ## reform(weights ## (fltarr(nmode) + 1.), nmode*crosssize), nmode, crosssize, ntime, nfreq)
; calculate Q:
q = total((((phasesfit - lin)^2 < (2 - abs(phasesfit - lin))^2)*ww), 2)
; Find minimum of Qs:
qs = min(q, ind, dimension = 1)
; Find mode numbers:
modenum = reform(m((array_indices(q, ind))(0, *)), ntime, nfreq)
; Calculate chi2:
chi2 = qs*weightsum/!Pi

return, modenum

end