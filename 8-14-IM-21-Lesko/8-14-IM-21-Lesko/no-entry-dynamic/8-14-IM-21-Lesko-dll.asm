.386
.model flat, stdcall
option casemap :none

.code

defining proc Avalue: ptr qword, Bvalue: ptr qword, Cvalue: ptr qword, Dvalue: ptr qword,
one: ptr qword, twentyThree: ptr qword, two: ptr qword, four: ptr qword, shared: ptr tbyte, divider: ptr tbyte, answer: ptr qword
    finit

    mov ecx, Avalue  ; define divider
    fld qword ptr [ecx] ; a
    mov ecx, Dvalue
    fld qword ptr [ecx] ; d
    fsub st(0), st(1) ; d - a
    mov ecx, one
    fld qword ptr [ecx] ; 1
    fxch st(1)   
    fadd st(0), st(1) ; (d - a) + 1       
    mov ecx, divider                
    fstp tbyte ptr [ecx]

    mov ecx, one  ; define shared
    fld qword ptr [ecx]
    mov ecx, Cvalue  ; c
    fld qword ptr [ecx]
    fyl2x                                 ; Calculate logarithm base 2 of c: log2(c)   
    fldl2t                                ; log2(10)    
    fdiv                                  ; Divide log2(c) by log2(10): log2(c) / log2(10) = lg(c)
    mov ecx, four  ; 4
    fld qword ptr [ecx]
    fmul                                  ; Multiply: 4 * log10(c)
    mov ecx, twentyThree  ; 23
    fld qword ptr [ecx]
    fadd                                  ; Add 23: 4 * log10(c) + 23
    mov ecx, Bvalue  ; b
    fld qword ptr [ecx]
    mov ecx, two  ; 2
    fld qword ptr [ecx]
    fdiv                                  ; Divide b by 2: b / 2
    fsub                                  ; Subtract b / 2 from 4 * log10(c) + 23
    mov ecx, shared
    fstp tbyte ptr [ecx] ;; save shared

    mov ecx, shared ; define our answer of this calculation
    fld tbyte ptr [ecx] ; shared (top)
    mov ecx, divider
    fld tbyte ptr [ecx] ; divider (bottom)
    fdivp st(1), st(0) ;shared / divider
    mov ecx, answer
    fstp qword ptr [ecx]

  ret 40
defining endp
end