call_msg_window MACRO title:REQ, msg:REQ ; Macrose: displaying message and title
    invoke MessageBox, 0, addr msg, addr title, 0 ; invoke messagebox and display window
    invoke EndDialog, NULL, 0 ;; HIDDEN: Ending dialog
ENDM

encrypt_password MACRO ; Macrose: encrypt inputed password
    mov esi, offset password_buffer   
    xor ecx, ecx                     
    mov edx, offset key               
encrypt_loop:
    mov al, [esi + ecx]               
    xor al, byte ptr [edx + ecx] ;; HIDDEN: XORing password
    mov [esi + ecx], al              
    inc ecx                       
    cmp byte ptr [esi + ecx], 0       
    jne encrypt_loop                
ENDM


password_validation MACRO ; Macros: Validate password and show needed window
    ; Comment: Start of the programm
    encrypt_password            
    invoke lstrcmp, addr password_buffer, addr password ; Comment: Compare passwords
    .if eax == 0 ;; HIDDEN: correct password data
        jmp correct_password
    .else   ;; HIDDEN: incorrect password data
        jmp incorrect_password
    .endif

    correct_password: ; Inctruction sequence to display correct information
        call_msg_window correct_password_msgbox_title, student_name
        call_msg_window correct_password_msgbox_title, student_birthday
        call_msg_window correct_password_msgbox_title, student_book
        invoke ExitProcess, NULL

    incorrect_password: ;; HIDDEN: Instructino sequence to display incorrect informatino
        call_msg_window incorrect_password_msgbox_title, wrong_password_msg
        invoke ExitProcess, NULL

ENDM
