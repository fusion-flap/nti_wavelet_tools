function create_parameter_struct, shotno




; Restore raw_data:
; -----------------
restore, './' + pg_num2str(shotno) + '_ECEI.sav'

raw_data = { $
  data : data, $
  dtimeax : timeax, $
  chpos : phi, $
  expname : expname, $
  shotnumber : shotnumber, $
  channels : channels $
}



; STFT parameters:
stft = { $
  selection : 1, $
  length : 100, $
  fres : 500, $
  step : 2 $
}

; CWT parameters:
cwt = { $
  selection : 0, $
  order : 6, $
  dscale : 0.02 $
}

; Cross-transform parameters:
crosstr = { $
  correction : 1 $
}

; Coherence parameters:
coherence = { $
  avr : 0 $
}

; Mode number parameters:
mode = { $
  type : 'Toroidal', $
  steps : 1, $
  min : -50, $
  max : 50, $
  optimized : 1 $
}

; Frequency range:
freq = { $
  min : 0, $
  max : 199.99 $
}

; Start path:

; Create parameter structure
parameters = { $
  raw_data : raw_data, $
  stft : stft, $
  cwt : cwt, $
  crosstr : crosstr, $
  coherence : coherence, $
  mode : mode, $
  freq : freq, $
  startpath : '/home/horla/svn-sandbox/NTI_Wavelet_Tools/trunk/' $
}

return, parameters

end