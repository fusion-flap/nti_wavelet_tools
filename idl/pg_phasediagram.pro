;+
; NAME: pg_phasediagram
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.03.09.
;
; PURPOSE: Plot phasediagrams derived from time-frequency cross-transforms at given time and frequency coordinates
;
; CALLING SEQUENCE:
;	pg_phasediagram, cphases, chpos, timeax, freqax, time, freq [,shot] [,channels] [,filters] [,/print]$
;		 [,filterparam1] [,filterparam2] [,cpows=cpows] [,cohs=cohs] [,cphaserr=cphaserr]
;
; INPUTS:
;		cphases: Cross-phases
;		chpos: channel positions in degrees; default: W7-AS Mirnov/MIR-1 coils
;		timeax: Time axis
;		freqax: Frequency axis
;		time: Time of phase diagram
;		freq: Frequency of phase diagram
;		shot (optional): shot number
;		channels (optional): channel numbers; default: W7-AS Mirnov/MIR-1 coils
;		cpows (optional): Cross-powers
;		cohs (optional): Coherences
;   cphaserr (optional): Cross-phases error (only with filter 11 & 12)
;		filters (optional): vector of filter numbers to use; default: [0] available filters:
;			0: Simple plot with all reference channels
;			1: Plot phase diagrams with all reference signals assuming monotone increase
;			2: Plot phase diagrams with all reference signals assuming monotone decrease
;			3: Plot phase diagrams with all reference signals assuming monotone increase and linear fit to mean
;			4: Plot phase diagrams with all reference signals assuming monotone decrease and linear fit to mean
;			5: Plot phase diagrams with all reference signals assuming increase and optimizing to linear fit to mean
;			6: Plot phase diagrams with all reference signals assuming decrease and optimizing to linear fit to mean
;			7: Plot relative phases as a function of their relative position
;			8: Plot relative phases as a function of their relative position and most fitting linear
;					+ residuum as function of modenumber
;				filterparam1 (optional): modenumber steps to be considered; default:1
;				filterparam2 (optional): modenumber range to be considered; default:[-channelssize,channelssize]
;			9: Plot relative phases as a function of their relative position and most fitting linear with
;					weight=coherence/median(coherence) + residuum as function of modenumber
;				filterparam1 (optional): modenumber steps to be considered; default:1
;				filterparam2 (optional): modenumber range to be considered; default:[-channelssize,channelssize]
;    10: Plot relative phases as a function of their relative postion in the interval [0,pi]
;         + residuum as function of modenumber
;       filterparam1 (optional): modenumber steps to be considered; default:1
;       filterparam2 (optional): modenumber range to be considered; default:[-channelssize,channelssize]
;    11: Plot relative phases with errorbars as a function of their relative position
;         + residuum as function of modenumber
;       filterparam1 (optional): modenumber steps to be considered; default:1
;       filterparam2 (optional): modenumber range to be considered; default:[-channelssize,channelssize]
;    12: Plot relative phases with errorbars as a function of their relative position
;        and the most fitting linear with weights calculated from phase-errors
;        + residuum as function of modenumber
;        + chi-square test result as function of modenumber
;       filterparam1 (optional): modenumber steps to be considered; default:1
;       filterparam2 (optional): modenumber range to be considered; default:[-channelssize,channelssize]
;		/print (optional): Print to file instead of plotting
;
; OUTPUT: -
;
; EXAMPLE:
;    restore, 'data/AUG_SXR_F17_G17_modenumbers_22036_2220_ord_12_avr_5_mode_6_Q_1_5_10_20.sav'
;    pg_phasediagram,cphases, chpos, timeax, freqax, 2.26, 8, shot=22036, channels=channels, filters=[8],$
;      filterparam2=[-6,6], /print, cpows=cpows, cohs=cohs
;
; MODIFICATION HISTORY:
;		2007.04.11. Gergo Pokol: filters 3,4 added
;-

pro pg_phasediagram, cphases, chpos, timeax, freqax, time, freq, shot=shot, channels=channels, filters=filters,$
	 filterparam1=filterparam1, filterparam2=filterparam2, print=print, cpows=cpows, cohs=cohs, cphaserr=cphaserr

compile_opt defint32 ; 32 bit integers

; Set defaults
save_directory='save_data'
print=keyword_set(print)
if not(keyword_set(filters)) then filters=[0]
if not(keyword_set(shot)) then shot=0
channelssize=n_elements(chpos)
if not(keyword_set(channels)) then channels=pg_num2str(indgen(channelssize))
crosssize=channelssize*(channelssize-1)/2
if crosssize NE n_elements(cphases(*,0,0)) then begin
	print,'Wrong input data dimensions!'
