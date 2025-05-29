;Gergely Papp, papp@reak.bme.hu
;resample to set new nyquist-frequency at fmax.

pro gp_resample, data, timeax, fmax

   print,'Resampling data to get f_n: '+pg_num2str(fmax)+' kHz (original f_n was: '+pg_num2str(0.0005/(timeax(1)-timeax(0)))+' kHz)'
   print,'Original time axis is: '+pg_num2str(timeax(0))+' - '+pg_num2str(timeax(n_elements(timeax)-1))
   newsize=(timeax(n_elements(timeax)-1)-timeax(0))*2*fmax*1000
   data=pg_resample(data,newsize)
   timeax=float(dindgen(n_elements(data))*(double(timeax(n_elements(timeax)-1))-double(timeax(0)))/n_elements(data))+timeax(0)
   print,'Resampled data, new timeax is: '+pg_num2str(timeax(0))+' - '+pg_num2str(timeax(n_elements(timeax)-1))+', f_n is: '+pg_num2str(0.0005/(timeax(1)-timeax(0)))+' kHz'

end
