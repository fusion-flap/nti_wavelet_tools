pro chirp_analysis_ridge, $
  ; STFT parameters:
    expname = expname, shotnumber = shotnumber, channel = channel, $
    trange = trange, stft_length = stft_length, stft_fres = stft_fres, $
    stft_step = stft_step, resample = resample, $
  ; Ridge following parameters:
    start_x = start_x, start_freq = start_freq, bandwidth = bandwidth, $
    external_ridge = external_ridge, xrange_unit = xrange_unit, $
  ; Noise:
    noisetime = noisetime, noisefreq = noisefreq, $
  ; Interpolation:
    tdens = tdens, fdens = fdens
    
; Restore stft from database:
restore, './database/stft/' + $
    expname + '_' + $
    pg_num2str(shotnumber) + '_' + $
    channel + '_' + $
    't' + pg_num2str(trange(0), length = 5) + '-' + $
      pg_num2str(trange(1), length = 5) + '_' + $
    'r' + pg_num2str(resample) + '_' + $
    'l' + pg_num2str(round(stft_length)) + '_' + $
    'f' + pg_num2str(stft_fres) + '_' + $
    's' + pg_num2str(stft_step) + '.sav'

; Calculate the power of the background noise:
noisetindex = $
  [ (where((timeax - noisetime(0)) eq min((timeax - noisetime(0)), /abs)))(0), $
    (where((timeax - noisetime(1)) eq min((timeax - noisetime(1)), /abs)))(0)]
noisefindex = $
  [ (where((freqax - noisefreq(0)) eq min((freqax - noisefreq(0)), /abs)))(0), $
    (where((freqax - noisefreq(1)) eq min((freqax - noisefreq(1)), /abs)))(0)]
bknoise = $
  stddev(real_part(transform(noisetindex(0):noisetindex(1), noisefindex(0):noisefindex(1))))

if not nti_wavelet_defined(external_ridge) then begin
  ; Start ridge following algorithm:
  nti_wavelet_ridge_follower, reform(abs(transform)), $
    xaxis = timeax, yaxis = freqax, $
    start_y = start_freq, start_x = start_x, $
    bandwidth = bandwidth, xrange_unit = xrange_unit, $
    ridge_index = ridges, noise = 3d*bknoise; 3sigma for 99% confidence

  ; Existence of the ridge:
  ind = where(ridges ne 0)

  if (tdens ne 0) then begin

  ; Recalculate ridge using interpolation:
    ; Calculate timeintrange and freqintrange for interpolation:
    timeintrange = [ind(0), ind(n_elements(ind) - 1)]
    freqintrange = [min(ridges(ind)), max(ridges(ind))]
    ; Create interpolated timeax:
    itimeax = (timeax(n_elements(timeax) - 1) - timeax(0))*$
      dindgen(tdens*(n_elements(timeax) - 1) + 1)/(tdens*(n_elements(timeax) - 1)) $
      + timeax(0)

    ; Create vector of interpolated ridge (in kHz) and amplitude:
    iridge = 0d*itimeax
    itransform = 0d*dcomplexarr(n_elements(itimeax))

    ; Initialize progress indicator:
    print, 'STFT interpolation started:'
    print, '---------------------------'
    ptime = systime(1)

    mini = ind(0)
    maxi = ind(n_elements(ind) - 1)
    for i = mini, maxi do begin
      ; First: interpolation in time is performed
        ; Create local timeax where interpolation is performed:
        newtimeax = itimeax(tdens*i:tdens*(i + 1) - 1)

        ; Create local freqax where interpolation is performed:
          ; Calculate the required interval where interpolation is performed:
          limit1 = ridges(i)
          limit2 = ridges(min([i + 1, maxi]))
          ; Calculate the local freqax:
          newfreqax = freqax( (min([limit1, limit2]) - 1):(max([limit1, limit2]) + 1) )
        ; Perform interpolation:
        nti_wavelet_stft_interpol, $
          transform = transform, timeax = timeax, freqax = freqax, $
          stft_length = stft_length, stft_step = stft_step, $
          newfreqax = newfreqax, newtimeax = newtimeax, $
          newtransform = newtransform, $
          timeintrange = timeintrange, freqintrange = freqintrange

        ; Second: find maximum in new time points using adaptive intepolation
        for j = 0, n_elements(newtimeax) - 1 do begin
          ; Find maximum of newtransform:
          maxindex = $
            (where(abs(newtransform(j, *)) eq max(abs(newtransform(j, *)))))(0)
          ; Start iteration:
          tmpfreqax = newfreqax

          ; Loop variable
          iterations = 0
          while iterations le fdens do begin
            ; Calculate new freqax:
            dfreqax = (tmpfreqax(n_elements(tmpfreqax) - 1) - tmpfreqax(0))/ $
              (n_elements(tmpfreqax) - 1)
            tmpfreqax = [tmpfreqax(maxindex) - 0.5*dfreqax, tmpfreqax(maxindex), $
              tmpfreqax(maxindex) + 0.5*dfreqax]
            ; Interpolate:
            nti_wavelet_stft_interpol, $
              transform = transform, timeax = timeax, freqax = freqax, $
              stft_length = stft_length, stft_step = stft_step, $
              newfreqax = tmpfreqax, newtimeax = newtimeax(j), $
              newtransform = tmptransform, $
              timeintrange = timeintrange, freqintrange = freqintrange
            maxindex = $
              (where(abs(tmptransform(0, *)) eq max(abs(tmptransform(0, *)))))(0)
            ; Step loop variable:
            iterations = iterations + 1
          endwhile

          iridge(tdens*i + j) = tmpfreqax(maxindex)
          itransform(tdens*i + j) = tmptransform(0, maxindex)
        endfor

      ; Progress indicator:
      if floor(systime(1) - ptime) GE 5 then begin
        print, pg_num2str(100*(i - ind(0))/double(ind(n_elements(ind) - 1) - ind(0)), $
          length = 6), ' % done'
        ptime = systime(1)
        wait, 0.1
      endif

    endfor

  endif else begin

    ; Variables renamed if interpolation is missed:
    itimeax = timeax
    iridge = freqax(ridges)
    itransform = dcomplexarr(n_elements(timeax))
    for i = 0L, n_elements(timeax) - 1 do begin
      if (ridges(i) ne 0) then begin
        itransform(i) = reform(transform(i, ridges(i)))
      endif
    endfor

  endelse