endif

; Extract phases at given time and frequency
freqpos=where(abs(freqax-freq) EQ min(abs(freqax-freq)))
freqpos=freqpos(0)
freq=freqax(freqpos)
timepos=where(abs(timeax-time) EQ min(abs(timeax-time)))
timepos=timepos(0)
time=timeax(timepos)
; Create array for phase diagrams with different reference channels
phases0=fltarr(channelssize,channelssize)
; Fill array from input
for i=0,channelssize-1 do begin
	for j=i+1,channelssize-1 do begin
		phases0(i,j)=cphases(i*(channelssize-(i+1)/2.)-(i+1)+j,timepos,freqpos)
		phases0(j,i)=-cphases(i*(channelssize-(i+1)/2.)-(i+1)+j,timepos,freqpos)
	endfor
endfor
; Translate phase diagrams to start from (0,0)
for i=1,channelssize-1 do begin
	phases0(i,*)=phases0(i,*)+(cphases(0*(channelssize-(0+1)/2.)-(0+1)+i,timepos,freqpos))(0)
endfor
chpos=chpos-chpos(0)

; Initialize graphics
pg_initgraph,print=print
title0='Phasediagrams: #'+nti_wavelet_i2str(shot)+' '+pg_num2str(time)+'s '+pg_num2str(freq,length=4)+'kHz'
printdatas0='shot: '+nti_wavelet_i2str(shot)
for i=0,channelssize-1 do printdatas0=printdatas0+'!C'+channels[i]
printdatas0=printdatas0+$
	'!Ctime: '+pg_num2str(time)+' s'+$
	'!Cfrequency: '+pg_num2str(freq)+' kHz'

; Filter 0 :simple plot of phasediagrams with all reference signals
if where(filters EQ 0) GT -1 then begin
	; Add 0 to the end of each phase diagram
	phases=[[phases0],[phases0(*,0)]]
	chpos0=[chpos,360]
	;Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+'!Cno filter'
	title=title0+' s'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[-2,2],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 1 :plot phasediagrams with all reference signals assuming monotone increase
if where(filters EQ 1) GT -1 then begin
	; Add 0 to the end of each phase diagram
	phases=[[phases0],[phases0(*,0)]]
	chpos0=[chpos,360]
	; Monotonize phase diagrams
	for i=0,channelssize-1 do begin
		for j=1,channelssize do begin
			if phases(i,j-1) GT phases(i,j) then phases(i,j:channelssize)=phases(i,j:channelssize)+2*!PI
		endfor
	endfor
	;Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+'!Cincreasing filter'
	title=title0+' i'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[0,max(phases/!PI)],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 2 :plot phasediagrams with all reference signals assuming monotone decrease
if where(filters EQ 2) GT -1 then begin
	; Add 0 to the end of each phase diagram
	phases=[[phases0],[phases0(*,0)]]
	chpos0=[chpos,360]
	; Monotonize phase diagrams
	for i=0,channelssize-1 do begin
		for j=1,channelssize do begin
			if phases(i,j-1) LT phases(i,j) then phases(i,j:channelssize)=phases(i,j:channelssize)-2*!PI
		endfor
	endfor
	;Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+'!Cdecreasing filter'
	title=title0+' d'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[min(phases/!PI),0],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 3 :plot phasediagrams with all reference signals assuming monotone increase and linear fit
