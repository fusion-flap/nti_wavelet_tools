pro examplePhaseRandomizedBicohDistribution

  unit = complex(0,1)
  
  N = 500000
  nbin = 50
  
  amplitudesStat = [1,1,1,1,1,1,1,1,1,1]
  amplitudesStat = [[amplitudesStat],[amplitudesStat],[amplitudesStat]]
  
  mag=100
  amplitudesInstat = 2*randomu(mag,10)
  print, 'Instat amplitudes:', amplitudesInstat
  print, 'Instat ampl dev rel:', stddev(amplitudesInstat)/mean(amplitudesInstat)
  amplitudesInstat = [[amplitudesInstat],[amplitudesInstat],[amplitudesInstat]]
  
  bicoherenceStat = dblarr(N)
  bicoherenceInstat =dblarr(N)
  for i=0L, N-1 do begin
    corn =i
    randomPhases = 2.*!Pi*randomu(seed,3,10)
    transformStat = amplitudesStat*exp(unit*randomPhases)
    transformInstat = amplitudesInstat*exp(unit*randomPhases)
    bicoherenceStat(i) = abs(mean(transformStat(*,0)*transformStat(*,1)*conj(transformStat(*,2))))/$
      (sqrt(mean(abs(transformStat(*,0)*transformStat(*,1))^2))*sqrt(mean(abs(transformStat(*,2))^2)))
      
    bicoherenceInstat(i) = abs(mean(transformInstat(*,0)*transformInstat(*,1)*conj(transformInstat(*,2))))/$
      (sqrt(mean(abs(transformInstat(*,0)*transformInstat(*,1))^2))*sqrt(mean(abs(transformInstat(*,2))^2)))
  endfor

  histStac = histogram(bicoherenceStat,nbin=nbin)/(0.+n_elements(bicoherenceStat))
  histInstac = histogram(bicoherenceInstat,nbin=nbin)/(0.+n_elements(bicoherenceInstat))
  x = (max(bicoherenceStat)-min(bicoherenceStat))*dindgen(nbin)/(nbin-1.0) + min(bicoherenceStat)
  stop
  nti_wavelet_plot_1d, x, transpose([[histStac],[histInstac]]),$
    xrange=[0,1], yrange=[0,max([histStac,histInstac])*1.05],$
    xtitle = 'Bicoherence', ytitle = 'Probability density',$
    legend=['Stationary process','Instationary process', 'Difference abs'],$
    title='Phase randomized bicoherence probability density function',$
    info='mean: '+pg_num2str(mean(amplitudesInstat))+'!C dev: '+pg_num2str(stddev(amplitudesInstat))
;=======================================================================================================  
;  
;  limits = [1e2,2e2,3e2,4e2,5e2,6e2,7e2,8e2,1e3,2e3,3e3,4e3,5e3,6e3,7e3,8e3,1e4,2e4,3e4,4e4,5e4,6e4,7e4,8e4,1e5,2e5,3e5,4e5]
;  ;bicoh as a function of number of samples at different confidence levels
;  bs90 = limits*0.0  
;  bs95 = limits*0.0
;  bs99 = limits*0.0
;
;  b90 = limits*0.0
;  b95 = limits*0.0
;  b99 = limits*0.0
;  for i=0, n_elements(limits)-1 do begin
;    ;stationary
;    subsetStat = reform(bicoherenceStat(0:limits(i)))
;    sortedSubset = subsetStat(sort(subsetStat))
;    bs90(i) = sortedSubset(floor(n_elements(subsetStat)*0.90))
;    bs95(i) = sortedSubset(floor(n_elements(subsetStat)*0.95))
;    bs99(i) = sortedSubset(floor(n_elements(subsetStat)*0.99))
;    ;instationary
;    subsetInstat = reform(bicoherenceInstat(0:limits(i)))
;    sortedSubset = subsetInstat(sort(subsetInstat))
;    b90(i) = sortedSubset(floor(n_elements(subsetInStat)*0.90))
;    b95(i) = sortedSubset(floor(n_elements(subsetInStat)*0.95))
;    b99(i) = sortedSubset(floor(n_elements(subsetInStat)*0.99))
;  endfor
;  
;  b = [[bs90],[bs95],[bs99],[b90],[b95],[b99]]
;  error = b*0.1
;  ;stop
;  legend=['sC=0.90','sC=0.95','sC=0.99','C=0.90','C=0.95','C=0.99']
;
;  nti_wavelet_plot_1d, alog10(limits), transpose(b),error=transpose(error),$
;    yrange=[0,1],xrange=[1.5, 1.1*alog10(max(limits))],$
;    xtitle = 'log10 Number of samples', ytitle = 'Bicoherence',$
;    legend=legend,$
;    title='bicoh value for different confidence values'
;  loadct, 0;,$
;    ;info='mean: '+pg_num2str(mean(amplitudesInstat))+'!C dev: '+pg_num2str(stddev(amplitudesInstat))

end