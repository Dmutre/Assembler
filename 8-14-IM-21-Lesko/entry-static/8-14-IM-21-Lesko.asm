.386
.model flat, stdcall
option casemap: none

include \masm32\include\masm32rt.inc
; Needed functions: MessageBox, FloatToStr2, wsprintf, ExitProcess

includelib 8-14-IM-21-Lesko-dll.lib
defining proto :ptr qword, :ptr qword, :ptr qword, :ptr qword, 
	:ptr qword, :ptr qword, :ptr qword, :ptr qword,
	:ptr tbyte, :ptr tbyte, :ptr qword

.data 
  zero_cause_msg_box_title db "Error has appeared", 0
  msg_box_title db "Entry static ( 4 * lg(c) - b/2 + 23)/(d - a + 1)", 0
  zero_cause_output_msg_box db "Zero appeared into the divider", 10, 13,
      "Our formula with inputed values: ", 10, 13,
      "(4 * lg(%s) - %s/2 + 23) / (%s - %s + 1)", 10, 13,
      "The output of our calculation is undefined, because we can`t divide on zero", 10, 13,
      "Our values: a = %s, b = %s, c = %s, d = %s", 10, 13,
      "Probably the erro is there: ( d - a + 1). It is the only one place where it can appear", 0
  default_output_msg db "Successfuly calculated", 10, 13,
      "Our formula with inputed values: ", 10, 13,
      "(4 * lg(%s) - %s/2 + 23) / (%s - %s + 1)", 10, 13,
      "Result: %s ", 10, 13,
      "Our values: a = %s, b = %s, c = %s, d = %s", 0
  c_less_than_zero_msg db "Invalid input values!!!", 10, 13,
      "(4 * lg(%s) - %s/2 + 23) / (%s - %s + 1)", 10, 13,
      "C value can`t be lower than 0!!!", 10, 13,
      "Our values: a = %s, b = %s, c = %s, d = %s", 10, 13,
      "Input correct params", 0

  debug_message db "Message is there: %s", 0
  procedure db "defining", 0

  Avalue dq 4.2, 8.1, -1.9, 7.6, 9.8, 55.4
  Bvalue dq -20.4, 12.6, 16.8, 2.2, -1.8, 15.88
  Cvalue dq 2.3, -0.6, 6.5, 9.9, 33.3, 6.1
  Dvalue dq 1.2, -0.5, 0.9, 11.4, 8.8, 3.3
  arraySize equ ($ - Avalue) / 32

  twentyThree dq 23.0
  ten dq 10.0
  four dq 4.0
  minus_two dq -2.0
  two dq 2.0
  one dq 1.0
  zero dq 0.0

.data?
  equationBuffer dd 512 dup(?)
  answer dq 8 dup(?)
  fix_buffer dq 8 dup(?) ; buffer user for debugging the program and tracking the numbers

  divider dt 1 dup(?) 
  shared dt 1 dup(?)    

  Acurrent db 32 dup(?)
  Bcurrent db 32 dup(?)
  Ccurrent db 32 dup(?)
  Dcurrent db 32 dup(?)
  result db 64 dup(?)

.code 

call_msg_window MACRO title:REQ, msg:REQ
    invoke MessageBox, 0, addr msg, addr title, 0
ENDM

main:
  mov esi, 0
  valueLoop:
    cmp esi, arraySize
    jge endLoop

    finit


    invoke FloatToStr2, [Avalue + esi * 8], addr Acurrent
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

    fld [Avalue + esi * 8] ; a
    fld [Dvalue + esi * 8] ; d
    fsub st(0), st(1) ; d - a
    fld one
    fxch st(1)   
    fadd st(0), st(1) ; (d - a) + 1  
    fstp divider 

    fld qword ptr [divider]   ; Load the divider value
    ftst                      ; Compare the divider value with 0
    fnstsw ax                 ; Store the FPU status word in AX
    sahf                      ; Set the flags in EFLAGS register

    test ah, 01000000b       ; Check if bit 7 (C3 flag) is set
    jnz zeroDenominatorError ; If the C3 flag is not set, jump to error handling

    invoke defining, addr Avalue[esi*8], addr Bvalue[esi*8], addr Cvalue[esi*8], addr Dvalue[esi*8],
    addr one, addr twentyThree, addr two, addr four, addr shared, addr divider, addr answer

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
