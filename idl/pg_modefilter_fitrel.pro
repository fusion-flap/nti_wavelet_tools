;+
; NAME: pg_modefilter_fitrel
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.04.20.
;
; PURPOSE: Select most fitting linear to the relative phases as a function of their relative position
;				(Can be used for a set of probes limited to a segment of the cross section)
;
; CALLING SEQUENCE:
;	modenum=pg_modefilter_fitrel(cphases, chpos [,weights] [,moderange] [,modestep] [,qlim]$
;		[,ms=ms][,qs=qs][,chi2=chi2])
;
; INPUTS:
;		cphases: relative cross-phases in radians
;		chpos: channel positions in radians 
;    If chpos is a 1D vector, a combination of all probes is implied, while a 2D chpos matrix implies 
;      pre/selected channel pairs. 
;		weigths (optional): weights of the fit; default: ones; For chi2 probe 1/sigma^2 is to be given.
;		moderange (optional): vector of minimum and maximum modenumbers to be considered
;			default:[-channelssize,channelssize]
;		modestep (optional): modenumber steps to be considered; default: 1
;		qlim (optional): minimum distance accepted Q values from Q_mean measuredin Q_stddev units
;			default: 0 (everything is accepted)
;
; OUTPUT:
;		modenum: modenumber, or 1000 for not defined modenumber
;		ms (optional): mode number vector
;		qs (optional): Q_m vector (with normalized weights)
;   chi2 (optional): chi2 value of each fit
;-

function pg_modefilter_fitrel, cphases, chpos, weights=weights,$
	moderange=moderange, modestep=modestep, qlim=qlim, ms=ms, qs=qs, chi2=chi2

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

if crosssize NE n_elements(cphases) then begin
	print,'Wrong input data dimensions!'
	return,1000
endif

modenum=1000 ; Initialize output variable

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


; Select most fitting modenumber
m=findgen((moderange(1)-moderange(0))/modestep+1)*modestep+moderange(0)
msize=n_elements(m)
q=fltarr(msize)
chi2=fltarr(msize)
for i=0,msize-1 do begin
	if m(i) EQ 0 then lin=cchposfit*0 $
		else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
	q(i)=total((phasesfit-lin)^2*weights<(2-abs(phasesfit-lin))^2*weights)
	chi2(i)=q(i)*weightsum/!Pi
endfor
qfit=min(q)
mfit=m(where(q EQ qfit))
mfit=mfit(0)
meanq=mean(q(where(q NE qfit)))
stddevq=stddev(q(where(q NE qfit)))

if meanq-qfit GT qlim*stddevq then modenum=mfit

ms=m
qs=q
chi2=chi2
return,modenum

end