if where(filters EQ 3) GT -1 then begin
	phases=phases0
	chpos0=chpos
	; Monotonize phase diagrams
	for i=0,channelssize-1 do begin
		for j=1,channelssize-1 do begin
			if phases(i,j-1) GT phases(i,j) then phases(i,j:channelssize-1)=phases(i,j:channelssize-1)+2*!PI
		endfor
	endfor
	; Linear fit
	meanphases=fltarr(channelssize)
	stddevphases=fltarr(channelssize)
	for i=0,channelssize-1 do begin
		meanphases(i)=mean(phases(*,i))
		stddevphases(i)=max([1.e-8,stddev(phases(*,i))]) ; Lower limit of standard deviation
	endfor
	stddevphases(0)=1.e-15 ; Force a=0
	fit=linfit(chpos0/360.*2*!PI,meanphases,measure_errors=stddevphases,sigma=sigma,chisq=chisq,$
		yfit=yfit,prob=prob)
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Cincreasing fit'+$
		'!Cmodenumber='+pg_num2str(fit(1))+$
		'!Csigma='+pg_num2str(sigma(1))+$
		'!Cchisq='+pg_num2str(chisq/float(channelssize-1))+$
		'!Cprob='+pg_num2str(prob)
	title=title0+' if'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[min(phases/!PI),max(phases/!PI)],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	oplot,chpos0,meanphases/!PI,psym=1,thick=8,symsize=2
	errplot,chpos0,(meanphases-stddevphases)/!PI,(meanphases+stddevphases)/!PI,width=0.02
	oplot,chpos0,yfit/!PI,linestyle=1,thick=3
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 4 :plot phasediagrams with all reference signals assuming monotone decrease and linear fit
if where(filters EQ 4) GT -1 then begin
	phases=phases0
	chpos0=chpos
	; Monotonize phase diagrams
	for i=0,channelssize-1 do begin
		for j=1,channelssize-1 do begin
			if phases(i,j-1) LT phases(i,j) then phases(i,j:channelssize-1)=phases(i,j:channelssize-1)-2*!PI
		endfor
	endfor
	; Linear fit
	meanphases=fltarr(channelssize)
	stddevphases=fltarr(channelssize)
	for i=0,channelssize-1 do begin
		meanphases(i)=mean(phases(*,i))
		stddevphases(i)=max([1.e-8,stddev(phases(*,i))]) ; Lower limit of standard deviation
	endfor
	stddevphases(0)=1.e-15 ; Force a=0
	fit=linfit(chpos0/360.*2*!PI,meanphases,measure_errors=stddevphases,sigma=sigma,chisq=chisq,$
		yfit=yfit,prob=prob)
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Cdecreasing fit'+$
		'!Cmodenumber='+pg_num2str(fit(1))+$
		'!Csigma='+pg_num2str(sigma(1))+$
		'!Cchisq='+pg_num2str(chisq/float(channelssize-1))+$
		'!Cprob='+pg_num2str(prob)
	title=title0+' df'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[min(phases/!PI),max(phases/!PI)],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	oplot,chpos0,meanphases/!PI,psym=1,thick=8,symsize=2
	errplot,chpos0,(meanphases-stddevphases)/!PI,(meanphases+stddevphases)/!PI,width=0.02
	oplot,chpos0,yfit/!PI,linestyle=1,thick=3
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 5 :plot phasediagrams with all reference signals assuming increase and optimizing to linear fit
if where(filters EQ 5) GT -1 then begin
	phases=phases0
	chpos0=chpos
	; Monotonize phase diagrams
	for i=0,channelssize-1 do begin
		for j=1,channelssize-1 do begin
			if phases(i,j-1) GT phases(i,j) then phases(i,j:channelssize-1)=phases(i,j:channelssize-1)+2*!PI
		endfor
	endfor
	; Linear fit
	meanphases=fltarr(channelssize)
	stddevphases0=fltarr(channelssize)
	stddevphases=fltarr(channelssize)
	for i=0,channelssize-1 do begin
		meanphases(i)=mean(phases(*,i))
		stddevphases0(i)=max([1.e-8,stddev(phases(*,i))]) ; Lower limit of standard deviation
	endfor
	stddevphases0(0)=1.e-15 ; Force a=0
	fit=linfit(chpos0/360.*2*!PI,meanphases,measure_errors=stddevphases0,sigma=sigma,chisq=chisq,$
		yfit=yfit,prob=prob)
	qmin=total((meanphases-yfit)^2)
	; Test for optimal fit
	for i=0,channelssize-1 do begin
		for j=1,channelssize-1 do begin
			phasesopt=phases
			phasesopt(i,j:channelssize-1)=phasesopt(i,j:channelssize-1)-2*!PI ; Shift back
			for k=0,channelssize-1 do begin
				meanphases(k)=mean(phasesopt(*,k))
				stddevphases(k)=max([1.e-8,stddev(phasesopt(*,k))]) ; Lower limit of standard deviation
			endfor
			stddevphases(0)=1.e-15 ; Force a=0
			fitopt=linfit(chpos/360.*2*!PI,meanphases,measure_errors=stddevphases,sigma=sigmaopt,chisq=chisqopt,$
				yfit=yfitopt,prob=probopt)
			qminopt=total((meanphases-yfitopt)^2)
