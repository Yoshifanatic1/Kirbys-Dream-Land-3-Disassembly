@echo off
setlocal EnableDelayedExpansion

set PATH="../../Global"

asar.exe ExtractOAMData.asm KDL3.sfc > output1.asm

pause

asar.exe output1.asm KDL3.sfc > TableData1.asm

pause
exit