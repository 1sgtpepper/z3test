; Division coverage when a significand's leading-zero count exceeds ebits.
(set-logic QF_FP)
(set-option :model_validate true)

; FP(2,8) crosses both ends of round's established exponent range.
(define-sort FP28 () (_ FloatingPoint 2 8))
(define-fun bad-div-28 ((rm RoundingMode) (x FP28) (y FP28) (want FP28)) Bool
  (not (= (fp.div rm x y) want)))
(define-fun bad-all-modes-28
  ((x FP28) (y FP28) (rne FP28) (rna FP28) (rtp FP28) (rtn FP28) (rtz FP28)) Bool
  (or
    (bad-div-28 RNE x y rne)
    (bad-div-28 RNA x y rna)
    (bad-div-28 RTP x y rtp)
    (bad-div-28 RTN x y rtn)
    (bad-div-28 RTZ x y rtz)))
(define-fun p-min-sub-28 () FP28 (fp #b0 #b00 #b0000001))
(define-fun p-max-28 () FP28 (fp #b0 #b10 #b1111111))

; Deep positive underflow distinguishes the directed modes.
(declare-fun numerator-28 () FP28)
(push 1)
(assert (and
  (fp.eq numerator-28 p-min-sub-28)
  (bad-all-modes-28 numerator-28 p-max-28
    (_ +zero 2 8) (_ +zero 2 8) p-min-sub-28
    (_ +zero 2 8) (_ +zero 2 8))))
(check-sat)
(pop 1)

; Wide positive overflow preserves the usual infinity/max-finite choices.
(declare-fun denominator-28 () FP28)
(push 1)
(assert (and
  (fp.eq denominator-28 p-min-sub-28)
  (bad-all-modes-28 p-max-28 denominator-28
    (_ +oo 2 8) (_ +oo 2 8) (_ +oo 2 8) p-max-28 p-max-28)))
(check-sat)
(pop 1)

; FP(2,16) grows the exact exponent workspace and has an unrepresentable
; sbits+2 shift cap in round's four-bit exponent count.
(define-sort FP216 () (_ FloatingPoint 2 16))
(define-fun bad-div-216 ((rm RoundingMode) (x FP216) (y FP216) (want FP216)) Bool
  (not (= (fp.div rm x y) want)))
(define-fun bad-all-modes-216
  ((x FP216) (y FP216) (rne FP216) (rna FP216) (rtp FP216) (rtn FP216) (rtz FP216)) Bool
  (or
    (bad-div-216 RNE x y rne)
    (bad-div-216 RNA x y rna)
    (bad-div-216 RTP x y rtp)
    (bad-div-216 RTN x y rtn)
    (bad-div-216 RTZ x y rtz)))
(define-fun p-min-sub-216 () FP216 (fp #b0 #b00 #b000000000000001))
(define-fun n-min-sub-216 () FP216 (fp #b1 #b00 #b000000000000001))
(define-fun p-two-216 () FP216 (fp #b0 #b10 #b000000000000000))

; This exact quotient requires a six-position right shift.
(declare-fun numerator-cap-216 () FP216)
(push 1)
(assert (and
  (fp.eq numerator-cap-216 (fp #b0 #b00 #b000000010000000))
  (not (fp.eq
    (fp.div RNE numerator-cap-216 (fp #b0 #b00 #b100000000000000))
    (fp #b0 #b00 #b000000100000000)))))
(check-sat)
(pop 1)

; Half-min-subnormal ties cover every rounding mode and both signs.
(declare-fun numerator-pos-216 () FP216)
(push 1)
(assert (and
  (fp.eq numerator-pos-216 p-min-sub-216)
  (bad-all-modes-216 numerator-pos-216 p-two-216
    (_ +zero 2 16) p-min-sub-216 p-min-sub-216
    (_ +zero 2 16) (_ +zero 2 16))))
(check-sat)
(pop 1)
(declare-fun numerator-neg-216 () FP216)
(push 1)
(assert (and
  (fp.eq numerator-neg-216 n-min-sub-216)
  (bad-all-modes-216 numerator-neg-216 p-two-216
    (_ -zero 2 16) n-min-sub-216 (_ -zero 2 16)
    n-min-sub-216 (_ -zero 2 16))))
(check-sat)
(pop 1)