;			if abs(1-chisqopt/float(channelssize-1)) LT abs(1-chisq/float(channelssize-1)) then begin
;			if qminopt LT qmin then begin
			if total(stddevphases) LT total(stddevphases0) then begin
				phases=phasesopt
				stddevphases0=stddevphases
				qmin=qminopt
				fit=fitopt
				sigma=sigmaopt
				chisq=chisqopt
				yfit=yfitopt
				prob=probopt
			endif
		endfor
	endfor
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Cincreasing optimized fit'+$
		'!Cmodenumber='+pg_num2str(fit(1))+$
		'!Csigma='+pg_num2str(sigma(1))+$
		'!Cchisq='+pg_num2str(chisq/float(channelssize-1))+$
		'!Cprob='+pg_num2str(prob)
	title=title0+' io'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[min(phases/!PI),max(phases/!PI)],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	oplot,chpos0,meanphases/!PI,psym=1,thick=8,symsize=2
	errplot,chpos0,(meanphases-stddevphases)/!PI,(meanphases+stddevphases)/!PI,width=0.02
	oplot,chpos0,yfit/!PI,linestyle=1,thick=3
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 6 :plot phasediagrams with all reference signals assuming monotone decrease and linear fit
if where(filters EQ 6) GT -1 then begin
	phases=phases0
	chpos0=chpos
	; Monotonize phase diagrams
	for i=0,channelssize-1 do begin
		for j=1,channelssize-1 do begin
			if phases(i,j-1) LT phases(i,j) then phases(i,j:channelssize-1)=phases(i,j:channelssize-1)-2*!PI
		endfor
	endfor
	; Linear fit
	meanphases=fltarr(channelssize)
	stddevphases0=fltarr(channelssize)
	stddevphases=fltarr(channelssize)
	for i=0,channelssize-1 do begin
		meanphases(i)=mean(phases(*,i))
		stddevphases0(i)=max([1.e-8,stddev(phases(*,i))]) ; Lower limit of standard deviation
	endfor
	stddevphases0(0)=1.e-15 ; Force a=0
	fit=linfit(chpos0/360.*2*!PI,meanphases,measure_errors=stddevphases0,sigma=sigma,chisq=chisq,$
		yfit=yfit,prob=prob)
	qmin=total((meanphases-yfit)^2)
	; Test for optimal fit
	for i=0,channelssize-1 do begin
		for j=1,channelssize-1 do begin
			phasesopt=phases
			phasesopt(i,j:channelssize-1)=phasesopt(i,j:channelssize-1)+2*!PI ; Shift back
			for k=0,channelssize-1 do begin
				meanphases(k)=mean(phasesopt(*,k))
				stddevphases(k)=max([1.e-8,stddev(phasesopt(*,k))]) ; Lower limit of standard deviation
			endfor
			stddevphases(0)=1.e-15 ; Force a=0
			fitopt=linfit(chpos/360.*2*!PI,meanphases,measure_errors=stddevphases,sigma=sigmaopt,chisq=chisqopt,$
				yfit=yfitopt,prob=probopt)
			qminopt=total((meanphases-yfitopt)^2)
;			if abs(1-chisqopt/float(channelssize-1)) LT abs(1-chisq/float(channelssize-1)) then begin
;			if qminopt LT qmin then begin
			if total(stddevphases) LT total(stddevphases0) then begin
				phases=phasesopt
				stddevphases0=stddevphases
				qmin=qminopt
				fit=fitopt
				sigma=sigmaopt
				chisq=chisqopt
				yfit=yfitopt
				prob=probopt
			endif
		endfor
	endfor
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Cdecreasing optimized fit'+$
		'!Cmode number='+pg_num2str(fit(1))+$
		'!Csigma='+pg_num2str(sigma(1))+$
		'!Cchisq='+pg_num2str(chisq/float(channelssize-1))+$
		'!Cprob='+pg_num2str(prob)
	title=title0+' do'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,chpos0,phases(0,*)/!PI,title=title0,xstyle=1,xtitle='Probe position [Deg]',$
		ystyle=1,ytitle='Cross-phases [Pi]',color=[cmin],yrange=[min(phases/!PI),max(phases/!PI)],charsize=3.
	for i=1,channelssize-1 do begin
		oplot,chpos0,phases(i,*)/!PI,color=[cmin+(cmax-cmin)/channelssize*i]
	endfor
	oplot,chpos0,meanphases/!PI,psym=1,thick=8,symsize=2
	errplot,chpos0,(meanphases-stddevphases)/!PI,(meanphases+stddevphases)/!PI,width=0.02
	oplot,chpos0,yfit/!PI,linestyle=1,thick=3
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 7 :plot relative phases as a function of their relative position
if where(filters EQ 7) GT -1 then begin
	phases=reform(cphases(*,timepos,freqpos))
	; Calculate relative channel positions
	cchpos=fltarr(crosssize)
	for i=0,channelssize-1 do begin
		for j=i+1,channelssize-1 do begin
			cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
		endfor
	endfor
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Crelative plot'
	title=title0+' r'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,cchpos/360.*2,phases/!PI,title=title0,xstyle=1,xtitle='Relative probe positions [Pi]',$
		ystyle=1,ytitle='Cross-phases [Pi]',yrange=[min(phases/!PI),max(phases/!PI)],charsize=3.,$
		xrange=[0,max(cchpos)/360.*2],psym=1,thick=5,symsize=2
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 8 :plot relative phases as a function of their relative position and most fitting linear
; + residuum as function of modenumber
if where(filters EQ 8) GT -1 then begin
	; Set defaults
	if not(keyword_set(filterparam1)) then modestep=1. else modestep=filterparam1
	if not(keyword_set(filterparam2)) then moderange=[-channelssize,channelssize] $
		else moderange=filterparam2
	phases=reform(cphases(*,timepos,freqpos))
	; Calculate relative channel positions
	cchpos=fltarr(crosssize)
	for i=0,channelssize-1 do begin
		for j=i+1,channelssize-1 do begin
			cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
			if cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*) LT 0 then $
				cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=360+$
				cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)
		endfor
	endfor
	; Convert to Pi units
	cchposfit=cchpos/360.*2
	phasesfit=phases/!Pi
	; Select most fitting modenumber
	m=findgen((moderange(1)-moderange(0))/modestep+1)*modestep+moderange(0)
	msize=n_elements(m)
	q=fltarr(msize)
	for i=0,msize-1 do begin
		if m(i) EQ 0 then lin=cchposfit*0 $
			else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
		q(i)=total((phasesfit-lin)^2<(2-abs(phasesfit-lin))^2)
	endfor
	qfit=min(q)
	mfit=m(where(q EQ qfit))
	mfit=mfit(0)
	meanq=mean(q)
	stddevq=stddev(q)
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Crelative fit'+$
		'!Cmodenumber='+pg_num2str(mfit)+$
		'!CQ_fit='+pg_num2str(qfit)+$
		'!CQ_mean='+pg_num2str(meanq)+$
		'!CQ_stddev='+pg_num2str(stddevq)
	title=title0+' rf'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,cchposfit,phasesfit,title=title0,xstyle=1,xtitle='Relative probe positions [Pi]',$
		ystyle=1,ytitle='Cross-phases [Pi]',yrange=[-1,1],charsize=3.,$
		xrange=[0,2],psym=1,thick=5,symsize=2