endif else begin
  ; Load external ridge:
  sobj = obj_new('IDL_Savefile', './database/ridge/' + external_ridge)
  sobj->Restore, 'start_freq'
  sobj->Restore, 'start_x'
  sobj->Restore, 'bandwidth'
  sobj->Restore, 'ridges'
  sobj->Restore, 'itimeax'
  sobj->Restore, 'iridge'
  sobj->Restore, 'itransform'
  
  if (tdens ne 0) then begin
  ; Interpolate the values of STFT in the points provided by the
  ; itimeax and iridge parameters from the external ridge:
  ; ------------------------------------------------------
    ; Delete itransform values of external ridge:
    itransform = 0*itransform

    ; Calculate timeintrange and freqintrange for interpolation:
    ind = where(ridges ne 0)  ; Existence of the ridge:
    timeintrange = [ind(0), ind(n_elements(ind) - 1)]
    freqintrange = [min(ridges(ind)), max(ridges(ind))]

    ; Initialize progress indicator:
    print, 'STFT interpolation started:'
    print, '---------------------------'
    ptime = systime(1)
    
    ; Run interpolation where iridge exists
    iind = where(iridge ne 0)  ; Existence of the ridge:
    ; Recalculate ridge using interpolation:
    for i = min(iind), max(iind) do begin
      ; Interpolate:
      nti_wavelet_stft_interpol, $
        transform = transform, timeax = timeax, freqax = freqax, $
        stft_length = stft_length, stft_step = stft_step, $
        newfreqax = iridge(i), newtimeax = itimeax(i), $
        newtransform = tmptransform, $
        timeintrange = timeintrange, freqintrange = freqintrange
      itransform(i) = tmptransform(0)
    
      ; Progress indicator:
      if floor(systime(1) - ptime) GE 5 then begin
        print, pg_num2str(100*(i - min(iind))/double(max(iind) - min(iind)), $
          length = 6), ' % done'
        ptime = systime(1)
        wait, 0.1
      endif
      
    endfor
  endif
endelse

; Save chirp to database:
save, filename = './database/ridge/' + $
    expname + '_' + $
    pg_num2str(shotnumber) + '_' + $
    'Ridge-' + pg_num2str(start_x, length = 5) + '_' + $
    channel + '_' + $
    't' + pg_num2str(trange(0), length = 5) + '-' + $
      pg_num2str(trange(1), length = 5) + '_' + $
    'r' + pg_num2str(resample) + '_' + $
    'l' + pg_num2str(round(stft_length)) + '_' + $
    'f' + pg_num2str(stft_fres) + '_' + $
    's' + pg_num2str(stft_step) + '_' + $
    'rb' + pg_num2str(bandwidth) + '_' + $
    'td' + pg_num2str(tdens) + '_' + $
    'fd' + pg_num2str(fdens) + '.sav', $
  expname, shotnumber, channel, trange, $
  itimeax, iridge, itransform, ridges, $
  resample, stft_length, stft_fres, stft_step, sigma, $
  bandwidth, tdens, fdens, start_x, start_freq, $
  noisetime, noisefreq, bknoise

end