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
  wrong_password_msg db "Пароль неправильний", 10, 13, 0
  correct_password_msg db "Відкритті дані", 0
  incorrect_password_msgbox_title db "Неправильно введені дані", 0
  password db "ZOXOGEMK", 0
  key db "*"
  password_length dw 8
  student_information db "Персональна інформація студента:", 13, 10, 
      "ПІБ‘: Лесько Дмитро Миколайович", 13, 10, 
      "Дата народження: 08.02.2005", 13, 10, 
      "Номер студентського квитка: KB13879076", 0

.code

call_correct_msg_window proc
    invoke MessageBox, 0, addr student_information, addr correct_password_msg, 0
    invoke ExitProcess, NULL
    ret
call_correct_msg_window endp

call_incorrect_msg_window proc
    invoke MessageBox, 0, addr wrong_password_msg, addr incorrect_password_msgbox_title, 0
    invoke ExitProcess, NULL
    ret
call_incorrect_msg_window endp

encrypt_password proc
    mov esi, offset password_buffer   
    xor ecx, ecx                     
    mov edx, offset key               
encrypt_loop:
    mov al, [esi + ecx]               
    xor al, byte ptr [edx]            
    mov [esi + ecx], al              
    inc ecx                       
    cmp byte ptr [esi + ecx], 0       
    jne encrypt_loop                
    ret
encrypt_password endp

password_validation proc
    call encrypt_password            
    invoke lstrcmp, addr password_buffer, addr password
    .if eax == 0
        call call_correct_msg_window
    .else
        call call_incorrect_msg_window
    .endif
    ret
password_validation endp

dialogWindow proc hWindow: dword, message: dword, wParam: dword, lParam: dword	
    .if message == WM_COMMAND
      .if wParam == 1
	   	invoke GetDlgItemText, hWindow, 1000, addr password_buffer, 512
		call password_validation
      .endif	   
      .if wParam == 2
		invoke ExitProcess, NULL
      .endif
    .elseif message == WM_CLOSE
       invoke ExitProcess, NULL
    .endif
    return 0 
dialogWindow endp

programThirdLab:
	Dialog "Лаб3 Леська Дмитра з ІМ-21", "MS Arial", 12, \            							    
        WS_OVERLAPPED or WS_SYSMENU or DS_CENTER, 4, 7, 7, 300, 150, 1024                 							      
		DlgStatic "Введіть пароль", SS_CENTER, 120, 10, 60, 10, 100	
		DlgEdit WS_BORDER, 90, 30, 120, 30, 1000		
		DlgButton "Підтвердити", WS_TABSTOP, 70, 90, 50, 15, 1 				
		DlgButton "Відмінити", WS_TABSTOP, 170, 90, 50, 15, 2 	

	CallModalDialog 0, 0, dialogWindow, NULL
end programThirdLab