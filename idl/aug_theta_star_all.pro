;+
;
; NAME: aug_theta_star_all
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2016.03.11.
;
; PURPOSE: Load saved raw data file. Convert geometrical poloidal coordinates with respect to the magnetic axis (theta) to poloidal coordinates
;    in straight filed line geometry (theta^star) in the ASDEX-Upgrade tokamak on a given q surface. Save new raw data file.
;    Uses az external FORTRAN routine to be found at the AUG AFS!
;
; CALLING SEQUENCE:
;   aug_theta_star_all, filename, q, [dianam]
;
; INPUTS:
;   filename: file name of the rwa data file to be converted
;   q: q value of the magnetic surface to do the calculation
;   dianam (optional): equilibrium reconstruction to use: can be 'FPP' for Function parametrization or 'EQI' for cliste; default: 'EQI'
;
; OUTPUTS:
;   Raw data file written to the same folder as the original file
;
; EXAMPLE:
;   aug_theta_star_all,'AUGD_32388_Loaded-with-MTR.sav',2; 
;-

pro aug_theta_star_all, filename, q, dianam=dianam

restore, filename

mid_time=(timeax(n_elements(timeax)-1)+timeax(0))/2.

; Do theta-star conversion for each theta value
theta=aug_theta_star_conv(shotnumber,mid_time,float(q),theta/!DtoR,dianam=dianam)*!DtoR

coord_history=coord_history+' + theta-star correction at q='+pg_num2str(q,length=4)

new_filename=strmid(filename,0,strlen(filename)-4) ; cut file extension
new_filename=new_filename + '_theta-star_at_q'+pg_num2str(q,length=4)+'.sav' ; extend filename to include q value used in correction
save, expname, shotnumber, channels, data, timeax, theta, phi, data_history, coord_history, filename=new_filename

end
