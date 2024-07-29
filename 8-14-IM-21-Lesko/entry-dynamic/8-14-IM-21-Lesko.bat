\masm32\bin\ml /c /coff "8-14-IM-21-Lesko-dll.asm"
link /out:"8-14-IM-21-Lesko-dll.dll" /export:defining /dll "8-14-IM-21-Lesko-dll.obj"
\masm32\bin\ml /c /coff "8-14-IM-21-Lesko.asm"
link /subsystem:windows "8-14-IM-21-Lesko.obj"	
8-14-IM-21-Lesko.exe