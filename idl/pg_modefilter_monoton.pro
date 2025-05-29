;+
; Name: pg_modefilter_monoton
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2007.02.26.-03.01.
;
; Purpose: Filter modenumbers from pre-calculated cross-phases assuming monoton (with a given margin)
;				 change of phases and equal modenumbers with all reference probes, selects smaller modenumber
;
; Inputs:
;		cphases: relative cross-phases in radians
;   chpos: 1D vector of channel positions in radians.
;		marginfraction (optional): fraction of default margin of monotonization; default:1
;   moderange (optional): vector of minimum and maximum modenumbers to be considered
;     default:[-999,999] (unlimited)
;
; Output:
;		modenum: modenumber, or 1000 for not defined modenumber
;   ms (optional): mode number vector [positive, negative]
;-


function pg_modefilter_monoton, cphases, chpos, marginfraction=marginfraction, moderange=moderange, ms=ms, debug=debug

if keyword_set(debug) then begin
  cphases = randomn(1,28)*0.05 ; test for 0 modenumber
  moderange = [-6,6] 
endif

compile_opt defint32 ; 32 bit integers

; Set defaults
if not(keyword_set(marginfraction)) then marginfraction=1.
if not(keyword_set(moderange)) then moderange=[-999,999]

crosssize=n_elements(cphases)
channelssize=ceil(sqrt(2*crosssize))
margin=float(marginfraction)*2*!PI/float(channelssize)/5. ; division by 5 is based on earlier experience

ms=[1000,1000]
modenum=1000 ;Marks undefined

; Create array for phase diagrams with different reference channels
phases0=fltarr(channelssize,channelssize)
; Fill array from input
for i=0,channelssize-1 do begin
	for j=i+1,channelssize-1 do begin
		phases0[i,j]=cphases[i*(channelssize-(i+1)/2.)-(i+1)+j]
		phases0[j,i]=-cphases[i*(channelssize-(i+1)/2.)-(i+1)+j]
	endfor
endfor

; Sort the phase arrays based on chpos values
sort_order=sort(chpos[*])
for i=0,channelssize-1 do begin
  for j=i+1,channelssize-1 do begin
    phases0[i,j]=phases0[sort_order[i],sort_order[j]]
  endfor
endfor

; Translate phase diagrams to start from (0,0)
for i=1,channelssize-1 do begin
	phases0[i,*]=phases0[i,*]-phases0[i,0]
endfor

; Add 0 to the end of each phase diagram
phases0=[[phases0],[phases0(*,0)*0.]]

; Test for positive modenumbers
phases=phases0
; Monotonize phase diagrams
for i=0,channelssize-1 do begin
	for j=1,channelssize do begin
		if phases[i,j-1] GT phases[i,j]+margin then phases[i,j:channelssize]=phases[i,j:channelssize]+2*!PI
	endfor
endfor
if n_elements(where(phases[*,channelssize] EQ phases[0,channelssize])) EQ channelssize $
	then ms[0]=phases[0,channelssize]/(2*!PI)

; Test for negative modenumbers
phases=phases0
; Monotonize phase diagrams
for i=0,channelssize-1 do begin
	for j=1,channelssize do begin
		if phases[i,j-1] LT phases[i,j]-margin then phases[i,j:channelssize]=phases[i,j:channelssize]-2*!PI
	endfor
endfor
if n_elements(where(phases[*,channelssize] EQ phases[0,channelssize])) EQ channelssize $
	then ms[1]=phases[0,channelssize]/(2*!PI)

if abs(ms[0]) EQ abs(ms[1]) AND ms[0] NE 0 then modenum=1000
if abs(ms[0]) LT abs(ms[1]) then modenum=ms[0]
if abs(ms[0]) GT abs(ms[1]) then modenum=ms[1]

; Check limits
if modenum LT moderange[0] OR modenum GT moderange[1] then modenum=1000

return,modenum

end