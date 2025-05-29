;+
; NAME:
; NTI_WAVELET_CLEANUP
;
; PURPOSE:
; This procedure stores the system variables in the IDL environment and restores them upon request.
; It creates a tepmorary_variable_storage.sav file for that purpose that is deleted after restoring.
;
; CALLING SEQUENCE:
; nti_wavelet_cleanup [,/store]
;
; INPUTS:
; /store (optional): Stores the variables instead of restoring
;
;-

pro nti_wavelet_cleanup, store=store

store = keyword_set(store)
filename='tepmorary_variable_storage.sav'

if store then begin ;Save variables to be restored after finishing
  save, /system_variables, filename='tepmorary_variable_storage.sav'
  print, 'tepmorary_variable_storage.sav saved.'
endif else begin ;Restore variables to the state before NTI Wavelet Tools run and clean up
  restore, 'tepmorary_variable_storage.sav'
  print, 'tepmorary_variable_storage.sav restored.'
  file_delete, 'tepmorary_variable_storage.sav' , /ALLOW_NONEXISTENT
  print, 'tepmorary_variable_storage.sav deleted.'
endelse

end