;		xrange=[0,max(cchposfit)],psym=1,thick=5,symsize=2
	if mfit EQ 0 then begin
		oplot,[0,2],[0,0]
	endif else begin
		for i=0,ceil(abs(mfit)) do begin
			oplot,[(2*i-1.)/abs(mfit),(2*i+1.)/abs(mfit)],mfit/abs(mfit)*[-1,1]
		endfor
	endelse
	xyouts,-0.13,0.9,printdatas,/normal
	printdatas=printdatas0+$
		'!Crelative fit'+$
		'!Cmode number='+pg_num2str(mfit)+$
		'!CQ_fit='+pg_num2str(qfit)+$
		'!CQ_mean='+pg_num2str(meanq)+$
		'!CQ_stddev='+pg_num2str(stddevq)
	title=title0+' rfq'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,m,q,title=title0,xstyle=1,xtitle='Mode number',$
		ystyle=1,ytitle='Q of fit',charsize=3.,$
		psym=4,thick=5,symsize=2
	oplot,moderange,[meanq,meanq]
	for i=fix((min(q)-meanq)/stddevq),fix((max(q)-meanq)/stddevq) $
		do oplot,moderange,[meanq+i*stddevq,meanq+i*stddevq],linestyle=1
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 9 :plot relative phases as a function of their relative position and most fitting linear with
; weight=coherence/median(coherence) + residuum as function of modenumber
if where(filters EQ 9) GT -1 then begin
	; Set defaults
	if not(keyword_set(filterparam1)) then modestep=1. else modestep=filterparam1
	if not(keyword_set(filterparam2)) then moderange=[-channelssize,channelssize] $
		else moderange=filterparam2
	phases=reform(cphases(*,timepos,freqpos))
	; Calculate weights
	mediancoh=median(median(cohs,dimension=[3]),dimension=[2])
	weights=(cohs(*,timepos,freqpos)/mediancoh)^2
	weights=cohs(*,timepos,freqpos)
	weights=1/mediancoh
	weights=cohs(*,timepos,freqpos)/mediancoh
	; Calculate relative channel positions
	cchpos=fltarr(crosssize)
	for i=0,channelssize-1 do begin
		for j=i+1,channelssize-1 do begin
			cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
			if cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*) LT 0 then $
				cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=360+$
				cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)
		endfor
	endfor
	; Convert to Pi units
	cchposfit=cchpos/360.*2
	phasesfit=phases/!Pi
	; Select most fitting modenumber
	m=findgen((moderange(1)-moderange(0))/modestep+1)*modestep+moderange(0)
	msize=n_elements(m)
	q=fltarr(msize)
	for i=0,msize-1 do begin
		if m(i) EQ 0 then lin=cchposfit*0 $
			else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
		q(i)=total((phasesfit-lin)^2*weights<(2-abs(phasesfit-lin))^2*weights)
	endfor
	qfit=min(q)
	mfit=m(where(q EQ qfit))
	mfit=mfit(0)
	meanq=mean(q)
	stddevq=stddev(q)
	; Plot
	loadct,1
	cmin=0
	cmax=220
	printdatas=printdatas0+$
		'!Crelative fit'+$
		'!Cmode number='+pg_num2str(mfit)+$
		'!CQ_fit='+pg_num2str(qfit)+$
		'!CQ_mean='+pg_num2str(meanq)+$
		'!CQ_stddev='+pg_num2str(stddevq)
	title=title0+' rfc'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	symsizemin=0.5
	symsizemax=6
	symsizes=(weights-min(weights))/(max(weights)-min(weights))*$
		(symsizemax-symsizemin)+symsizemin
	plot,[cchposfit(0)],[phasesfit(0)],title=title0,xstyle=1,xtitle='Relative probe positions [Pi]',$
		ystyle=1,ytitle='Cross-phases [Pi]',yrange=[-1,1],charsize=3.,$
		xrange=[0,2],psym=1,thick=5,symsize=symsizes(0)
