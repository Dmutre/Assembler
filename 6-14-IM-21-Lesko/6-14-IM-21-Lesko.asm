.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\macros\macros.asm
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\user32.inc
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data?
    equationBuffer dd 512 dup(?)
    answer dq 8 dup(?)
    
    divider dt 1 dup(?) 
    shared dt 1 dup(?)      

    Acurrent db 32 dup(?)
    Bcurrent db 32 dup(?)
    Ccurrent db 32 dup(?)
    Dcurrent db 32 dup(?)
    result db 64 dup(?)

.data
    zero_cause_msg_box_title db "Виникла помилка", 0
    msg_box_title db "( 4 * lg(c) - b/2 + 23)/(d - a + 1)", 0
    zero_cause_output_msg_box db "Під час розрахунків виникло ділення на нуль", 10, 13,
        "формула з підставленими значеннями: ", 10, 13,
        "(4 * lg(%s) - %s/2 + 23) / (%s - %s + 1)", 10, 13,
        "Результат обчислень не відомий, адже на нуль ділити не можна.", 10, 13,
        "Наші параметри: а = %s, b = %s, c = %s, d = %s", 10, 13,
        "Можлива помилка: у нашому рівнянні ми ділимо на змінну тільки в одному місці: ( d - a + 1). Раджу перевірити це місце", 0
    default_output_msg db "Розрахунки пройшли успішно", 10, 13,
        "формула з підставленими значеннями: ", 10, 13,
        "(4 * lg(%s) - %s/2 + 23) / (%s - %s + 1)", 10, 13,
        "Результат: %s ", 10, 13,
        "Наші параметри: а = %s, b = %s, c = %s, d = %s", 0
    c_less_than_zero_msg db "Невалідні вхідні параметри!!!", 10, 13,
        "(4 * lg(%s) - %s/2 + 23) / (%s - %s + 1)", 10, 13,
        "Параметр с не може бути меншим 0!!!", 10, 13,
        "Наші параметри: а = %s, b = %s, c = %s, d = %s", 10, 13,
        "Введіть правильні параметри", 0

    Avalue dq 4.2, 8.1, -1.9, 7.6, 9.8, 55.4
    Bvalue dq -20.4, 12.6, 16.8, 2.2, -1.8, 15.88
    Cvalue dq 2.3, -0.6, 6.5, 9.9, 33.3, 6.1
    Dvalue dq 1.2, -0.5, 0.9, 11.4, 8.8, 3.3
    arraySize equ ($ - Avalue) / 32

    twentyThree dq 23.0
    ten dq 10.0
    four dq 4.0
    two dq 2.0
    one dq 1.0
    zero dq 0.0

.code

call_msg_window MACRO title:REQ, msg:REQ
    invoke MessageBox, 0, addr msg, addr title, 0
ENDM

count_divider MACRO index:REQ
    ; Calculate the denominator (d - a + 1)
    fld [Avalue + index * 8] ; a
    fld [Dvalue + index * 8] ; d
    fsub st(0), st(1) ; d - a
    fld one
    fxch st(1)   
    fadd st(0), st(1) ; (d - a) + 1                       
    fstp divider                          
ENDM

count_shared MACRO index:REQ
    ; Load values from memory into FPU stack
    fld [one]
    fld qword ptr [Cvalue + index * 8]    ; Load c
    fyl2x                                 ; Calculate logarithm base 2 of c: log2(c)   
    fldl2t                                ; log2(10)    
    fdiv                                  ; Divide log2(c) by log2(10): log2(c) / log2(10) = lg(c)
    fld qword ptr [four]                  ; Load 4
    fmul                                  ; Multiply: 4 * log10(c)
    fld qword ptr [twentyThree]           ; Load 23
    fadd                                  ; Add 23: 4 * log10(c) + 23
    fld qword ptr [Bvalue + index * 8]    ; Load b
    fld qword ptr [two]                   ; Load 2
    fdiv                                  ; Divide b by 2: b / 2
    fsub                                  ; Subtract b / 2 from 4 * log10(c) + 23
    fstp shared                           ; Store the result in shared
ENDM

main:
    mov esi, 0  

valueLoop:
    cmp esi, arraySize
    jge endLoop

    finit

    invoke FloatToStr2, [Avalue + esi * 8], addr Acurrent
    invoke FloatToStr2, [Bvalue + esi * 8], addr Bcurrent
    invoke FloatToStr2, [Cvalue + esi * 8], addr Ccurrent
    invoke FloatToStr2, [Dvalue + esi * 8], addr Dcurrent

    fld qword ptr [Cvalue + esi * 8] ; Load the current value of C
    fldz                              ; Load 0
    fcom                               ; Compare C with 0
    fstsw ax                          ; Store the FPU status word in AX
    sahf                              ; Set the flags in EFLAGS register

    ; Test if the C0 (greater than) flag is set
    test ah, 00000001b               ; Check if bit 0 (C0 flag) is set
    jnz continueWithCode             ; If the C0 flag is set, jump to continueWithCode

    ; If C is less than or equal to 0, jump to errorNegativeC
    jmp errorNegativeC

    continueWithCode:

    count_divider esi    ; Calculate the denominator
    count_shared esi     ; Calculate the numerator

    fld qword ptr [divider]   ; Load the divider value
    ftst                      ; Compare the divider value with 0
    fnstsw ax                 ; Store the FPU status word in AX
    sahf                      ; Set the flags in EFLAGS register

    test ah, 01000000b       ; Check if bit 7 (C3 flag) is set
    jnz zeroDenominatorError ; If the C3 flag is not set, jump to error handling


    ; Perform the division and store the result
    fld shared
    fld divider
    fdiv
    fstp answer

    ; Format the output message
    invoke FloatToStr2, answer, addr result
    invoke wsprintf, addr equationBuffer, addr default_output_msg, 
        addr Ccurrent, addr Bcurrent, addr Dcurrent, addr Acurrent,
        addr result,
        addr Acurrent, addr Bcurrent, addr Ccurrent, addr Dcurrent

    
    call_msg_window msg_box_title, equationBuffer

    jmp loopEnd
    
    errorNegativeC:
    ; Display error message for C, when it is lower than 0
    invoke wsprintf, addr equationBuffer, addr c_less_than_zero_msg, 
        addr Ccurrent, addr Bcurrent, addr Dcurrent, addr Acurrent,
        addr Acurrent, addr Bcurrent, addr Ccurrent, addr Dcurrent

    call_msg_window zero_cause_msg_box_title, equationBuffer

    jmp loopEnd

    zeroDenominatorError:
    ; Display error message for division by zero
    invoke wsprintf, addr equationBuffer, addr zero_cause_output_msg_box, 
        addr Ccurrent, addr Bcurrent, addr Dcurrent, addr Acurrent,
        addr Acurrent, addr Bcurrent, addr Ccurrent, addr Dcurrent

    call_msg_window zero_cause_msg_box_title, equationBuffer

loopEnd:
    add esi, 1
    jmp valueLoop

endLoop:
    invoke ExitProcess, NULL
end main
