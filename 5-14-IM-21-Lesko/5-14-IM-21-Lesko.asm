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
    answer dd 8 dup(?)
    divider dd 1 dup(?)
    shared dd 1 dup(?)
.data
    zero_cause_msg_box_title db "Виникла помилка", 0
    msg_box_title db "(-15*a + b - a/4)/(b*a -1)", 0
    zero_cause_output_msg_box db "Під час розрахунків виникло ділення на нуль", 10, 13,
        "формула з підставленими значеннями: ", 10, 13,
        "(-15 * %i + %i - %i / 4)/( %i * %i - 1)", 10, 13,
        "Результат обчислень не відомий, адже на нуль ділити не можна.", 10, 13,
        "Наші параметри: а = %i, b = %i", 10, 13,
        "Можлива помилка: у нашому рівнянні ми ділимо на змінну тільки в одному місці: ( a*b - 1). Раджу перевірити це місце", 0
    default_output_msg db "Розрахунки пройшли успішно", 10, 13,
        "формула з підставленими значеннями: ", 10, 13,
        "(-15 * %i + %i - %i / 4)/( %i * %i - 1)", 10, 13,
        "Результат: %i ", 10, 13,
        "Наші параметри: а = %i, b = %i", 10, 13,
        "Змінений результат: %i", 0
    Avalue dd 4, 8, -20, 8, -1, 56
    Bvalue dd -20, 122, 16, 2, -1, 15
    arraySize equ ($ - Avalue) / 8
    
.code

call_msg_window MACRO title:REQ, msg:REQ ; Macrose: displaying message and title
    invoke MessageBox, 0, addr msg, addr title, 0 ; invoke messagebox and display window
ENDM


count_divider MACRO index:REQ
    mov eax, DWORD PTR [Avalue + index * 4] ; a
    mov ebx, DWORD PTR [Bvalue + index * 4] ; b
    imul ebx, eax ; a * b
    sub ebx, 1 ; a * b - 1
    mov divider, ebx
ENDM

count_shared MACRO index:REQ
    mov eax, DWORD PTR [Avalue + index * 4] ; a
    mov ebx, DWORD PTR [Bvalue + index * 4] ; b
    mov edx, -15 ; 15
    imul edx, eax ; -15 * a
    add edx, ebx ; -15*a + b
    mov ecx, eax ; 
    sar ecx, 2 ; a/4 (зберігає знак)
    sub edx, ecx ; -15*a + b - a/4
    mov shared, edx
ENDM

main:

    mov esi, 0  
    mov ecx, arraySize 
    cld

    valueLoop:
    count_divider esi
    count_shared esi


    .if divider == 0
        invoke wsprintf, addr equationBuffer, addr zero_cause_output_msg_box, 
        [Avalue + esi * 4], [Bvalue + esi * 4], [Avalue + esi * 4], [Bvalue + esi * 4], [Avalue + esi * 4],
        [Avalue + esi * 4], [Bvalue + esi * 4]
        
        call_msg_window msg_box_title, equationBuffer

        jmp loopEnd
    .endif
    
    mov eax, shared
    mov ebx, divider
    cdq
    idiv ebx ; (-15*a + b - a/4)/(b*a -1)
    mov answer, eax ; save our real result

    test eax, 1
    jnz oddNumber
    jz evenNumber

    oddNumber:
        mov ecx, 5
        imul eax, ecx ; answer * 5
        jmp endCalculation

    evenNumber:
        sar eax, 1 ; answer / 2

    endCalculation:
        invoke wsprintf, addr equationBuffer, addr default_output_msg, 
        [Avalue + esi * 4], [Bvalue + esi * 4], [Avalue + esi * 4], [Bvalue + esi * 4], [Avalue + esi * 4],
        answer,
        [Avalue + esi * 4], [Bvalue + esi * 4],
        eax
        call_msg_window msg_box_title, equationBuffer

    loopEnd:
        add esi, 1
        cmp esi, arraySize
        jl valueLoop

    invoke ExitProcess, NULL
end main