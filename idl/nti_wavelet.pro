;==========================================================================================

;NTI_WAVELET.PRO

;==========================================================================================
;-- NTI_WAVELET.PRO is a part of MTR environment
;-- This program runs, when NTI_WAVELET is called from the main menu of MTR
;-- All variable, which MTR read is stored in state variable
;==========================================================================================

pro nti_wavelet, state, event

;Create mtr_state variable, because I don't want to return any changes to Marc
mtr_state=state

;Preapre data:
  mtr_prepare_data, mtr_state


;Creating data_block for NTI WAVELET TOOLS (included all nescessarry information for modenumber calculations)
;------------------------------------------------------------------------------------------------------------
;Expeiment Name:
  expname=mtr_state.ExpName
;Shotnumber:
  shotnumber=mtr_state.shotnum
;Signal name:
  handle_value,mtr_state.signame_handle,signame
;Real diagnostic and signal names for selected channels:
  handle_value,mtr_state.indices_handle,indices
  case mtr_state.diagname of
    'gen': begin
      ; MRM: only here mtr_state.realdiagname is usefull
      diagname = strarr(n_elements(indices))
      diagname[*] = mtr_state.realdiagname
    end
    'MH_' OR 'SX_' OR 'XV_' OR 'com': begin
      ; MRM: in the combined case diagname_handle is valid and
      ; MRM: contains the diagnostics which you have selected
      handle_value,mtr_state.diagname_handle,diagname
    end
    else: begin
      ; MRM: for all other cases state.diagName is sufficient for
      ; MRM: rereading the data and could be used.
      diagname = replicate(mtr_state.diagName,n_elements(indices))
    end
  endcase
  channels=diagname[where(indices)]+"-"+signame[where(indices)]

;Data vector:
  handle_value,mtr_state.data_handle,data
;Time vector:
  handle_value,mtr_state.time_handle,time
;Theta
  handle_value,mtr_state.theta_handle,theta
;Phi
  handle_value,mtr_state.phi_handle,phi

;Calculate geometrical values:
;Here coordinate transformations are to be inserted for different diagnostics
coord_history = "Geometrical_Loaded-with-MTR"

;Creating the datablock structure: (This is the expected structure from NTI_WAVELET_GUI.PRO)
mtr_output = { $
;Signal features:
	expname : expname, $
	shotnumber : shotnumber, $
	channels : channels, $
	coord_history : coord_history, $
	data_history : "Loaded-with-MTR", $
;Data of signals:
	data : data, $
	time : time, $
	theta : theta, $
	phi : phi $
}

nti_wavelet_gui, input_structure=mtr_output, environment='mtr', event=event

end