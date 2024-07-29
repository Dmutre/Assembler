@echo off
ml /c /coff "7-14-IM-21-Lesko.asm"
ml /c /coff "7-14-IM-21-Lesko-thirdpart.asm"
link /subsystem:WINDOWS "7-14-IM-21-Lesko.obj" "7-14-IM-21-Lesko-thirdpart.obj"
7-14-IM-21-Lesko.exe