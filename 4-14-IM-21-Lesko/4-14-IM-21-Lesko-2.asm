.386
.model flat, stdcall
option casemap :none

include 4-14-IM-21-Lesko.inc

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