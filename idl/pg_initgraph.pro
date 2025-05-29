;+
; NAME: pg_initgraph
;
; Written by: Gergo Pokol (pokol@reak.bme.hu) 2003.04.15.
;
; PURPOSE: Initialize graphics
;
; CALLING SEQUENCE:
;	pg_initgraph [,/print] [,/portrait]
;
; INPUTS:
;	/print (optional): Print to file instead of plotting
;	/portrait (optional): Portrait ps file
;
; OUTPUT: -
;
; EXAMPLE:
;   pg_initgraph, /print
;-

pro pg_initgraph, print=print, portrait=portrait

!P.MULTI=0

if keyword_set(print) then begin
	set_plot, 'PS'
	if keyword_set(portrait) then device, bits_per_pixel=8, font_size=8, /color, /portrait, /cmyk $
	else device,bits_per_pixel=8,font_size=8,/color,/landscape,/cmyk
endif else begin
  ; Reset colortable 
  loadct, 0
	if (strupcase(!version.os) EQ 'WIN32') then begin
		set_plot, 'WIN'
		device,retain=2,decompose=0
	endif else begin
		set_plot, 'X'
		device,retain=2,decompose=0
	endelse
endelse

end
