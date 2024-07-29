.386
.model flat, stdcall
option casemap :none

include \masm32\include\windows.inc
include \masm32\include\dialogs.inc
include \masm32\macros\macros.asm
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data?
    password_buffer db 32 dup (?)
.data
  wrong_password_msg db "Неправильний пароль", 10, 13, 0
  correct_password_msgbox_title db "Персональні дані студента", 0
  incorrect_password_msgbox_title db "Помилка", 0
  password db "74>5=*RU", 0
  key db "GQLPPE54"
  student_name db "ПІБ‘: Лесько Дмитро Миколайович", 0 ;; Comment: separated student info on three variable to display it separately
  student_birthday db "Дата народження: 08.02.2005", 0
  student_book db "Номер студентського квитка: KB13879076", 0
.code

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

dialogWindow proc hWindow: dword, message: dword, wParam: dword, lParam: dword	
    .if message == WM_COMMAND
      .if wParam == 1
	   	invoke GetDlgItemText, hWindow, 1000, addr password_buffer, 512
		password_validation
      .endif	   
      .if wParam == 2
		invoke ExitProcess, NULL
      .endif
    .elseif message == WM_CLOSE
       invoke ExitProcess, NULL
    .endif
    return 0 
dialogWindow endp

main:
	Dialog "Лаб4 Леська Дмитра з ІМ-21", "MS Arial", 12, \            							    
        WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, 4, 7, 7, 300, 150, 1024                 							      
		DlgStatic "Введіть пароль", SS_CENTER, 120, 10, 60, 10, 100	
		DlgEdit WS_BORDER, 90, 30, 120, 30, 1000		
		DlgButton "Підтвердити", WS_TABSTOP, 70, 90, 50, 15, 1 				
		DlgButton "Відмінити", WS_TABSTOP, 170, 90, 50, 15, 2 	

	CallModalDialog 0, 0, dialogWindow, NULL
end main