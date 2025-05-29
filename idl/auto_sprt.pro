; Program to filter the measured data by AR modelling
; written by G.Por, Hungary, BME-NTI, Association Euratom
;first we read the signal, using widget for opening the file
; we plot the original signal in an IDL0 subwindow
;then a promt comes asking if zou want the default values for SPRT
;default are: desision levels A=-4.6 (meaning 1% of uncertainty of missed alarms)
;B=4.6 (meaning 1% of uncertainty of false alarm), model order P=14, desision level at ration of the variance=2.0000

; then we find the abnormal behaviours by SPRT algorithm
; plotting the filtered signal, the white detection noise
;the lambda function i.e.the decisions, where the signal was regarded as contaminated by distrurbances
;finally those parts are cut out from the signal and replaced by their AR mdoelling

pro auto_sprt, data = data, timeax = timeax, history = history, gui = gui, verbose = verbose, channel_name = channel_name

nti_wavelet_default, history, 'Manually-selected'
nti_wavelet_default, channel_name, history
nti_wavelet_default, gui, 0
nti_wavelet_default, verbose, 1

pg_initgraph
data_history='Manually selected'


if (gui EQ 0) then begin

PRINT, 'Welcome'
Print, 'please find your data file in widget and open it!'
compile_opt defint32; 32 bit integers
filters=['*.sav','*.dat']
data_file=DIALOG_PICKFILE(/READ, FILTER=filters)                              ;'*.sav')

;in case of .sav file we expect usal structure, which can be extracted by store to get time and data
if (STRpos(data_file,'.sav') GT 0) then begin
	restore, data_file
	;timeax,data and a string named:'data_history' are coming from restore
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


;lastslash = STRPOS(data_file, '/', /REVERSE_SEARCH) 
;fullnamelength=n_elements(data_file)
;finenamelength=fullnamelength-lastslash
;filen=makearray
;signal1=STRSPLIT(data_file,'/')

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
!P.Multi=[0,1,7]
!P.color=0
  !P.background=255
  !X.style = 1
  !Y.style = 1
 !P.CHARSIZE = 2.0
 
  plot, time, data, TITLE ='Program auto_sprt, Selected INPUT SIGNAL(to be processed):  '+signal,Xtitle=' time [sec] '

endif

;Auto i.e not interactive version Read, DEFA, Prompt='enter 1 if you want to run on default values: '

    N=n_elements(data)
    P=14
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


;here we start SPRT on szurtjel

;function [ lambda, esemenyA, esemenyB, tisztaA, tisztaB, hol ] = sprt( szigma1c, A, B, szurtjel, mertjel, felbontas)
;%SPRT Summary of this function goes here
;%   Csak is AR szűréssel szűrt jelet érdemes feldolgoztatni az
;%   algoritmussal, amely elemszáma az AR modell rendjével kisebb, mint a
;%   mért jel elemszáma.
;% Usage:
;% [ lambda, esemenyA, esemenyB, tisztaA, tisztaB, dontesek ] = sprt( szigma1c, A, B, szurtjel, mertjel, felbontas)
;% Example:
;% [ lambda, esemenyA, esemenyB, tisztaA, tisztaB, dontesek ] = sprt(2, -4.6, 4.6, szurtjel, mertjel, 64)
 B=4.6
 A=-4.6
;if (DEFA NE 1) then READ,B,PROMPT='enter the abnormal level >2.3: '
if (B LT 2.3) then B=4.6
PRINT,'B=',B
;if (DEFA NE 1) then READ,A,PROMPT='enter the normal level <-2.3: '
 if (A GT -2.3) then  A=-4.6
PRINT,'A=',A 
    
    N=n_elements(szurtjel);
    M=n_elements(data);
    sorA=make_array(N);
    sorB=make_array(N);
    lambda=make_array(N);
    numdontes=make_array(N);
    hol=make_array(N);
    elozo=-1;
    X=M-N;
    szigma0=stddev(szurtjel);
    szigma1=kkkkk*szigma0;   
    j=1;
    h=1;
    keplet=(((szigma1^2)-(szigma0^2))/(2*(szigma1^2)*(szigma0^2)));
    masod=alog(szigma1/szigma0)
    
    for i=0L,N-1 DO BEGIN
        if (i EQ 0) then begin
            lambda(i)=0+(szurtjel(i)*szurtjel(i)*keplet-masod);
        endif else begin
            lambda(i)=lambda(i-1)+(szurtjel(i)*szurtjel(i)*keplet-masod);
        endelse
        

        
        
        if (lambda(i) GE B) then begin
            lambda(i)=0;
            sorB(j)=i+X;
            j=j+1;
            numdontes(i)=1;
            elozo=1;
        endif else begin 
        
                  if (lambda(i) LE A) then begin
                      lambda(i)=0;
                      sorA(h)=i+X;
                       h=h+1;;
                       numdontes(i)=-1;
                       elozo=-1;
                  endif else begin
                      numdontes(i)=0;
                        endelse
                  hol(i)=elozo;
             endelse
    
    endfor;i
