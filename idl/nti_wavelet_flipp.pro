;+
; NAME:
; NTI_WAVELET_FLIPP
;
; PURPOSE:
; This program loads data with get_rawsignal.pro, creates a structure, and passes  
; to nti_wavelet_gui.pro -  This way any data can be used that readable with get_rawsignal.
; !!! Important: the program can only handle one time vector, thus signals with identical 
; time vector are only readable in this version. !!! 
;
; CALLING SEQUENCE:
; NTI_WAVELET_FLIPP,<shotnumber>,['signal_in_1',...,'signal_in_n'],trange=[t1,t2]
; 
; To get a list of available data sources call:
; get_rawsignal,data_names=names
; After return <names> containes a string array, each string is the name of the
; associated data source.
; 
; INPUTS:
; shotnumber: shot number
;  signals: array of [<data source>/]<signal name> or numeric channel number (see chan_prefiox and chan_postfix)
;       <data_source> is any of the names returned in data_names. This overrides the
;          data_source input
;           Signal names for Li channels:   Li-xx
;           Signal names for Mirnov channels: Mir-<m>-<ch>  <m>: module  <ch>: channel
;  !!  Will return full signal name string (e.g. W7-AS Nicolet/Li-1) !!!!
;  errorproc: name of error processing routine to call on error
;  data_source:  0 --> W7-AS Nicolet system (see meas_config.pro)
;                1 --> W7-AS Aurora system
;                2 --> W7-AS standard Li-beam data acquisition
;                3 --> AUG standard Li-beam data acquisition
;                4 --> W7-AS Mirnov system
;                5 --> AUG Nicolet data (Data taken with W7 Nicolet)
;                6 --> W7-AS CO2 laser scattering
;                7 --> TEXTOR Li-beam with LMS loggers
;                8 --> TEXTOR Blo-off-beam with LMS loggers
;                9 --> TEXTOR Li-beam for test shots
;               10 --> W7-AS Blo-off-beam (diagn.: VUV,module: Juelich 1-4, channel: 1,2
;               11 --> JET Li-beam channels measured in CATS
;               12 --> Numerical tests, simulated light signals
;               13 --> Signals measured with NI6115 system
;               14 --> W7-AS ECE signals (saved from eaus and read through read_ece.pro
;               15 --> JET KK3 ECE system (through MDS+)
;               16 --> General interface for signals in IDL save file
;                        File name: <shot><signal name>.sav
;                        Contents:  data: data array
;                                   sampletime: sample time in sec
;                                   starttime: start time in sec
;               17 --> CASTOR data. Channel name is system-channel
;               18 --> MT-1M data: Channel name is system-channel
;               19 --> TEXTOR web umbrella access
;               20 --> TEXTOR supersonic He beam   /D. D.  2005. 06.13.
;               21 --> NI-6115 Test Measurements   / D. D. 2005. 10. 10.
;               22 --> AUG Mirnov diagnostocs      /K. G. 2005.11.14
;               23 --> MAST data through read_data.pro  /Z.S. 2006.01.10
;               24 --> NI card measurements ( MAST, TEXTOR)  /D. D. 2007. 01. 10.
;               25 --> TEXTOR Fast libeam 2008               /D. D. 2008. 02. 29.
;               26 --> JET JPF  (Signal name: subsystem/node
;               27 --> JET PPF
;               28 --> Signal cache (see signal_cache_add.pro)
;               29 --> ITER CXRS test spectrometer using APDCAM detector
;               30 --> MAST NETCDF data through getdata  /D.D. 2011. 05. 04.
;               31 --> ASDEX Upgrade data /S. Zoletnik  11 May 2011
;               32 --> KSTAR data / S. Zoletnik   2 August 2011
;               33 --> JET KY6D raw data from controlling PC  S. Zoletnik 19 April 2012
;               34 --> COMPASS Li-BES  D. Refy 1` April 2013
;               35 --> AUG Li-beam data with APDCAM    S. Zoletnik 4 April 2013
;               36 --> JET JPF/PPF data from BEAM server  (Signal name: 'JPF/DH/Y6-DOWN:001' or 'ppf/cxsm/rcor')
;               37 --> ASDEX MDSPlus reading
;               38 --> APDCAM-10G reading
;               39 --> EAST Li-BES
;               40 --> EAST BES
;               41 --> generalized JET data reader (JPF/PPF/MDSPlus)
;               42 --> COMPASS ABP 1. Dec. 2014 M. Lampert
; trange: time range in sec (default: get all data)
; /nocalibrate: do not calibrate signal (e.g. relative calibaration of Li channels)
; /cache:  Store signal in signal cache using the full signal name (see signal_cache_add.pro)
;   cache='name'  Store signal in signal cache using name as signal name
; /search_cache: Search cache for signal
; datapath: Path for the datafile
; local_datapath: The path for the directory where locally cached data are stored (see /store_data)
;
;-

pro nti_wavelet_flipp, shotnumber,signals, data_source=data_source,trange=trange,  $
    nocalibrate=nocalibrate,datapath=datapath,local_datapath=local_datapath,cache=cache, $
    search_cache=search_cache,data_names=data_names
    
for i=0, n_elements(signals)-1 do begin
  get_rawsignal,shotnumber,signals[i],time,data, data_source=data_source,trange=trange,  $
    nocalibrate=nocalibrate,datapath=datapath,local_datapath=local_datapath,cache=cache, $
    search_cache=search_cache,data_names=data_names
  if i EQ 0 then begin
    data_array=fltarr(n_elements(data),n_elements(signals))
    time_array=fltarr(n_elements(time))
    theta_array=fltarr(n_elements(signals))
    phi_array=fltarr(n_elements(signals))
    time_array=time
  endif
  if ~array_equal(time_array,time) then begin
    print, 'The time vector of '+signals[i]+' is not identical with time vector of '+signals[0]+' !
    print, 'Program terminates.'
    return
  endif
  data_array[*,i]=congrid(data,n_elements(data_array[*,0]))
  if data_source EQ 41 then begin
    read_jet_magnetic_coordinate, signals[i], coordinates=coordinates
    routine='read_jet_magnetic_coordinate'
  endif
  if data_source EQ 32 then begin
    read_kstar_bes_coordinate, shotnumber, signals[i], coordinates=coordinates
    routine='read_kstar_bes_coordinate'
  endif
  if data_source EQ 39 then begin
    read_east_bes_coordinate, shotnumber, signals[i], coordinates=coordinates
    routine='read_east_bes_coordinate'
  endif
  if data_source EQ 30 then begin
    read_mast_bes_coordinate, shotnumber, signals[i], coordinates=coordinates
    routine='read_mast_bes_coordinate'
  endif
  if defined(coordinates) then begin
    theta_array[i]=coordinates.PolAng * !DTOR
    phi_array[i]=coordinates.TorAng * !DTOR
    coord_history = 'Data loaded from FLIPP, coordinates with '+routine
  endif else begin
    coord_history = "Data loaded from FLIPP, no coordinates found.."
    theta_array[i]=0.
    phi_array[i]=0.
  endelse
   
endfor
;Creating data_block for NTI WAVELET TOOLS (included all nescessarry information for modenumber calculations)
;------------------------------------------------------------------------------------------------------------
;Expeiment Name:
  expname=data_names[data_source]
;Shotnumber:
  shotnumber=shotnumber
;Signal name:
  signame=signals
;Data vector:
  data=data_array
;Time vector:
  time=time_array
;Theta
  theta=theta_array
;Phi
  phi=phi_array

;Calculate geometrical values:
;
;Here coordinate transformations are to be inserted for different diagnostics
;coord_history = "Data loaded from FLIPP, coordinates with 'read_jet_magnetic.pro'"

;Creating the datablock structure: (This is the expected structure from NTI_WAVELET_GUI.PRO)
flipp_output = { $
;Signal features:
	expname : expname, $
	shotnumber : shotnumber, $
	channels : signals, $
	coord_history : coord_history, $
	data_history : "Loaded-with-FLIPP", $
;Data of signals:
	data : data, $
	time : time, $
	theta : theta, $
	phi : phi $
}

nti_wavelet_gui, input_structure=flipp_output, environment='flipp', event=event

end