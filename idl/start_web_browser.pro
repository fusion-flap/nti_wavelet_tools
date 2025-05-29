;+
; NAME:
;	START_WEB_BROWSER
;
; PURPOSE:
;	This procedure starts the input website in a web browser.
;
; CALLING SEQUENCE:
;	START_WEB_BROWSER, site
;
; INPUTS:
;	site:	This is the website, which will be started.
;
; EXAMPLE:
;	START_WEB_BROWSER, 'www.reak.bme.hu'
;
;-


pro start_web_browser, site

os = !VERSION.OS
exit_status = 1

case os of
  'Win32': begin
    spawn, 'start '+site, /nowait
    exit_status = 0
  end
  'sunos': begin
    spawn, 'sdtwebclient '+site+' &'
    exit_status = 0
  end
  'darwin': begin
    spawn, 'open '+site+' &'
    exit_status = 0
  end
  'linux': begin
    ;Testing existence of browsers:
    browsers = ['firefox', 'google-chrome', 'konqueror', 'opera', 'safari']
    exit_status = 1
    i=0
      while (exit_status ne 0) do begin
	spawn, 'which '+browsers(i), exit_status = exit_status
	i=i+1
	if (i eq n_elements(browsers)) then break
      endwhile
    ;If one of the browsers exist, starting it:
    if (exit_status eq 0) then begin
      spawn, browsers(i-1)+' '+site+' &'
    endif
  end
  else : begin
    exit_status = 1
  endelse
endcase

if (exit_status ne 0) then begin
  res = dialog_message('Visit '+site, /center)
endif


end