;		xrange=[0,max(cchposfit)],psym=1,thick=5,symsize=symsizes(0)
	for i=1,crosssize-1 do begin
		oplot,[cchposfit(i)],[phasesfit(i)],psym=1,thick=5,symsize=symsizes(i)
	endfor
	if mfit EQ 0 then begin
		oplot,[0,2],[0,0]
	endif else begin
		for i=0,ceil(abs(mfit)) do begin
			oplot,[(2*i-1.)/abs(mfit),(2*i+1.)/abs(mfit)],mfit/abs(mfit)*[-1,1]
		endfor
	endelse
	xyouts,-0.13,0.9,printdatas,/normal
	printdatas=printdatas0+$
		'!Crelative fit'+$
		'!Cmodenumber='+pg_num2str(mfit)+$
		'!CQ_fit='+pg_num2str(qfit)+$
		'!CQ_mean='+pg_num2str(meanq)+$
		'!CQ_stddev='+pg_num2str(stddevq)
	title=title0+' rfcq'
	if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
	plot,m,q,title=title0,xstyle=1,xtitle='Mode number',$
		ystyle=1,ytitle='Q of fit',charsize=3.,$
		psym=4,thick=5,symsize=2
	oplot,moderange,[meanq,meanq]
	for i=fix((min(q)-meanq)/stddevq),fix((max(q)-meanq)/stddevq) $
		do oplot,moderange,[meanq+i*stddevq,meanq+i*stddevq],linestyle=1
	xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 10 :plot relative phases as a function of their relative position on the interval [0,pi] and the most fitting linear
; + residuum as function of modenumber
if where(filters EQ 10) GT -1 then begin
  ; Set defaults
  if not(keyword_set(filterparam1)) then modestep=1. else modestep=filterparam1
  if not(keyword_set(filterparam2)) then moderange=[-channelssize,channelssize] $
    else moderange=filterparam2
  phases=reform(cphases(*,timepos,freqpos))
  ; Calculate relative channel positions
  cchpos=fltarr(crosssize)
  for i=0,channelssize-1 do begin
    for j=i+1,channelssize-1 do begin
      cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
      if cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*) LT 0 then $
        cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=360+$
        cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)
    endfor
  endfor
  ; Change channel position range to [0,pi]
  for i=0, crosssize-1 do begin
    if cchpos(i) GT 180 then begin
      cchpos(i) = 360 - cchpos(i)
      phases(i) = -phases(i)
    endif
  endfor 
  ; Convert to Pi units
  cchposfit=cchpos/360.*2
  phasesfit=phases/!Pi
  ; Select most fitting modenumber
  m=findgen((moderange(1)-moderange(0))/modestep+1)*modestep+moderange(0)
  msize=n_elements(m)
  q=fltarr(msize)
  for i=0,msize-1 do begin
    if m(i) EQ 0 then lin=cchposfit*0 $
      else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
    q(i)=total((phasesfit-lin)^2<(2-abs(phasesfit-lin))^2)
  endfor
  qfit=min(q)
  mfit=m(where(q EQ qfit))
  mfit=mfit(0)
  meanq=mean(q)
  stddevq=stddev(q)
  ; Plot
  loadct,1
  cmin=0
  cmax=220
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmodenumber='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' rf'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,cchposfit,phasesfit,title=title0,xstyle=1,xtitle='Relative probe positions [Pi]',$
    ystyle=1,ytitle='Cross-phases [Pi]',yrange=[-1,1],charsize=3.,$
    xrange=[0,1],psym=1,thick=5,symsize=2