; ha minden igaz, akkor a numdontes array-ban 
;+1 az értéke, ahol B döntés van, 
;-1 az értéke, ha A döntés van 
;és másutt 0

if verbose then begin
  plot,time,numdontes, TITLE='THESE ARE the decisions by SPRT, +1=event, -1=normal, 0=no decision yet, parameters: ratio='+string(kkkkk,format='(F4.1)')+'A='+string(A,format='(F4.1)')+'B='+string(B,format='(F4.1)')
endif

;  felbontas=256
;    O=floor(N/felbontas);
;    k=0L;
;    l=§L;
;    tisztaA=make_array(O,felbontas);
;    tisztaB=make_array(O,felbontas);
;    i=felbontas;
;    while (i LE N) DO
;        minta=numdontes(((i-felbontas)+1):i,1);
;        mini=min(minta);
;        maxi=max(minta);
;        if mini==0 && maxi==1
;           tisztaB(k,:)=mertjel(((i-felbontas)+1+X):(i+X),1)'; 
;           k=k+1;
;           i=i+felbontas;
;        elseif mini==-1 && maxi==0
;           tisztaA(l,:)=mertjel(((i-felbontas)+1+X):(i+X),1)';
;           l=l+1; 
;           i=i+felbontas;
;        else
;           i=i+1;
;        end
;    endwhile
;    tisztaB=tisztaB(1:k-1,:);
;    tisztaA=tisztaA(1:l-1,:);
;    esemenyA=sorA(1:h-1,:);
;    esemenyB=sorB(1:j-1,:);
;end

;STOP


;here we start to cut and replace the affected parts of the original signal
; principe: replacing the signal part between the last A decision till the found B decision
; by its substitute calculated by AR modell
;replacedjel=kivontjel
;corrected=kivontjel                    ;szurtjel
corrected=data
kmaxx=256
i=kmaxx
while (i LE N-1L) Do Begin   			;For i=kmaxx, N-1L do begin
      if numdontes(i) EQ 1 then begin
        
        j=i-1
         ;jelresz=data[j-kmaxx:j];itt is csak kmaxx, de a databol;jelresz=szurtjel[j-256:j] 
        ll=1

veg=0


markj:          ;kmaxx=ll
		if (numdontes(j) EQ -1) then begin
              	veg=1

nextA:  ;i novelese akovetekezo A dontesig	
		i=i+1
		ll=ll+1
		if (numdontes(i) NE -1) then goto, nextA

		jelresz=corrected[(i-ll-kmaxx-1):(i-ll)];data[(i-ll-kmaxx-1):(i-ll)];		
		result=TS_FCAST(jelresz,P,ll+1,/DOUBLE)
              for kk=j,i DO begin
eleje=data(j)
vege=data(i)
szog=(vege-eleje)/(i-j)
              corrected(kk)=(kk-j)*szog+eleje		;result(kk-i+ll);replacedjel(kk)=result(ll)
              endfor;kk
          endif   Else begin j=j-1
                         ll=ll+1
			print, ll
                  endelse
		if veg EQ 1 then goto,markk 
		goto, markj    
markk:
      endif
i=i+1
ENDWHILE;i  ;endfor;i

if not gui then begin
  ;preparation to saving
  sk=STRING(kkkkk,FORMAT='(F4.1)')
  sA=STRING(A,FORMAT='(F4.1)')
  sB=STRING(B,FORMAT='(F4.1)')
  ;fajlnev=strmid(signal,0,5)+'_'+sA+'A'+sB+'B'+sK+'K'+signal
  fajlnev='SPRT_'+signal
  hova=konyvtar+'/'+fajlnev
  data_history=data_history+' SPRT '
endif

replacedjel=corrected

correction=replacedjel-data

if verbose then begin
  if gui then begin
    plot,time,replacedjel, title=' CORRECTED SIGNAL'
    plot,time,correction, title='this is the difference between original and corrected signals /i.e.:5-1/'
  endif else begin
    plot,time,replacedjel, title=' CORRECTED SIGNAL', Xtitle=' saved as:  '+hova
    plot,time,correction, title='this is the difference between original and corrected signals /i.e.:5-1/'
  endelse
endif

miez=replacedjel-kivontjel
if verbose then begin
  plot,time, miez,title='replaced (corrected signal)-simple filtered by AR signal, /i.e.:5-3/'
endif

; ez itt egy durva mentes
;STOP
;data=replacedjel
;sk=STRING(kkkkk,FORMAT='(F4.1)')
;sA=STRING(A,FORMAT='(F4.1)')
;sB=STRING(B,FORMAT='(F4.1)')
;fajlnev=strmid(signal,0,5)+'_'+sA+'A'+sB+'B'+sK+'K'+signal
;hova=konyvtar+'/'+fajlnev
if not gui then begin
  SAVE,data,timeax,time,data_history,expname,shotnumber,channels,theta_type,theta,phi,filename=hova
endif

data = replacedjel

END
