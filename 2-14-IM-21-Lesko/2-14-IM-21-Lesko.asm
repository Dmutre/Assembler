.386
.model flat, stdcall
option casemap :none
include \masm32\include\masm32rt.inc
include \masm32\include\Fpu.inc
includelib \masm32\lib\Fpu.lib


.data?
    textBoxBuffer db 256 dup(?)
    positiveBufferD db 128 dup(?)
    positiveBufferE db 128 dup(?)
    positiveBufferF db 128 dup(?)
    negativeBufferD db 128 dup(?)
    negativeBufferE db 128 dup(?)
    negativeBufferF db 128 dup(?)
 
.data
    messageBoxTitle db "Lab 2 Lesko Dmytro IM-21", 0
    messageBoxContent db "My birthday: %s", 0Ah, "Student book number: %s", 0Ah, "Numbers:",0Ah, "A = %d", 0Ah, "-A = %d", 0Ah, "B = %d", 0Ah, "-B = %d", 0Ah, 
    "C = %d", 0Ah, "-C = %d", 0Ah, "D = %s", 0Ah, "-D = %s", 0Ah, "E = %s", 0Ah, "-E = %s", 0Ah, "F = %s", 0Ah, "-F = %s", 0


    myBirthday db "08.02.2005", 0

    studentBookNumber db "9076", 0

    positiveByteA db 8
    positiveWordA dw 8
    positiveShortIntA dd 8
    positiveLongIntA dq 8

    negativeByteA db -8
    negativeWordA dw -8
    negativeShortIntA dd -8
    negativeLongIntA dq -8

    positiveWordB dw 802
    positiveShortIntB dd 802
    positiveLongIntB dq 802

    negativeWordB dw -802
    negativeShortIntB dd -802
    negativeLongIntB dq -802

    positiveShortIntC dd 8022005
    positiveLongIntC dq 8022005

    negativeShortIntC dd -8022005
    negativeLongIntC dq -8022005

    positiveSingleD dd 0.001
    negativeSingleD dd -0.001

    positiveDoubleD dq 0.001
    negativeDoubleD dq -0.001

    positiveDoubleE dq 0.088
    negativeDoubleE dq -0.088
    
    positiveDoubleF dq 833.87
    negativeDoubleF dq -833.87

    positiveExtendedF dt 833.87
    negativeExtendedF dt -833.87

.code
lab2Main:
    fld positiveDoubleE
    invoke FpuFLtoA, 0, 3, addr positiveBufferE, SRC1_FPU or SRC2_DIMM
    fld negativeDoubleE
    invoke FpuFLtoA, 0, 3, addr negativeBufferE, SRC1_FPU or SRC2_DIMM
    
    invoke FloatToStr2, positiveDoubleD, addr positiveBufferD
    invoke FloatToStr2, positiveDoubleF, addr positiveBufferF
    invoke FloatToStr2, negativeDoubleD, addr negativeBufferD
    invoke FloatToStr2, negativeDoubleF, addr negativeBufferF

    invoke wsprintf, addr textBoxBuffer, addr messageBoxContent, addr myBirthday, addr studentBookNumber, 
        positiveShortIntA, negativeShortIntA, 
        positiveShortIntB, negativeShortIntB, 
        positiveShortIntC, negativeShortIntC, 
        addr positiveBufferD, addr negativeBufferD, 
        addr positiveBufferE, addr negativeBufferE, 
        addr positiveBufferF, addr negativeBufferF

    invoke MessageBox, 0, addr textBoxBuffer, addr messageBoxTitle, 0

       invoke ExitProcess, 0
end lab2Main