;----------------------------------------------------------------
; $Id: pg_fn_coiflet.pro,v 1.1 2008-07-23 16:44:38 pokol Exp $
;
; Copyright (c) 1999-2002, Research Systems, Inc.  All rights reserved.
;   Unauthorized reproduction prohibited.
;+
; NAME:
;    WV_FN_COIFLET
;
; PURPOSE:
;    This function returns the Coiflet wavelet coefficients.
;
; CALLING SEQUENCE:
;    info = WV_FN_COIFLET( Order, Scaling, Wavelet, Ioff, Joff)
;
; INPUTS:
;    Order: This is the order number for the Coiflet wavelet.
;           Order=1 is the "Daubechies Coiflet L=2" wavelet,
;           and has 2 vanishing moments and 6 coefficients.
;
; OUTPUTS:
;    Scaling: A vector of the scaling (father) coefficients
;
;    Wavelet: A vector of the wavelet (mother) coefficients
;
;    Ioff: The offset index used to center the Scaling support
;
;    Joff: The offset index used to center the Wavelet support
;
; KEYWORD PARAMETERS:
;    None.
;
; RETURN VALUE:
;    Returns a structure with the following information:
;          (this is an example for order=1)
;       info = {family:'Coiflet', $    ; name of wavelet family
;               order_name:'Order', $     ; term used for "order"
;               order_range:[1,5,1], $    ; valid range [first,last,default]
;               order:1, $                ; order number
;               discrete:1, $             ; 0=continuous, 1=discrete
;               orthogonal:1, $           ; 0=nonorthogonal, 1=orthogonal
;               symmetric:2, $            ; 0=asymmetric, 1=sym., 2=near sym.
;               support:5, $              ; support width
;               moments:2, $              ; # of vanishing moments
;               regularity:0.550}         ; # of continuous derivatives
;
; REFERENCE:
;    Daubechies, I., 1992: Ten Lectures on Wavelets, SIAM, p. 261.
;       Note that Daubechies has divided by Sqrt(2), and the coefficients
;       are reversed.
;
;    Actual coefficients from <http://www.isds.duke.edu/~brani/filters.html>
;
; MODIFICATION HISTORY:
;    Written by: Chris Torrence, 1999
;-


;----------------------------------------------------------------
; Coiflet orthogonal near symmetric wavelet coefficients
FUNCTION wv_fn_coiflet_coeff, order
    COMPILE_OPT strictarr, hidden
    CASE (order) OF
    1: coeff = [ $
        -0.0156557285289848d,$
        -0.0727326213410511d,$
         0.3848648565381134d,$
         0.8525720416423900d,$
         0.3378976709511590d,$
        -0.0727322757411889d]
    2: coeff = [ $
        -0.0007205494453679d,$
        -0.0018232088707116d,$
         0.0056114348194211d,$
         0.0236801719464464d,$
        -0.0594344186467388d,$
        -0.0764885990786692d,$
         0.4170051844236707d,$
         0.8127236354493977d,$
         0.3861100668229939d,$
        -0.0673725547222826d,$
        -0.0414649367819558d,$
         0.0163873364635998d]
    3: coeff = [ $
        -0.0000345997728362d,$
        -0.0000709833031381d,$
         0.0004662169601129d,$
         0.0011175187708906d,$
        -0.0025745176887502d,$
        -0.0090079761366615d,$
         0.0158805448636158d,$
         0.0345550275730615d,$
        -0.0823019271068856d,$
        -0.0717998216193117d,$
         0.4284834763776168d,$
         0.7937772226256169d,$
         0.4051769024096150d,$
        -0.0611233900026726d,$
        -0.0657719112818552d,$
         0.0234526961418362d,$
         0.0077825964273254d,$
        -0.0037935128644910d]
    4: coeff = [ $
        -0.0000017849850031d,$
        -0.0000032596802369d,$
         0.0000312298758654d,$
         0.0000623390344610d,$
        -0.0002599745524878d,$
        -0.0005890207562444d,$
         0.0012665619292991d,$
         0.0037514361572790d,$
        -0.0056582866866115d,$
        -0.0152117315279485d,$
         0.0250822618448678d,$
         0.0393344271233433d,$
        -0.0962204420340021d,$
        -0.0666274742634348d,$
         0.4343860564915321d,$
         0.7822389309206135d,$
         0.4153084070304910d,$
        -0.0560773133167630d,$
        -0.0812666996808907d,$
         0.0266823001560570d,$
         0.0160689439647787d,$
        -0.0073461663276432d,$
        -0.0016294920126020d,$
         0.0008923136685824d]
    5: coeff = [ $
        -0.0000000951765727d,$
        -0.0000001674428858d,$
         0.0000020637618516d,$
         0.0000037346551755d,$
        -0.0000213150268122d,$
        -0.0000413404322768d,$
         0.0001405411497166d,$
         0.0003022595818445d,$
        -0.0006381313431115d,$
        -0.0016628637021860d,$
         0.0024333732129107d,$
         0.0067641854487565d,$
        -0.0091642311634348d,$
        -0.0197617789446276d,$
         0.0326835742705106d,$
         0.0412892087544753d,$
        -0.1055742087143175d,$
        -0.0620359639693546d,$
         0.4379916262173834d,$
         0.7742896037334738d,$
         0.4215662067346898d,$
        -0.0520431631816557d,$
        -0.0919200105692549d,$
         0.0281680289738655d,$
         0.0234081567882734d,$
        -0.0101311175209033d,$
        -0.0041593587818186d,$
         0.0021782363583355d,$
         0.0003585896879330d,$
        -0.0002120808398259d]
    ELSE: coeff = -1
    ENDCASE
    RETURN,coeff
END


;----------------------------------------------------------------
FUNCTION wv_fn_coiflet,order,scaling,wavelet,ioff,joff

    COMPILE_OPT strictarr
    ON_ERROR,2  ; return to caller

;defaults
    order_range = [1,5,1]  ; [first,last,default]
    IF (N_ELEMENTS(order) LT 1) THEN order = order_range[2]  ; default

; check for invalid Order
    order = FIX(order + 1E-5)
    IF ((order LT order_range[0]) OR (order GT order_range[1])) THEN BEGIN
        MESSAGE,/INFO,'Order out of range, reverting to default...'
        order = order_range[2]  ; default
    ENDIF

; Regularity = # of continuous derivatives
; orders from Taswell (1998) p. 36 "DROLA"
    regularity = [0d,0.550d,1.088d, $ ; order 0-3
        1.403d,1.776d,2.122d,2.468d]     ; 4-7
    regularity = regularity[FIX(order)]

; construct Info structure
    info = {family:'Coiflet', $
        order_name:'Order', $
        order_range:order_range, $
        order:order, $
        discrete:1, $
        orthogonal:1, $
        symmetric:2, $
        support:FIX(order*6-1), $
        moments:FIX(order*2), $
        regularity:regularity}

    IF (N_PARAMS() LT 1) THEN RETURN, info ; don't bother with rest

; find scaling coefficients
    scaling = WV_FN_COIFLET_COEFF(order)

; construct wavelet coefficients & offsets
    n = N_ELEMENTS(scaling)
    wavelet = REVERSE(scaling)*((-1)^LINDGEN(n))
    ioff = -n/2 + 2  ; offset for scaling
    joff = ioff     ; offset for wavelet

    RETURN, info
END

