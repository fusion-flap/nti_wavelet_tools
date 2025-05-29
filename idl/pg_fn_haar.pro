;----------------------------------------------------------------
; $Id: pg_fn_haar.pro,v 1.1 2008-07-23 16:44:38 pokol Exp $
;
; Copyright (c) 1999-2002, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;+
; NAME:
;    WV_FN_HAAR
;
; PURPOSE:
;    This function returns the Haar wavelet coefficients.
;
; CALLING SEQUENCE:
;    info = WV_FN_HAAR(Order, Scaling, Wavelet, Ioff, Joff)
;
; INPUTS:
;    Order: This is the order number for the Haar wavelet.
;           It is automatically set to 1 (equivalent to Daubechies order=1),
;           regardless of the input.
;
; OUTPUTS:
;    Scaling: The scaling (father) coefficients [1d,1d]/SQRT(2d)
;
;    Wavelet: The wavelet (mother) coefficients [1d,-1d]/SQRT(2d)
;
;    Ioff: The offset index used to center the Scaling support (Ioff=0)
;
;    Joff: The offset index used to center the Wavelet support (Joff=0)
;
; KEYWORD PARAMETERS:
;    None.
;
; RETURN VALUE:
;    Returns a structure with the following information:
;       info = {family:'Haar', $    ; name of wavelet family
;               order:1, $                ; order number
;               order_name:'Order', $     ; term used for "order"
;               order_range:[1], $        ; valid range for orders
;               discrete:1, $             ; 0=continuous, 1=discrete
;               orthogonal:1, $           ; 0=nonorthogonal, 1=orthogonal
;               symmetric:0, $            ; 0=asymmetric, 1=symmetric
;               support:1, $              ; support width
;               moments:1, $              ; # of vanishing moments
;               regularity:0.0}           ; # of continuous derivatives
;
; MODIFICATION HISTORY:
;    Written by: Chris Torrence, 1999
;-
FUNCTION wv_fn_haar,order,scaling,wavelet,ioff,joff

    COMPILE_OPT strictarr
    ON_ERROR,2  ; return to caller

    order = 1
    info = {family:'Haar', $
        order_name:'Order', $
        order_range:[1,1,1], $
        order:1, $
        discrete:1, $
        orthogonal:1, $
        symmetric:1, $
        support:1, $
        moments:1, $
        regularity:0.0}

    IF (N_PARAMS() LT 1) THEN RETURN, info

    scaling = [1d,1d]/SQRT(2d)

; construct wavelet coefficients & offsets
    n = N_ELEMENTS(scaling)
    wavelet = REVERSE(scaling)*((-1)^LINDGEN(n))
    ioff = -n/2 + 2  ; offset for scaling
    joff = ioff      ; offset for wavelet

    RETURN, info
END

