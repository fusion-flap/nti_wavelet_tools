;+
; NAME:
;	NTI_WAVELET_PRIME_FACTOR
;
; PURPOSE:
;	This function calculate the prime factors of a given number.
;
; CALLING SEQUENCE:
;	result = NTI_WAVELET_PRIME_FACTOR(num)
;
; INPUTS:
;	num:	The integer number which will be splitted into primes.
;
; EXAMPLE:
;	print, NTI_WAVELET_PRIME_FACTOR(234243)
;           3           3          17        1531
;
;-


function nti_wavelet_prime_factor, num

;CHECK INPUT:
  if (size(num, /n_dimensions) ne 0) then message, 'Incorrect number of arguments!'
  if ((size(num, /type) ne 2) and (size(num, /type) ne 3)) and (size(num, /type) ne 14) then message, 'Integer arguments required!'

;TRANSFORM INPUT TO LONG INTEGER:
  num = long(num)

;CALCULATE PRIME FACTORS:
  n = num
  f = 2
  factors = [-1]

  while (f le sqrt(n)) do begin
    while ((n mod f) eq 0) do begin
      factors = [factors, f]
      n = n / f
    endwhile
    f = f + 1
  endwhile
  if (n gt 1) then factors = [factors, n] 
  if (n_elements(factors) ne 1) then factors=factors[1:*]

;RETURN THE RESULT:
  return, factors

end