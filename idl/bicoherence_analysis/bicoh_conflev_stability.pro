pro bicoh_conflev_stability
unit=complex(0,1)

amplitudesStat = [1,1,1,1,1,1,1,1,1,1]
amplitudesStat=2*randomu(100,10)
amplitudesStat = [[amplitudesStat],[amplitudesStat],[amplitudesStat]]

confLev = [0.95, 0.99, 0.998]
numConf = n_elements(confLev)
limits = [5e2,6e2,7e2,8e2,1e3,2e3,3e3,4e3,5e3,6e3,7e3,8e3,1e4];l,2e4,3e4,4e4,5e4,6e4,7e4,8e4,1e5,2e5,3e5,4e5]
;limits = [1e3,2e3,3e3,4e3,5e3,6e3]
numLimit = n_elements(limits)

numSamp = 1000

limAvg = dblarr(3,numLimit)
limDev = dblarr(3,numLimit)
confRealization = dblarr(numConf,numSamp)

for i=0, numLimit-1 do begin
  print, 'Calculation for limit: ', limits(i)
  for j=0, numSamp-1 do begin
    bicoharr = dblarr(limits(i))
    for k=0L, limits(i)-1 do begin
      randomPhases = 2.*!Pi*randomu(seed,3,10)
      transformStat = amplitudesStat*exp(unit*randomPhases)
      bicoharr(k) = abs(mean(transformStat(*,0)*transformStat(*,1)*conj(transformStat(*,2))))/$
        (sqrt(mean(abs(transformStat(*,0)*transformStat(*,1))^2))*sqrt(mean(abs(transformStat(*,2))^2)))
    endfor
    bicoharr =bicoharr(sort(bicoharr))
    confRealization(0,j)=bicoharr(floor(limits(i)*confLev(0)))
    confRealization(1,j)=bicoharr(floor(limits(i)*confLev(1)))
    confRealization(2,j)=bicoharr(floor(limits(i)*confLev(2)))
  endfor
  
  limAvg(0,i)=mean(confRealization(0,*))
  limAvg(1,i)=mean(confRealization(1,*))
  limAvg(2,i)=mean(confRealization(2,*))
  
  limDev(0,i)=stddev(confRealization(0,*))
  limDev(1,i)=stddev(confRealization(1,*))
  limDev(2,i)=stddev(confRealization(2,*))
endfor
legend=['sC=0.95','sC=0.99','sC=0.997']
data2plot=[[reform(limAvg(0,*))],[reform(limAvg(1,*))],[reform(limAvg(2,*))]]
error2plot=[[reform(limDev(0,*))],[reform(limDev(1,*))],[reform(limDev(2,*))]]
nti_wavelet_plot_1d, alog10(limits), transpose(data2plot),error=transpose(error2plot),$
  yrange=[0.5,1],xrange=[2.6, 1.05*alog10(max(limits))],$
  xtitle='log10 Number of samples', ytitle = 'Bicoherence',$
  legend=legend,$
  title='bicoh value for different confidence values',$
  name='bicoherenceCrit_at_diff_numSamps'
nti_wavelet_plot_1d, alog10(limits), 100.*transpose(error2plot)/transpose(data2plot),$
  xrange=[2.6, 1.05*alog10(max(limits))], yrange=[0,3],$
  xtitle= 'log10 Number of samples', ytitle='STDDEVs/mean percent',$
  legend=legend,$
  title='Error levels for different confidence values',$
  name='error_at_diff_numSamps'
stop
end