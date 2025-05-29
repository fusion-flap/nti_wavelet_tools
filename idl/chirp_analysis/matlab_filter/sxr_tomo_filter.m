function sxr_tomo_filter( filename, filter )
%SXR_TOMO_FILTER This function filters SXR data
%Set the requested frequency band in kHz.
%Example:  sxr_tomo_filter('SXR_30951.mat', [70, 110])

% Load data:
xx = load(filename);
timeax = xx.t;
data = xx.sxr;

% Create frequency axis of FFT:
  % The length of the frequency axis is half of the time axis:
  freqax = 1:(floor(size(data, 1)/2.) + 1);
  freqax = freqax/max(freqax);
  % Calculate sampling time:
  dt = (timeax(end) - timeax(1))/(length(timeax) - 1);
  % Calculate Nyquist frequency:
  fn = (1./dt/2.);
  % Frequency axis in kHz
  freqax = freqax*fn/1e3;

% FFT filter
  % Calculate FFT of the data:
  fft_data = fft(data);

  % High pass filter:
    % Find the index of the requested frequency on the freqax:
    [value index] = min(abs(freqax - filter(1)));
    % Set to zero the frequencies under the requested value:
    fft_data(1:index - 1, :) = complex(0);
    fft_data(length(fft_data) - index + 3 : end, :) = complex(0);

  % Low pass filter:
    % Find the index of the requested frequency on the freqax:
    [value index] = min(abs(freqax - filter(2)));
    % Set to zero the frequencies under the requested value:
    fft_data(index + 1 : length(fft_data) - index + 1, :) = complex(0);
    
  % Calculate the inverz FFT of the filtered FFT data:
  data = real(ifft(fft_data));

% Save data:
  % Rename variables:
  t = timeax;
  sxr = data;
  % Create output name:
  tmp = strfind(filename, '.');
  outname = strcat(filename(1:tmp(end) - 1), '_filtered_', ...
      num2str(filter(1)), '-', num2str(filter(2)), 'kHz.mat');
  % Save:
  save(outname, 't', 'sxr');

end