.386
.model flat, stdcall
option casemap :none

public count_divider
extern Avalue:qword, Dvalue:qword, one:qword

.code
  count_divider proc
      ; Calculate the denominator (d - a + 1)
      fld [Avalue + esi * 8] ; a
      fld [Dvalue + esi * 8] ; d
      fsub st(0), st(1) ; d - a
      fld one
      fxch st(1)   
      fadd st(0), st(1) ; (d - a) + 1                       
      ret                       
  count_divider endp
end