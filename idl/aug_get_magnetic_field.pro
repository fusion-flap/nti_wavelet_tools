; Name: aug_get_magnetic_field
;
; Written by: Nora Lazanyi (laznor@reak.bme.hu) 2010.10.03.
;
; Purpose: Get the magnetic field coordinates, and calculate the pitch angle.
;     Uses az external FORTRAN routine to be found at the AUG AFS!
;
; Inputs:
;   shot: shot numbers
;   time: time-point to serch for in s
;   dianam (optional): equilibrium reconstruction to use: can be 'FPP' for Function parametrization or 'EQI' for cliste; default: 'EQI'
;
; Output:
;   Brn: radial component of magnetic field
;   Bzn: vertical component of magnetic field
;   Btn: toroidal component of magnetic field
;   pitch_angle: angle between the toroidal and poloidal magnetic field lines
;   time: time-point found

pro aug_get_magnetic_field, shot, time, q, angles, dianam=dianam, Brn=Brn, Bzn=Bzn, Btn=Btn, pitch_angle=pitch_angle

; Set defaults
if (!VERSION.MEMORY_BITS eq 32) then begin              $
    _libddww = '/afs/.ipp/aug/ads/lib/@sys/libddww.so'  &$
    _libkk   = '/afs/.ipp/aug/ads/lib/@sys/libkk.so'    &$
    _libjj   = '/afs/.ipp/aug/ads/lib/@sys/libjj.so'    &$
endif else begin                                        $
    _libddww = '/afs/.ipp/aug/ads/lib64/@sys/libddww8.so'&$
    _libkk   = '/afs/.ipp/aug/ads/lib64/@sys/libkk8.so'  &$
    _libjj   = '/afs/.ipp/aug/ads/lib64/@sys/libjj8.so'  &$
endelse

defsysv, '!LIBDDWW', _libddww
defsysv, '!LIBKK',   _libkk
defsysv, '!LIBJJ',   _libjj

; Set libkk parameters
iERR=0L
expnam='AUGD'
nSHOT=long(shot)
nEDIT=0L
tSHOT=float(time)
qval=float(q)
Nangl=long(n_elements(angles))
angle=float(angles)
swrad=0L
Rmag=fltarr(1)
zmag=fltarr(1)
Rn=fltarr(Nangl)
zn=fltarr(Nangl)
tSHf=fltarr(1)
thetsn=fltarr(Nangl)
Brn=fltarr(Nangl)
Bzn=fltarr(Nangl)
Btn=fltarr(Nangl)

; Call libkk routine on AUG AFS
s=call_external(!LIBKK, 'kkidl', 'kkEQqFL',$
                iERR,expnam,dianam,nSHOT,nEDIT,tSHOT,$
                qval,Nangl,angle,swrad,$
                Rmag,zmag,Rn,zn,tSHf,$
                thetsn,Brn,Bzn,Btn)

if (iERR ne 0) then begin 
  print,'Magnetic angle conversion failed!'
  print,'Geometrical angles will be used!'
  
endif

time=tSHf
Brn=Brn
Bzn=Bzn
Btn=Btn

print, 'B_r: '+ pg_num2str(Brn)
print, 'B_z: '+ pg_num2str(Bzn)
print, 'B_t: '+ pg_num2str(Btn)

B_pol=sqrt((Brn)^2+(Bzn)^2)
pitch_angle=atan(B_pol/Btn)

print, 'pitch angle:' + pg_num2str(pitch_angle)

pitch_angle=pitch_angle



end