;   xrange=[0,max(cchposfit)],psym=1,thick=5,symsize=2
  if mfit EQ 0 then begin
    oplot,[0,1],[0,0]
  endif else begin
    for i=0,ceil(abs(mfit)) do begin
      oplot,[(2*i-1.)/abs(mfit),(2*i+1.)/abs(mfit)],mfit/abs(mfit)*[-1,1]
    endfor
  endelse
  xyouts,-0.13,0.9,printdatas,/normal
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmode number='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' rfq'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,m,q,title=title0,xstyle=1,xtitle='Mode number',$
    ystyle=1,ytitle='Q of fit',charsize=3.,$
    psym=4,thick=5,symsize=2
  oplot,moderange,[meanq,meanq]
  for i=fix((min(q)-meanq)/stddevq),fix((max(q)-meanq)/stddevq) $
    do oplot,moderange,[meanq+i*stddevq,meanq+i*stddevq],linestyle=1
  xyouts,-0.13,0.9,printdatas,/normal
endif

; Filter 11 :plot relative phases with errorbars as a function of their relative position on the interval [0,pi] and the most fitting linear
; + residuum as function of modenumber
if where(filters EQ 11) GT -1 then begin
  ; Set defaults
  if not(keyword_set(filterparam1)) then modestep=1. else modestep=filterparam1
  if not(keyword_set(filterparam2)) then moderange=[-channelssize,channelssize] $
    else moderange=filterparam2
  phase_errors=reform(cphaserr(*,timepos,freqpos))
  phases=reform(cphases(*,timepos,freqpos))
  ; Calculate relative channel positions
  cchpos=fltarr(crosssize)
  for i=0,channelssize-1 do begin
    for j=i+1,channelssize-1 do begin
      cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
      if cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*) LT 0 then $
        cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=360+$
        cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)
    endfor
  endfor
  ; Change channel position range to [0,pi]
  for i=0, crosssize-1 do begin
    if cchpos(i) GT 180 then begin
      cchpos(i) = 360 - cchpos(i)
      phases(i) = -phases(i)
    endif
  endfor 
  ; Convert to Pi units
  cchposfit=cchpos/360.*2
  phasesfit=phases/!Pi
  errorsfit=phase_errors/!Pi
  ; Select most fitting modenumber
  m=findgen((moderange(1)-moderange(0))/modestep+1)*modestep+moderange(0)
  msize=n_elements(m)
  q=fltarr(msize)
  for i=0,msize-1 do begin
    if m(i) EQ 0 then lin=cchposfit*0 $
      else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
    q(i)=total((phasesfit-lin)^2<(2-abs(phasesfit-lin))^2)
  endfor
  qfit=min(q)
  mfit=m(where(q EQ qfit))
  mfit=mfit(0)
  meanq=mean(q)
  stddevq=stddev(q)
  ; Plot
  loadct,1
  cmin=0
  cmax=220
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmodenumber='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' rf'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,cchposfit,phasesfit,title=title0,xstyle=1,xtitle='Relative probe positions [Pi]',$
    ystyle=1,ytitle='Cross-phases [Pi]',yrange=[-1,1],charsize=3.,$
    xrange=[0,1],psym=4,thick=3,symsize=3
;   xrange=[0,max(cchposfit)],psym=1,thick=5,symsize=2
  errplot,cchposfit,phasesfit-errorsfit, phasesfit+errorsfit
  if mfit EQ 0 then begin
    oplot,[0,1],[0,0]
  endif else begin
    for i=0,ceil(abs(mfit)) do begin
      oplot,[(2*i-1.)/abs(mfit),(2*i+1.)/abs(mfit)],mfit/abs(mfit)*[-1,1]
    endfor
  endelse
  xyouts,-0.13,0.9,printdatas,/normal
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmode number='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' rfq'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,m,q,title=title0,xstyle=1,xtitle='Mode number',$
    ystyle=1,ytitle='Q of fit',charsize=3.,$
    psym=4,thick=5,symsize=2
  oplot,moderange,[meanq,meanq]
  for i=fix((min(q)-meanq)/stddevq),fix((max(q)-meanq)/stddevq) $
    do oplot,moderange,[meanq+i*stddevq,meanq+i*stddevq],linestyle=1
  xyouts,-0.13,0.9,printdatas,/normal
endif

