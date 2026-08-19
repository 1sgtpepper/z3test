; Six non-division caller families reach round at its first wide-count format;
; other callers retain independent pre-round width restrictions.
(set-logic ALL)
(set-option :model_validate true)

(define-sort FP133 () (_ FloatingPoint 13 3))
(define-fun one-13-3 () FP133 (fp #b0 #b0111111111111 #b00))
(declare-fun x13-3 () FP133)

; Multiplication.
(push 1)
(assert (and
  (fp.eq x13-3 one-13-3)
  (not (= (fp.mul RNE x13-3 x13-3) one-13-3))))
(check-sat)
(pop 1)

; Square root.
(push 1)
(assert (and
  (fp.eq x13-3 one-13-3)
  (not (= (fp.sqrt RNE x13-3) one-13-3))))
(check-sat)
(pop 1)

; Conversion from a different floating-point sort.
(declare-fun x14-3 () (_ FloatingPoint 14 3))
(push 1)
(assert (and
  (fp.eq x14-3 (fp #b0 #b01111111111111 #b00))
  (not (= ((_ to_fp 13 3) RNE x14-3) one-13-3))))
(check-sat)
(pop 1)

; Conversion from a symbolic Real keeps the non-numeral path reachable.
(push 1)
(declare-fun real-one () Real)
(assert (and (<= real-one 1.0) (>= real-one 1.0)))
(assert (not (= ((_ to_fp 13 3) RNE real-one) one-13-3)))
(check-sat)
(pop 1)

; Signed and unsigned BV sources are wide enough to reach round.
(declare-fun sbv-one () (_ BitVec 15))
(push 1)
(assert (and
  (bvsle sbv-one (_ bv1 15))
  (bvsge sbv-one (_ bv1 15))
  (not (= ((_ to_fp 13 3) RNE sbv-one) one-13-3))))
(check-sat)
(pop 1)
(declare-fun ubv-one () (_ BitVec 15))
(push 1)
(assert (and
  (bvule ubv-one (_ bv1 15))
  (bvuge ubv-one (_ bv1 15))
  (not (= ((_ to_fp_unsigned 13 3) RNE ubv-one) one-13-3))))
(check-sat)
(pop 1)

; At FP(16,3), the shift-count operand is narrower than round's exponent.
; half*half exercises a nonzero left normalization count.
(define-sort FP163 () (_ FloatingPoint 16 3))
(define-fun half-16-3 () FP163 (fp #b0 #b0111111111111110 #b00))
(define-fun quarter-16-3 () FP163 (fp #b0 #b0111111111111101 #b00))
(define-fun min-sub-16-3 () FP163 (fp #b0 #b0000000000000000 #b01))
(declare-fun x16-3 () FP163)
(push 1)
(assert (and
  (fp.eq x16-3 half-16-3)
  (not (= (fp.mul RNE x16-3 x16-3) quarter-16-3))))
(check-sat)
(pop 1)

; min-subnormal * min-subnormal forces the capped right-shift path.
(push 1)
(assert (and
  (fp.eq x16-3 min-sub-16-3)
  (not (= (fp.mul RNE x16-3 x16-3) (_ +zero 16 3)))))
(check-sat)
(pop 1)

; FP(2,16)'s sbits+2 cap does not fit round's four-bit exponent count.
; Converting an exact 2^-6 requires a five-bit right shift, so truncating that
; cap to four bits changes the result.
(declare-fun x8-24 () (_ FloatingPoint 8 24))
(push 1)
(assert (and
  (fp.eq x8-24 (fp #b0 #b01111001 (_ bv0 23)))
  (not (=
    ((_ to_fp 2 16) RNE x8-24)
    (fp #b0 #b00 (_ bv512 15))))))
(check-sat)
(pop 1)

; Fitting-width control preserves the legacy round branch.
(declare-fun x12-3 () (_ FloatingPoint 12 3))
(push 1)
(assert (and
  (fp.eq x12-3 (fp #b0 #b011111111111 #b00))
  (not (=
    (fp.mul RNE x12-3 x12-3)
    (fp #b0 #b011111111111 #b00)))))
(check-sat)
(pop 1)
