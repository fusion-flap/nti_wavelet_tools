; Program to filter the measured data by AR modelling
; written by G.Por, Hungary, BME-NTI, Association Euratom
;first we read the signal, using widget for opening the file


; then we find an AR modell for it P=50
; plotting the filtered signal, the white detection noise

;finally those parts are cut out from the signal and replaced by their AR mdoelling

pro auto_ar_filter, data = data, timeax = timeax, history = history, gui = gui, verbose = verbose, channel_name = channel_name

nti_wavelet_default, history, 'Manually-selected'
nti_wavelet_default, channel_name, history
nti_wavelet_default, gui, 0
nti_wavelet_default, verbose, 1

pg_initgraph

if (gui EQ 0) then begin

PRINT, 'Welcome'
Print, 'please find your data file in widget and open it!'
compile_opt defint32; 32 bit integers
filters=['*.sav','*.dat']
data_file=DIALOG_PICKFILE(/READ, FILTER=filters)                              ;'*.sav')

;in case of .sav file we expect usal structure, which can be extracted by store to get time and data
if (STRpos(data_file,'.sav') GT 0) then begin
	restore, data_file
	;timeax,data and a string named:'history' are coming from restore
if keyword_set(timeax) then begin
	time=timeax
	timeax=0
endif else begin
	time = dindgen(n_elements(data))*(double(endtime)-double(starttime))/(n_elements(data)-1)+double(starttime) 
endelse
	
	print, data_file
	goto, work
endif		;strpos


;in case of .dat file we expect two coloums of data
if (STRpos(data_file,'.dat') GT 0) then begin
	kiolvas=pi_loadncol(data_file,headerline=13)
	time=kiolvas[*,0]
	data=kiolvas[*,1]
	stop
	goto, work
endif

work:



signal=FILE_BASENAME(data_file)
konyvtar=FILE_DIRNAME(data_file)
print, signal

endif;gui

if gui then begin
  time = timeax
  signal = channel_name
endif

;showing the input time signal

if verbose then begin

 set_plot,'X'
WINDOW, 0,XPOS=100,YPOS=0, XSIZE=900, YSIZE=900, TITLE='ASDEX-U-window'
!P.Multi=[0,1,3]
!P.color=0
  !P.background=255
  !X.style = 1
  !Y.style = 1
 !P.CHARSIZE = 2.0
 
  plot, time, data, TITLE ='Program auto_AR_filter, Selected INPUT SIGNAL(to be processed):  '+signal,Xtitle=' time [sec] '

endif

;Auto i.e not interactive version Read, DEFA, Prompt='enter 1 if you want to run on default values: '

    N=n_elements(data)
    P=50   ;here you may change the model order
;if (DEFA NE 1) then READ,P,PROMPT='enter the model order (default:14) integer number: '
if (P LT 3) then P=14
PRINT,'P=',P

    kkkkk=2.0
;if (DEFA NE 1) then READ,kkkkk,PROMPT='enter the ration of standard deviation: '
PRINT,'ratio(sigma1/sigma0)=',kkkkk
if (kkkkk LT 1.1) then kkkkk=2.0
    
partial=TS_COEF(data,P)
AR=partial
ARmodell=partial
Print, 'AR-coefficients=',AR
;here we start to filter the signal by AR modell
;
;
;

;function [ szurtjel ] = arszures( mertjel, armodell )
;%ARSZURES függvény súgó
;%   A függvény lehetővé teszi az autoregressziós modell segítségével a  
;%   mért időjel kifehérítését.
;%
;%   Példa a használathoz :
;%   szurtjel=arszures(y(1025:5120,1), AR);
    ardb=n_elements(armodell);
    mertjeldb=n_elements(data);
    s=make_array(mertjeldb); 
    for i=ardb,mertjeldb-1L DO BEGIN
        osszeg=0;
        for j=0L,ardb-1 DO BEGIN
            szorzat=ARmodell(j)*data(i-j-1); 
            osszeg=osszeg+szorzat;
        endfor;j
        s(i)=data(i)-osszeg;
    endfor;i
    szurtjel=s;
;end
kivontjel=data-szurtjel
;plot, time, data
if verbose then begin
  plot, time, szurtjel, TITLE='White noise part of the signal separated by AR model, model order='+string(P,format='(i3)')
  plot, time, kivontjel, TITLE='White noise component removed from the signal i.e. AR model, oder='+STRING(P,format='(i3)')
endif
;preparation to saving

data = szurtjel
history=history+'_AR-filtered'

if (gui eq 0) then begin
  fajlnev='AR_'+signal
  hova=konyvtar+'/'+fajlnev
  data_history = history
  SAVE,data,timeax,time,data_history,expname,shotnumber,channels,theta_type,theta,phi,filename=hova
endif


END