;  Filter 12: Plot relative phases with errorbars as a function of their relative position
;  and the most fitting linear with weights calculated from phase-errors
;  + residuum as function of modenumber
;  + chi-square test result as function of modenumber
if where(filters EQ 12) GT -1 then begin
  ; Set defaults
  if not(keyword_set(filterparam1)) then modestep=1. else modestep=filterparam1
  if not(keyword_set(filterparam2)) then moderange=[-channelssize,channelssize] $
    else moderange=filterparam2
  phase_errors=reform(cphaserr(*,timepos,freqpos))
  phases=reform(cphases(*,timepos,freqpos))
  ; Calculate relative channel positions
  cchpos=fltarr(crosssize)
  for i=0,channelssize-1 do begin
    for j=i+1,channelssize-1 do begin
      cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=chpos(j)-chpos(i)
      if cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*) LT 0 then $
        cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)=360+$
        cchpos(i*(channelssize-(i+1)/2.)-(i+1)+j,*,*)
    endfor
  endfor
  ; Change channel position range to [0,pi]
  for i=0, crosssize-1 do begin
    if cchpos(i) GT 180 then begin
      cchpos(i) = 360 - cchpos(i)
      phases(i) = -phases(i)
    endif
  endfor
  ; Calculate weights for most fitting linear
  inv_sq=1/(phase_errors*phase_errors)
  weight=inv_sq*(1/total(inv_sq))
  ; Convert to Pi units
  cchposfit=cchpos/360.*2
  phasesfit=phases/!Pi
  errorsfit=phase_errors/!Pi
  inv_sqpi=inv_sq/!Pi
  ; Select most fitting modenumber &
  ; Calculate chi_square test result for each modenumber
  m=findgen((moderange(1)-moderange(0))/modestep+1)*modestep+moderange(0)
  msize=n_elements(m)
  chisq=fltarr(msize)
  q=fltarr(msize)
  for i=0,msize-1 do begin
    if m(i) EQ 0 then lin=cchposfit*0 $
      else lin=((m(i)*(cchposfit+1./abs(m(i)))) mod 2 )-m(i)/abs(m(i))
    q(i)=total(weight*((phasesfit-lin)^2)<(weight*(2-abs(phasesfit-lin))^2))
    chisq(i)=total((inv_sqpi*((phasesfit-lin))^2)<(inv_sqpi*((2-abs(phasesfit-lin)))^2))
  endfor
  qfit=min(q)
  mfit=m(where(q EQ qfit))
  mfit=mfit(0)
  meanq=mean(q)
  stddevq=stddev(q)
  ; Plot
  loadct,1
  cmin=0
  cmax=220
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmode number='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' rf'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,cchposfit,phasesfit,title=title0,xstyle=1,xtitle='Relative probe positions [Pi]',$
    ystyle=1,ytitle='Cross-phases [Pi]',yrange=[-1,1],charsize=3.,$
    xrange=[0,1],psym=4,thick=3,symsize=3
;   xrange=[0,max(cchposfit)],psym=1,thick=5,symsize=2
  errplot,cchposfit,phasesfit-errorsfit, phasesfit+errorsfit
  if mfit EQ 0 then begin
    oplot,[0,1],[0,0]
  endif else begin
    for i=0,ceil(abs(mfit)) do begin
      oplot,[(2*i-1.)/abs(mfit),(2*i+1.)/abs(mfit)],mfit/abs(mfit)*[-1,1]
    endfor
  endelse
  xyouts,-0.13,0.9,printdatas,/normal
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmode number='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' rfq'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,m,q,title=title0,xstyle=1,xtitle='Mode number',$
    ystyle=1,ytitle='Q of fit',charsize=3.,$
    psym=4,thick=5,symsize=2
  oplot,moderange,[meanq,meanq]
  for i=fix((min(q)-meanq)/stddevq),fix((max(q)-meanq)/stddevq) $
    do oplot,moderange,[meanq+i*stddevq,meanq+i*stddevq],linestyle=1
  xyouts,-0.13,0.9,printdatas,/normal
  printdatas=printdatas0+$
    '!Crelative fit'+$
    '!Cmode number='+pg_num2str(mfit)+$
    '!CQ_fit='+pg_num2str(qfit)+$
    '!CQ_mean='+pg_num2str(meanq)+$
    '!CQ_stddev='+pg_num2str(stddevq)
  title=title0+' chsq'
  if print then device,filename=pg_filename(title, dir=save_directory) else window,/free
  plot,m,chisq,title=title0,xstyle=1,xtitle='Mode number',$
  ystyle=1,ytitle='Chi-square', charsize=3.,$
  psym=4,thick=5,symsize=2
  xyouts,-0.13,0.9,printdatas,/normal
endif

if print then device,/close

end