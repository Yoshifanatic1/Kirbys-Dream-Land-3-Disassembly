@echo off

set PATH="../../Global"
set Input1=
set ROMName=KDL3.sfc
set MemMap=sa1rom

setlocal EnableDelayedExpansion

echo To fully extract all files for supported ROMs, you'll need one of the following ROMs in each group:
echo - Graphics: Any
echo - Tilemaps: Any
echo - Palettes: Any
echo - Levels: Any
echo - Music: Any
echo - Sound effects: Any
echo - Samples: Any
echo.

:Start
echo Place a headerless KDL3 ROM named %ROMName% in this folder, then type the number representing what version %ROMName% is.
echo 0 = KDL3 (USA)
echo 1 = KDL3 (Japan)

:Mode
set /p Input1=""
if exist %ROMName% goto :ROMExists

echo You need to place a KDL3 ROM named %ROMName% in this folder before you can extract any assets^^!
goto :Mode

:ROMExists
if "%Input1%" equ "0" goto :USA
if "%Input1%" equ "1" goto :Japan

echo %Input1% is not a valid mode.
goto :Mode

:USA
:Japan
set UGFXLoc="../Graphics"
set CGFXLoc="../Graphics/Compressed"
set UTilemapLoc="../Tilemaps"
set CTilemapLoc="../Tilemaps/Compressed"
set PaletteLoc="../Palettes"
set LevelDataLoc="../LevelData"
set MusicLoc="../SPC700/Music"
set SoundEffectsLoc="../SPC700/SoundEffects"
set BRRLoc="../SPC700/Samples"
set UnsortedDatLoc="../UnsortedData"
set ROMBit=$0001
goto :BeginExtract

:BeginExtract
set i=0
set PointerSet=0

echo Generating temporary ROM
asar --fix-checksum=off --no-title-check --define ROMVer="%ROMBit%" "AssetPointersAndFiles.asm" TEMP.sfc

CALL :GetLoopIndex
set MaxFileTypes=%Length%
set PointerSet=6

:GetNewLoopIndex
CALL :GetLoopIndex

:ExtractLoop
if %i% equ %Length% goto :NewFileType

CALL :GetGFXFileName
CALL :ExtractFile
set /a i = %i%+1
if exist TEMP1.asm del TEMP1.asm
if exist TEMP2.asm del TEMP2.asm
if exist TEMP3.txt del TEMP3.txt
goto :ExtractLoop

:NewFileType
echo Moving extracted files to appropriate locations
if %PointerSet% equ 6 goto :MoveUGFX
if %PointerSet% equ 12 goto :MoveCGFX
if %PointerSet% equ 18 goto :MoveUTilemap
if %PointerSet% equ 24 goto :MoveCTilemap
if %PointerSet% equ 30 goto :MovePalette
if %PointerSet% equ 36 goto :MoveLevelData
if %PointerSet% equ 42 goto :MoveMusic
if %PointerSet% equ 48 goto :MoveSounds
if %PointerSet% equ 54 goto :MoveBRR
if %PointerSet% equ 60 goto :MoveUnsortedDat
goto :MoveNothing

:MoveUGFX
CALL :MergeSplitGFX
move "*.bin" %UGFXLoc%
goto :MoveNothing

:MoveCGFX
move "*.bin" %CGFXLoc%
goto :MoveNothing

:MoveUTilemap
move "*.bin" %UTilemapLoc%
goto :MoveNothing

:MoveCTilemap
move "*.bin" %CTilemapLoc%
goto :MoveNothing

:MovePalette
CALL :MergeSplitPalettes
move "*.bin" %PaletteLoc%
goto :MoveNothing

:MoveLevelData
move "*.bin" %LevelDataLoc%
goto :MoveNothing

:MoveMusic
move "*.bin" %MusicLoc%
goto :MoveNothing

:MoveSounds
move "*.bin" %SoundEffectsLoc%
goto :MoveNothing

:MoveBRR
move "*.brr" %BRRLoc%
goto :MoveNothing

:MoveUnsortedDat
move "*.bin" %UnsortedDatLoc%
goto :MoveNothing

:MoveNothing
set i=0
set /a PointerSet = %PointerSet%+6
if %PointerSet% neq %MaxFileTypes% goto :GetNewLoopIndex
if exist TEMP.sfc del TEMP.sfc

echo Done^^!
goto :Start

EXIT /B %ERRORLEVEL% 

:ExtractFile
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:^^!OffsetStart #= snestopc(readfile3("TEMP.sfc", snestopc(readfile3("TEMP.sfc", snestopc($C00000+%PointerSet%))+$00+(%i%*$0C)))) >> TEMP1.asm
echo:^^!OffsetEnd #= snestopc(readfile3("TEMP.sfc", snestopc(readfile3("TEMP.sfc", snestopc($C00000+%PointerSet%))+$03+(%i%*$0C)))) >> TEMP1.asm
echo:incbin %ROMName%:(^^!OffsetStart)-(^^!OffsetEnd) >> TEMP1.asm

echo Extracting %FileName%
asar --fix-checksum=off --no-title-check "TEMP1.asm" %FileName%
EXIT /B 0

:GetGFXFileName
echo:%MemMap% >> TEMP2.asm
echo:org $C00000 >> TEMP2.asm
echo:^^!FileNameStart #= snestopc(readfile3("TEMP.sfc", snestopc(readfile3("TEMP.sfc", snestopc($C00000+%PointerSet%))+$06+(%i%*$0C)))) >> TEMP2.asm
echo:^^!FileNameEnd #= snestopc(readfile3("TEMP.sfc", snestopc(readfile3("TEMP.sfc", snestopc($C00000+%PointerSet%))+$09+(%i%*$0C)))) >> TEMP2.asm
echo:incbin TEMP.sfc:(^^!FileNameStart)-(^^!FileNameEnd) >> TEMP2.asm
asar --fix-checksum=off --no-title-check "TEMP2.asm" TEMP3.txt

for /f "delims=" %%x in (TEMP3.txt) do set FileName=%%x

EXIT /B 0

:GetLoopIndex
echo:%MemMap% >> TEMP4.asm
echo:org $C00000 >> TEMP4.asm
echo:^^!OnesDigit = 0 >> TEMP4.asm
echo:^^!TensDigit = 0 >> TEMP4.asm
echo:^^!HundredsDigit = 0 >> TEMP4.asm
echo:^^!ThousandsDigit = 0 >> TEMP4.asm
echo:^^!TensDigitSet = 0 >> TEMP4.asm
echo:^^!HundredsDigitSet = 0 >> TEMP4.asm
echo:^^!ThousandsDigitSet = 0 >> TEMP4.asm
echo:^^!Offset #= readfile3("TEMP.sfc", snestopc($C00000+%PointerSet%+$03)) >> TEMP4.asm
echo:while ^^!Offset ^> 0 >> TEMP4.asm
::echo:print hex(^^!Offset) >> TEMP4.asm
echo:^^!OnesDigit #= ^^!OnesDigit+1 >> TEMP4.asm
echo:if ^^!OnesDigit == 10 >> TEMP4.asm
echo:^^!OnesDigit #= 0 >> TEMP4.asm
echo:^^!TensDigit #= ^^!TensDigit+1 >> TEMP4.asm
echo:^^!TensDigitSet #= 1 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:if ^^!TensDigit == 10 >> TEMP4.asm
echo:^^!TensDigit #= 0 >> TEMP4.asm
echo:^^!HundredsDigit #= ^^!HundredsDigit+1 >> TEMP4.asm
echo:^^!HundredsDigitSet #= 1 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:if ^^!HundredsDigit == 10 >> TEMP4.asm
echo:^^!HundredsDigit #= 0 >> TEMP4.asm
echo:^^!ThousandsDigit #= ^^!ThousandsDigit+1 >> TEMP4.asm
echo:^^!ThousandsDigitSet #= 1 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:^^!Offset #= ^^!Offset-1 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:if ^^!ThousandsDigitSet == 1 >> TEMP4.asm
echo:db ^^!ThousandsDigit+$30 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:if ^^!HundredsDigitSet == 1 >> TEMP4.asm
echo:db ^^!HundredsDigit+$30 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:if ^^!TensDigitSet == 1 >> TEMP4.asm
echo:db ^^!TensDigit+$30 >> TEMP4.asm
echo:endif >> TEMP4.asm
echo:db ^^!OnesDigit+$30 >> TEMP4.asm
asar --fix-checksum=off --no-title-check "TEMP4.asm" TEMP5.txt

for /f "delims=" %%x in (TEMP5.txt) do set Length=%%x

if exist TEMP4.asm del TEMP4.asm
if exist TEMP5.txt del TEMP5.txt

EXIT /B 0

:MergeSplitGFX
echo:Extracting and merging Kirby's graphics...

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":1EAF20-1EB0C0>> TEMP1.asm
echo:incbin "%ROMName%":1EB0C8-1EB268>> TEMP1.asm
echo:incbin "%ROMName%":1EB270-1EB410>> TEMP1.asm
echo:incbin "%ROMName%":1EB418-1EB5B8>> TEMP1.asm
echo:incbin "%ROMName%":1EB5C0-1EB760>> TEMP1.asm
echo:incbin "%ROMName%":1EB768-1EB908>> TEMP1.asm
echo:incbin "%ROMName%":1EB910-1EBAB0>> TEMP1.asm
echo:incbin "%ROMName%":1EBAB8-1EBC58>> TEMP1.asm
echo:incbin "%ROMName%":1EBC60-1EBD20>> TEMP1.asm
echo:incbin "%ROMName%":1EBD28-1EBE68>> TEMP1.asm
echo:incbin "%ROMName%":1EBE70-1EBE90>> TEMP1.asm
echo:incbin "%ROMName%":1EBE98-1EBF18>> TEMP1.asm
echo:incbin "%ROMName%":1EBF20-1EC040>> TEMP1.asm
echo:incbin "%ROMName%":1EC048-1EC168>> TEMP1.asm
echo:incbin "%ROMName%":1EC170-1EC290>> TEMP1.asm
echo:incbin "%ROMName%":1EC298-1EC3B8>> TEMP1.asm
echo:incbin "%ROMName%":1EC3C0-1EC4E0>> TEMP1.asm
echo:incbin "%ROMName%":1EC4E8-1EC608>> TEMP1.asm
echo:incbin "%ROMName%":1EC610-1EC730>> TEMP1.asm
echo:incbin "%ROMName%":1EC738-1EC858>> TEMP1.asm
echo:incbin "%ROMName%":1EC860-1EC920>> TEMP1.asm
echo:incbin "%ROMName%":1EC928-1ECA48>> TEMP1.asm
echo:incbin "%ROMName%":1ECA50-1ECB10>> TEMP1.asm
echo:incbin "%ROMName%":1ECB18-1ECBD8>> TEMP1.asm
echo:incbin "%ROMName%":1ECBE0-1ECCA0>> TEMP1.asm
echo:incbin "%ROMName%":1ECCA8-1ECD68>> TEMP1.asm
echo:incbin "%ROMName%":1ECD70-1ECE30>> TEMP1.asm
echo:incbin "%ROMName%":1ECE38-1ECEF8>> TEMP1.asm
echo:incbin "%ROMName%":1ECF00-1ED020>> TEMP1.asm
echo:incbin "%ROMName%":1ED028-1ED0E8>> TEMP1.asm
echo:incbin "%ROMName%":1ED0F0-1ED210>> TEMP1.asm
echo:incbin "%ROMName%":1ED218-1ED3F8>> TEMP1.asm
echo:incbin "%ROMName%":1ED400-1ED4C0>> TEMP1.asm
echo:incbin "%ROMName%":1ED4C8-1ED5E8>> TEMP1.asm
echo:incbin "%ROMName%":1ED5F0-1ED710>> TEMP1.asm
echo:incbin "%ROMName%":1ED718-1ED838>> TEMP1.asm
echo:incbin "%ROMName%":1ED840-1ED960>> TEMP1.asm
echo:incbin "%ROMName%":1ED968-1EDA88>> TEMP1.asm
echo:incbin "%ROMName%":1EDA90-1EDBB0>> TEMP1.asm
echo:incbin "%ROMName%":1EDBB8-1EDCD8>> TEMP1.asm
echo:incbin "%ROMName%":1EDCE0-1EDE00>> TEMP1.asm
echo:incbin "%ROMName%":1EDE08-1EDF28>> TEMP1.asm
echo:incbin "%ROMName%":1EDF30-1EE050>> TEMP1.asm
echo:incbin "%ROMName%":1EE058-1EE178>> TEMP1.asm
echo:incbin "%ROMName%":1EE180-1EE2A0>> TEMP1.asm
echo:incbin "%ROMName%":1EE2A8-1EE3C8>> TEMP1.asm
echo:incbin "%ROMName%":1EE3D0-1EE4F0>> TEMP1.asm
echo:incbin "%ROMName%":1EE4F8-1EE618>> TEMP1.asm
echo:incbin "%ROMName%":1EE620-1EE6E0>> TEMP1.asm
echo:incbin "%ROMName%":1EE6E8-1EE7A8>> TEMP1.asm
echo:incbin "%ROMName%":1EE7B0-1EE870>> TEMP1.asm
echo:incbin "%ROMName%":1EE878-1EE938>> TEMP1.asm
echo:incbin "%ROMName%":1EE940-1EEA00>> TEMP1.asm
echo:incbin "%ROMName%":1EEA08-1EEB28>> TEMP1.asm
echo:incbin "%ROMName%":1EEB30-1EEC50>> TEMP1.asm
echo:incbin "%ROMName%":1EEC58-1EED78>> TEMP1.asm
echo:incbin "%ROMName%":1EED80-1EEEA0>> TEMP1.asm
echo:incbin "%ROMName%":1EEEA8-1EEFC8>> TEMP1.asm
echo:incbin "%ROMName%":1EEFD0-1EF0F0>> TEMP1.asm
echo:incbin "%ROMName%":1EF0F8-1EF218>> TEMP1.asm
echo:incbin "%ROMName%":1EF220-1EF340>> TEMP1.asm
echo:incbin "%ROMName%":1EF348-1EF468>> TEMP1.asm
echo:incbin "%ROMName%":1EF470-1EF590>> TEMP1.asm
echo:incbin "%ROMName%":1EF598-1EF6B8>> TEMP1.asm
echo:incbin "%ROMName%":1EF6C0-1EF7E0>> TEMP1.asm
echo:incbin "%ROMName%":1EF7E8-1EF908>> TEMP1.asm
echo:incbin "%ROMName%":1EF910-1EFA30>> TEMP1.asm
echo:incbin "%ROMName%":1EFA38-1EFB58>> TEMP1.asm
echo:incbin "%ROMName%":1EFB60-1EFC80>> TEMP1.asm
echo:incbin "%ROMName%":1EFC88-1EFDA8>> TEMP1.asm
echo:incbin "%ROMName%":1EFDB0-1EFED0>> TEMP1.asm
echo:incbin "%ROMName%":1EFED8-1EFFF8>> TEMP1.asm
echo:incbin "%ROMName%":1F0008-1F0128>> TEMP1.asm
echo:incbin "%ROMName%":1F0130-1F0250>> TEMP1.asm
echo:incbin "%ROMName%":1F0258-1F0378>> TEMP1.asm
echo:incbin "%ROMName%":1F0380-1F04A0>> TEMP1.asm
echo:incbin "%ROMName%":1F04A8-1F05C8>> TEMP1.asm
echo:incbin "%ROMName%":1F05D0-1F06F0>> TEMP1.asm
echo:incbin "%ROMName%":1F06F8-1F0818>> TEMP1.asm
echo:incbin "%ROMName%":1F0820-1F0940>> TEMP1.asm
echo:incbin "%ROMName%":1F0948-1F0A68>> TEMP1.asm
echo:incbin "%ROMName%":1F0A70-1F0B90>> TEMP1.asm
echo:incbin "%ROMName%":1F0B98-1F0CB8>> TEMP1.asm
echo:incbin "%ROMName%":1F0CC0-1F0DE0>> TEMP1.asm
echo:incbin "%ROMName%":1F0DE8-1F0F08>> TEMP1.asm
echo:incbin "%ROMName%":1F0F10-1F1030>> TEMP1.asm
echo:incbin "%ROMName%":1F1038-1F1158>> TEMP1.asm
echo:incbin "%ROMName%":1F1160-1F1280>> TEMP1.asm
echo:incbin "%ROMName%":1F1288-1F13A8>> TEMP1.asm
echo:incbin "%ROMName%":1F13B0-1F14D0>> TEMP1.asm
echo:incbin "%ROMName%":1F14D8-1F15F8>> TEMP1.asm
echo:incbin "%ROMName%":1F1600-1F1720>> TEMP1.asm
echo:incbin "%ROMName%":1F1728-1F1848>> TEMP1.asm
echo:incbin "%ROMName%":1F1850-1F1970>> TEMP1.asm
echo:incbin "%ROMName%":1F1978-1F1A98>> TEMP1.asm
echo:incbin "%ROMName%":1F1AA0-1F1BC0>> TEMP1.asm
echo:incbin "%ROMName%":1F1BC8-1F1CE8>> TEMP1.asm
echo:incbin "%ROMName%":1F1CF0-1F1E10>> TEMP1.asm
echo:incbin "%ROMName%":1F1E18-1F1F38>> TEMP1.asm
echo:incbin "%ROMName%":1F1F40-1F2060>> TEMP1.asm
echo:incbin "%ROMName%":1F2068-1F2188>> TEMP1.asm
echo:incbin "%ROMName%":1F2190-1F22B0>> TEMP1.asm
echo:incbin "%ROMName%":1F22B8-1F2378>> TEMP1.asm
echo:incbin "%ROMName%":1F2380-1F2440>> TEMP1.asm
echo:incbin "%ROMName%":1F2448-1F2508>> TEMP1.asm
echo:incbin "%ROMName%":1F2510-1F25D0>> TEMP1.asm
echo:incbin "%ROMName%":1F25D8-1F2698>> TEMP1.asm
echo:incbin "%ROMName%":1F26A0-1F27C0>> TEMP1.asm
echo:incbin "%ROMName%":1F27C8-1F28E8>> TEMP1.asm
echo:incbin "%ROMName%":1F28F0-1F2A10>> TEMP1.asm
echo:incbin "%ROMName%":1F2A18-1F2B38>> TEMP1.asm
echo:incbin "%ROMName%":1F2B40-1F2CE0>> TEMP1.asm
echo:incbin "%ROMName%":1F2CE8-1F2E88>> TEMP1.asm
echo:incbin "%ROMName%":1F2E90-1F3070>> TEMP1.asm
echo:incbin "%ROMName%":1F3078-1F3258>> TEMP1.asm
echo:incbin "%ROMName%":1F3260-1F3380>> TEMP1.asm
echo:incbin "%ROMName%":1F3388-1F3448>> TEMP1.asm
echo:incbin "%ROMName%":1F3450-1F35F0>> TEMP1.asm
echo:incbin "%ROMName%":1F35F8-1F37B8>> TEMP1.asm
echo:incbin "%ROMName%":1F37C0-1F3960>> TEMP1.asm
echo:incbin "%ROMName%":1F3968-1F3B08>> TEMP1.asm
echo:incbin "%ROMName%":1F3B10-1F3CD0>> TEMP1.asm
echo:incbin "%ROMName%":1F3CD8-1F3E78>> TEMP1.asm
echo:incbin "%ROMName%":1F3E80-1F41A0>> TEMP1.asm
echo:incbin "%ROMName%":1F41A8-1F44C8>> TEMP1.asm
echo:incbin "%ROMName%":1F44D0-1F47F0>> TEMP1.asm
echo:incbin "%ROMName%":1F47F8-1F4918>> TEMP1.asm
echo:incbin "%ROMName%":1F4920-1F4AC0>> TEMP1.asm
echo:incbin "%ROMName%":1F4AC8-1F4C88>> TEMP1.asm
echo:incbin "%ROMName%":1F4C90-1F4DB0>> TEMP1.asm
echo:incbin "%ROMName%":1F4DB8-1F4ED8>> TEMP1.asm
echo:incbin "%ROMName%":1F4EE0-1F5000>> TEMP1.asm
echo:incbin "%ROMName%":1F5008-1F5128>> TEMP1.asm
echo:incbin "%ROMName%":1F5130-1F5250>> TEMP1.asm
echo:incbin "%ROMName%":1F5258-1F5378>> TEMP1.asm
echo:incbin "%ROMName%":1F5380-1F54A0>> TEMP1.asm
echo:incbin "%ROMName%":1F54A8-1F56A8>> TEMP1.asm
echo:incbin "%ROMName%":1F56B0-1F58B0>> TEMP1.asm
echo:incbin "%ROMName%":1F58B8-1F5AB8>> TEMP1.asm
echo:incbin "%ROMName%":1F5AC0-1F5BE0>> TEMP1.asm
echo:incbin "%ROMName%":1F5BE8-1F5D88>> TEMP1.asm
echo:incbin "%ROMName%":1F5D90-1F5F30>> TEMP1.asm
echo:incbin "%ROMName%":1F5F38-1F6118>> TEMP1.asm
echo:incbin "%ROMName%":1F6120-1F6300>> TEMP1.asm
echo:incbin "%ROMName%":1F6308-1F6508>> TEMP1.asm
echo:incbin "%ROMName%":1F6510-1F66B0>> TEMP1.asm
echo:incbin "%ROMName%":1F66B8-1F6858>> TEMP1.asm
echo:incbin "%ROMName%":1F6860-1F6A00>> TEMP1.asm
echo:incbin "%ROMName%":1F6A08-1F6BA8>> TEMP1.asm
echo:incbin "%ROMName%":1F6BB0-1F6D50>> TEMP1.asm
echo:incbin "%ROMName%":1F6D58-1F6F78>> TEMP1.asm
echo:incbin "%ROMName%":1F6F80-1F7120>> TEMP1.asm
echo:incbin "%ROMName%":1F7128-1F72C8>> TEMP1.asm
echo:incbin "%ROMName%":1F72D0-1F7470>> TEMP1.asm
echo:incbin "%ROMName%":1F7478-1F7618>> TEMP1.asm
echo:incbin "%ROMName%":1F7620-1F77C0>> TEMP1.asm
echo:incbin "%ROMName%":1F77C8-1F7968>> TEMP1.asm
echo:incbin "%ROMName%":1F7970-1F7B10>> TEMP1.asm
echo:incbin "%ROMName%":1F7B18-1F7CB8>> TEMP1.asm
echo:incbin "%ROMName%":1F7CC0-1F7E60>> TEMP1.asm
echo:incbin "%ROMName%":1F7E68-1F8008>> TEMP1.asm
echo:incbin "%ROMName%":1F8010-1F81B0>> TEMP1.asm
echo:incbin "%ROMName%":1F81B8-1F8358>> TEMP1.asm
echo:incbin "%ROMName%":1F8360-1F8500>> TEMP1.asm
echo:incbin "%ROMName%":1F8508-1F86A8>> TEMP1.asm
echo:incbin "%ROMName%":1F86B0-1F8850>> TEMP1.asm
echo:incbin "%ROMName%":1F8858-1F89F8>> TEMP1.asm
echo:incbin "%ROMName%":1F8A00-1F8BA0>> TEMP1.asm
echo:incbin "%ROMName%":1F8BA8-1F8D48>> TEMP1.asm
echo:incbin "%ROMName%":1F8D50-1F8EF0>> TEMP1.asm
echo:incbin "%ROMName%":1F8EF8-1F9098>> TEMP1.asm
echo:incbin "%ROMName%":1F90A0-1F9240>> TEMP1.asm
echo:incbin "%ROMName%":1F9248-1F93E8>> TEMP1.asm
echo:incbin "%ROMName%":1F93F0-1F9590>> TEMP1.asm
echo:incbin "%ROMName%":1F9598-1F9738>> TEMP1.asm
echo:incbin "%ROMName%":1F9740-1F98E0>> TEMP1.asm
echo:incbin "%ROMName%":1F98E8-1F9A88>> TEMP1.asm
echo:incbin "%ROMName%":1F9A90-1F9C30>> TEMP1.asm
echo:incbin "%ROMName%":1F9C38-1F9DD8>> TEMP1.asm
echo:incbin "%ROMName%":1F9DE0-1F9F80>> TEMP1.asm
echo:incbin "%ROMName%":1F9F88-1FA128>> TEMP1.asm
echo:incbin "%ROMName%":1FA130-1FA2D0>> TEMP1.asm
echo:incbin "%ROMName%":1FA2D8-1FA478>> TEMP1.asm
echo:incbin "%ROMName%":1FA480-1FA5C0>> TEMP1.asm
echo:incbin "%ROMName%":1FA5C8-1FA768>> TEMP1.asm
echo:incbin "%ROMName%":1FA770-1FA890>> TEMP1.asm
echo:incbin "%ROMName%":1FA898-1FA958>> TEMP1.asm
echo:incbin "%ROMName%":1FA960-1FAA20>> TEMP1.asm
echo:incbin "%ROMName%":1FAA28-1FAC68>> TEMP1.asm
echo:incbin "%ROMName%":1FAC70-1FAFB0>> TEMP1.asm
echo:incbin "%ROMName%":1FAFB8-1FB2F8>> TEMP1.asm
echo:incbin "%ROMName%":1FB300-1FB6E0>> TEMP1.asm
echo:incbin "%ROMName%":1FB6E8-1FB808>> TEMP1.asm
echo:incbin "%ROMName%":1FB810-1FB930>> TEMP1.asm
echo:incbin "%ROMName%":1FB938-1FBA58>> TEMP1.asm
echo:incbin "%ROMName%":1FBA60-1FBB80>> TEMP1.asm
echo:incbin "%ROMName%":1FBB88-1FBCA8>> TEMP1.asm
echo:incbin "%ROMName%":1FBCB0-1FBDD0>> TEMP1.asm
echo:incbin "%ROMName%":1FBDD8-1FBEF8>> TEMP1.asm
echo:incbin "%ROMName%":1FBF00-1FC140>> TEMP1.asm
echo:incbin "%ROMName%":1FC148-1FC388>> TEMP1.asm
echo:incbin "%ROMName%":1FC390-1FC5D0>> TEMP1.asm
echo:incbin "%ROMName%":1FC5D8-1FC7B8>> TEMP1.asm
echo:incbin "%ROMName%":1FC7C0-1FCA00>> TEMP1.asm
echo:incbin "%ROMName%":1FCA08-1FCC68>> TEMP1.asm
echo:incbin "%ROMName%":1FCC70-1FCFB0>> TEMP1.asm
echo:incbin "%ROMName%":1FCFB8-1FD2F8>> TEMP1.asm
echo:incbin "%ROMName%":1FD300-1FD520>> TEMP1.asm
echo:incbin "%ROMName%":1FD528-1FD708>> TEMP1.asm
echo:incbin "%ROMName%":1FD710-1FD950>> TEMP1.asm
echo:incbin "%ROMName%":1FD958-1FDB38>> TEMP1.asm
echo:incbin "%ROMName%":1FDB40-1FDC60>> TEMP1.asm
echo:incbin "%ROMName%":1FDC68-1FDE08>> TEMP1.asm
echo:incbin "%ROMName%":1FDE10-1FDFB0>> TEMP1.asm
echo:incbin "%ROMName%":1FDFB8-1FE198>> TEMP1.asm
echo:incbin "%ROMName%":1FE1A0-1FE380>> TEMP1.asm
echo:incbin "%ROMName%":1FE388-1FE4A8>> TEMP1.asm
echo:incbin "%ROMName%":1FE4B0-1FE5D0>> TEMP1.asm
echo:incbin "%ROMName%":1FE5D8-1FE6B8>> TEMP1.asm
echo:incbin "%ROMName%":1FE6C0-1FE780>> TEMP1.asm
echo:incbin "%ROMName%":1FE788-1FE848>> TEMP1.asm
echo:incbin "%ROMName%":1FE850-1FE970>> TEMP1.asm
echo:incbin "%ROMName%":1FE978-1FEA98>> TEMP1.asm
echo:incbin "%ROMName%":1FEAA0-1FEBC0>> TEMP1.asm
echo:incbin "%ROMName%":1FEBC8-1FEC88>> TEMP1.asm
echo:incbin "%ROMName%":1FEC90-1FEDB0>> TEMP1.asm
echo:incbin "%ROMName%":1FEDB8-1FEED8>> TEMP1.asm
echo:incbin "%ROMName%":1FEEE0-1FF000>> TEMP1.asm
echo:incbin "%ROMName%":1FF008-1FF128>> TEMP1.asm
echo:incbin "%ROMName%":1FF130-1FF250>> TEMP1.asm
echo:incbin "%ROMName%":1FF258-1FF318>> TEMP1.asm
echo:incbin "%ROMName%":1FF320-1FF440>> TEMP1.asm
echo:incbin "%ROMName%":1FF448-1FF568>> TEMP1.asm
echo:incbin "%ROMName%":1FF570-1FF690>> TEMP1.asm
echo:incbin "%ROMName%":1FF698-1FF7B8>> TEMP1.asm
echo:incbin "%ROMName%":1FF7C0-1FF8E0>> TEMP1.asm
echo:incbin "%ROMName%":1FF8E8-1FFA08>> TEMP1.asm
echo:incbin "%ROMName%":1FFA10-1FFB30>> TEMP1.asm
echo:incbin "%ROMName%":1FFB38-1FFC58>> TEMP1.asm
echo:incbin "%ROMName%":1FFC60-1FFD80>> TEMP1.asm
echo:incbin "%ROMName%":1FFD88-1FFEA8>> TEMP1.asm
echo:incbin "%ROMName%":1FFEB0-1FFFD0>> TEMP1.asm
echo:incbin "%ROMName%":200008-200128>> TEMP1.asm
echo:incbin "%ROMName%":200130-200250>> TEMP1.asm
echo:incbin "%ROMName%":200258-200378>> TEMP1.asm
echo:incbin "%ROMName%":200380-2004A0>> TEMP1.asm
echo:incbin "%ROMName%":2004A8-2005C8>> TEMP1.asm
echo:incbin "%ROMName%":2005D0-200690>> TEMP1.asm
echo:incbin "%ROMName%":200698-200758>> TEMP1.asm
echo:incbin "%ROMName%":200760-200820>> TEMP1.asm
echo:incbin "%ROMName%":200828-200948>> TEMP1.asm
echo:incbin "%ROMName%":200950-200A10>> TEMP1.asm
echo:incbin "%ROMName%":200A18-200B38>> TEMP1.asm
echo:incbin "%ROMName%":200B40-200C60>> TEMP1.asm
echo:incbin "%ROMName%":200C68-200D88>> TEMP1.asm
echo:incbin "%ROMName%":200D90-200EB0>> TEMP1.asm
echo:incbin "%ROMName%":200EB8-200FD8>> TEMP1.asm
echo:incbin "%ROMName%":200FE0-201100>> TEMP1.asm
echo:incbin "%ROMName%":201108-201228>> TEMP1.asm
echo:incbin "%ROMName%":201230-2012F0>> TEMP1.asm
echo:incbin "%ROMName%":2012F8-2013B8>> TEMP1.asm
echo:incbin "%ROMName%":2013C0-2014E0>> TEMP1.asm
echo:incbin "%ROMName%":2014E8-201608>> TEMP1.asm
echo:incbin "%ROMName%":201610-201730>> TEMP1.asm
echo:incbin "%ROMName%":201738-201858>> TEMP1.asm
echo:incbin "%ROMName%":201860-201980>> TEMP1.asm
echo:incbin "%ROMName%":201988-201AA8>> TEMP1.asm
echo:incbin "%ROMName%":201AB0-201BB0>> TEMP1.asm
echo:incbin "%ROMName%":201BB8-201C98>> TEMP1.asm
echo:incbin "%ROMName%":201CA0-201DA0>> TEMP1.asm
echo:incbin "%ROMName%":201DA8-201EA8>> TEMP1.asm
echo:incbin "%ROMName%":201EB0-201FB0>> TEMP1.asm
echo:incbin "%ROMName%":201FB8-2020B8>> TEMP1.asm
echo:incbin "%ROMName%":2020C0-2021E0>> TEMP1.asm
echo:incbin "%ROMName%":2021E8-202308>> TEMP1.asm
echo:incbin "%ROMName%":202310-202430>> TEMP1.asm
echo:incbin "%ROMName%":202438-202558>> TEMP1.asm
echo:incbin "%ROMName%":202560-202620>> TEMP1.asm
echo:incbin "%ROMName%":202628-2026E8>> TEMP1.asm
echo:incbin "%ROMName%":2026F0-2027F0>> TEMP1.asm
echo:incbin "%ROMName%":2027F8-2028D8>> TEMP1.asm
echo:incbin "%ROMName%":2028E0-2029C0>> TEMP1.asm
echo:incbin "%ROMName%":2029C8-202B28>> TEMP1.asm
echo:incbin "%ROMName%":202B30-202D10>> TEMP1.asm
echo:incbin "%ROMName%":202D18-202ED8>> TEMP1.asm
echo:incbin "%ROMName%":202EE0-2030C0>> TEMP1.asm
echo:incbin "%ROMName%":2030C8-2031C8>> TEMP1.asm
echo:incbin "%ROMName%":2031D0-203370>> TEMP1.asm
echo:incbin "%ROMName%":203378-203518>> TEMP1.asm
echo:incbin "%ROMName%":203520-203720>> TEMP1.asm
echo:incbin "%ROMName%":203728-203928>> TEMP1.asm
echo:incbin "%ROMName%":203930-203AD0>> TEMP1.asm
echo:incbin "%ROMName%":203AD8-203BD8>> TEMP1.asm
echo:incbin "%ROMName%":203BE0-203CC0>> TEMP1.asm
echo:incbin "%ROMName%":203CC8-203DA8>> TEMP1.asm
echo:incbin "%ROMName%":203DB0-203E90>> TEMP1.asm
echo:incbin "%ROMName%":203E98-203F58>> TEMP1.asm
echo:incbin "%ROMName%":203F60-204080>> TEMP1.asm
echo:incbin "%ROMName%":204088-2041C8>> TEMP1.asm
echo:incbin "%ROMName%":2041D0-204310>> TEMP1.asm
echo:incbin "%ROMName%":204318-204498>> TEMP1.asm
echo:incbin "%ROMName%":2044A0-204620>> TEMP1.asm
echo:incbin "%ROMName%":204628-2046E8>> TEMP1.asm
echo:incbin "%ROMName%":2046F0-204730>> TEMP1.asm
echo:incbin "%ROMName%":204738-204778>> TEMP1.asm
echo:incbin "%ROMName%":204780-204800>> TEMP1.asm
echo:incbin "%ROMName%":204808-2048C8>> TEMP1.asm
echo:incbin "%ROMName%":2048D0-204930>> TEMP1.asm
echo:incbin "%ROMName%":204938-204978>> TEMP1.asm
echo:incbin "%ROMName%":204980-204A40>> TEMP1.asm
echo:incbin "%ROMName%":204A48-204B08>> TEMP1.asm
echo:incbin "%ROMName%":204B10-204B50>> TEMP1.asm
echo:incbin "%ROMName%":204B58-204B98>> TEMP1.asm
echo:incbin "%ROMName%":204BA0-204BE0>> TEMP1.asm
echo:incbin "%ROMName%":204BE8-204CA8>> TEMP1.asm
echo:incbin "%ROMName%":204CB0-204D70>> TEMP1.asm
echo:incbin "%ROMName%":204D78-204E38>> TEMP1.asm
echo:incbin "%ROMName%":204E40-204EC0>> TEMP1.asm
echo:incbin "%ROMName%":204EC8-204F08>> TEMP1.asm
echo:incbin "%ROMName%":204F10-204F50>> TEMP1.asm
echo:incbin "%ROMName%":204F58-204FD8>> TEMP1.asm
echo:incbin "%ROMName%":204FE0-205060>> TEMP1.asm
echo:incbin "%ROMName%":205068-205128>> TEMP1.asm
echo:incbin "%ROMName%":205130-205170>> TEMP1.asm
echo:incbin "%ROMName%":205178-2051B8>> TEMP1.asm
echo:incbin "%ROMName%":2051C0-205200>> TEMP1.asm
echo:incbin "%ROMName%":205208-2052C8>> TEMP1.asm
echo:incbin "%ROMName%":2052D0-205390>> TEMP1.asm
echo:incbin "%ROMName%":205398-2053D8>> TEMP1.asm
echo:incbin "%ROMName%":2053E0-205420>> TEMP1.asm
echo:incbin "%ROMName%":205428-205488>> TEMP1.asm
echo:incbin "%ROMName%":205490-205510>> TEMP1.asm
echo:incbin "%ROMName%":205518-205618>> TEMP1.asm
echo:incbin "%ROMName%":205620-205660>> TEMP1.asm
echo:incbin "%ROMName%":205668-2056A8>> TEMP1.asm
echo:incbin "%ROMName%":2056B0-205710>> TEMP1.asm
echo:incbin "%ROMName%":205718-205778>> TEMP1.asm
echo:incbin "%ROMName%":205780-205800>> TEMP1.asm
echo:incbin "%ROMName%":205808-2058C8>> TEMP1.asm
echo:incbin "%ROMName%":2058D0-205A10>> TEMP1.asm
echo:incbin "%ROMName%":205A18-205A98>> TEMP1.asm
echo:incbin "%ROMName%":205AA0-205B20>> TEMP1.asm
echo:incbin "%ROMName%":205B28-205BE8>> TEMP1.asm
echo:incbin "%ROMName%":205BF0-205C70>> TEMP1.asm
echo:incbin "%ROMName%":205C78-205CB8>> TEMP1.asm
echo:incbin "%ROMName%":205CC0-205D40>> TEMP1.asm
echo:incbin "%ROMName%":205D48-205E48>> TEMP1.asm
echo:incbin "%ROMName%":205E50-205F50>> TEMP1.asm
echo:incbin "%ROMName%":205F58-206058>> TEMP1.asm
echo:incbin "%ROMName%":206060-2060E0>> TEMP1.asm
echo:incbin "%ROMName%":2060E8-206168>> TEMP1.asm
echo:incbin "%ROMName%":206170-206290>> TEMP1.asm
echo:incbin "%ROMName%":206298-2063B8>> TEMP1.asm
echo:incbin "%ROMName%":2063C0-2064E0>> TEMP1.asm
echo:incbin "%ROMName%":2064E8-206608>> TEMP1.asm
echo:incbin "%ROMName%":206610-206690>> TEMP1.asm
echo:incbin "%ROMName%":206698-206718>> TEMP1.asm
echo:incbin "%ROMName%":206720-206840>> TEMP1.asm
echo:incbin "%ROMName%":206848-206988>> TEMP1.asm
echo:incbin "%ROMName%":206990-206AD0>> TEMP1.asm
echo:incbin "%ROMName%":206AD8-206C58>> TEMP1.asm
echo:incbin "%ROMName%":206C60-206DE0>> TEMP1.asm
echo:incbin "%ROMName%":206DE8-206EA8>> TEMP1.asm
echo:incbin "%ROMName%":206EB0-206F70>> TEMP1.asm
echo:incbin "%ROMName%":206F78-207038>> TEMP1.asm
echo:incbin "%ROMName%":207040-207100>> TEMP1.asm
echo:incbin "%ROMName%":207108-2071C8>> TEMP1.asm
echo:incbin "%ROMName%":2071D0-207290>> TEMP1.asm
echo:incbin "%ROMName%":207298-207358>> TEMP1.asm
echo:incbin "%ROMName%":207360-207420>> TEMP1.asm
echo:incbin "%ROMName%":207428-2074E8>> TEMP1.asm
echo:incbin "%ROMName%":2074F0-2075B0>> TEMP1.asm
echo:incbin "%ROMName%":2075B8-207678>> TEMP1.asm
echo:incbin "%ROMName%":207680-207740>> TEMP1.asm
echo:incbin "%ROMName%":207748-207808>> TEMP1.asm
echo:incbin "%ROMName%":207810-2078D0>> TEMP1.asm
echo:incbin "%ROMName%":2078D8-207998>> TEMP1.asm
echo:incbin "%ROMName%":2079A0-207A60>> TEMP1.asm
echo:incbin "%ROMName%":207A68-207B88>> TEMP1.asm
echo:incbin "%ROMName%":207B90-207CB0>> TEMP1.asm
echo:incbin "%ROMName%":207CB8-207DD8>> TEMP1.asm
echo:incbin "%ROMName%":207DE0-207F00>> TEMP1.asm
echo:incbin "%ROMName%":207F08-207FC8>> TEMP1.asm
echo:incbin "%ROMName%":207FD0-208090>> TEMP1.asm
echo:incbin "%ROMName%":208098-208158>> TEMP1.asm
echo:incbin "%ROMName%":208160-208280>> TEMP1.asm
echo:incbin "%ROMName%":208288-2083A8>> TEMP1.asm
echo:incbin "%ROMName%":2083B0-208530>> TEMP1.asm
echo:incbin "%ROMName%":208538-2085F8>> TEMP1.asm
echo:incbin "%ROMName%":208600-208700>> TEMP1.asm
echo:incbin "%ROMName%":208708-2087C8>> TEMP1.asm
echo:incbin "%ROMName%":2087D0-208890>> TEMP1.asm
echo:incbin "%ROMName%":208898-208958>> TEMP1.asm
echo:incbin "%ROMName%":208960-208A20>> TEMP1.asm
echo:incbin "%ROMName%":208A28-208AE8>> TEMP1.asm
echo:incbin "%ROMName%":208AF0-208BB0>> TEMP1.asm
echo:incbin "%ROMName%":208BB8-208C78>> TEMP1.asm
echo:incbin "%ROMName%":208C80-208D80>> TEMP1.asm
echo:incbin "%ROMName%":208D88-208E88>> TEMP1.asm
echo:incbin "%ROMName%":208E90-208F90>> TEMP1.asm
echo:incbin "%ROMName%":208F98-2090B8>> TEMP1.asm
echo:incbin "%ROMName%":2090C0-2091E0>> TEMP1.asm
echo:incbin "%ROMName%":2091E8-209308>> TEMP1.asm
echo:incbin "%ROMName%":209310-209430>> TEMP1.asm
echo:incbin "%ROMName%":209438-209558>> TEMP1.asm
echo:incbin "%ROMName%":209560-209680>> TEMP1.asm
echo:incbin "%ROMName%":209688-2097C8>> TEMP1.asm
echo:incbin "%ROMName%":2097D0-2099D0>> TEMP1.asm
echo:incbin "%ROMName%":2099D8-209B58>> TEMP1.asm
echo:incbin "%ROMName%":209B60-209CA0>> TEMP1.asm
echo:incbin "%ROMName%":209CA8-209E28>> TEMP1.asm
echo:incbin "%ROMName%":209E30-209EF0>> TEMP1.asm
echo:incbin "%ROMName%":209EF8-209FB8>> TEMP1.asm
echo:incbin "%ROMName%":209FC0-20A0E0>> TEMP1.asm
echo:incbin "%ROMName%":20A0E8-20A208>> TEMP1.asm
echo:incbin "%ROMName%":20A210-20A330>> TEMP1.asm
echo:incbin "%ROMName%":20A338-20A3F8>> TEMP1.asm
echo:incbin "%ROMName%":20A400-20A540>> TEMP1.asm
echo:incbin "%ROMName%":20A548-20A6C8>> TEMP1.asm
echo:incbin "%ROMName%":20A6D0-20A850>> TEMP1.asm
echo:incbin "%ROMName%":20A858-20A9D8>> TEMP1.asm
echo:incbin "%ROMName%":20A9E0-20AB60>> TEMP1.asm
echo:incbin "%ROMName%":20AB68-20ACE8>> TEMP1.asm
echo:incbin "%ROMName%":20ACF0-20AE70>> TEMP1.asm
echo:incbin "%ROMName%":20AE78-20AFF8>> TEMP1.asm
echo:incbin "%ROMName%":20B000-20B180>> TEMP1.asm
echo:incbin "%ROMName%":20B188-20B308>> TEMP1.asm
echo:incbin "%ROMName%":20B310-20B490>> TEMP1.asm
echo:incbin "%ROMName%":20B498-20B618>> TEMP1.asm
echo:incbin "%ROMName%":20B620-20B7A0>> TEMP1.asm
echo:incbin "%ROMName%":20B7A8-20B928>> TEMP1.asm
echo:incbin "%ROMName%":20B930-20BAB0>> TEMP1.asm
echo:incbin "%ROMName%":20BAB8-20BB78>> TEMP1.asm
echo:incbin "%ROMName%":20BB80-20BCA0>> TEMP1.asm
echo:incbin "%ROMName%":20BCA8-20BDC8>> TEMP1.asm
echo:incbin "%ROMName%":20BDD0-20BEF0>> TEMP1.asm
echo:incbin "%ROMName%":20BEF8-20C018>> TEMP1.asm
echo:incbin "%ROMName%":20C020-20C140>> TEMP1.asm
echo:incbin "%ROMName%":20C148-20C268>> TEMP1.asm
echo:incbin "%ROMName%":20C270-20C390>> TEMP1.asm
echo:incbin "%ROMName%":20C398-20C4B8>> TEMP1.asm
echo:incbin "%ROMName%":20C4C0-20C600>> TEMP1.asm
echo:incbin "%ROMName%":20C608-20C748>> TEMP1.asm
echo:incbin "%ROMName%":20C750-20C930>> TEMP1.asm
echo:incbin "%ROMName%":20C938-20CB18>> TEMP1.asm
echo:incbin "%ROMName%":20CB20-20CC20>> TEMP1.asm
echo:incbin "%ROMName%":20CC28-20CCE8>> TEMP1.asm
echo:incbin "%ROMName%":20CCF0-20CDB0>> TEMP1.asm
echo:incbin "%ROMName%":20CDB8-20CE78>> TEMP1.asm
echo:incbin "%ROMName%":20CE80-20CF60>> TEMP1.asm
echo:incbin "%ROMName%":20CF68-20D028>> TEMP1.asm
echo:incbin "%ROMName%":20D030-20D0F0>> TEMP1.asm
echo:incbin "%ROMName%":20D0F8-20D1B8>> TEMP1.asm
echo:incbin "%ROMName%":20D1C0-20D240>> TEMP1.asm
echo:incbin "%ROMName%":20D248-20D308>> TEMP1.asm
echo:incbin "%ROMName%":20D310-20D390>> TEMP1.asm
echo:incbin "%ROMName%":20D398-20D458>> TEMP1.asm
echo:incbin "%ROMName%":20D460-20D520>> TEMP1.asm
echo:incbin "%ROMName%":20D528-20D628>> TEMP1.asm
echo:incbin "%ROMName%":20D630-20D750>> TEMP1.asm
echo:incbin "%ROMName%":20D758-20D878>> TEMP1.asm
echo:incbin "%ROMName%":20D880-20D940>> TEMP1.asm
echo:incbin "%ROMName%":20D948-20DA08>> TEMP1.asm
echo:incbin "%ROMName%":20DA10-20DAD0>> TEMP1.asm
echo:incbin "%ROMName%":20DAD8-20DB98>> TEMP1.asm
echo:incbin "%ROMName%":20DBA0-20DCC0>> TEMP1.asm
echo:incbin "%ROMName%":20DCC8-20DDE8>> TEMP1.asm
echo:incbin "%ROMName%":20DDF0-20DF10>> TEMP1.asm
echo:incbin "%ROMName%":20DF18-20E038>> TEMP1.asm
echo:incbin "%ROMName%":20E040-20E160>> TEMP1.asm
echo:incbin "%ROMName%":20E168-20E288>> TEMP1.asm
echo:incbin "%ROMName%":20E290-20E3B0>> TEMP1.asm
echo:incbin "%ROMName%":20E3B8-20E4D8>> TEMP1.asm
echo:incbin "%ROMName%":20E4E0-20E600>> TEMP1.asm
echo:incbin "%ROMName%":20E608-20E728>> TEMP1.asm
echo:incbin "%ROMName%":20E730-20E850>> TEMP1.asm
echo:incbin "%ROMName%":20E858-20E978>> TEMP1.asm
echo:incbin "%ROMName%":20E980-20EA40>> TEMP1.asm
echo:incbin "%ROMName%":20EA48-20EB68>> TEMP1.asm
echo:incbin "%ROMName%":20EB70-20EC50>> TEMP1.asm
echo:incbin "%ROMName%":20EC58-20ED78>> TEMP1.asm
echo:incbin "%ROMName%":20ED80-20EEA0>> TEMP1.asm
echo:incbin "%ROMName%":20EEA8-20EFC8>> TEMP1.asm
echo:incbin "%ROMName%":20EFD0-20F0F0>> TEMP1.asm
echo:incbin "%ROMName%":20F0F8-20F218>> TEMP1.asm
echo:incbin "%ROMName%":20F220-20F280>> TEMP1.asm
echo:incbin "%ROMName%":20F288-20F348>> TEMP1.asm
echo:incbin "%ROMName%":20F350-20F410>> TEMP1.asm
echo:incbin "%ROMName%":20F418-20F4D8>> TEMP1.asm
echo:incbin "%ROMName%":20F4E0-20F5A0>> TEMP1.asm
echo:incbin "%ROMName%":20F5A8-20F6C8>> TEMP1.asm
echo:incbin "%ROMName%":20F6D0-20F7F0>> TEMP1.asm
echo:incbin "%ROMName%":20F7F8-20F918>> TEMP1.asm
echo:incbin "%ROMName%":20F920-20FA40>> TEMP1.asm
echo:incbin "%ROMName%":20FA48-20FB48>> TEMP1.asm
echo:incbin "%ROMName%":20FB50-20FC50>> TEMP1.asm
echo:incbin "%ROMName%":20FC58-20FD58>> TEMP1.asm
echo:incbin "%ROMName%":20FD60-20FE60>> TEMP1.asm
echo:incbin "%ROMName%":20FE68-20FF28>> TEMP1.asm
echo:incbin "%ROMName%":20FF30-20FFF0>> TEMP1.asm
echo:incbin "%ROMName%":210008-2100C8>> TEMP1.asm
echo:incbin "%ROMName%":2100D0-210190>> TEMP1.asm
echo:incbin "%ROMName%":210198-210258>> TEMP1.asm
echo:incbin "%ROMName%":210260-210300>> TEMP1.asm
echo:incbin "%ROMName%":210308-210368>> TEMP1.asm
echo:incbin "%ROMName%":210370-210490>> TEMP1.asm
echo:incbin "%ROMName%":210498-2105B8>> TEMP1.asm
echo:incbin "%ROMName%":2105C0-2106E0>> TEMP1.asm
echo:incbin "%ROMName%":2106E8-2107A8>> TEMP1.asm
echo:incbin "%ROMName%":2107B0-2108D0>> TEMP1.asm
echo:incbin "%ROMName%":2108D8-210998>> TEMP1.asm
echo:incbin "%ROMName%":2109A0-210A60>> TEMP1.asm
echo:incbin "%ROMName%":210A68-210B28>> TEMP1.asm
echo:incbin "%ROMName%":210B30-210C10>> TEMP1.asm
echo:incbin "%ROMName%":210C18-210D18>> TEMP1.asm
echo:incbin "%ROMName%":210D20-210E00>> TEMP1.asm
echo:incbin "%ROMName%":210E08-210EC8>> TEMP1.asm
echo:incbin "%ROMName%":210ED0-210F70>> TEMP1.asm
echo:incbin "%ROMName%":210F78-210FD8>> TEMP1.asm
echo:incbin "%ROMName%":210FE0-211040>> TEMP1.asm
echo:incbin "%ROMName%":211048-2110A8>> TEMP1.asm
echo:incbin "%ROMName%":2110B0-2111B0>> TEMP1.asm
echo:incbin "%ROMName%":2111B8-2112B8>> TEMP1.asm
echo:incbin "%ROMName%":2112C0-211440>> TEMP1.asm
echo:incbin "%ROMName%":211448-211548>> TEMP1.asm
echo:incbin "%ROMName%":211550-211690>> TEMP1.asm
echo:incbin "%ROMName%":211698-211758>> TEMP1.asm
echo:incbin "%ROMName%":211760-211820>> TEMP1.asm
echo:incbin "%ROMName%":211828-2118C8>> TEMP1.asm
echo:incbin "%ROMName%":2118D0-211990>> TEMP1.asm
echo:incbin "%ROMName%":211998-211B18>> TEMP1.asm
echo:incbin "%ROMName%":211B20-211D20>> TEMP1.asm
echo:incbin "%ROMName%":211D28-211F28>> TEMP1.asm
echo:incbin "%ROMName%":211F30-211FF0>> TEMP1.asm
echo:incbin "%ROMName%":211FF8-212178>> TEMP1.asm
echo:incbin "%ROMName%":212180-212320>> TEMP1.asm
echo:incbin "%ROMName%":212328-2124C8>> TEMP1.asm
echo:incbin "%ROMName%":2124D0-2126B0>> TEMP1.asm
echo:incbin "%ROMName%":2126B8-212898>> TEMP1.asm
echo:incbin "%ROMName%":2128A0-2129C0>> TEMP1.asm
echo:incbin "%ROMName%":2129C8-212AE8>> TEMP1.asm
echo:incbin "%ROMName%":212AF0-212C10>> TEMP1.asm
echo:incbin "%ROMName%":212C18-212D38>> TEMP1.asm
echo:incbin "%ROMName%":212D40-212E60>> TEMP1.asm
echo:incbin "%ROMName%":212E68-212F88>> TEMP1.asm
echo:incbin "%ROMName%":212F90-2130B0>> TEMP1.asm
echo:incbin "%ROMName%":2130B8-2131D8>> TEMP1.asm
echo:incbin "%ROMName%":2131E0-213300>> TEMP1.asm
echo:incbin "%ROMName%":213308-213428>> TEMP1.asm
echo:incbin "%ROMName%":213430-213550>> TEMP1.asm
echo:incbin "%ROMName%":213558-213678>> TEMP1.asm
echo:incbin "%ROMName%":213680-2137A0>> TEMP1.asm
echo:incbin "%ROMName%":2137A8-213868>> TEMP1.asm
echo:incbin "%ROMName%":213870-213990>> TEMP1.asm
echo:incbin "%ROMName%":213998-213AB8>> TEMP1.asm
echo:incbin "%ROMName%":213AC0-213BE0>> TEMP1.asm
echo:incbin "%ROMName%":213BE8-213D08>> TEMP1.asm
echo:incbin "%ROMName%":213D10-213E30>> TEMP1.asm
echo:incbin "%ROMName%":213E38-213F58>> TEMP1.asm
echo:incbin "%ROMName%":213F60-214080>> TEMP1.asm
echo:incbin "%ROMName%":214088-2141A8>> TEMP1.asm
echo:incbin "%ROMName%":2141B0-2142D0>> TEMP1.asm
echo:incbin "%ROMName%":2142D8-2143F8>> TEMP1.asm
echo:incbin "%ROMName%":214400-214520>> TEMP1.asm
echo:incbin "%ROMName%":214528-214648>> TEMP1.asm
echo:incbin "%ROMName%":214650-214770>> TEMP1.asm
echo:incbin "%ROMName%":214778-214898>> TEMP1.asm
echo:incbin "%ROMName%":2148A0-2149C0>> TEMP1.asm
echo:incbin "%ROMName%":2149C8-214AE8>> TEMP1.asm
echo:incbin "%ROMName%":214AF0-214C10>> TEMP1.asm
echo:incbin "%ROMName%":214C18-214D38>> TEMP1.asm
echo:incbin "%ROMName%":214D40-214E60>> TEMP1.asm
echo:incbin "%ROMName%":214E68-214F88>> TEMP1.asm
echo:incbin "%ROMName%":214F90-2150B0>> TEMP1.asm
echo:incbin "%ROMName%":2150B8-2151D8>> TEMP1.asm
echo:incbin "%ROMName%":2151E0-215300>> TEMP1.asm
echo:incbin "%ROMName%":215308-215428>> TEMP1.asm
echo:incbin "%ROMName%":215430-215550>> TEMP1.asm
echo:incbin "%ROMName%":215558-215678>> TEMP1.asm
echo:incbin "%ROMName%":215680-2157A0>> TEMP1.asm
echo:incbin "%ROMName%":2157A8-2158C8>> TEMP1.asm
echo:incbin "%ROMName%":2158D0-2159F0>> TEMP1.asm
echo:incbin "%ROMName%":2159F8-215AB8>> TEMP1.asm
echo:incbin "%ROMName%":215AC0-215B80>> TEMP1.asm
echo:incbin "%ROMName%":215B88-215C48>> TEMP1.asm
echo:incbin "%ROMName%":215C50-215D70>> TEMP1.asm
echo:incbin "%ROMName%":215D78-215E98>> TEMP1.asm
echo:incbin "%ROMName%":215EA0-215FC0>> TEMP1.asm
echo:incbin "%ROMName%":215FC8-2160E8>> TEMP1.asm
echo:incbin "%ROMName%":2160F0-216210>> TEMP1.asm
echo:incbin "%ROMName%":216218-216338>> TEMP1.asm
echo:incbin "%ROMName%":216340-216460>> TEMP1.asm
echo:incbin "%ROMName%":216468-216588>> TEMP1.asm
echo:incbin "%ROMName%":216590-2166B0>> TEMP1.asm
echo:incbin "%ROMName%":2166B8-2167D8>> TEMP1.asm
echo:incbin "%ROMName%":2167E0-216900>> TEMP1.asm
echo:incbin "%ROMName%":216908-216A28>> TEMP1.asm
echo:incbin "%ROMName%":216A30-216C30>> TEMP1.asm
echo:incbin "%ROMName%":216C38-216E38>> TEMP1.asm
echo:incbin "%ROMName%":216E40-217040>> TEMP1.asm
echo:incbin "%ROMName%":217048-217248>> TEMP1.asm
echo:incbin "%ROMName%":217250-217370>> TEMP1.asm
echo:incbin "%ROMName%":217378-2174D8>> TEMP1.asm
echo:incbin "%ROMName%":2174E0-217640>> TEMP1.asm
echo:incbin "%ROMName%":217648-217768>> TEMP1.asm
echo:incbin "%ROMName%":217770-217890>> TEMP1.asm
echo:incbin "%ROMName%":217898-2179B8>> TEMP1.asm
echo:incbin "%ROMName%":2179C0-217AE0>> TEMP1.asm
echo:incbin "%ROMName%":217AE8-217C08>> TEMP1.asm
echo:incbin "%ROMName%":217C10-217D30>> TEMP1.asm
echo:incbin "%ROMName%":217D38-217E58>> TEMP1.asm
echo:incbin "%ROMName%":217E60-217F80>> TEMP1.asm
echo:incbin "%ROMName%":217F88-218048>> TEMP1.asm
echo:incbin "%ROMName%":218050-2181F0>> TEMP1.asm
echo:incbin "%ROMName%":2181F8-218398>> TEMP1.asm
echo:incbin "%ROMName%":2183A0-218540>> TEMP1.asm
echo:incbin "%ROMName%":218548-2186A8>> TEMP1.asm
echo:incbin "%ROMName%":2186B0-218890>> TEMP1.asm
echo:incbin "%ROMName%":218898-218A18>> TEMP1.asm
echo:incbin "%ROMName%":218A20-218BE0>> TEMP1.asm
echo:incbin "%ROMName%":218BE8-218DA8>> TEMP1.asm
echo:incbin "%ROMName%":218DB0-218F70>> TEMP1.asm
echo:incbin "%ROMName%":218F78-219138>> TEMP1.asm
echo:incbin "%ROMName%":219140-219260>> TEMP1.asm
echo:incbin "%ROMName%":219268-219388>> TEMP1.asm
echo:incbin "%ROMName%":219390-2194B0>> TEMP1.asm
echo:incbin "%ROMName%":2194B8-219598>> TEMP1.asm
echo:incbin "%ROMName%":2195A0-219680>> TEMP1.asm
echo:incbin "%ROMName%":219688-219768>> TEMP1.asm
echo:incbin "%ROMName%":219770-219850>> TEMP1.asm
echo:incbin "%ROMName%":219858-219938>> TEMP1.asm
echo:incbin "%ROMName%":219940-219A60>> TEMP1.asm
echo:incbin "%ROMName%":219A68-219B88>> TEMP1.asm
echo:incbin "%ROMName%":219B90-219CB0>> TEMP1.asm
echo:incbin "%ROMName%":219CB8-219DD8>> TEMP1.asm
echo:incbin "%ROMName%":219DE0-219F00>> TEMP1.asm
echo:incbin "%ROMName%":219F08-21A028>> TEMP1.asm
echo:incbin "%ROMName%":21A030-21A150>> TEMP1.asm
echo:incbin "%ROMName%":21A158-21A278>> TEMP1.asm
echo:incbin "%ROMName%":21A280-21A3A0>> TEMP1.asm
echo:incbin "%ROMName%":21A3A8-21A4C8>> TEMP1.asm
echo:incbin "%ROMName%":21A4D0-21A5F0>> TEMP1.asm
echo:incbin "%ROMName%":21A5F8-21A798>> TEMP1.asm
echo:incbin "%ROMName%":21A7A0-21A940>> TEMP1.asm
echo:incbin "%ROMName%":21A948-21AB28>> TEMP1.asm
echo:incbin "%ROMName%":21AB30-21AD10>> TEMP1.asm
echo:incbin "%ROMName%":21AD18-21ADD8>> TEMP1.asm
echo:incbin "%ROMName%":21ADE0-21AEA0>> TEMP1.asm
echo:incbin "%ROMName%":21AEA8-21AF68>> TEMP1.asm
echo:incbin "%ROMName%":21AF70-21B150>> TEMP1.asm
echo:incbin "%ROMName%":21B158-21B398>> TEMP1.asm
echo:incbin "%ROMName%":21B3A0-21B580>> TEMP1.asm
echo:incbin "%ROMName%":21B588-21B768>> TEMP1.asm
echo:incbin "%ROMName%":21B770-21B910>> TEMP1.asm
echo:incbin "%ROMName%":21B918-21BAF8>> TEMP1.asm
echo:incbin "%ROMName%":21BB00-21BCE0>> TEMP1.asm
echo:incbin "%ROMName%":21BCE8-21BEC8>> TEMP1.asm
echo:incbin "%ROMName%":21BED0-21C0F0>> TEMP1.asm
echo:incbin "%ROMName%":21C0F8-21C298>> TEMP1.asm
echo:incbin "%ROMName%":21C2A0-21C480>> TEMP1.asm
echo:incbin "%ROMName%":21C488-21C668>> TEMP1.asm
echo:incbin "%ROMName%":21C670-21C770>> TEMP1.asm
echo:incbin "%ROMName%":21C778-21C838>> TEMP1.asm
echo:incbin "%ROMName%":21C840-21C960>> TEMP1.asm
echo:incbin "%ROMName%":21C968-21CA88>> TEMP1.asm
echo:incbin "%ROMName%":21CA90-21CBB0>> TEMP1.asm
echo:incbin "%ROMName%":21CBB8-21CC78>> TEMP1.asm
echo:incbin "%ROMName%":21CC80-21CD40>> TEMP1.asm
echo:incbin "%ROMName%":21CD48-21CE68>> TEMP1.asm
echo:incbin "%ROMName%":21CE70-21CEF0>> TEMP1.asm
echo:incbin "%ROMName%":21CEF8-21CF78>> TEMP1.asm
echo:incbin "%ROMName%":21CF80-21D000>> TEMP1.asm
echo:incbin "%ROMName%":21D008-21D128>> TEMP1.asm
echo:incbin "%ROMName%":21D130-21D250>> TEMP1.asm
echo:incbin "%ROMName%":21D258-21D378>> TEMP1.asm
echo:incbin "%ROMName%":21D380-21D4A0>> TEMP1.asm
echo:incbin "%ROMName%":21D4A8-21D5C8>> TEMP1.asm
echo:incbin "%ROMName%":21D5D0-21D6F0>> TEMP1.asm
echo:incbin "%ROMName%":21D6F8-21D818>> TEMP1.asm
echo:incbin "%ROMName%":21D820-21D940>> TEMP1.asm
echo:incbin "%ROMName%":21D948-21DA68>> TEMP1.asm
echo:incbin "%ROMName%":21DA70-21DB90>> TEMP1.asm
echo:incbin "%ROMName%":21DB98-21DC58>> TEMP1.asm
echo:incbin "%ROMName%":21DC60-21DD80>> TEMP1.asm
echo:incbin "%ROMName%":21DD88-21DEA8>> TEMP1.asm
echo:incbin "%ROMName%":21DEB0-21DF70>> TEMP1.asm
echo:incbin "%ROMName%":21DF78-21E098>> TEMP1.asm
echo:incbin "%ROMName%":21E0A0-21E1C0>> TEMP1.asm
echo:incbin "%ROMName%":21E1C8-21E2E8>> TEMP1.asm
echo:incbin "%ROMName%":21E2F0-21E410>> TEMP1.asm
echo:incbin "%ROMName%":21E418-21E538>> TEMP1.asm
echo:incbin "%ROMName%":21E540-21E660>> TEMP1.asm
echo:incbin "%ROMName%":21E668-21E788>> TEMP1.asm
echo:incbin "%ROMName%":21E790-21E8B0>> TEMP1.asm
echo:incbin "%ROMName%":21E8B8-21E9D8>> TEMP1.asm
echo:incbin "%ROMName%":21E9E0-21EB00>> TEMP1.asm
echo:incbin "%ROMName%":21EB08-21EC28>> TEMP1.asm
echo:incbin "%ROMName%":21EC30-21ED50>> TEMP1.asm
echo:incbin "%ROMName%":21ED58-21EE18>> TEMP1.asm
echo:incbin "%ROMName%":21EE20-21EEE0>> TEMP1.asm
echo:incbin "%ROMName%":21EEE8-21EFA8>> TEMP1.asm
echo:incbin "%ROMName%":21EFB0-21F0D0>> TEMP1.asm
echo:incbin "%ROMName%":21F0D8-21F1F8>> TEMP1.asm
echo:incbin "%ROMName%":21F200-21F320>> TEMP1.asm
echo:incbin "%ROMName%":21F328-21F448>> TEMP1.asm
echo:incbin "%ROMName%":21F450-21F570>> TEMP1.asm
echo:incbin "%ROMName%":21F578-21F698>> TEMP1.asm
echo:incbin "%ROMName%":21F6A0-21F7C0>> TEMP1.asm
echo:incbin "%ROMName%":21F7C8-21F8E8>> TEMP1.asm
echo:incbin "%ROMName%":21F8F0-21FA10>> TEMP1.asm
echo:incbin "%ROMName%":21FA18-21FAD8>> TEMP1.asm
echo:incbin "%ROMName%":21FAE0-21FC00>> TEMP1.asm
echo:incbin "%ROMName%":21FC08-21FD28>> TEMP1.asm
echo:incbin "%ROMName%":21FD30-21FE50>> TEMP1.asm
echo:incbin "%ROMName%":21FE58-21FF78>> TEMP1.asm
echo:incbin "%ROMName%":21FF80-220000>> TEMP1.asm
echo:incbin "%ROMName%":220008-220128>> TEMP1.asm
echo:incbin "%ROMName%":220130-220250>> TEMP1.asm
echo:incbin "%ROMName%":220258-220378>> TEMP1.asm
echo:incbin "%ROMName%":220380-2204A0>> TEMP1.asm
echo:incbin "%ROMName%":2204A8-220628>> TEMP1.asm
echo:incbin "%ROMName%":220630-2206B0>> TEMP1.asm
echo:incbin "%ROMName%":2206B8-220738>> TEMP1.asm
echo:incbin "%ROMName%":220740-2207C0>> TEMP1.asm
echo:incbin "%ROMName%":2207C8-220848>> TEMP1.asm
echo:incbin "%ROMName%":220850-220910>> TEMP1.asm
echo:incbin "%ROMName%":220918-2209F8>> TEMP1.asm
echo:incbin "%ROMName%":220A00-220B00>> TEMP1.asm
echo:incbin "%ROMName%":220B08-220C28>> TEMP1.asm
echo:incbin "%ROMName%":220C30-220D50>> TEMP1.asm
echo:incbin "%ROMName%":220D58-220E78>> TEMP1.asm
echo:incbin "%ROMName%":220E80-220FA0>> TEMP1.asm
echo:incbin "%ROMName%":220FA8-2210C8>> TEMP1.asm
echo:incbin "%ROMName%":2210D0-2211F0>> TEMP1.asm
echo:incbin "%ROMName%":2211F8-221318>> TEMP1.asm
echo:incbin "%ROMName%":221320-221440>> TEMP1.asm
echo:incbin "%ROMName%":221448-221568>> TEMP1.asm
echo:incbin "%ROMName%":221570-221690>> TEMP1.asm
echo:incbin "%ROMName%":221698-2217B8>> TEMP1.asm
echo:incbin "%ROMName%":2217C0-2218E0>> TEMP1.asm
echo:incbin "%ROMName%":2218E8-221968>> TEMP1.asm
echo:incbin "%ROMName%":221970-221A70>> TEMP1.asm
echo:incbin "%ROMName%":221A78-221AF8>> TEMP1.asm
echo:incbin "%ROMName%":221B00-221BC0>> TEMP1.asm
echo:incbin "%ROMName%":221BC8-221C88>> TEMP1.asm
echo:incbin "%ROMName%":221C90-221D50>> TEMP1.asm
echo:incbin "%ROMName%":221D58-221E78>> TEMP1.asm
echo:incbin "%ROMName%":221E80-221FA0>> TEMP1.asm
echo:incbin "%ROMName%":221FA8-222068>> TEMP1.asm
echo:incbin "%ROMName%":222070-222150>> TEMP1.asm
echo:incbin "%ROMName%":222158-222258>> TEMP1.asm
echo:incbin "%ROMName%":222260-222340>> TEMP1.asm
echo:incbin "%ROMName%":222348-222448>> TEMP1.asm
echo:incbin "%ROMName%":222450-222510>> TEMP1.asm
echo:incbin "%ROMName%":222518-222638>> TEMP1.asm
echo:incbin "%ROMName%":222640-222720>> TEMP1.asm
echo:incbin "%ROMName%":222728-222848>> TEMP1.asm
echo:incbin "%ROMName%":222850-222950>> TEMP1.asm
echo:incbin "%ROMName%":222958-222A58>> TEMP1.asm
echo:incbin "%ROMName%":222A60-222B80>> TEMP1.asm
echo:incbin "%ROMName%":222B88-222CA8>> TEMP1.asm
echo:incbin "%ROMName%":222CB0-222DD0>> TEMP1.asm
echo:incbin "%ROMName%":222DD8-222FB8>> TEMP1.asm
echo:incbin "%ROMName%":222FC0-223200>> TEMP1.asm
echo:incbin "%ROMName%":223208-2233E8>> TEMP1.asm
echo:incbin "%ROMName%":2233F0-2235D0>> TEMP1.asm
echo:incbin "%ROMName%":2235D8-223778>> TEMP1.asm
echo:incbin "%ROMName%":223780-223960>> TEMP1.asm
echo:incbin "%ROMName%":223968-223B48>> TEMP1.asm
echo:incbin "%ROMName%":223B50-223D30>> TEMP1.asm
echo:incbin "%ROMName%":223D38-223F58>> TEMP1.asm
echo:incbin "%ROMName%":223F60-224180>> TEMP1.asm
echo:incbin "%ROMName%":224188-2243A8>> TEMP1.asm
echo:incbin "%ROMName%":2243B0-224610>> TEMP1.asm
echo:incbin "%ROMName%":224618-224838>> TEMP1.asm
echo:incbin "%ROMName%":224840-224960>> TEMP1.asm
echo:incbin "%ROMName%":224968-224A88>> TEMP1.asm
echo:incbin "%ROMName%":224A90-224BB0>> TEMP1.asm
echo:incbin "%ROMName%":224BB8-224CD8>> TEMP1.asm
echo:incbin "%ROMName%":224CE0-224E00>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Kirby.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Gooey's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":1FFFD8-1FFFF8>> TEMP1.asm
echo:incbin "%ROMName%":22F09A-22F21A>> TEMP1.asm
echo:incbin "%ROMName%":22F222-22F3C2>> TEMP1.asm
echo:incbin "%ROMName%":22F3CA-22F56A>> TEMP1.asm
echo:incbin "%ROMName%":22F572-22F712>> TEMP1.asm
echo:incbin "%ROMName%":22F71A-22F89A>> TEMP1.asm
echo:incbin "%ROMName%":22F8A2-22FA42>> TEMP1.asm
echo:incbin "%ROMName%":22FA4A-22FB6A>> TEMP1.asm
echo:incbin "%ROMName%":22FB72-22FC92>> TEMP1.asm
echo:incbin "%ROMName%":22FC9A-22FD5A>> TEMP1.asm
echo:incbin "%ROMName%":22FD62-22FE22>> TEMP1.asm
echo:incbin "%ROMName%":22FE2A-22FF4A>> TEMP1.asm
echo:incbin "%ROMName%":22FF52-22FFD2>> TEMP1.asm
echo:incbin "%ROMName%":230008-230128>> TEMP1.asm
echo:incbin "%ROMName%":230130-230250>> TEMP1.asm
echo:incbin "%ROMName%":230258-230378>> TEMP1.asm
echo:incbin "%ROMName%":230380-2304A0>> TEMP1.asm
echo:incbin "%ROMName%":2304A8-2305C8>> TEMP1.asm
echo:incbin "%ROMName%":2305D0-2306F0>> TEMP1.asm
echo:incbin "%ROMName%":2306F8-230818>> TEMP1.asm
echo:incbin "%ROMName%":230820-230940>> TEMP1.asm
echo:incbin "%ROMName%":230948-230A68>> TEMP1.asm
echo:incbin "%ROMName%":230A70-230B90>> TEMP1.asm
echo:incbin "%ROMName%":230B98-230CB8>> TEMP1.asm
echo:incbin "%ROMName%":230CC0-230DE0>> TEMP1.asm
echo:incbin "%ROMName%":230DE8-230F08>> TEMP1.asm
echo:incbin "%ROMName%":230F10-231030>> TEMP1.asm
echo:incbin "%ROMName%":231038-231158>> TEMP1.asm
echo:incbin "%ROMName%":231160-231280>> TEMP1.asm
echo:incbin "%ROMName%":231288-2313A8>> TEMP1.asm
echo:incbin "%ROMName%":2313B0-2314D0>> TEMP1.asm
echo:incbin "%ROMName%":2314D8-2315F8>> TEMP1.asm
echo:incbin "%ROMName%":231600-231720>> TEMP1.asm
echo:incbin "%ROMName%":231728-231848>> TEMP1.asm
echo:incbin "%ROMName%":231850-231910>> TEMP1.asm
echo:incbin "%ROMName%":231918-2319D8>> TEMP1.asm
echo:incbin "%ROMName%":2319E0-231AA0>> TEMP1.asm
echo:incbin "%ROMName%":231AA8-231B68>> TEMP1.asm
echo:incbin "%ROMName%":231B70-231C30>> TEMP1.asm
echo:incbin "%ROMName%":231C38-231D58>> TEMP1.asm
echo:incbin "%ROMName%":231D60-231E80>> TEMP1.asm
echo:incbin "%ROMName%":231E88-231FA8>> TEMP1.asm
echo:incbin "%ROMName%":231FB0-2320D0>> TEMP1.asm
echo:incbin "%ROMName%":2320D8-2321F8>> TEMP1.asm
echo:incbin "%ROMName%":232200-232320>> TEMP1.asm
echo:incbin "%ROMName%":232328-232448>> TEMP1.asm
echo:incbin "%ROMName%":232450-232570>> TEMP1.asm
echo:incbin "%ROMName%":232578-232698>> TEMP1.asm
echo:incbin "%ROMName%":2326A0-2327C0>> TEMP1.asm
echo:incbin "%ROMName%":2327C8-2328E8>> TEMP1.asm
echo:incbin "%ROMName%":2328F0-232A10>> TEMP1.asm
echo:incbin "%ROMName%":232A18-232B38>> TEMP1.asm
echo:incbin "%ROMName%":232B40-232C60>> TEMP1.asm
echo:incbin "%ROMName%":232C68-232D88>> TEMP1.asm
echo:incbin "%ROMName%":232D90-232EB0>> TEMP1.asm
echo:incbin "%ROMName%":232EB8-232FD8>> TEMP1.asm
echo:incbin "%ROMName%":232FE0-233100>> TEMP1.asm
echo:incbin "%ROMName%":233108-233228>> TEMP1.asm
echo:incbin "%ROMName%":233230-233350>> TEMP1.asm
echo:incbin "%ROMName%":233358-233478>> TEMP1.asm
echo:incbin "%ROMName%":233480-2335A0>> TEMP1.asm
echo:incbin "%ROMName%":2335A8-2336C8>> TEMP1.asm
echo:incbin "%ROMName%":2336D0-2337F0>> TEMP1.asm
echo:incbin "%ROMName%":2337F8-233918>> TEMP1.asm
echo:incbin "%ROMName%":233920-233A40>> TEMP1.asm
echo:incbin "%ROMName%":233A48-233B68>> TEMP1.asm
echo:incbin "%ROMName%":233B70-233C30>> TEMP1.asm
echo:incbin "%ROMName%":233C38-233D58>> TEMP1.asm
echo:incbin "%ROMName%":233D60-233E80>> TEMP1.asm
echo:incbin "%ROMName%":233E88-233FA8>> TEMP1.asm
echo:incbin "%ROMName%":233FB0-2340D0>> TEMP1.asm
echo:incbin "%ROMName%":2340D8-2341F8>> TEMP1.asm
echo:incbin "%ROMName%":234200-234360>> TEMP1.asm
echo:incbin "%ROMName%":234368-234548>> TEMP1.asm
echo:incbin "%ROMName%":234550-2346F0>> TEMP1.asm
echo:incbin "%ROMName%":2346F8-234858>> TEMP1.asm
echo:incbin "%ROMName%":234860-234980>> TEMP1.asm
echo:incbin "%ROMName%":234988-234AA8>> TEMP1.asm
echo:incbin "%ROMName%":234AB0-234BD0>> TEMP1.asm
echo:incbin "%ROMName%":234BD8-234CF8>> TEMP1.asm
echo:incbin "%ROMName%":234D00-234E20>> TEMP1.asm
echo:incbin "%ROMName%":234E28-234F48>> TEMP1.asm
echo:incbin "%ROMName%":234F50-235070>> TEMP1.asm
echo:incbin "%ROMName%":235078-235138>> TEMP1.asm
echo:incbin "%ROMName%":235140-235200>> TEMP1.asm
echo:incbin "%ROMName%":235208-2352C8>> TEMP1.asm
echo:incbin "%ROMName%":2352D0-235390>> TEMP1.asm
echo:incbin "%ROMName%":235398-235458>> TEMP1.asm
echo:incbin "%ROMName%":235460-235580>> TEMP1.asm
echo:incbin "%ROMName%":235588-2356A8>> TEMP1.asm
echo:incbin "%ROMName%":2356B0-2357D0>> TEMP1.asm
echo:incbin "%ROMName%":2357D8-2358F8>> TEMP1.asm
echo:incbin "%ROMName%":235900-235AA0>> TEMP1.asm
echo:incbin "%ROMName%":235AA8-235C48>> TEMP1.asm
echo:incbin "%ROMName%":235C50-235E30>> TEMP1.asm
echo:incbin "%ROMName%":235E38-236018>> TEMP1.asm
echo:incbin "%ROMName%":236020-236140>> TEMP1.asm
echo:incbin "%ROMName%":236148-236208>> TEMP1.asm
echo:incbin "%ROMName%":236210-2363B0>> TEMP1.asm
echo:incbin "%ROMName%":2363B8-236578>> TEMP1.asm
echo:incbin "%ROMName%":236580-236720>> TEMP1.asm
echo:incbin "%ROMName%":236728-2368C8>> TEMP1.asm
echo:incbin "%ROMName%":2368D0-236A90>> TEMP1.asm
echo:incbin "%ROMName%":236A98-236C38>> TEMP1.asm
echo:incbin "%ROMName%":236C40-236F60>> TEMP1.asm
echo:incbin "%ROMName%":236F68-237288>> TEMP1.asm
echo:incbin "%ROMName%":237290-2375B0>> TEMP1.asm
echo:incbin "%ROMName%":2375B8-2376D8>> TEMP1.asm
echo:incbin "%ROMName%":2376E0-237880>> TEMP1.asm
echo:incbin "%ROMName%":237888-237A48>> TEMP1.asm
echo:incbin "%ROMName%":237A50-237B70>> TEMP1.asm
echo:incbin "%ROMName%":237B78-237C98>> TEMP1.asm
echo:incbin "%ROMName%":237CA0-237DC0>> TEMP1.asm
echo:incbin "%ROMName%":237DC8-237EE8>> TEMP1.asm
echo:incbin "%ROMName%":237EF0-238010>> TEMP1.asm
echo:incbin "%ROMName%":238018-238138>> TEMP1.asm
echo:incbin "%ROMName%":238140-238260>> TEMP1.asm
echo:incbin "%ROMName%":238268-238468>> TEMP1.asm
echo:incbin "%ROMName%":238470-238670>> TEMP1.asm
echo:incbin "%ROMName%":238678-238878>> TEMP1.asm
echo:incbin "%ROMName%":238880-238A20>> TEMP1.asm
echo:incbin "%ROMName%":238A28-238BC8>> TEMP1.asm
echo:incbin "%ROMName%":238BD0-238DB0>> TEMP1.asm
echo:incbin "%ROMName%":238DB8-238F98>> TEMP1.asm
echo:incbin "%ROMName%":238FA0-2391E0>> TEMP1.asm
echo:incbin "%ROMName%":2391E8-239388>> TEMP1.asm
echo:incbin "%ROMName%":239390-239530>> TEMP1.asm
echo:incbin "%ROMName%":239538-2396D8>> TEMP1.asm
echo:incbin "%ROMName%":2396E0-239880>> TEMP1.asm
echo:incbin "%ROMName%":239888-239A28>> TEMP1.asm
echo:incbin "%ROMName%":239A30-239C50>> TEMP1.asm
echo:incbin "%ROMName%":239C58-239DF8>> TEMP1.asm
echo:incbin "%ROMName%":239E00-239FA0>> TEMP1.asm
echo:incbin "%ROMName%":239FA8-23A148>> TEMP1.asm
echo:incbin "%ROMName%":23A150-23A2F0>> TEMP1.asm
echo:incbin "%ROMName%":23A2F8-23A498>> TEMP1.asm
echo:incbin "%ROMName%":23A4A0-23A640>> TEMP1.asm
echo:incbin "%ROMName%":23A648-23A7E8>> TEMP1.asm
echo:incbin "%ROMName%":23A7F0-23A990>> TEMP1.asm
echo:incbin "%ROMName%":23A998-23AB38>> TEMP1.asm
echo:incbin "%ROMName%":23AB40-23ACE0>> TEMP1.asm
echo:incbin "%ROMName%":23ACE8-23AE88>> TEMP1.asm
echo:incbin "%ROMName%":23AE90-23B030>> TEMP1.asm
echo:incbin "%ROMName%":23B038-23B1D8>> TEMP1.asm
echo:incbin "%ROMName%":23B1E0-23B380>> TEMP1.asm
echo:incbin "%ROMName%":23B388-23B528>> TEMP1.asm
echo:incbin "%ROMName%":23B530-23B6D0>> TEMP1.asm
echo:incbin "%ROMName%":23B6D8-23B878>> TEMP1.asm
echo:incbin "%ROMName%":23B880-23BA20>> TEMP1.asm
echo:incbin "%ROMName%":23BA28-23BBC8>> TEMP1.asm
echo:incbin "%ROMName%":23BBD0-23BD70>> TEMP1.asm
echo:incbin "%ROMName%":23BD78-23BF18>> TEMP1.asm
echo:incbin "%ROMName%":23BF20-23C0C0>> TEMP1.asm
echo:incbin "%ROMName%":23C0C8-23C268>> TEMP1.asm
echo:incbin "%ROMName%":23C270-23C410>> TEMP1.asm
echo:incbin "%ROMName%":23C418-23C5B8>> TEMP1.asm
echo:incbin "%ROMName%":23C5C0-23C760>> TEMP1.asm
echo:incbin "%ROMName%":23C768-23C908>> TEMP1.asm
echo:incbin "%ROMName%":23C910-23CAB0>> TEMP1.asm
echo:incbin "%ROMName%":23CAB8-23CC58>> TEMP1.asm
echo:incbin "%ROMName%":23CC60-23CE00>> TEMP1.asm
echo:incbin "%ROMName%":23CE08-23CFA8>> TEMP1.asm
echo:incbin "%ROMName%":23CFB0-23D150>> TEMP1.asm
echo:incbin "%ROMName%":23D158-23D298>> TEMP1.asm
echo:incbin "%ROMName%":23D2A0-23D440>> TEMP1.asm
echo:incbin "%ROMName%":23D448-23D508>> TEMP1.asm
echo:incbin "%ROMName%":23D510-23D5D0>> TEMP1.asm
echo:incbin "%ROMName%":23D5D8-23D818>> TEMP1.asm
echo:incbin "%ROMName%":23D820-23DBA0>> TEMP1.asm
echo:incbin "%ROMName%":23DBA8-23DEE8>> TEMP1.asm
echo:incbin "%ROMName%":23DEF0-23E2D0>> TEMP1.asm
echo:incbin "%ROMName%":23E2D8-23E3F8>> TEMP1.asm
echo:incbin "%ROMName%":23E400-23E520>> TEMP1.asm
echo:incbin "%ROMName%":23E528-23E5E8>> TEMP1.asm
echo:incbin "%ROMName%":23E5F0-23E710>> TEMP1.asm
echo:incbin "%ROMName%":23E718-23E838>> TEMP1.asm
echo:incbin "%ROMName%":23E840-23E960>> TEMP1.asm
echo:incbin "%ROMName%":23E968-23EA88>> TEMP1.asm
echo:incbin "%ROMName%":23EA90-23EBB0>> TEMP1.asm
echo:incbin "%ROMName%":23EBB8-23ECD8>> TEMP1.asm
echo:incbin "%ROMName%":23ECE0-23EE00>> TEMP1.asm
echo:incbin "%ROMName%":23EE08-23EF28>> TEMP1.asm
echo:incbin "%ROMName%":23EF30-23F050>> TEMP1.asm
echo:incbin "%ROMName%":23F058-23F178>> TEMP1.asm
echo:incbin "%ROMName%":23F180-23F2A0>> TEMP1.asm
echo:incbin "%ROMName%":23F2A8-23F3C8>> TEMP1.asm
echo:incbin "%ROMName%":23F3D0-23F4F0>> TEMP1.asm
echo:incbin "%ROMName%":23F4F8-23F678>> TEMP1.asm
echo:incbin "%ROMName%":23F680-23F820>> TEMP1.asm
echo:incbin "%ROMName%":23F828-23F9C8>> TEMP1.asm
echo:incbin "%ROMName%":23F9D0-23FB70>> TEMP1.asm
echo:incbin "%ROMName%":23FB78-23FD18>> TEMP1.asm
echo:incbin "%ROMName%":23FD20-23FE40>> TEMP1.asm
echo:incbin "%ROMName%":23FE48-23FF68>> TEMP1.asm
echo:incbin "%ROMName%":23FF70-23FFB0>> TEMP1.asm
echo:incbin "%ROMName%":23FFB8-23FFF8>> TEMP1.asm
echo:incbin "%ROMName%":240008-2400E8>> TEMP1.asm
echo:incbin "%ROMName%":2400F0-2401B0>> TEMP1.asm
echo:incbin "%ROMName%":2401B8-240278>> TEMP1.asm
echo:incbin "%ROMName%":240280-2403A0>> TEMP1.asm
echo:incbin "%ROMName%":2403A8-2404C8>> TEMP1.asm
echo:incbin "%ROMName%":2404D0-2405F0>> TEMP1.asm
echo:incbin "%ROMName%":2405F8-2406B8>> TEMP1.asm
echo:incbin "%ROMName%":2406C0-2407E0>> TEMP1.asm
echo:incbin "%ROMName%":2407E8-240908>> TEMP1.asm
echo:incbin "%ROMName%":240910-240A30>> TEMP1.asm
echo:incbin "%ROMName%":240A38-240B58>> TEMP1.asm
echo:incbin "%ROMName%":240B60-240C80>> TEMP1.asm
echo:incbin "%ROMName%":240C88-240D48>> TEMP1.asm
echo:incbin "%ROMName%":240D50-240E70>> TEMP1.asm
echo:incbin "%ROMName%":240E78-240F98>> TEMP1.asm
echo:incbin "%ROMName%":240FA0-2410C0>> TEMP1.asm
echo:incbin "%ROMName%":2410C8-2411E8>> TEMP1.asm
echo:incbin "%ROMName%":2411F0-241310>> TEMP1.asm
echo:incbin "%ROMName%":241318-241438>> TEMP1.asm
echo:incbin "%ROMName%":241440-241560>> TEMP1.asm
echo:incbin "%ROMName%":241568-241688>> TEMP1.asm
echo:incbin "%ROMName%":241690-2417B0>> TEMP1.asm
echo:incbin "%ROMName%":2417B8-2418D8>> TEMP1.asm
echo:incbin "%ROMName%":2418E0-241A00>> TEMP1.asm
echo:incbin "%ROMName%":241A08-241B28>> TEMP1.asm
echo:incbin "%ROMName%":241B30-241C50>> TEMP1.asm
echo:incbin "%ROMName%":241C58-241D78>> TEMP1.asm
echo:incbin "%ROMName%":241D80-241EA0>> TEMP1.asm
echo:incbin "%ROMName%":241EA8-241FC8>> TEMP1.asm
echo:incbin "%ROMName%":241FD0-242090>> TEMP1.asm
echo:incbin "%ROMName%":242098-242158>> TEMP1.asm
echo:incbin "%ROMName%":242160-242220>> TEMP1.asm
echo:incbin "%ROMName%":242228-242348>> TEMP1.asm
echo:incbin "%ROMName%":242350-242410>> TEMP1.asm
echo:incbin "%ROMName%":242418-242538>> TEMP1.asm
echo:incbin "%ROMName%":242540-242660>> TEMP1.asm
echo:incbin "%ROMName%":242668-242788>> TEMP1.asm
echo:incbin "%ROMName%":242790-2428B0>> TEMP1.asm
echo:incbin "%ROMName%":2428B8-2429D8>> TEMP1.asm
echo:incbin "%ROMName%":2429E0-242B00>> TEMP1.asm
echo:incbin "%ROMName%":242B08-242C28>> TEMP1.asm
echo:incbin "%ROMName%":242C30-242CF0>> TEMP1.asm
echo:incbin "%ROMName%":242CF8-242DB8>> TEMP1.asm
echo:incbin "%ROMName%":242DC0-242EE0>> TEMP1.asm
echo:incbin "%ROMName%":242EE8-243008>> TEMP1.asm
echo:incbin "%ROMName%":243010-243130>> TEMP1.asm
echo:incbin "%ROMName%":243138-243258>> TEMP1.asm
echo:incbin "%ROMName%":243260-243380>> TEMP1.asm
echo:incbin "%ROMName%":243388-2434A8>> TEMP1.asm
echo:incbin "%ROMName%":2434B0-2435B0>> TEMP1.asm
echo:incbin "%ROMName%":2435B8-243698>> TEMP1.asm
echo:incbin "%ROMName%":2436A0-2437A0>> TEMP1.asm
echo:incbin "%ROMName%":2437A8-2438A8>> TEMP1.asm
echo:incbin "%ROMName%":2438B0-2439B0>> TEMP1.asm
echo:incbin "%ROMName%":2439B8-243AB8>> TEMP1.asm
echo:incbin "%ROMName%":243AC0-243BE0>> TEMP1.asm
echo:incbin "%ROMName%":243BE8-243D08>> TEMP1.asm
echo:incbin "%ROMName%":243D10-243E30>> TEMP1.asm
echo:incbin "%ROMName%":243E38-243F58>> TEMP1.asm
echo:incbin "%ROMName%":243F60-244020>> TEMP1.asm
echo:incbin "%ROMName%":244028-2440E8>> TEMP1.asm
echo:incbin "%ROMName%":2440F0-2441D0>> TEMP1.asm
echo:incbin "%ROMName%":2441D8-2442B8>> TEMP1.asm
echo:incbin "%ROMName%":2442C0-2443A0>> TEMP1.asm
echo:incbin "%ROMName%":2443A8-244508>> TEMP1.asm
echo:incbin "%ROMName%":244510-2446F0>> TEMP1.asm
echo:incbin "%ROMName%":2446F8-2448B8>> TEMP1.asm
echo:incbin "%ROMName%":2448C0-244AA0>> TEMP1.asm
echo:incbin "%ROMName%":244AA8-244C28>> TEMP1.asm
echo:incbin "%ROMName%":244C30-244DD0>> TEMP1.asm
echo:incbin "%ROMName%":244DD8-244F78>> TEMP1.asm
echo:incbin "%ROMName%":244F80-245180>> TEMP1.asm
echo:incbin "%ROMName%":245188-245388>> TEMP1.asm
echo:incbin "%ROMName%":245390-245530>> TEMP1.asm
echo:incbin "%ROMName%":245538-245638>> TEMP1.asm
echo:incbin "%ROMName%":245640-245720>> TEMP1.asm
echo:incbin "%ROMName%":245728-245808>> TEMP1.asm
echo:incbin "%ROMName%":245810-2458F0>> TEMP1.asm
echo:incbin "%ROMName%":2458F8-2459B8>> TEMP1.asm
echo:incbin "%ROMName%":2459C0-245AE0>> TEMP1.asm
echo:incbin "%ROMName%":245AE8-245C28>> TEMP1.asm
echo:incbin "%ROMName%":245C30-245D70>> TEMP1.asm
echo:incbin "%ROMName%":245D78-245EF8>> TEMP1.asm
echo:incbin "%ROMName%":245F00-246080>> TEMP1.asm
echo:incbin "%ROMName%":246088-246148>> TEMP1.asm
echo:incbin "%ROMName%":246150-2461D0>> TEMP1.asm
echo:incbin "%ROMName%":2461D8-246298>> TEMP1.asm
echo:incbin "%ROMName%":2462A0-246300>> TEMP1.asm
echo:incbin "%ROMName%":246308-246348>> TEMP1.asm
echo:incbin "%ROMName%":246350-246390>> TEMP1.asm
echo:incbin "%ROMName%":246398-246458>> TEMP1.asm
echo:incbin "%ROMName%":246460-246520>> TEMP1.asm
echo:incbin "%ROMName%":246528-246568>> TEMP1.asm
echo:incbin "%ROMName%":246570-2465B0>> TEMP1.asm
echo:incbin "%ROMName%":2465B8-2465F8>> TEMP1.asm
echo:incbin "%ROMName%":246600-246680>> TEMP1.asm
echo:incbin "%ROMName%":246688-246748>> TEMP1.asm
echo:incbin "%ROMName%":246750-246850>> TEMP1.asm
echo:incbin "%ROMName%":246858-246918>> TEMP1.asm
echo:incbin "%ROMName%":246920-2469A0>> TEMP1.asm
echo:incbin "%ROMName%":2469A8-246A68>> TEMP1.asm
echo:incbin "%ROMName%":246A70-246B30>> TEMP1.asm
echo:incbin "%ROMName%":246B38-246BF8>> TEMP1.asm
echo:incbin "%ROMName%":246C00-246C80>> TEMP1.asm
echo:incbin "%ROMName%":246C88-246CC8>> TEMP1.asm
echo:incbin "%ROMName%":246CD0-246D10>> TEMP1.asm
echo:incbin "%ROMName%":246D18-246D98>> TEMP1.asm
echo:incbin "%ROMName%":246DA0-246E20>> TEMP1.asm
echo:incbin "%ROMName%":246E28-246EE8>> TEMP1.asm
echo:incbin "%ROMName%":246EF0-246F30>> TEMP1.asm
echo:incbin "%ROMName%":246F38-246F78>> TEMP1.asm
echo:incbin "%ROMName%":246F80-246FC0>> TEMP1.asm
echo:incbin "%ROMName%":246FC8-247088>> TEMP1.asm
echo:incbin "%ROMName%":247090-247150>> TEMP1.asm
echo:incbin "%ROMName%":247158-247198>> TEMP1.asm
echo:incbin "%ROMName%":2471A0-2471E0>> TEMP1.asm
echo:incbin "%ROMName%":2471E8-247228>> TEMP1.asm
echo:incbin "%ROMName%":247230-247290>> TEMP1.asm
echo:incbin "%ROMName%":247298-247318>> TEMP1.asm
echo:incbin "%ROMName%":247320-247420>> TEMP1.asm
echo:incbin "%ROMName%":247428-247468>> TEMP1.asm
echo:incbin "%ROMName%":247470-2474B0>> TEMP1.asm
echo:incbin "%ROMName%":2474B8-247518>> TEMP1.asm
echo:incbin "%ROMName%":247520-247580>> TEMP1.asm
echo:incbin "%ROMName%":247588-247608>> TEMP1.asm
echo:incbin "%ROMName%":247610-2476D0>> TEMP1.asm
echo:incbin "%ROMName%":2476D8-247818>> TEMP1.asm
echo:incbin "%ROMName%":247820-2478A0>> TEMP1.asm
echo:incbin "%ROMName%":2478A8-247928>> TEMP1.asm
echo:incbin "%ROMName%":247930-2479F0>> TEMP1.asm
echo:incbin "%ROMName%":2479F8-247A78>> TEMP1.asm
echo:incbin "%ROMName%":247A80-247AC0>> TEMP1.asm
echo:incbin "%ROMName%":247AC8-247B48>> TEMP1.asm
echo:incbin "%ROMName%":247B50-247C50>> TEMP1.asm
echo:incbin "%ROMName%":247C58-247D58>> TEMP1.asm
echo:incbin "%ROMName%":247D60-247E60>> TEMP1.asm
echo:incbin "%ROMName%":247E68-247EE8>> TEMP1.asm
echo:incbin "%ROMName%":247EF0-247F70>> TEMP1.asm
echo:incbin "%ROMName%":247F78-248098>> TEMP1.asm
echo:incbin "%ROMName%":2480A0-2481C0>> TEMP1.asm
echo:incbin "%ROMName%":2481C8-2482E8>> TEMP1.asm
echo:incbin "%ROMName%":2482F0-248410>> TEMP1.asm
echo:incbin "%ROMName%":248418-248498>> TEMP1.asm
echo:incbin "%ROMName%":2484A0-248520>> TEMP1.asm
echo:incbin "%ROMName%":248528-248648>> TEMP1.asm
echo:incbin "%ROMName%":248650-248790>> TEMP1.asm
echo:incbin "%ROMName%":248798-2488D8>> TEMP1.asm
echo:incbin "%ROMName%":2488E0-248A60>> TEMP1.asm
echo:incbin "%ROMName%":248A68-248BE8>> TEMP1.asm
echo:incbin "%ROMName%":248BF0-248CB0>> TEMP1.asm
echo:incbin "%ROMName%":248CB8-248D78>> TEMP1.asm
echo:incbin "%ROMName%":248D80-248E40>> TEMP1.asm
echo:incbin "%ROMName%":248E48-248F08>> TEMP1.asm
echo:incbin "%ROMName%":248F10-248FD0>> TEMP1.asm
echo:incbin "%ROMName%":248FD8-249098>> TEMP1.asm
echo:incbin "%ROMName%":2490A0-249160>> TEMP1.asm
echo:incbin "%ROMName%":249168-249228>> TEMP1.asm
echo:incbin "%ROMName%":249230-2492F0>> TEMP1.asm
echo:incbin "%ROMName%":2492F8-2493B8>> TEMP1.asm
echo:incbin "%ROMName%":2493C0-249480>> TEMP1.asm
echo:incbin "%ROMName%":249488-249548>> TEMP1.asm
echo:incbin "%ROMName%":249550-249610>> TEMP1.asm
echo:incbin "%ROMName%":249618-2496D8>> TEMP1.asm
echo:incbin "%ROMName%":2496E0-2497A0>> TEMP1.asm
echo:incbin "%ROMName%":2497A8-249868>> TEMP1.asm
echo:incbin "%ROMName%":249870-249970>> TEMP1.asm
echo:incbin "%ROMName%":249978-249AB8>> TEMP1.asm
echo:incbin "%ROMName%":249AC0-249C40>> TEMP1.asm
echo:incbin "%ROMName%":249C48-249D88>> TEMP1.asm
echo:incbin "%ROMName%":249D90-249E90>> TEMP1.asm
echo:incbin "%ROMName%":249E98-249FB8>> TEMP1.asm
echo:incbin "%ROMName%":249FC0-24A0E0>> TEMP1.asm
echo:incbin "%ROMName%":24A0E8-24A208>> TEMP1.asm
echo:incbin "%ROMName%":24A210-24A330>> TEMP1.asm
echo:incbin "%ROMName%":24A338-24A3F8>> TEMP1.asm
echo:incbin "%ROMName%":24A400-24A4C0>> TEMP1.asm
echo:incbin "%ROMName%":24A4C8-24A588>> TEMP1.asm
echo:incbin "%ROMName%":24A590-24A6B0>> TEMP1.asm
echo:incbin "%ROMName%":24A6B8-24A7D8>> TEMP1.asm
echo:incbin "%ROMName%":24A7E0-24A960>> TEMP1.asm
echo:incbin "%ROMName%":24A968-24AA28>> TEMP1.asm
echo:incbin "%ROMName%":24AA30-24AB30>> TEMP1.asm
echo:incbin "%ROMName%":24AB38-24AC38>> TEMP1.asm
echo:incbin "%ROMName%":24AC40-24AD00>> TEMP1.asm
echo:incbin "%ROMName%":24AD08-24ADC8>> TEMP1.asm
echo:incbin "%ROMName%":24ADD0-24AE90>> TEMP1.asm
echo:incbin "%ROMName%":24AE98-24AF58>> TEMP1.asm
echo:incbin "%ROMName%":24AF60-24B020>> TEMP1.asm
echo:incbin "%ROMName%":24B028-24B0E8>> TEMP1.asm
echo:incbin "%ROMName%":24B0F0-24B1B0>> TEMP1.asm
echo:incbin "%ROMName%":24B1B8-24B2B8>> TEMP1.asm
echo:incbin "%ROMName%":24B2C0-24B3C0>> TEMP1.asm
echo:incbin "%ROMName%":24B3C8-24B4C8>> TEMP1.asm
echo:incbin "%ROMName%":24B4D0-24B5F0>> TEMP1.asm
echo:incbin "%ROMName%":24B5F8-24B718>> TEMP1.asm
echo:incbin "%ROMName%":24B720-24B840>> TEMP1.asm
echo:incbin "%ROMName%":24B848-24B968>> TEMP1.asm
echo:incbin "%ROMName%":24B970-24BA90>> TEMP1.asm
echo:incbin "%ROMName%":24BA98-24BBB8>> TEMP1.asm
echo:incbin "%ROMName%":24BBC0-24BCE0>> TEMP1.asm
echo:incbin "%ROMName%":24BCE8-24BE28>> TEMP1.asm
echo:incbin "%ROMName%":24BE30-24C030>> TEMP1.asm
echo:incbin "%ROMName%":24C038-24C1B8>> TEMP1.asm
echo:incbin "%ROMName%":24C1C0-24C300>> TEMP1.asm
echo:incbin "%ROMName%":24C308-24C488>> TEMP1.asm
echo:incbin "%ROMName%":24C490-24C550>> TEMP1.asm
echo:incbin "%ROMName%":24C558-24C618>> TEMP1.asm
echo:incbin "%ROMName%":24C620-24C740>> TEMP1.asm
echo:incbin "%ROMName%":24C748-24C868>> TEMP1.asm
echo:incbin "%ROMName%":24C870-24C990>> TEMP1.asm
echo:incbin "%ROMName%":24C998-24CA58>> TEMP1.asm
echo:incbin "%ROMName%":24CA60-24CBA0>> TEMP1.asm
echo:incbin "%ROMName%":24CBA8-24CD28>> TEMP1.asm
echo:incbin "%ROMName%":24CD30-24CEB0>> TEMP1.asm
echo:incbin "%ROMName%":24CEB8-24D038>> TEMP1.asm
echo:incbin "%ROMName%":24D040-24D1C0>> TEMP1.asm
echo:incbin "%ROMName%":24D1C8-24D348>> TEMP1.asm
echo:incbin "%ROMName%":24D350-24D4D0>> TEMP1.asm
echo:incbin "%ROMName%":24D4D8-24D658>> TEMP1.asm
echo:incbin "%ROMName%":24D660-24D7E0>> TEMP1.asm
echo:incbin "%ROMName%":24D7E8-24D968>> TEMP1.asm
echo:incbin "%ROMName%":24D970-24DAF0>> TEMP1.asm
echo:incbin "%ROMName%":24DAF8-24DC78>> TEMP1.asm
echo:incbin "%ROMName%":24DC80-24DE00>> TEMP1.asm
echo:incbin "%ROMName%":24DE08-24DF88>> TEMP1.asm
echo:incbin "%ROMName%":24DF90-24E110>> TEMP1.asm
echo:incbin "%ROMName%":24E118-24E1D8>> TEMP1.asm
echo:incbin "%ROMName%":24E1E0-24E300>> TEMP1.asm
echo:incbin "%ROMName%":24E308-24E428>> TEMP1.asm
echo:incbin "%ROMName%":24E430-24E550>> TEMP1.asm
echo:incbin "%ROMName%":24E558-24E678>> TEMP1.asm
echo:incbin "%ROMName%":24E680-24E7A0>> TEMP1.asm
echo:incbin "%ROMName%":24E7A8-24E8C8>> TEMP1.asm
echo:incbin "%ROMName%":24E8D0-24E9F0>> TEMP1.asm
echo:incbin "%ROMName%":24E9F8-24EB38>> TEMP1.asm
echo:incbin "%ROMName%":24EB40-24EC80>> TEMP1.asm
echo:incbin "%ROMName%":24EC88-24EE68>> TEMP1.asm
echo:incbin "%ROMName%":24EE70-24F050>> TEMP1.asm
echo:incbin "%ROMName%":24F058-24F178>> TEMP1.asm
echo:incbin "%ROMName%":24F180-24F240>> TEMP1.asm
echo:incbin "%ROMName%":24F248-24F308>> TEMP1.asm
echo:incbin "%ROMName%":24F310-24F3D0>> TEMP1.asm
echo:incbin "%ROMName%":24F3D8-24F4B8>> TEMP1.asm
echo:incbin "%ROMName%":24F4C0-24F580>> TEMP1.asm
echo:incbin "%ROMName%":24F588-24F648>> TEMP1.asm
echo:incbin "%ROMName%":24F650-24F710>> TEMP1.asm
echo:incbin "%ROMName%":24F718-24F798>> TEMP1.asm
echo:incbin "%ROMName%":24F7A0-24F860>> TEMP1.asm
echo:incbin "%ROMName%":24F868-24F8E8>> TEMP1.asm
echo:incbin "%ROMName%":24F8F0-24F9B0>> TEMP1.asm
echo:incbin "%ROMName%":24F9B8-24FA78>> TEMP1.asm
echo:incbin "%ROMName%":24FA80-24FB80>> TEMP1.asm
echo:incbin "%ROMName%":24FB88-24FCA8>> TEMP1.asm
echo:incbin "%ROMName%":24FCB0-24FDD0>> TEMP1.asm
echo:incbin "%ROMName%":24FDD8-24FE98>> TEMP1.asm
echo:incbin "%ROMName%":24FEA0-24FF60>> TEMP1.asm
echo:incbin "%ROMName%":24FF68-24FFC8>> TEMP1.asm
echo:incbin "%ROMName%":250008-2500C8>> TEMP1.asm
echo:incbin "%ROMName%":2500D0-250190>> TEMP1.asm
echo:incbin "%ROMName%":250198-2502B8>> TEMP1.asm
echo:incbin "%ROMName%":2502C0-2503E0>> TEMP1.asm
echo:incbin "%ROMName%":2503E8-250508>> TEMP1.asm
echo:incbin "%ROMName%":250510-250630>> TEMP1.asm
echo:incbin "%ROMName%":250638-250758>> TEMP1.asm
echo:incbin "%ROMName%":250760-250880>> TEMP1.asm
echo:incbin "%ROMName%":250888-2509A8>> TEMP1.asm
echo:incbin "%ROMName%":2509B0-250AD0>> TEMP1.asm
echo:incbin "%ROMName%":250AD8-250BF8>> TEMP1.asm
echo:incbin "%ROMName%":250C00-250D20>> TEMP1.asm
echo:incbin "%ROMName%":250D28-250E48>> TEMP1.asm
echo:incbin "%ROMName%":250E50-250F70>> TEMP1.asm
echo:incbin "%ROMName%":250F78-251038>> TEMP1.asm
echo:incbin "%ROMName%":251040-251160>> TEMP1.asm
echo:incbin "%ROMName%":251168-251248>> TEMP1.asm
echo:incbin "%ROMName%":251250-251370>> TEMP1.asm
echo:incbin "%ROMName%":251378-251498>> TEMP1.asm
echo:incbin "%ROMName%":2514A0-2515C0>> TEMP1.asm
echo:incbin "%ROMName%":2515C8-2516E8>> TEMP1.asm
echo:incbin "%ROMName%":2516F0-251810>> TEMP1.asm
echo:incbin "%ROMName%":251818-251938>> TEMP1.asm
echo:incbin "%ROMName%":251940-251AC0>> TEMP1.asm
echo:incbin "%ROMName%":251AC8-251CA8>> TEMP1.asm
echo:incbin "%ROMName%":251CB0-251E50>> TEMP1.asm
echo:incbin "%ROMName%":251E58-251F98>> TEMP1.asm
echo:incbin "%ROMName%":251FA0-252060>> TEMP1.asm
echo:incbin "%ROMName%":252068-252128>> TEMP1.asm
echo:incbin "%ROMName%":252130-2521F0>> TEMP1.asm
echo:incbin "%ROMName%":2521F8-2522B8>> TEMP1.asm
echo:incbin "%ROMName%":2522C0-2523E0>> TEMP1.asm
echo:incbin "%ROMName%":2523E8-252508>> TEMP1.asm
echo:incbin "%ROMName%":252510-252630>> TEMP1.asm
echo:incbin "%ROMName%":252638-252758>> TEMP1.asm
echo:incbin "%ROMName%":252760-252860>> TEMP1.asm
echo:incbin "%ROMName%":252868-252968>> TEMP1.asm
echo:incbin "%ROMName%":252970-252A70>> TEMP1.asm
echo:incbin "%ROMName%":252A78-252B78>> TEMP1.asm
echo:incbin "%ROMName%":252B80-252C40>> TEMP1.asm
echo:incbin "%ROMName%":252C48-252D08>> TEMP1.asm
echo:incbin "%ROMName%":252D10-252DD0>> TEMP1.asm
echo:incbin "%ROMName%":252DD8-252E98>> TEMP1.asm
echo:incbin "%ROMName%":252EA0-252FA0>> TEMP1.asm
echo:incbin "%ROMName%":252FA8-2530A8>> TEMP1.asm
echo:incbin "%ROMName%":2530B0-253130>> TEMP1.asm
echo:incbin "%ROMName%":253138-253258>> TEMP1.asm
echo:incbin "%ROMName%":253260-253380>> TEMP1.asm
echo:incbin "%ROMName%":253388-2534A8>> TEMP1.asm
echo:incbin "%ROMName%":2534B0-253570>> TEMP1.asm
echo:incbin "%ROMName%":253578-253698>> TEMP1.asm
echo:incbin "%ROMName%":2536A0-2537C0>> TEMP1.asm
echo:incbin "%ROMName%":2537C8-2538E8>> TEMP1.asm
echo:incbin "%ROMName%":2538F0-253A10>> TEMP1.asm
echo:incbin "%ROMName%":253A18-253B38>> TEMP1.asm
echo:incbin "%ROMName%":253B40-253C60>> TEMP1.asm
echo:incbin "%ROMName%":253C68-253D88>> TEMP1.asm
echo:incbin "%ROMName%":253D90-253E90>> TEMP1.asm
echo:incbin "%ROMName%":253E98-253F38>> TEMP1.asm
echo:incbin "%ROMName%":253F40-253FE0>> TEMP1.asm
echo:incbin "%ROMName%":253FE8-254048>> TEMP1.asm
echo:incbin "%ROMName%":254050-2540B0>> TEMP1.asm
echo:incbin "%ROMName%":2540B8-2541F8>> TEMP1.asm
echo:incbin "%ROMName%":254200-254380>> TEMP1.asm
echo:incbin "%ROMName%":254388-254508>> TEMP1.asm
echo:incbin "%ROMName%":254510-254670>> TEMP1.asm
echo:incbin "%ROMName%":254678-2547F8>> TEMP1.asm
echo:incbin "%ROMName%":254800-2548C0>> TEMP1.asm
echo:incbin "%ROMName%":2548C8-254988>> TEMP1.asm
echo:incbin "%ROMName%":254990-254A30>> TEMP1.asm
echo:incbin "%ROMName%":254A38-254AF8>> TEMP1.asm
echo:incbin "%ROMName%":254B00-254C80>> TEMP1.asm
echo:incbin "%ROMName%":254C88-254E88>> TEMP1.asm
echo:incbin "%ROMName%":254E90-255090>> TEMP1.asm
echo:incbin "%ROMName%":255098-255158>> TEMP1.asm
echo:incbin "%ROMName%":255160-255280>> TEMP1.asm
echo:incbin "%ROMName%":255288-255428>> TEMP1.asm
echo:incbin "%ROMName%":255430-2555D0>> TEMP1.asm
echo:incbin "%ROMName%":2555D8-2557B8>> TEMP1.asm
echo:incbin "%ROMName%":2557C0-2559A0>> TEMP1.asm
echo:incbin "%ROMName%":2559A8-255AC8>> TEMP1.asm
echo:incbin "%ROMName%":255AD0-255BF0>> TEMP1.asm
echo:incbin "%ROMName%":255BF8-255D18>> TEMP1.asm
echo:incbin "%ROMName%":255D20-255E40>> TEMP1.asm
echo:incbin "%ROMName%":255E48-255F68>> TEMP1.asm
echo:incbin "%ROMName%":255F70-256090>> TEMP1.asm
echo:incbin "%ROMName%":256098-2561B8>> TEMP1.asm
echo:incbin "%ROMName%":2561C0-2562E0>> TEMP1.asm
echo:incbin "%ROMName%":2562E8-256408>> TEMP1.asm
echo:incbin "%ROMName%":256410-256530>> TEMP1.asm
echo:incbin "%ROMName%":256538-256658>> TEMP1.asm
echo:incbin "%ROMName%":256660-256780>> TEMP1.asm
echo:incbin "%ROMName%":256788-2568A8>> TEMP1.asm
echo:incbin "%ROMName%":2568B0-256970>> TEMP1.asm
echo:incbin "%ROMName%":256978-256A98>> TEMP1.asm
echo:incbin "%ROMName%":256AA0-256BC0>> TEMP1.asm
echo:incbin "%ROMName%":256BC8-256CE8>> TEMP1.asm
echo:incbin "%ROMName%":256CF0-256E10>> TEMP1.asm
echo:incbin "%ROMName%":256E18-256F38>> TEMP1.asm
echo:incbin "%ROMName%":256F40-257060>> TEMP1.asm
echo:incbin "%ROMName%":257068-257188>> TEMP1.asm
echo:incbin "%ROMName%":257190-2572B0>> TEMP1.asm
echo:incbin "%ROMName%":2572B8-2573D8>> TEMP1.asm
echo:incbin "%ROMName%":2573E0-257500>> TEMP1.asm
echo:incbin "%ROMName%":257508-257628>> TEMP1.asm
echo:incbin "%ROMName%":257630-257750>> TEMP1.asm
echo:incbin "%ROMName%":257758-257878>> TEMP1.asm
echo:incbin "%ROMName%":257880-2579A0>> TEMP1.asm
echo:incbin "%ROMName%":2579A8-257AC8>> TEMP1.asm
echo:incbin "%ROMName%":257AD0-257BF0>> TEMP1.asm
echo:incbin "%ROMName%":257BF8-257D18>> TEMP1.asm
echo:incbin "%ROMName%":257D20-257E40>> TEMP1.asm
echo:incbin "%ROMName%":257E48-257F68>> TEMP1.asm
echo:incbin "%ROMName%":257F70-258090>> TEMP1.asm
echo:incbin "%ROMName%":258098-2581B8>> TEMP1.asm
echo:incbin "%ROMName%":2581C0-2582E0>> TEMP1.asm
echo:incbin "%ROMName%":2582E8-258408>> TEMP1.asm
echo:incbin "%ROMName%":258410-258530>> TEMP1.asm
echo:incbin "%ROMName%":258538-258658>> TEMP1.asm
echo:incbin "%ROMName%":258660-258780>> TEMP1.asm
echo:incbin "%ROMName%":258788-2588A8>> TEMP1.asm
echo:incbin "%ROMName%":2588B0-2589D0>> TEMP1.asm
echo:incbin "%ROMName%":2589D8-258AF8>> TEMP1.asm
echo:incbin "%ROMName%":258B00-258C20>> TEMP1.asm
echo:incbin "%ROMName%":258C28-258CE8>> TEMP1.asm
echo:incbin "%ROMName%":258CF0-258DB0>> TEMP1.asm
echo:incbin "%ROMName%":258DB8-258E78>> TEMP1.asm
echo:incbin "%ROMName%":258E80-258FA0>> TEMP1.asm
echo:incbin "%ROMName%":258FA8-2590C8>> TEMP1.asm
echo:incbin "%ROMName%":2590D0-2591F0>> TEMP1.asm
echo:incbin "%ROMName%":2591F8-259318>> TEMP1.asm
echo:incbin "%ROMName%":259320-259440>> TEMP1.asm
echo:incbin "%ROMName%":259448-259568>> TEMP1.asm
echo:incbin "%ROMName%":259570-259690>> TEMP1.asm
echo:incbin "%ROMName%":259698-2597B8>> TEMP1.asm
echo:incbin "%ROMName%":2597C0-259880>> TEMP1.asm
echo:incbin "%ROMName%":259888-259948>> TEMP1.asm
echo:incbin "%ROMName%":259950-259A10>> TEMP1.asm
echo:incbin "%ROMName%":259A18-259AD8>> TEMP1.asm
echo:incbin "%ROMName%":259AE0-259C00>> TEMP1.asm
echo:incbin "%ROMName%":259C08-259D28>> TEMP1.asm
echo:incbin "%ROMName%":259D30-259E50>> TEMP1.asm
echo:incbin "%ROMName%":259E58-259F78>> TEMP1.asm
echo:incbin "%ROMName%":259F80-25A180>> TEMP1.asm
echo:incbin "%ROMName%":25A188-25A388>> TEMP1.asm
echo:incbin "%ROMName%":25A390-25A590>> TEMP1.asm
echo:incbin "%ROMName%":25A598-25A798>> TEMP1.asm
echo:incbin "%ROMName%":25A7A0-25A8C0>> TEMP1.asm
echo:incbin "%ROMName%":25A8C8-25AA28>> TEMP1.asm
echo:incbin "%ROMName%":25AA30-25AB90>> TEMP1.asm
echo:incbin "%ROMName%":25AB98-25ACB8>> TEMP1.asm
echo:incbin "%ROMName%":25ACC0-25ADE0>> TEMP1.asm
echo:incbin "%ROMName%":25ADE8-25AF08>> TEMP1.asm
echo:incbin "%ROMName%":25AF10-25B030>> TEMP1.asm
echo:incbin "%ROMName%":25B038-25B158>> TEMP1.asm
echo:incbin "%ROMName%":25B160-25B280>> TEMP1.asm
echo:incbin "%ROMName%":25B288-25B3A8>> TEMP1.asm
echo:incbin "%ROMName%":25B3B0-25B4D0>> TEMP1.asm
echo:incbin "%ROMName%":25B4D8-25B5F8>> TEMP1.asm
echo:incbin "%ROMName%":25B600-25B7E0>> TEMP1.asm
echo:incbin "%ROMName%":25B7E8-25B9C8>> TEMP1.asm
echo:incbin "%ROMName%":25B9D0-25BBB0>> TEMP1.asm
echo:incbin "%ROMName%":25BBB8-25BDB8>> TEMP1.asm
echo:incbin "%ROMName%":25BDC0-25BFC0>> TEMP1.asm
echo:incbin "%ROMName%":25BFC8-25C1E8>> TEMP1.asm
echo:incbin "%ROMName%":25C1F0-25C410>> TEMP1.asm
echo:incbin "%ROMName%":25C418-25C638>> TEMP1.asm
echo:incbin "%ROMName%":25C640-25C860>> TEMP1.asm
echo:incbin "%ROMName%":25C868-25CA88>> TEMP1.asm
echo:incbin "%ROMName%":25CA90-25CBB0>> TEMP1.asm
echo:incbin "%ROMName%":25CBB8-25CCD8>> TEMP1.asm
echo:incbin "%ROMName%":25CCE0-25CDE0>> TEMP1.asm
echo:incbin "%ROMName%":25CDE8-25CEC8>> TEMP1.asm
echo:incbin "%ROMName%":25CED0-25CFB0>> TEMP1.asm
echo:incbin "%ROMName%":25CFB8-25D098>> TEMP1.asm
echo:incbin "%ROMName%":25D0A0-25D180>> TEMP1.asm
echo:incbin "%ROMName%":25D188-25D268>> TEMP1.asm
echo:incbin "%ROMName%":25D270-25D390>> TEMP1.asm
echo:incbin "%ROMName%":25D398-25D4B8>> TEMP1.asm
echo:incbin "%ROMName%":25D4C0-25D5E0>> TEMP1.asm
echo:incbin "%ROMName%":25D5E8-25D708>> TEMP1.asm
echo:incbin "%ROMName%":25D710-25D830>> TEMP1.asm
echo:incbin "%ROMName%":25D838-25D958>> TEMP1.asm
echo:incbin "%ROMName%":25D960-25DA80>> TEMP1.asm
echo:incbin "%ROMName%":25DA88-25DBA8>> TEMP1.asm
echo:incbin "%ROMName%":25DBB0-25DCD0>> TEMP1.asm
echo:incbin "%ROMName%":25DCD8-25DDF8>> TEMP1.asm
echo:incbin "%ROMName%":25DE00-25DF20>> TEMP1.asm
echo:incbin "%ROMName%":25DF28-25E0C8>> TEMP1.asm
echo:incbin "%ROMName%":25E0D0-25E270>> TEMP1.asm
echo:incbin "%ROMName%":25E278-25E458>> TEMP1.asm
echo:incbin "%ROMName%":25E460-25E640>> TEMP1.asm
echo:incbin "%ROMName%":25E648-25E708>> TEMP1.asm
echo:incbin "%ROMName%":25E710-25E7D0>> TEMP1.asm
echo:incbin "%ROMName%":25E7D8-25E898>> TEMP1.asm
echo:incbin "%ROMName%":25E8A0-25EA80>> TEMP1.asm
echo:incbin "%ROMName%":25EA88-25ECC8>> TEMP1.asm
echo:incbin "%ROMName%":25ECD0-25EEB0>> TEMP1.asm
echo:incbin "%ROMName%":25EEB8-25F098>> TEMP1.asm
echo:incbin "%ROMName%":25F0A0-25F240>> TEMP1.asm
echo:incbin "%ROMName%":25F248-25F428>> TEMP1.asm
echo:incbin "%ROMName%":25F430-25F610>> TEMP1.asm
echo:incbin "%ROMName%":25F618-25F7F8>> TEMP1.asm
echo:incbin "%ROMName%":25F800-25FA20>> TEMP1.asm
echo:incbin "%ROMName%":25FA28-25FBC8>> TEMP1.asm
echo:incbin "%ROMName%":25FBD0-25FDB0>> TEMP1.asm
echo:incbin "%ROMName%":25FDB8-25FF98>> TEMP1.asm
echo:incbin "%ROMName%":260008-260128>> TEMP1.asm
echo:incbin "%ROMName%":260130-260250>> TEMP1.asm
echo:incbin "%ROMName%":260258-260378>> TEMP1.asm
echo:incbin "%ROMName%":260380-2604A0>> TEMP1.asm
echo:incbin "%ROMName%":2604A8-260568>> TEMP1.asm
echo:incbin "%ROMName%":260570-260630>> TEMP1.asm
echo:incbin "%ROMName%":260638-260758>> TEMP1.asm
echo:incbin "%ROMName%":260760-2607E0>> TEMP1.asm
echo:incbin "%ROMName%":2607E8-260868>> TEMP1.asm
echo:incbin "%ROMName%":260870-2608F0>> TEMP1.asm
echo:incbin "%ROMName%":2608F8-260A18>> TEMP1.asm
echo:incbin "%ROMName%":260A20-260B40>> TEMP1.asm
echo:incbin "%ROMName%":260B48-260C68>> TEMP1.asm
echo:incbin "%ROMName%":260C70-260D90>> TEMP1.asm
echo:incbin "%ROMName%":260D98-260EB8>> TEMP1.asm
echo:incbin "%ROMName%":260EC0-260FE0>> TEMP1.asm
echo:incbin "%ROMName%":260FE8-261108>> TEMP1.asm
echo:incbin "%ROMName%":261110-261230>> TEMP1.asm
echo:incbin "%ROMName%":261238-261358>> TEMP1.asm
echo:incbin "%ROMName%":261360-261480>> TEMP1.asm
echo:incbin "%ROMName%":261488-261548>> TEMP1.asm
echo:incbin "%ROMName%":261550-261670>> TEMP1.asm
echo:incbin "%ROMName%":261678-261798>> TEMP1.asm
echo:incbin "%ROMName%":2617A0-261860>> TEMP1.asm
echo:incbin "%ROMName%":261868-261988>> TEMP1.asm
echo:incbin "%ROMName%":261990-261AB0>> TEMP1.asm
echo:incbin "%ROMName%":261AB8-261BD8>> TEMP1.asm
echo:incbin "%ROMName%":261BE0-261D00>> TEMP1.asm
echo:incbin "%ROMName%":261D08-261E28>> TEMP1.asm
echo:incbin "%ROMName%":261E30-261F50>> TEMP1.asm
echo:incbin "%ROMName%":261F58-262078>> TEMP1.asm
echo:incbin "%ROMName%":262080-2621A0>> TEMP1.asm
echo:incbin "%ROMName%":2621A8-2622C8>> TEMP1.asm
echo:incbin "%ROMName%":2622D0-2623F0>> TEMP1.asm
echo:incbin "%ROMName%":2623F8-262518>> TEMP1.asm
echo:incbin "%ROMName%":262520-262640>> TEMP1.asm
echo:incbin "%ROMName%":262648-262708>> TEMP1.asm
echo:incbin "%ROMName%":262710-262830>> TEMP1.asm
echo:incbin "%ROMName%":262838-262958>> TEMP1.asm
echo:incbin "%ROMName%":262960-262A80>> TEMP1.asm
echo:incbin "%ROMName%":262A88-262BA8>> TEMP1.asm
echo:incbin "%ROMName%":262BB0-262CD0>> TEMP1.asm
echo:incbin "%ROMName%":262CD8-262DF8>> TEMP1.asm
echo:incbin "%ROMName%":262E00-262F20>> TEMP1.asm
echo:incbin "%ROMName%":262F28-263048>> TEMP1.asm
echo:incbin "%ROMName%":263050-263170>> TEMP1.asm
echo:incbin "%ROMName%":263178-263298>> TEMP1.asm
echo:incbin "%ROMName%":2632A0-2633C0>> TEMP1.asm
echo:incbin "%ROMName%":2633C8-263548>> TEMP1.asm
echo:incbin "%ROMName%":263550-263730>> TEMP1.asm
echo:incbin "%ROMName%":263738-2638D8>> TEMP1.asm
echo:incbin "%ROMName%":2638E0-263A20>> TEMP1.asm
echo:incbin "%ROMName%":263A28-263B48>> TEMP1.asm
echo:incbin "%ROMName%":263B50-263C70>> TEMP1.asm
echo:incbin "%ROMName%":263C78-263D98>> TEMP1.asm
echo:incbin "%ROMName%":263DA0-263EC0>> TEMP1.asm
echo:incbin "%ROMName%":263EC8-263FE8>> TEMP1.asm
echo:incbin "%ROMName%":263FF0-264110>> TEMP1.asm
echo:incbin "%ROMName%":264118-264198>> TEMP1.asm
echo:incbin "%ROMName%":2641A0-264220>> TEMP1.asm
echo:incbin "%ROMName%":264228-2642A8>> TEMP1.asm
echo:incbin "%ROMName%":2642B0-264330>> TEMP1.asm
echo:incbin "%ROMName%":264338-2643B8>> TEMP1.asm
echo:incbin "%ROMName%":2643C0-264480>> TEMP1.asm
echo:incbin "%ROMName%":264488-264568>> TEMP1.asm
echo:incbin "%ROMName%":264570-264670>> TEMP1.asm
echo:incbin "%ROMName%":264678-264798>> TEMP1.asm
echo:incbin "%ROMName%":2647A0-2648C0>> TEMP1.asm
echo:incbin "%ROMName%":2648C8-2649E8>> TEMP1.asm
echo:incbin "%ROMName%":2649F0-264B10>> TEMP1.asm
echo:incbin "%ROMName%":264B18-264C38>> TEMP1.asm
echo:incbin "%ROMName%":264C40-264D60>> TEMP1.asm
echo:incbin "%ROMName%":264D68-264E88>> TEMP1.asm
echo:incbin "%ROMName%":264E90-264FB0>> TEMP1.asm
echo:incbin "%ROMName%":264FB8-2650D8>> TEMP1.asm
echo:incbin "%ROMName%":2650E0-265200>> TEMP1.asm
echo:incbin "%ROMName%":265208-265328>> TEMP1.asm
echo:incbin "%ROMName%":265330-265450>> TEMP1.asm
echo:incbin "%ROMName%":265458-2654D8>> TEMP1.asm
echo:incbin "%ROMName%":2654E0-2655E0>> TEMP1.asm
echo:incbin "%ROMName%":2655E8-265668>> TEMP1.asm
echo:incbin "%ROMName%":265670-265730>> TEMP1.asm
echo:incbin "%ROMName%":265738-2657F8>> TEMP1.asm
echo:incbin "%ROMName%":265800-2658C0>> TEMP1.asm
echo:incbin "%ROMName%":2658C8-2659E8>> TEMP1.asm
echo:incbin "%ROMName%":2659F0-265B10>> TEMP1.asm
echo:incbin "%ROMName%":265B18-265BD8>> TEMP1.asm
echo:incbin "%ROMName%":265BE0-265CC0>> TEMP1.asm
echo:incbin "%ROMName%":265CC8-265DC8>> TEMP1.asm
echo:incbin "%ROMName%":265DD0-265ED0>> TEMP1.asm
echo:incbin "%ROMName%":265ED8-265FD8>> TEMP1.asm
echo:incbin "%ROMName%":265FE0-2660A0>> TEMP1.asm
echo:incbin "%ROMName%":2660A8-2661C8>> TEMP1.asm
echo:incbin "%ROMName%":2661D0-2662B0>> TEMP1.asm
echo:incbin "%ROMName%":2662B8-2663B8>> TEMP1.asm
echo:incbin "%ROMName%":2663C0-2664C0>> TEMP1.asm
echo:incbin "%ROMName%":2664C8-2665E8>> TEMP1.asm
echo:incbin "%ROMName%":2665F0-266710>> TEMP1.asm
echo:incbin "%ROMName%":266718-266838>> TEMP1.asm
echo:incbin "%ROMName%":266840-266A20>> TEMP1.asm
echo:incbin "%ROMName%":266A28-266C68>> TEMP1.asm
echo:incbin "%ROMName%":266C70-266E50>> TEMP1.asm
echo:incbin "%ROMName%":266E58-267038>> TEMP1.asm
echo:incbin "%ROMName%":267040-2671E0>> TEMP1.asm
echo:incbin "%ROMName%":2671E8-2673C8>> TEMP1.asm
echo:incbin "%ROMName%":2673D0-2675B0>> TEMP1.asm
echo:incbin "%ROMName%":2675B8-267798>> TEMP1.asm
echo:incbin "%ROMName%":2677A0-2679C0>> TEMP1.asm
echo:incbin "%ROMName%":2679C8-267BE8>> TEMP1.asm
echo:incbin "%ROMName%":267BF0-267E10>> TEMP1.asm
echo:incbin "%ROMName%":267E18-268078>> TEMP1.asm
echo:incbin "%ROMName%":268080-2682A0>> TEMP1.asm
echo:incbin "%ROMName%":2682A8-2683C8>> TEMP1.asm
echo:incbin "%ROMName%":2683D0-2684F0>> TEMP1.asm
echo:incbin "%ROMName%":2684F8-268618>> TEMP1.asm
echo:incbin "%ROMName%":268620-268740>> TEMP1.asm
echo:incbin "%ROMName%":268748-268868>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Gooey.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Rick's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":269E6A-26A06A>> TEMP1.asm
echo:incbin "%ROMName%":26A072-26A272>> TEMP1.asm
echo:incbin "%ROMName%":26A27A-26A47A>> TEMP1.asm
echo:incbin "%ROMName%":26A482-26A602>> TEMP1.asm
echo:incbin "%ROMName%":26A60A-26A78A>> TEMP1.asm
echo:incbin "%ROMName%":26A792-26A912>> TEMP1.asm
echo:incbin "%ROMName%":26A91A-26AA9A>> TEMP1.asm
echo:incbin "%ROMName%":26AAA2-26ACA2>> TEMP1.asm
echo:incbin "%ROMName%":26ACAA-26AEAA>> TEMP1.asm
echo:incbin "%ROMName%":26AEB2-26B0B2>> TEMP1.asm
echo:incbin "%ROMName%":26B0BA-26B2BA>> TEMP1.asm
echo:incbin "%ROMName%":26B2C2-26B442>> TEMP1.asm
echo:incbin "%ROMName%":26B44A-26B5CA>> TEMP1.asm
echo:incbin "%ROMName%":26B5D2-26B752>> TEMP1.asm
echo:incbin "%ROMName%":26B75A-26B8DA>> TEMP1.asm
echo:incbin "%ROMName%":26B8E2-26BAE2>> TEMP1.asm
echo:incbin "%ROMName%":26BAEA-26BC6A>> TEMP1.asm
echo:incbin "%ROMName%":26BC72-26BDF2>> TEMP1.asm
echo:incbin "%ROMName%":26BDFA-26BF7A>> TEMP1.asm
echo:incbin "%ROMName%":26BF82-26C102>> TEMP1.asm
echo:incbin "%ROMName%":26C10A-26C28A>> TEMP1.asm
echo:incbin "%ROMName%":26C292-26C412>> TEMP1.asm
echo:incbin "%ROMName%":26C41A-26C59A>> TEMP1.asm
echo:incbin "%ROMName%":26C5A2-26C722>> TEMP1.asm
echo:incbin "%ROMName%":26C72A-26CAAA>> TEMP1.asm
echo:incbin "%ROMName%":26CAB2-26CE32>> TEMP1.asm
echo:incbin "%ROMName%":26CE3A-26D03A>> TEMP1.asm
echo:incbin "%ROMName%":26D042-26D1C2>> TEMP1.asm
echo:incbin "%ROMName%":26D1CA-26D3CA>> TEMP1.asm
echo:incbin "%ROMName%":26D3D2-26D5D2>> TEMP1.asm
echo:incbin "%ROMName%":26D5DA-26D75A>> TEMP1.asm
echo:incbin "%ROMName%":26D762-26D8E2>> TEMP1.asm
echo:incbin "%ROMName%":26D8EA-26DA6A>> TEMP1.asm
echo:incbin "%ROMName%":26DA72-26DB92>> TEMP1.asm
echo:incbin "%ROMName%":26DB9A-26DD9A>> TEMP1.asm
echo:incbin "%ROMName%":26DDA2-26DFA2>> TEMP1.asm
echo:incbin "%ROMName%":26DFAA-26E1AA>> TEMP1.asm
echo:incbin "%ROMName%":26E1B2-26E3B2>> TEMP1.asm
echo:incbin "%ROMName%":26E3BA-26E5BA>> TEMP1.asm
echo:incbin "%ROMName%":26E5C2-26E7C2>> TEMP1.asm
echo:incbin "%ROMName%":26E7CA-26E9CA>> TEMP1.asm
echo:incbin "%ROMName%":26E9D2-26EBD2>> TEMP1.asm
echo:incbin "%ROMName%":26EBDA-26EDDA>> TEMP1.asm
echo:incbin "%ROMName%":26EDE2-26EFE2>> TEMP1.asm
echo:incbin "%ROMName%":26EFEA-26F1EA>> TEMP1.asm
echo:incbin "%ROMName%":26F1F2-26F3F2>> TEMP1.asm
echo:incbin "%ROMName%":26F3FA-26F5FA>> TEMP1.asm
echo:incbin "%ROMName%":26F602-26F802>> TEMP1.asm
echo:incbin "%ROMName%":26F80A-26FA0A>> TEMP1.asm
echo:incbin "%ROMName%":26FA12-26FC12>> TEMP1.asm
echo:incbin "%ROMName%":26FC1A-26FE1A>> TEMP1.asm
echo:incbin "%ROMName%":26FE22-26FFA2>> TEMP1.asm
echo:incbin "%ROMName%":270008-270208>> TEMP1.asm
echo:incbin "%ROMName%":270210-270410>> TEMP1.asm
echo:incbin "%ROMName%":270418-270618>> TEMP1.asm
echo:incbin "%ROMName%":270620-270820>> TEMP1.asm
echo:incbin "%ROMName%":270828-270A28>> TEMP1.asm
echo:incbin "%ROMName%":270A30-270C30>> TEMP1.asm
echo:incbin "%ROMName%":270C38-270E38>> TEMP1.asm
echo:incbin "%ROMName%":270E40-271040>> TEMP1.asm
echo:incbin "%ROMName%":271048-271248>> TEMP1.asm
echo:incbin "%ROMName%":271250-271450>> TEMP1.asm
echo:incbin "%ROMName%":271458-271658>> TEMP1.asm
echo:incbin "%ROMName%":271660-271860>> TEMP1.asm
echo:incbin "%ROMName%":271868-271A68>> TEMP1.asm
echo:incbin "%ROMName%":271A70-271C70>> TEMP1.asm
echo:incbin "%ROMName%":271C78-271E78>> TEMP1.asm
echo:incbin "%ROMName%":271E80-272000>> TEMP1.asm
echo:incbin "%ROMName%":272008-272188>> TEMP1.asm
echo:incbin "%ROMName%":272190-272390>> TEMP1.asm
echo:incbin "%ROMName%":272398-272598>> TEMP1.asm
echo:incbin "%ROMName%":2725A0-2727A0>> TEMP1.asm
echo:incbin "%ROMName%":2727A8-2729A8>> TEMP1.asm
echo:incbin "%ROMName%":2729B0-272BB0>> TEMP1.asm
echo:incbin "%ROMName%":272BB8-272DB8>> TEMP1.asm
echo:incbin "%ROMName%":272DC0-272F40>> TEMP1.asm
echo:incbin "%ROMName%":272F48-273148>> TEMP1.asm
echo:incbin "%ROMName%":273150-273350>> TEMP1.asm
echo:incbin "%ROMName%":273358-273558>> TEMP1.asm
echo:incbin "%ROMName%":273560-273760>> TEMP1.asm
echo:incbin "%ROMName%":273768-273968>> TEMP1.asm
echo:incbin "%ROMName%":273970-273B70>> TEMP1.asm
echo:incbin "%ROMName%":273B78-273D78>> TEMP1.asm
echo:incbin "%ROMName%":273D80-273F00>> TEMP1.asm
echo:incbin "%ROMName%":273F08-274088>> TEMP1.asm
echo:incbin "%ROMName%":274090-274210>> TEMP1.asm
echo:incbin "%ROMName%":274218-274398>> TEMP1.asm
echo:incbin "%ROMName%":2743A0-274520>> TEMP1.asm
echo:incbin "%ROMName%":274528-2746A8>> TEMP1.asm
echo:incbin "%ROMName%":2746B0-2748B0>> TEMP1.asm
echo:incbin "%ROMName%":2748B8-274AB8>> TEMP1.asm
echo:incbin "%ROMName%":274AC0-274C40>> TEMP1.asm
echo:incbin "%ROMName%":274C48-274DC8>> TEMP1.asm
echo:incbin "%ROMName%":274DD0-274F30>> TEMP1.asm
echo:incbin "%ROMName%":274F38-275098>> TEMP1.asm
echo:incbin "%ROMName%":2750A0-2752A0>> TEMP1.asm
echo:incbin "%ROMName%":2752A8-2754A8>> TEMP1.asm
echo:incbin "%ROMName%":2754B0-2756B0>> TEMP1.asm
echo:incbin "%ROMName%":2756B8-275818>> TEMP1.asm
echo:incbin "%ROMName%":275820-275980>> TEMP1.asm
echo:incbin "%ROMName%":275988-275B08>> TEMP1.asm
echo:incbin "%ROMName%":275B10-275D30>> TEMP1.asm
echo:incbin "%ROMName%":275D38-275F58>> TEMP1.asm
echo:incbin "%ROMName%":275F60-2760E0>> TEMP1.asm
echo:incbin "%ROMName%":2760E8-276268>> TEMP1.asm
echo:incbin "%ROMName%":276270-2763F0>> TEMP1.asm
echo:incbin "%ROMName%":2763F8-276558>> TEMP1.asm
echo:incbin "%ROMName%":276560-276720>> TEMP1.asm
echo:incbin "%ROMName%":276728-276888>> TEMP1.asm
echo:incbin "%ROMName%":276890-276A10>> TEMP1.asm
echo:incbin "%ROMName%":276A18-276BD8>> TEMP1.asm
echo:incbin "%ROMName%":276BE0-276D60>> TEMP1.asm
echo:incbin "%ROMName%":276D68-276EE8>> TEMP1.asm
echo:incbin "%ROMName%":276EF0-277070>> TEMP1.asm
echo:incbin "%ROMName%":277078-2771F8>> TEMP1.asm
echo:incbin "%ROMName%":277200-277380>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Rick.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Kine's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "KDL3.sfc":278408-278608>> TEMP1.asm
echo:incbin "KDL3.sfc":278610-278810>> TEMP1.asm
echo:incbin "KDL3.sfc":278818-278A18>> TEMP1.asm
echo:incbin "KDL3.sfc":278A20-278C20>> TEMP1.asm
echo:incbin "KDL3.sfc":278C28-278E28>> TEMP1.asm
echo:incbin "KDL3.sfc":278E30-279030>> TEMP1.asm
echo:incbin "KDL3.sfc":279038-279238>> TEMP1.asm
echo:incbin "KDL3.sfc":279240-279420>> TEMP1.asm
echo:incbin "KDL3.sfc":279428-279608>> TEMP1.asm
echo:incbin "KDL3.sfc":279610-279810>> TEMP1.asm
echo:incbin "KDL3.sfc":279818-279A18>> TEMP1.asm
echo:incbin "KDL3.sfc":279A20-279C20>> TEMP1.asm
echo:incbin "KDL3.sfc":279C28-279E28>> TEMP1.asm
echo:incbin "KDL3.sfc":279E30-27A0B0>> TEMP1.asm
echo:incbin "KDL3.sfc":27A0B8-27A238>> TEMP1.asm
echo:incbin "KDL3.sfc":27A240-27A440>> TEMP1.asm
echo:incbin "KDL3.sfc":27A448-27A5C8>> TEMP1.asm
echo:incbin "KDL3.sfc":27A5D0-27A7D0>> TEMP1.asm
echo:incbin "KDL3.sfc":27A7D8-27A9D8>> TEMP1.asm
echo:incbin "KDL3.sfc":27A9E0-27ABE0>> TEMP1.asm
echo:incbin "KDL3.sfc":27ABE8-27ADE8>> TEMP1.asm
echo:incbin "KDL3.sfc":27ADF0-27AFF0>> TEMP1.asm
echo:incbin "KDL3.sfc":27AFF8-27B1F8>> TEMP1.asm
echo:incbin "KDL3.sfc":27B200-27B400>> TEMP1.asm
echo:incbin "KDL3.sfc":27B408-27B588>> TEMP1.asm
echo:incbin "KDL3.sfc":27B590-27B790>> TEMP1.asm
echo:incbin "KDL3.sfc":27B798-27B998>> TEMP1.asm
echo:incbin "KDL3.sfc":27B9A0-27BBA0>> TEMP1.asm
echo:incbin "KDL3.sfc":27BBA8-27BDA8>> TEMP1.asm
echo:incbin "KDL3.sfc":27BDB0-27BFB0>> TEMP1.asm
echo:incbin "KDL3.sfc":27BFB8-27C1B8>> TEMP1.asm
echo:incbin "KDL3.sfc":27C1C0-27C3C0>> TEMP1.asm
echo:incbin "KDL3.sfc":27C3C8-27C5C8>> TEMP1.asm
echo:incbin "KDL3.sfc":27C5D0-27C7D0>> TEMP1.asm
echo:incbin "KDL3.sfc":27C7D8-27C9D8>> TEMP1.asm
echo:incbin "KDL3.sfc":27C9E0-27CBE0>> TEMP1.asm
echo:incbin "KDL3.sfc":27CBE8-27CDE8>> TEMP1.asm
echo:incbin "KDL3.sfc":27CDF0-27CFF0>> TEMP1.asm
echo:incbin "KDL3.sfc":27CFF8-27D1F8>> TEMP1.asm
echo:incbin "KDL3.sfc":27D200-27D400>> TEMP1.asm
echo:incbin "KDL3.sfc":27D408-27D588>> TEMP1.asm
echo:incbin "KDL3.sfc":27D590-27D710>> TEMP1.asm
echo:incbin "KDL3.sfc":27D718-27D898>> TEMP1.asm
echo:incbin "KDL3.sfc":27D8A0-27DA20>> TEMP1.asm
echo:incbin "KDL3.sfc":27DA28-27DBA8>> TEMP1.asm
echo:incbin "KDL3.sfc":27DBB0-27DDB0>> TEMP1.asm
echo:incbin "KDL3.sfc":27DDB8-27DFB8>> TEMP1.asm
echo:incbin "KDL3.sfc":27DFC0-27E1C0>> TEMP1.asm
echo:incbin "KDL3.sfc":27E1C8-27E3C8>> TEMP1.asm
echo:incbin "KDL3.sfc":27E3D0-27E550>> TEMP1.asm
echo:incbin "KDL3.sfc":27E558-27E6D8>> TEMP1.asm
echo:incbin "KDL3.sfc":27E6E0-27E8E0>> TEMP1.asm
echo:incbin "KDL3.sfc":27E8E8-27EAE8>> TEMP1.asm
echo:incbin "KDL3.sfc":27EAF0-27EC70>> TEMP1.asm
echo:incbin "KDL3.sfc":27EC78-27EE78>> TEMP1.asm
echo:incbin "KDL3.sfc":27EE80-27F000>> TEMP1.asm
echo:incbin "KDL3.sfc":27F008-27F188>> TEMP1.asm
echo:incbin "KDL3.sfc":27F190-27F390>> TEMP1.asm
echo:incbin "KDL3.sfc":27F398-27F598>> TEMP1.asm
echo:incbin "KDL3.sfc":27F5A0-27F7A0>> TEMP1.asm
echo:incbin "KDL3.sfc":27F7A8-27F9A8>> TEMP1.asm
echo:incbin "KDL3.sfc":27F9B0-27FBB0>> TEMP1.asm
echo:incbin "KDL3.sfc":27FBB8-27FE78>> TEMP1.asm
echo:incbin "KDL3.sfc":280008-2802C8>> TEMP1.asm
echo:incbin "KDL3.sfc":2802D0-2804D0>> TEMP1.asm
echo:incbin "KDL3.sfc":2804D8-2806D8>> TEMP1.asm
echo:incbin "KDL3.sfc":2806E0-2808E0>> TEMP1.asm
echo:incbin "KDL3.sfc":2808E8-280AE8>> TEMP1.asm
echo:incbin "KDL3.sfc":280AF0-280CF0>> TEMP1.asm
echo:incbin "KDL3.sfc":280CF8-280EF8>> TEMP1.asm
echo:incbin "KDL3.sfc":280F00-281100>> TEMP1.asm
echo:incbin "KDL3.sfc":281108-281308>> TEMP1.asm
echo:incbin "KDL3.sfc":281310-281510>> TEMP1.asm
echo:incbin "KDL3.sfc":281518-281718>> TEMP1.asm
echo:incbin "KDL3.sfc":281720-281920>> TEMP1.asm
echo:incbin "KDL3.sfc":281928-281B28>> TEMP1.asm
echo:incbin "KDL3.sfc":281B30-281D30>> TEMP1.asm
echo:incbin "KDL3.sfc":281D38-281F38>> TEMP1.asm
echo:incbin "KDL3.sfc":281F40-282140>> TEMP1.asm
echo:incbin "KDL3.sfc":282148-282348>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Kine.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Coo's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":27FE80-280000>> TEMP1.asm
echo:incbin "%ROMName%":28395C-283ADC>> TEMP1.asm
echo:incbin "%ROMName%":283AE4-283C64>> TEMP1.asm
echo:incbin "%ROMName%":283C6C-283DEC>> TEMP1.asm
echo:incbin "%ROMName%":283DF4-283F74>> TEMP1.asm
echo:incbin "%ROMName%":283F7C-2840FC>> TEMP1.asm
echo:incbin "%ROMName%":284104-284284>> TEMP1.asm
echo:incbin "%ROMName%":28428C-28440C>> TEMP1.asm
echo:incbin "%ROMName%":284414-284594>> TEMP1.asm
echo:incbin "%ROMName%":28459C-28471C>> TEMP1.asm
echo:incbin "%ROMName%":284724-2848A4>> TEMP1.asm
echo:incbin "%ROMName%":2848AC-284A0C>> TEMP1.asm
echo:incbin "%ROMName%":284A14-284B94>> TEMP1.asm
echo:incbin "%ROMName%":284B9C-284DDC>> TEMP1.asm
echo:incbin "%ROMName%":284DE4-285024>> TEMP1.asm
echo:incbin "%ROMName%":28502C-28534C>> TEMP1.asm
echo:incbin "%ROMName%":285354-2854D4>> TEMP1.asm
echo:incbin "%ROMName%":2854DC-28565C>> TEMP1.asm
echo:incbin "%ROMName%":285664-285784>> TEMP1.asm
echo:incbin "%ROMName%":28578C-28590C>> TEMP1.asm
echo:incbin "%ROMName%":285914-285A94>> TEMP1.asm
echo:incbin "%ROMName%":285A9C-285C1C>> TEMP1.asm
echo:incbin "%ROMName%":285C24-285DA4>> TEMP1.asm
echo:incbin "%ROMName%":285DAC-285F2C>> TEMP1.asm
echo:incbin "%ROMName%":285F34-2860B4>> TEMP1.asm
echo:incbin "%ROMName%":2860BC-28623C>> TEMP1.asm
echo:incbin "%ROMName%":286244-2863C4>> TEMP1.asm
echo:incbin "%ROMName%":2863CC-28654C>> TEMP1.asm
echo:incbin "%ROMName%":286554-2866D4>> TEMP1.asm
echo:incbin "%ROMName%":2866DC-28685C>> TEMP1.asm
echo:incbin "%ROMName%":286864-2869E4>> TEMP1.asm
echo:incbin "%ROMName%":2869EC-286B6C>> TEMP1.asm
echo:incbin "%ROMName%":286B74-286CF4>> TEMP1.asm
echo:incbin "%ROMName%":286CFC-286E7C>> TEMP1.asm
echo:incbin "%ROMName%":286E84-287004>> TEMP1.asm
echo:incbin "%ROMName%":28700C-28718C>> TEMP1.asm
echo:incbin "%ROMName%":287194-287314>> TEMP1.asm
echo:incbin "%ROMName%":28731C-28749C>> TEMP1.asm
echo:incbin "%ROMName%":2874A4-2876A4>> TEMP1.asm
echo:incbin "%ROMName%":2876AC-28782C>> TEMP1.asm
echo:incbin "%ROMName%":287834-287A34>> TEMP1.asm
echo:incbin "%ROMName%":287A3C-287C3C>> TEMP1.asm
echo:incbin "%ROMName%":287C44-287E44>> TEMP1.asm
echo:incbin "%ROMName%":287E4C-28804C>> TEMP1.asm
echo:incbin "%ROMName%":288054-288254>> TEMP1.asm
echo:incbin "%ROMName%":28825C-28845C>> TEMP1.asm
echo:incbin "%ROMName%":288464-2885E4>> TEMP1.asm
echo:incbin "%ROMName%":2885EC-28876C>> TEMP1.asm
echo:incbin "%ROMName%":288774-2888F4>> TEMP1.asm
echo:incbin "%ROMName%":2888FC-288A7C>> TEMP1.asm
echo:incbin "%ROMName%":288A84-288C04>> TEMP1.asm
echo:incbin "%ROMName%":288C0C-288D8C>> TEMP1.asm
echo:incbin "%ROMName%":288D94-288F14>> TEMP1.asm
echo:incbin "%ROMName%":288F1C-28911C>> TEMP1.asm
echo:incbin "%ROMName%":289124-289324>> TEMP1.asm
echo:incbin "%ROMName%":28932C-28952C>> TEMP1.asm
echo:incbin "%ROMName%":289534-2896B4>> TEMP1.asm
echo:incbin "%ROMName%":2896BC-28983C>> TEMP1.asm
echo:incbin "%ROMName%":289844-2899C4>> TEMP1.asm
echo:incbin "%ROMName%":2899CC-289B4C>> TEMP1.asm
echo:incbin "%ROMName%":289B54-289CD4>> TEMP1.asm
echo:incbin "%ROMName%":289CDC-289E5C>> TEMP1.asm
echo:incbin "%ROMName%":289E64-289FE4>> TEMP1.asm
echo:incbin "%ROMName%":289FEC-28A16C>> TEMP1.asm
echo:incbin "%ROMName%":28A174-28A2F4>> TEMP1.asm
echo:incbin "%ROMName%":28A2FC-28A47C>> TEMP1.asm
echo:incbin "%ROMName%":28A484-28A604>> TEMP1.asm
echo:incbin "%ROMName%":28A60C-28A78C>> TEMP1.asm
echo:incbin "%ROMName%":28A794-28A914>> TEMP1.asm
echo:incbin "%ROMName%":28A91C-28AA9C>> TEMP1.asm
echo:incbin "%ROMName%":28AAA4-28AC24>> TEMP1.asm
echo:incbin "%ROMName%":28AC2C-28ADAC>> TEMP1.asm
echo:incbin "%ROMName%":28ADB4-28AF34>> TEMP1.asm
echo:incbin "%ROMName%":28AF3C-28B0BC>> TEMP1.asm
echo:incbin "%ROMName%":28B0C4-28B244>> TEMP1.asm
echo:incbin "%ROMName%":28B24C-28B44C>> TEMP1.asm
echo:incbin "%ROMName%":28B454-28B6D4>> TEMP1.asm
echo:incbin "%ROMName%":28B6DC-28B85C>> TEMP1.asm
echo:incbin "%ROMName%":28B864-28B9E4>> TEMP1.asm
echo:incbin "%ROMName%":28B9EC-28BB6C>> TEMP1.asm
echo:incbin "%ROMName%":28BB74-28BCF4>> TEMP1.asm
echo:incbin "%ROMName%":28BCFC-28BE7C>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Coo.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Nago's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":28D156-28D356>> TEMP1.asm
echo:incbin "%ROMName%":28D35E-28D55E>> TEMP1.asm
echo:incbin "%ROMName%":28D566-28D766>> TEMP1.asm
echo:incbin "%ROMName%":28D76E-28D96E>> TEMP1.asm
echo:incbin "%ROMName%":28D976-28DB76>> TEMP1.asm
echo:incbin "%ROMName%":28DB7E-28DD7E>> TEMP1.asm
echo:incbin "%ROMName%":28DD86-28DF86>> TEMP1.asm
echo:incbin "%ROMName%":28DF8E-28E18E>> TEMP1.asm
echo:incbin "%ROMName%":28E196-28E316>> TEMP1.asm
echo:incbin "%ROMName%":28E31E-28E51E>> TEMP1.asm
echo:incbin "%ROMName%":28E526-28E726>> TEMP1.asm
echo:incbin "%ROMName%":28E72E-28E8AE>> TEMP1.asm
echo:incbin "%ROMName%":28E8B6-28EA36>> TEMP1.asm
echo:incbin "%ROMName%":28EA3E-28EC3E>> TEMP1.asm
echo:incbin "%ROMName%":28EC46-28EE46>> TEMP1.asm
echo:incbin "%ROMName%":28EE4E-28F04E>> TEMP1.asm
echo:incbin "%ROMName%":28F056-28F256>> TEMP1.asm
echo:incbin "%ROMName%":28F25E-28F45E>> TEMP1.asm
echo:incbin "%ROMName%":28F466-28F666>> TEMP1.asm
echo:incbin "%ROMName%":28F66E-28F86E>> TEMP1.asm
echo:incbin "%ROMName%":28F876-28FA76>> TEMP1.asm
echo:incbin "%ROMName%":28FA7E-28FC7E>> TEMP1.asm
echo:incbin "%ROMName%":28FC86-28FE86>> TEMP1.asm
echo:incbin "%ROMName%":28FE8E-28FFEE>> TEMP1.asm
echo:incbin "%ROMName%":290008-290228>> TEMP1.asm
echo:incbin "%ROMName%":290230-2904B0>> TEMP1.asm
echo:incbin "%ROMName%":2904B8-2906B8>> TEMP1.asm
echo:incbin "%ROMName%":2906C0-2908C0>> TEMP1.asm
echo:incbin "%ROMName%":2908C8-290AC8>> TEMP1.asm
echo:incbin "%ROMName%":290AD0-290CD0>> TEMP1.asm
echo:incbin "%ROMName%":290CD8-290ED8>> TEMP1.asm
echo:incbin "%ROMName%":290EE0-2910E0>> TEMP1.asm
echo:incbin "%ROMName%":2910E8-2912E8>> TEMP1.asm
echo:incbin "%ROMName%":2912F0-2914F0>> TEMP1.asm
echo:incbin "%ROMName%":2914F8-2916F8>> TEMP1.asm
echo:incbin "%ROMName%":291700-291900>> TEMP1.asm
echo:incbin "%ROMName%":291908-291B08>> TEMP1.asm
echo:incbin "%ROMName%":291B10-291D10>> TEMP1.asm
echo:incbin "%ROMName%":291D18-291F18>> TEMP1.asm
echo:incbin "%ROMName%":291F20-292120>> TEMP1.asm
echo:incbin "%ROMName%":292128-2922A8>> TEMP1.asm
echo:incbin "%ROMName%":2922B0-292430>> TEMP1.asm
echo:incbin "%ROMName%":292438-2925B8>> TEMP1.asm
echo:incbin "%ROMName%":2925C0-292740>> TEMP1.asm
echo:incbin "%ROMName%":292748-292948>> TEMP1.asm
echo:incbin "%ROMName%":292950-292B50>> TEMP1.asm
echo:incbin "%ROMName%":292B58-292D58>> TEMP1.asm
echo:incbin "%ROMName%":292D60-292F60>> TEMP1.asm
echo:incbin "%ROMName%":292F68-293168>> TEMP1.asm
echo:incbin "%ROMName%":293170-293370>> TEMP1.asm
echo:incbin "%ROMName%":293378-293578>> TEMP1.asm
echo:incbin "%ROMName%":293580-293780>> TEMP1.asm
echo:incbin "%ROMName%":293788-293988>> TEMP1.asm
echo:incbin "%ROMName%":293990-293B90>> TEMP1.asm
echo:incbin "%ROMName%":293B98-293D98>> TEMP1.asm
echo:incbin "%ROMName%":293DA0-293FA0>> TEMP1.asm
echo:incbin "%ROMName%":293FA8-2941A8>> TEMP1.asm
echo:incbin "%ROMName%":2941B0-2943B0>> TEMP1.asm
echo:incbin "%ROMName%":2943B8-2945B8>> TEMP1.asm
echo:incbin "%ROMName%":2945C0-2947C0>> TEMP1.asm
echo:incbin "%ROMName%":2947C8-2949C8>> TEMP1.asm
echo:incbin "%ROMName%":2949D0-294BD0>> TEMP1.asm
echo:incbin "%ROMName%":294BD8-294D58>> TEMP1.asm
echo:incbin "%ROMName%":294D60-294EE0>> TEMP1.asm
echo:incbin "%ROMName%":294EE8-295068>> TEMP1.asm
echo:incbin "%ROMName%":295070-295270>> TEMP1.asm
echo:incbin "%ROMName%":295278-295478>> TEMP1.asm
echo:incbin "%ROMName%":295480-295680>> TEMP1.asm
echo:incbin "%ROMName%":295688-295888>> TEMP1.asm
echo:incbin "%ROMName%":295890-295A90>> TEMP1.asm
echo:incbin "%ROMName%":295A98-295C98>> TEMP1.asm
echo:incbin "%ROMName%":295CA0-295EA0>> TEMP1.asm
echo:incbin "%ROMName%":295EA8-296028>> TEMP1.asm
echo:incbin "%ROMName%":296030-296230>> TEMP1.asm
echo:incbin "%ROMName%":296238-296438>> TEMP1.asm
echo:incbin "%ROMName%":296440-296640>> TEMP1.asm
echo:incbin "%ROMName%":296648-296848>> TEMP1.asm
echo:incbin "%ROMName%":296850-296A50>> TEMP1.asm
echo:incbin "%ROMName%":296A58-296C58>> TEMP1.asm
echo:incbin "%ROMName%":296C60-296E60>> TEMP1.asm
echo:incbin "%ROMName%":296E68-297068>> TEMP1.asm
echo:incbin "%ROMName%":297070-2971F0>> TEMP1.asm
echo:incbin "%ROMName%":2971F8-297378>> TEMP1.asm
echo:incbin "%ROMName%":297380-297540>> TEMP1.asm
echo:incbin "%ROMName%":297548-297748>> TEMP1.asm
echo:incbin "%ROMName%":297750-297950>> TEMP1.asm
echo:incbin "%ROMName%":297958-297B58>> TEMP1.asm
echo:incbin "%ROMName%":297B60-297D60>> TEMP1.asm
echo:incbin "%ROMName%":297D68-297F68>> TEMP1.asm
echo:incbin "%ROMName%":297F70-298170>> TEMP1.asm
echo:incbin "%ROMName%":298178-298378>> TEMP1.asm
echo:incbin "%ROMName%":298380-298580>> TEMP1.asm
echo:incbin "%ROMName%":298588-298788>> TEMP1.asm
echo:incbin "%ROMName%":298790-298990>> TEMP1.asm
echo:incbin "%ROMName%":298998-298B78>> TEMP1.asm
echo:incbin "%ROMName%":298B80-298D80>> TEMP1.asm
echo:incbin "%ROMName%":298D88-298F48>> TEMP1.asm
echo:incbin "%ROMName%":298F50-299130>> TEMP1.asm
echo:incbin "%ROMName%":299138-2992F8>> TEMP1.asm
echo:incbin "%ROMName%":299300-2994C0>> TEMP1.asm
echo:incbin "%ROMName%":2994C8-299688>> TEMP1.asm
echo:incbin "%ROMName%":299690-299890>> TEMP1.asm
echo:incbin "%ROMName%":299898-299A58>> TEMP1.asm
echo:incbin "%ROMName%":299A60-299C00>> TEMP1.asm
echo:incbin "%ROMName%":299C08-299DE8>> TEMP1.asm
echo:incbin "%ROMName%":299DF0-299FD0>> TEMP1.asm
echo:incbin "%ROMName%":299FD8-29A1B8>> TEMP1.asm
echo:incbin "%ROMName%":29A1C0-29A3C0>> TEMP1.asm
echo:incbin "%ROMName%":29A3C8-29A548>> TEMP1.asm
echo:incbin "%ROMName%":29A550-29A6D0>> TEMP1.asm
echo:incbin "%ROMName%":29A6D8-29A8D8>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Nago.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Chuchu's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":29CE14-29CF34>> TEMP1.asm
echo:incbin "%ROMName%":29CF3C-29D05C>> TEMP1.asm
echo:incbin "%ROMName%":29D064-29D184>> TEMP1.asm
echo:incbin "%ROMName%":29D18C-29D2AC>> TEMP1.asm
echo:incbin "%ROMName%":29D2B4-29D3D4>> TEMP1.asm
echo:incbin "%ROMName%":29D3DC-29D4FC>> TEMP1.asm
echo:incbin "%ROMName%":29D504-29D624>> TEMP1.asm
echo:incbin "%ROMName%":29D62C-29D74C>> TEMP1.asm
echo:incbin "%ROMName%":29D754-29D874>> TEMP1.asm
echo:incbin "%ROMName%":29D87C-29D99C>> TEMP1.asm
echo:incbin "%ROMName%":29D9A4-29DAC4>> TEMP1.asm
echo:incbin "%ROMName%":29DACC-29DBEC>> TEMP1.asm
echo:incbin "%ROMName%":29DBF4-29DD14>> TEMP1.asm
echo:incbin "%ROMName%":29DD1C-29DE3C>> TEMP1.asm
echo:incbin "%ROMName%":29DE44-29DF64>> TEMP1.asm
echo:incbin "%ROMName%":29DF6C-29E08C>> TEMP1.asm
echo:incbin "%ROMName%":29E094-29E1B4>> TEMP1.asm
echo:incbin "%ROMName%":29E1BC-29E2DC>> TEMP1.asm
echo:incbin "%ROMName%":29E2E4-29E464>> TEMP1.asm
echo:incbin "%ROMName%":29E46C-29E64C>> TEMP1.asm
echo:incbin "%ROMName%":29E654-29E894>> TEMP1.asm
echo:incbin "%ROMName%":29E89C-29EA7C>> TEMP1.asm
echo:incbin "%ROMName%":29EA84-29EC04>> TEMP1.asm
echo:incbin "%ROMName%":29EC0C-29ED2C>> TEMP1.asm
echo:incbin "%ROMName%":29ED34-29EE54>> TEMP1.asm
echo:incbin "%ROMName%":29EE5C-29EF7C>> TEMP1.asm
echo:incbin "%ROMName%":29EF84-29F0A4>> TEMP1.asm
echo:incbin "%ROMName%":29F0AC-29F1CC>> TEMP1.asm
echo:incbin "%ROMName%":29F1D4-29F334>> TEMP1.asm
echo:incbin "%ROMName%":29F33C-29F51C>> TEMP1.asm
echo:incbin "%ROMName%":29F524-29F644>> TEMP1.asm
echo:incbin "%ROMName%":29F64C-29F76C>> TEMP1.asm
echo:incbin "%ROMName%":29F774-29F894>> TEMP1.asm
echo:incbin "%ROMName%":29F89C-29FA1C>> TEMP1.asm
echo:incbin "%ROMName%":29FA24-29FBA4>> TEMP1.asm
echo:incbin "%ROMName%":29FBAC-29FD4C>> TEMP1.asm
echo:incbin "%ROMName%":29FD54-29FED4>> TEMP1.asm
echo:incbin "%ROMName%":29FEDC-29FFFC>> TEMP1.asm
echo:incbin "%ROMName%":2A0008-2A0188>> TEMP1.asm
echo:incbin "%ROMName%":2A0190-2A0310>> TEMP1.asm
echo:incbin "%ROMName%":2A0318-2A0438>> TEMP1.asm
echo:incbin "%ROMName%":2A0440-2A0560>> TEMP1.asm
echo:incbin "%ROMName%":2A0568-2A0688>> TEMP1.asm
echo:incbin "%ROMName%":2A0690-2A07B0>> TEMP1.asm
echo:incbin "%ROMName%":2A07B8-2A08D8>> TEMP1.asm
echo:incbin "%ROMName%":2A08E0-2A0A00>> TEMP1.asm
echo:incbin "%ROMName%":2A0A08-2A0B28>> TEMP1.asm
echo:incbin "%ROMName%":2A0B30-2A0C50>> TEMP1.asm
echo:incbin "%ROMName%":2A0C58-2A0DD8>> TEMP1.asm
echo:incbin "%ROMName%":2A0DE0-2A0F00>> TEMP1.asm
echo:incbin "%ROMName%":2A0F08-2A1028>> TEMP1.asm
echo:incbin "%ROMName%":2A1030-2A1230>> TEMP1.asm
echo:incbin "%ROMName%":2A1238-2A1358>> TEMP1.asm
echo:incbin "%ROMName%":2A1360-2A1480>> TEMP1.asm
echo:incbin "%ROMName%":2A1488-2A15A8>> TEMP1.asm
echo:incbin "%ROMName%":2A15B0-2A16D0>> TEMP1.asm
echo:incbin "%ROMName%":2A16D8-2A17F8>> TEMP1.asm
echo:incbin "%ROMName%":2A1800-2A1920>> TEMP1.asm
echo:incbin "%ROMName%":2A1928-2A1A48>> TEMP1.asm
echo:incbin "%ROMName%":2A1A50-2A1B70>> TEMP1.asm
echo:incbin "%ROMName%":2A1B78-2A1C98>> TEMP1.asm
echo:incbin "%ROMName%":2A1CA0-2A1DC0>> TEMP1.asm
echo:incbin "%ROMName%":2A1DC8-2A1EE8>> TEMP1.asm
echo:incbin "%ROMName%":2A1EF0-2A2010>> TEMP1.asm
echo:incbin "%ROMName%":2A2018-2A2138>> TEMP1.asm
echo:incbin "%ROMName%":2A2140-2A2260>> TEMP1.asm
echo:incbin "%ROMName%":2A2268-2A2388>> TEMP1.asm
echo:incbin "%ROMName%":2A2390-2A24B0>> TEMP1.asm
echo:incbin "%ROMName%":2A24B8-2A25D8>> TEMP1.asm
echo:incbin "%ROMName%":2A25E0-2A2700>> TEMP1.asm
echo:incbin "%ROMName%":2A2708-2A2828>> TEMP1.asm
echo:incbin "%ROMName%":2A2830-2A2950>> TEMP1.asm
echo:incbin "%ROMName%":2A2958-2A2AF8>> TEMP1.asm
echo:incbin "%ROMName%":2A2B00-2A2D00>> TEMP1.asm
echo:incbin "%ROMName%":2A2D08-2A2EA8>> TEMP1.asm
echo:incbin "%ROMName%":2A2EB0-2A3050>> TEMP1.asm
echo:incbin "%ROMName%":2A3058-2A31B8>> TEMP1.asm
echo:incbin "%ROMName%":2A31C0-2A3340>> TEMP1.asm
echo:incbin "%ROMName%":2A3348-2A34C8>> TEMP1.asm
echo:incbin "%ROMName%":2A34D0-2A3650>> TEMP1.asm
echo:incbin "%ROMName%":2A3658-2A37D8>> TEMP1.asm
echo:incbin "%ROMName%":2A37E0-2A3900>> TEMP1.asm
echo:incbin "%ROMName%":2A3908-2A3A28>> TEMP1.asm
echo:incbin "%ROMName%":2A3A30-2A3B50>> TEMP1.asm
echo:incbin "%ROMName%":2A3B58-2A3C78>> TEMP1.asm
echo:incbin "%ROMName%":2A3C80-2A3DA0>> TEMP1.asm
echo:incbin "%ROMName%":2A3DA8-2A3EC8>> TEMP1.asm
echo:incbin "%ROMName%":2A3ED0-2A3FF0>> TEMP1.asm
echo:incbin "%ROMName%":2A3FF8-2A4118>> TEMP1.asm
echo:incbin "%ROMName%":2A4120-2A4240>> TEMP1.asm
echo:incbin "%ROMName%":2A4248-2A4368>> TEMP1.asm
echo:incbin "%ROMName%":2A4370-2A4490>> TEMP1.asm
echo:incbin "%ROMName%":2A4498-2A4558>> TEMP1.asm
echo:incbin "%ROMName%":2A4560-2A4620>> TEMP1.asm
echo:incbin "%ROMName%":2A4628-2A46E8>> TEMP1.asm
echo:incbin "%ROMName%":2A46F0-2A4870>> TEMP1.asm
echo:incbin "%ROMName%":2A4878-2A49F8>> TEMP1.asm
echo:incbin "%ROMName%":2A4A00-2A4B80>> TEMP1.asm
echo:incbin "%ROMName%":2A4B88-2A4D68>> TEMP1.asm
echo:incbin "%ROMName%":2A4D70-2A4F50>> TEMP1.asm
echo:incbin "%ROMName%":2A4F58-2A5138>> TEMP1.asm
echo:incbin "%ROMName%":2A5140-2A52C0>> TEMP1.asm
echo:incbin "%ROMName%":2A52C8-2A5448>> TEMP1.asm
echo:incbin "%ROMName%":2A5450-2A55D0>> TEMP1.asm
echo:incbin "%ROMName%":2A55D8-2A5798>> TEMP1.asm
echo:incbin "%ROMName%":2A57A0-2A5920>> TEMP1.asm
echo:incbin "%ROMName%":2A5928-2A5A48>> TEMP1.asm
echo:incbin "%ROMName%":2A5A50-2A5B70>> TEMP1.asm
echo:incbin "%ROMName%":2A5B78-2A5C98>> TEMP1.asm
echo:incbin "%ROMName%":2A5CA0-2A5DC0>> TEMP1.asm
echo:incbin "%ROMName%":2A5DC8-2A5EE8>> TEMP1.asm
echo:incbin "%ROMName%":2A5EF0-2A60F0>> TEMP1.asm
echo:incbin "%ROMName%":2A60F8-2A62F8>> TEMP1.asm
echo:incbin "%ROMName%":2A6300-2A6500>> TEMP1.asm
echo:incbin "%ROMName%":2A6508-2A6708>> TEMP1.asm
echo:incbin "%ROMName%":2A6710-2A6830>> TEMP1.asm
echo:incbin "%ROMName%":2A6838-2A6958>> TEMP1.asm
echo:incbin "%ROMName%":2A6960-2A6A80>> TEMP1.asm
echo:incbin "%ROMName%":2A6A88-2A6C08>> TEMP1.asm
echo:incbin "%ROMName%":2A6C10-2A6DB0>> TEMP1.asm
echo:incbin "%ROMName%":2A6DB8-2A6F38>> TEMP1.asm
echo:incbin "%ROMName%":2A6F40-2A70C0>> TEMP1.asm
echo:incbin "%ROMName%":2A70C8-2A7268>> TEMP1.asm
echo:incbin "%ROMName%":2A7270-2A7410>> TEMP1.asm
echo:incbin "%ROMName%":2A7418-2A75B8>> TEMP1.asm
echo:incbin "%ROMName%":2A75C0-2A7780>> TEMP1.asm
echo:incbin "%ROMName%":2A7788-2A7928>> TEMP1.asm
echo:incbin "%ROMName%":2A7930-2A7A50>> TEMP1.asm
echo:incbin "%ROMName%":2A7A58-2A7BF8>> TEMP1.asm
echo:incbin "%ROMName%":2A7C00-2A7E80>> TEMP1.asm
echo:incbin "%ROMName%":2A7E88-2A7FE8>> TEMP1.asm
echo:incbin "%ROMName%":2A7FF0-2A8150>> TEMP1.asm
echo:incbin "%ROMName%":2A8158-2A82B8>> TEMP1.asm
echo:incbin "%ROMName%":2A82C0-2A83E0>> TEMP1.asm
echo:incbin "%ROMName%":2A83E8-2A8508>> TEMP1.asm
echo:incbin "%ROMName%":2A8510-2A8690>> TEMP1.asm
echo:incbin "%ROMName%":2A8698-2A87B8>> TEMP1.asm
echo:incbin "%ROMName%":2A87C0-2A88E0>> TEMP1.asm
echo:incbin "%ROMName%":2A88E8-2A8A08>> TEMP1.asm
echo:incbin "%ROMName%":2A8A10-2A8B90>> TEMP1.asm
echo:incbin "%ROMName%":2A8B98-2A8CB8>> TEMP1.asm
echo:incbin "%ROMName%":2A8CC0-2A8DE0>> TEMP1.asm
echo:incbin "%ROMName%":2A8DE8-2A8F08>> TEMP1.asm
echo:incbin "%ROMName%":2A8F10-2A9070>> TEMP1.asm
echo:incbin "%ROMName%":2A9078-2A91F8>> TEMP1.asm
echo:incbin "%ROMName%":2A9200-2A9380>> TEMP1.asm
echo:incbin "%ROMName%":2A9388-2A9508>> TEMP1.asm
echo:incbin "%ROMName%":2A9510-2A9690>> TEMP1.asm
echo:incbin "%ROMName%":2A9698-2A9818>> TEMP1.asm
echo:incbin "%ROMName%":2A9820-2A9A20>> TEMP1.asm
echo:incbin "%ROMName%":2A9A28-2A9BC8>> TEMP1.asm
echo:incbin "%ROMName%":2A9BD0-2A9D50>> TEMP1.asm
echo:incbin "%ROMName%":2A9D58-2A9F38>> TEMP1.asm
echo:incbin "%ROMName%":2A9F40-2AA0C0>> TEMP1.asm
echo:incbin "%ROMName%":2AA0C8-2AA2C8>> TEMP1.asm
echo:incbin "%ROMName%":2AA2D0-2AA4D0>> TEMP1.asm
echo:incbin "%ROMName%":2AA4D8-2AA6D8>> TEMP1.asm
echo:incbin "%ROMName%":2AA6E0-2AA8E0>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Chuchu.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging Pitch's graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":22FFDA-22FFFA>> TEMP1.asm
echo:incbin "%ROMName%":2ACBE6-2ACD06>> TEMP1.asm
echo:incbin "%ROMName%":2ACD0E-2ACE2E>> TEMP1.asm
echo:incbin "%ROMName%":2ACE36-2ACF56>> TEMP1.asm
echo:incbin "%ROMName%":2ACF5E-2AD07E>> TEMP1.asm
echo:incbin "%ROMName%":2AD086-2AD1A6>> TEMP1.asm
echo:incbin "%ROMName%":2AD1AE-2AD2CE>> TEMP1.asm
echo:incbin "%ROMName%":2AD2D6-2AD3F6>> TEMP1.asm
echo:incbin "%ROMName%":2AD3FE-2AD51E>> TEMP1.asm
echo:incbin "%ROMName%":2AD526-2AD646>> TEMP1.asm
echo:incbin "%ROMName%":2AD64E-2AD76E>> TEMP1.asm
echo:incbin "%ROMName%":2AD776-2AD896>> TEMP1.asm
echo:incbin "%ROMName%":2AD89E-2AD95E>> TEMP1.asm
echo:incbin "%ROMName%":2AD966-2AD9E6>> TEMP1.asm
echo:incbin "%ROMName%":2AD9EE-2ADAAE>> TEMP1.asm
echo:incbin "%ROMName%":2ADAB6-2ADB36>> TEMP1.asm
echo:incbin "%ROMName%":2ADB3E-2ADBBE>> TEMP1.asm
echo:incbin "%ROMName%":2ADBC6-2ADC46>> TEMP1.asm
echo:incbin "%ROMName%":2ADC4E-2ADD6E>> TEMP1.asm
echo:incbin "%ROMName%":2ADD76-2ADE96>> TEMP1.asm
echo:incbin "%ROMName%":2ADE9E-2ADFBE>> TEMP1.asm
echo:incbin "%ROMName%":2ADFC6-2AE0E6>> TEMP1.asm
echo:incbin "%ROMName%":2AE0EE-2AE20E>> TEMP1.asm
echo:incbin "%ROMName%":2AE216-2AE296>> TEMP1.asm
echo:incbin "%ROMName%":2AE29E-2AE41E>> TEMP1.asm
echo:incbin "%ROMName%":2AE426-2AE4A6>> TEMP1.asm
echo:incbin "%ROMName%":2AE4AE-2AE52E>> TEMP1.asm
echo:incbin "%ROMName%":2AE536-2AE5B6>> TEMP1.asm
echo:incbin "%ROMName%":2AE5BE-2AE6DE>> TEMP1.asm
echo:incbin "%ROMName%":2AE6E6-2AE806>> TEMP1.asm
echo:incbin "%ROMName%":2AE80E-2AE92E>> TEMP1.asm
echo:incbin "%ROMName%":2AE936-2AEA56>> TEMP1.asm
echo:incbin "%ROMName%":2AEA5E-2AEB7E>> TEMP1.asm
echo:incbin "%ROMName%":2AEB86-2AECA6>> TEMP1.asm
echo:incbin "%ROMName%":2AECAE-2AED6E>> TEMP1.asm
echo:incbin "%ROMName%":2AED76-2AEE56>> TEMP1.asm
echo:incbin "%ROMName%":2AEE5E-2AEF1E>> TEMP1.asm
echo:incbin "%ROMName%":2AEF26-2AEFE6>> TEMP1.asm
echo:incbin "%ROMName%":2AEFEE-2AF0AE>> TEMP1.asm
echo:incbin "%ROMName%":2AF0B6-2AF176>> TEMP1.asm
echo:incbin "%ROMName%":2AF17E-2AF23E>> TEMP1.asm
echo:incbin "%ROMName%":2AF246-2AF366>> TEMP1.asm
echo:incbin "%ROMName%":2AF36E-2AF48E>> TEMP1.asm
echo:incbin "%ROMName%":2AF496-2AF556>> TEMP1.asm
echo:incbin "%ROMName%":2AF55E-2AF67E>> TEMP1.asm
echo:incbin "%ROMName%":2AF686-2AF7A6>> TEMP1.asm
echo:incbin "%ROMName%":2AF7AE-2AF8CE>> TEMP1.asm
echo:incbin "%ROMName%":2AF8D6-2AF996>> TEMP1.asm
echo:incbin "%ROMName%":2AF99E-2AFA5E>> TEMP1.asm
echo:incbin "%ROMName%":2AFA66-2AFB26>> TEMP1.asm
echo:incbin "%ROMName%":2AFB2E-2AFBEE>> TEMP1.asm
echo:incbin "%ROMName%":2AFBF6-2AFCB6>> TEMP1.asm
echo:incbin "%ROMName%":2AFCBE-2AFDDE>> TEMP1.asm
echo:incbin "%ROMName%":2AFDE6-2AFF06>> TEMP1.asm
echo:incbin "%ROMName%":2AFF0E-2AFFCE>> TEMP1.asm
echo:incbin "%ROMName%":2B0008-2B0128>> TEMP1.asm
echo:incbin "%ROMName%":2B0130-2B0250>> TEMP1.asm
echo:incbin "%ROMName%":2B0258-2B0378>> TEMP1.asm
echo:incbin "%ROMName%":2B0380-2B04A0>> TEMP1.asm
echo:incbin "%ROMName%":2B04A8-2B05C8>> TEMP1.asm
echo:incbin "%ROMName%":2B05D0-2B06F0>> TEMP1.asm
echo:incbin "%ROMName%":2B06F8-2B0818>> TEMP1.asm
echo:incbin "%ROMName%":2B0820-2B0940>> TEMP1.asm
echo:incbin "%ROMName%":2B0948-2B0A68>> TEMP1.asm
echo:incbin "%ROMName%":2B0A70-2B0B90>> TEMP1.asm
echo:incbin "%ROMName%":2B0B98-2B0C58>> TEMP1.asm
echo:incbin "%ROMName%":2B0C60-2B0D80>> TEMP1.asm
echo:incbin "%ROMName%":2B0D88-2B0EA8>> TEMP1.asm
echo:incbin "%ROMName%":2B0EB0-2B0FD0>> TEMP1.asm
echo:incbin "%ROMName%":2B0FD8-2B10F8>> TEMP1.asm
echo:incbin "%ROMName%":2B1100-2B11C0>> TEMP1.asm
echo:incbin "%ROMName%":2B11C8-2B1288>> TEMP1.asm
echo:incbin "%ROMName%":2B1290-2B1350>> TEMP1.asm
echo:incbin "%ROMName%":2B1358-2B1418>> TEMP1.asm
echo:incbin "%ROMName%":2B1420-2B1540>> TEMP1.asm
echo:incbin "%ROMName%":2B1548-2B1668>> TEMP1.asm
echo:incbin "%ROMName%":2B1670-2B1790>> TEMP1.asm
echo:incbin "%ROMName%":2B1798-2B1858>> TEMP1.asm
echo:incbin "%ROMName%":2B1860-2B1980>> TEMP1.asm
echo:incbin "%ROMName%":2B1988-2B1AA8>> TEMP1.asm
echo:incbin "%ROMName%":2B1AB0-2B1BD0>> TEMP1.asm
echo:incbin "%ROMName%":2B1BD8-2B1CF8>> TEMP1.asm
echo:incbin "%ROMName%":2B1D00-2B1E20>> TEMP1.asm
echo:incbin "%ROMName%":2B1E28-2B1F48>> TEMP1.asm
echo:incbin "%ROMName%":2B1F50-2B2070>> TEMP1.asm
echo:incbin "%ROMName%":2B2078-2B2198>> TEMP1.asm
echo:incbin "%ROMName%":2B21A0-2B22C0>> TEMP1.asm
echo:incbin "%ROMName%":2B22C8-2B2348>> TEMP1.asm
echo:incbin "%ROMName%":2B2350-2B2450>> TEMP1.asm
echo:incbin "%ROMName%":2B2458-2B2518>> TEMP1.asm
echo:incbin "%ROMName%":2B2520-2B2640>> TEMP1.asm
echo:incbin "%ROMName%":2B2648-2B2768>> TEMP1.asm
echo:incbin "%ROMName%":2B2770-2B2890>> TEMP1.asm
echo:incbin "%ROMName%":2B2898-2B29B8>> TEMP1.asm
echo:incbin "%ROMName%":2B29C0-2B2AC0>> TEMP1.asm
echo:incbin "%ROMName%":2B2AC8-2B2B68>> TEMP1.asm
echo:incbin "%ROMName%":2B2B70-2B2C10>> TEMP1.asm
echo:incbin "%ROMName%":2B2C18-2B2CB8>> TEMP1.asm
echo:incbin "%ROMName%":2B2CC0-2B2D60>> TEMP1.asm
echo:incbin "%ROMName%":2B2D68-2B2E68>> TEMP1.asm
echo:incbin "%ROMName%":2B2E70-2B2F70>> TEMP1.asm
echo:incbin "%ROMName%":2B2F78-2B3038>> TEMP1.asm
echo:incbin "%ROMName%":2B3040-2B3180>> TEMP1.asm
echo:incbin "%ROMName%":2B3188-2B3248>> TEMP1.asm
echo:incbin "%ROMName%":2B3250-2B3350>> TEMP1.asm
echo:incbin "%ROMName%":2B3358-2B3418>> TEMP1.asm
echo:incbin "%ROMName%":2B3420-2B34E0>> TEMP1.asm
echo:incbin "%ROMName%":2B34E8-2B3568>> TEMP1.asm
echo:incbin "%ROMName%":2B3570-2B3630>> TEMP1.asm
echo:incbin "%ROMName%":2B3638-2B3758>> TEMP1.asm
echo:incbin "%ROMName%":2B3760-2B3880>> TEMP1.asm
echo:incbin "%ROMName%":2B3888-2B39A8>> TEMP1.asm
echo:incbin "%ROMName%":2B39B0-2B3A70>> TEMP1.asm
echo:incbin "%ROMName%":2B3A78-2B3B98>> TEMP1.asm
echo:incbin "%ROMName%":2B3BA0-2B3CC0>> TEMP1.asm
echo:incbin "%ROMName%":2B3CC8-2B3DE8>> TEMP1.asm
echo:incbin "%ROMName%":2B3DF0-2B3F10>> TEMP1.asm
echo:incbin "%ROMName%":2B3F18-2B4038>> TEMP1.asm
echo:incbin "%ROMName%":2B4040-2B4160>> TEMP1.asm
echo:incbin "%ROMName%":2B4168-2B4288>> TEMP1.asm
echo:incbin "%ROMName%":2B4290-2B43B0>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_Pitch.bin"

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging miscellaneous graphics...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":1ABBDF-1ADFDF>> TEMP1.asm
echo:incbin "%ROMName%":1AEFDF-1AF7DF>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_ZeroPhase1.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":1BBE89-1BD089>> TEMP1.asm
echo:incbin "%ROMName%":1BD289-1BF289>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_Sprite_CopyAbilityEffects.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":30C43B-30C4FB>> TEMP1.asm
echo:incbin "%ROMName%":30C508-30C5C8>> TEMP1.asm
echo:incbin "%ROMName%":30C5D5-30C695>> TEMP1.asm
echo:incbin "%ROMName%":30C6A2-30C762>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3WaterWithLightShine.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":317A4E-317B4E>> TEMP1.asm
echo:incbin "%ROMName%":317B5B-317C5B>> TEMP1.asm
echo:incbin "%ROMName%":317C68-317D68>> TEMP1.asm
echo:incbin "%ROMName%":317D75-317E75>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3Embers.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":317E89-317F89>> TEMP1.asm
echo:incbin "%ROMName%":317F96-318096>> TEMP1.asm
echo:incbin "%ROMName%":3180A3-3181A3>> TEMP1.asm
echo:incbin "%ROMName%":3181B0-3182B0>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedSandfall.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3182C4-3183C4>> TEMP1.asm
echo:incbin "%ROMName%":3183D1-3184D1>> TEMP1.asm
echo:incbin "%ROMName%":3184DE-3185DE>> TEMP1.asm
echo:incbin "%ROMName%":3185EB-3186EB>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3Leaves.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":31D4FD-31D5ED>> TEMP1.asm
echo:incbin "%ROMName%":31D5FA-31D6EA>> TEMP1.asm
echo:incbin "%ROMName%":31D6F7-31D7E7>> TEMP1.asm
echo:incbin "%ROMName%":31D7F4-31D8E4>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3SuperHeavySnowfall.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":31D8F8-31D9E8>> TEMP1.asm
echo:incbin "%ROMName%":31D9F5-31DAE5>> TEMP1.asm
echo:incbin "%ROMName%":31DAF2-31DBE2>> TEMP1.asm
echo:incbin "%ROMName%":31DBEF-31DCDF>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3LightSnowfall.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":31DCF3-31DDE3>> TEMP1.asm
echo:incbin "%ROMName%":31DDF0-31DEE0>> TEMP1.asm
echo:incbin "%ROMName%":31DEED-31DFDD>> TEMP1.asm
echo:incbin "%ROMName%":31DFEA-31E0DA>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3HeavySnowfall.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":323AE3-323CC3>> TEMP1.asm
echo:incbin "%ROMName%":323CD0-323EB0>> TEMP1.asm
echo:incbin "%ROMName%":323EBD-32409D>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedSpinningFlowersAndMovingStackedPlants.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":33C19E-33C1BE>> TEMP1.asm
echo:incbin "%ROMName%":33C1CB-33C1EB>> TEMP1.asm
echo:incbin "%ROMName%":33C1F8-33C218>> TEMP1.asm
echo:incbin "%ROMName%":33C225-33C245>> TEMP1.asm
echo:incbin "%ROMName%":33C252-33C272>> TEMP1.asm
echo:incbin "%ROMName%":33C27F-33C29F>> TEMP1.asm
echo:incbin "%ROMName%":33C2AC-33C2CC>> TEMP1.asm
echo:incbin "%ROMName%":33C2D9-33C2F9>> TEMP1.asm
echo:incbin "%ROMName%":33C306-33C326>> TEMP1.asm
echo:incbin "%ROMName%":33C333-33C353>> TEMP1.asm
echo:incbin "%ROMName%":33C360-33C380>> TEMP1.asm
echo:incbin "%ROMName%":33C38D-33C3AD>> TEMP1.asm
echo:incbin "%ROMName%":33C3BA-33C3DA>> TEMP1.asm
echo:incbin "%ROMName%":33C3E7-33C407>> TEMP1.asm
echo:incbin "%ROMName%":33C414-33C434>> TEMP1.asm
echo:incbin "%ROMName%":33C441-33C461>> TEMP1.asm
echo:incbin "%ROMName%":33C46E-33C48E>> TEMP1.asm
echo:incbin "%ROMName%":33C49B-33C4BB>> TEMP1.asm
echo:incbin "%ROMName%":33C4C8-33C4E8>> TEMP1.asm
echo:incbin "%ROMName%":33C4F5-33C515>> TEMP1.asm
echo:incbin "%ROMName%":33C522-33C542>> TEMP1.asm
echo:incbin "%ROMName%":33C54F-33C56F>> TEMP1.asm
echo:incbin "%ROMName%":33C57C-33C59C>> TEMP1.asm
echo:incbin "%ROMName%":33C5A9-33C5C9>> TEMP1.asm
echo:incbin "%ROMName%":33C5D6-33C5F6>> TEMP1.asm
echo:incbin "%ROMName%":33C603-33C623>> TEMP1.asm
echo:incbin "%ROMName%":33C630-33C650>> TEMP1.asm
echo:incbin "%ROMName%":33C65D-33C67D>> TEMP1.asm
echo:incbin "%ROMName%":33C68A-33C6AA>> TEMP1.asm
echo:incbin "%ROMName%":33C6B7-33C6D7>> TEMP1.asm
echo:incbin "%ROMName%":33C6E4-33C704>> TEMP1.asm
echo:incbin "%ROMName%":33C711-33C731>> TEMP1.asm
echo:incbin "%ROMName%":33C73E-33C75E>> TEMP1.asm
echo:incbin "%ROMName%":33C76B-33C78B>> TEMP1.asm
echo:incbin "%ROMName%":33C798-33C7B8>> TEMP1.asm
echo:incbin "%ROMName%":33C7C5-33C7E5>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3RuinsWater.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":34564C-34574C>> TEMP1.asm
echo:incbin "%ROMName%":345759-345859>> TEMP1.asm
echo:incbin "%ROMName%":345866-345966>> TEMP1.asm
echo:incbin "%ROMName%":345973-345A73>> TEMP1.asm
echo:incbin "%ROMName%":345A80-345B80>> TEMP1.asm
echo:incbin "%ROMName%":345B8D-345C8D>> TEMP1.asm
echo:incbin "%ROMName%":345C9A-345D9A>> TEMP1.asm
echo:incbin "%ROMName%":345DA7-345EA7>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedConveyorSand.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":348874-348A74>> TEMP1.asm
echo:incbin "%ROMName%":348A81-348C81>> TEMP1.asm
echo:incbin "%ROMName%":348C8E-348E8E>> TEMP1.asm
echo:incbin "%ROMName%":348E9B-34909B>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedCloverClouds.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3490AF-3492AF>> TEMP1.asm
echo:incbin "%ROMName%":3492BC-3494BC>> TEMP1.asm
echo:incbin "%ROMName%":3494C9-3496C9>> TEMP1.asm
echo:incbin "%ROMName%":3496D6-3498D6>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedWallFan.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3498EA-349AEA>> TEMP1.asm
echo:incbin "%ROMName%":349AF7-349CF7>> TEMP1.asm
echo:incbin "%ROMName%":349D04-349F04>> TEMP1.asm
echo:incbin "%ROMName%":349F11-34A111>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedTreetopLeaves.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":34D912-34DAF2>> TEMP1.asm
echo:incbin "%ROMName%":34DAFF-34DCDF>> TEMP1.asm
echo:incbin "%ROMName%":34DCEC-34DECC>> TEMP1.asm
echo:incbin "%ROMName%":34DED9-34E0B9>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedCloudFG.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3768CB-3769CB>> TEMP1.asm
echo:incbin "%ROMName%":3769D8-376AD8>> TEMP1.asm
echo:incbin "%ROMName%":376AE5-376BE5>> TEMP1.asm
echo:incbin "%ROMName%":376BF2-376CF2>> TEMP1.asm
echo:incbin "%ROMName%":376CFF-376DFF>> TEMP1.asm
echo:incbin "%ROMName%":376E0C-376F0C>> TEMP1.asm
echo:incbin "%ROMName%":376F19-377019>> TEMP1.asm
echo:incbin "%ROMName%":377026-377126>> TEMP1.asm
echo:incbin "%ROMName%":377133-377233>> TEMP1.asm
echo:incbin "%ROMName%":377240-377340>> TEMP1.asm
echo:incbin "%ROMName%":37734D-37744D>> TEMP1.asm
echo:incbin "%ROMName%":37745A-37755A>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3Flowers.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":38000E-38010E>> TEMP1.asm
echo:incbin "%ROMName%":38011B-38021B>> TEMP1.asm
echo:incbin "%ROMName%":380228-380328>> TEMP1.asm
echo:incbin "%ROMName%":380335-380435>> TEMP1.asm
echo:incbin "%ROMName%":380442-380542>> TEMP1.asm
echo:incbin "%ROMName%":38054F-38064F>> TEMP1.asm
echo:incbin "%ROMName%":38065C-38075C>> TEMP1.asm
echo:incbin "%ROMName%":380769-380869>> TEMP1.asm
echo:incbin "%ROMName%":380876-380976>> TEMP1.asm
echo:incbin "%ROMName%":380983-380A83>> TEMP1.asm
echo:incbin "%ROMName%":380A90-380B90>> TEMP1.asm
echo:incbin "%ROMName%":380B9D-380C9D>> TEMP1.asm
echo:incbin "%ROMName%":380CAA-380DAA>> TEMP1.asm
echo:incbin "%ROMName%":380DB7-380EB7>> TEMP1.asm
echo:incbin "%ROMName%":380EC4-380FC4>> TEMP1.asm
echo:incbin "%ROMName%":380FD1-3810D1>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLayer3Rain.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":382170-382370>> TEMP1.asm
echo:incbin "%ROMName%":38237D-38257D>> TEMP1.asm
echo:incbin "%ROMName%":38258A-38278A>> TEMP1.asm
echo:incbin "%ROMName%":382797-382997>> TEMP1.asm
echo:incbin "%ROMName%":3829A4-382BA4>> TEMP1.asm
echo:incbin "%ROMName%":382BB1-382DB1>> TEMP1.asm
echo:incbin "%ROMName%":382DBE-382FBE>> TEMP1.asm
echo:incbin "%ROMName%":382FCB-3831CB>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedMeltingSnow.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3831DF-3833DF>> TEMP1.asm
echo:incbin "%ROMName%":3833EC-3835EC>> TEMP1.asm
echo:incbin "%ROMName%":3835F9-3837F9>> TEMP1.asm
echo:incbin "%ROMName%":383806-383A06>> TEMP1.asm
echo:incbin "%ROMName%":383A13-383C13>> TEMP1.asm
echo:incbin "%ROMName%":383C20-383E20>> TEMP1.asm
echo:incbin "%ROMName%":383E2D-38402D>> TEMP1.asm
echo:incbin "%ROMName%":38403A-38423A>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedWaterfall.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":38424E-38444E>> TEMP1.asm
echo:incbin "%ROMName%":38445B-38465B>> TEMP1.asm
echo:incbin "%ROMName%":384668-384868>> TEMP1.asm
echo:incbin "%ROMName%":384875-384A75>> TEMP1.asm
echo:incbin "%ROMName%":384A82-384C82>> TEMP1.asm
echo:incbin "%ROMName%":384C8F-384E8F>> TEMP1.asm
echo:incbin "%ROMName%":384E9C-38509C>> TEMP1.asm
echo:incbin "%ROMName%":3850A9-3852A9>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedPyramidWalls.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3852BD-3854BD>> TEMP1.asm
echo:incbin "%ROMName%":3854CA-3856CA>> TEMP1.asm
echo:incbin "%ROMName%":3856D7-3858D7>> TEMP1.asm
echo:incbin "%ROMName%":3858E4-385AE4>> TEMP1.asm
echo:incbin "%ROMName%":385AF1-385CF1>> TEMP1.asm
echo:incbin "%ROMName%":385CFE-385EFE>> TEMP1.asm
echo:incbin "%ROMName%":385F0B-38610B>> TEMP1.asm
echo:incbin "%ROMName%":386118-386318>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedDesertPlant.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":38835D-38853D>> TEMP1.asm
echo:incbin "%ROMName%":38854A-38872A>> TEMP1.asm
echo:incbin "%ROMName%":388737-388917>> TEMP1.asm
echo:incbin "%ROMName%":388924-388B04>> TEMP1.asm
echo:incbin "%ROMName%":388B11-388CF1>> TEMP1.asm
echo:incbin "%ROMName%":388CFE-388EDE>> TEMP1.asm
echo:incbin "%ROMName%":388EEB-3890CB>> TEMP1.asm
echo:incbin "%ROMName%":3890D8-3892B8>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedSeaweedAndStarfish.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3892CC-3894AC>> TEMP1.asm
echo:incbin "%ROMName%":3894B9-389699>> TEMP1.asm
echo:incbin "%ROMName%":3896A6-389886>> TEMP1.asm
echo:incbin "%ROMName%":389893-389A73>> TEMP1.asm
echo:incbin "%ROMName%":389A80-389C60>> TEMP1.asm
echo:incbin "%ROMName%":389C6D-389E4D>> TEMP1.asm
echo:incbin "%ROMName%":389E5A-38A03A>> TEMP1.asm
echo:incbin "%ROMName%":38A047-38A227>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedLava.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3C000E-3C020E>> TEMP1.asm
echo:incbin "%ROMName%":3C021B-3C041B>> TEMP1.asm
echo:incbin "%ROMName%":3C0428-3C0628>> TEMP1.asm
echo:incbin "%ROMName%":3C0635-3C0835>> TEMP1.asm
echo:incbin "%ROMName%":3C0842-3C0A42>> TEMP1.asm
echo:incbin "%ROMName%":3C0A4F-3C0C4F>> TEMP1.asm
echo:incbin "%ROMName%":3C0C5C-3C0E5C>> TEMP1.asm
echo:incbin "%ROMName%":3C0E69-3C1069>> TEMP1.asm
echo:incbin "%ROMName%":3C1076-3C1276>> TEMP1.asm
echo:incbin "%ROMName%":3C1283-3C1483>> TEMP1.asm
echo:incbin "%ROMName%":3C1490-3C1690>> TEMP1.asm
echo:incbin "%ROMName%":3C169D-3C189D>> TEMP1.asm
echo:incbin "%ROMName%":3C18AA-3C1AAA>> TEMP1.asm
echo:incbin "%ROMName%":3C1AB7-3C1CB7>> TEMP1.asm
echo:incbin "%ROMName%":3C1CC4-3C1EC4>> TEMP1.asm
echo:incbin "%ROMName%":3C1ED1-3C20D1>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedCloudStars.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":3DD46D-3DD66D>> TEMP1.asm
echo:incbin "%ROMName%":3DD67A-3DD87A>> TEMP1.asm
echo:incbin "%ROMName%":3DD887-3DDA87>> TEMP1.asm
echo:incbin "%ROMName%":3DDA94-3DDC94>> TEMP1.asm
echo:incbin "%ROMName%":3DDCA1-3DDEA1>> TEMP1.asm
echo:incbin "%ROMName%":3DDEAE-3DE0AE>> TEMP1.asm
echo:incbin "%ROMName%":3DE0BB-3DE2BB>> TEMP1.asm
echo:incbin "%ROMName%":3DE2C8-3DE4C8>> TEMP1.asm
echo:incbin "%ROMName%":3DE4D5-3DE6D5>> TEMP1.asm
echo:incbin "%ROMName%":3DE6E2-3DE8E2>> TEMP1.asm
echo:incbin "%ROMName%":3DE8EF-3DEAEF>> TEMP1.asm
echo:incbin "%ROMName%":3DEAFC-3DECFC>> TEMP1.asm
echo:incbin "%ROMName%":3DED09-3DEF09>> TEMP1.asm
echo:incbin "%ROMName%":3DEF16-3DF116>> TEMP1.asm
echo:incbin "%ROMName%":3DF123-3DF323>> TEMP1.asm
echo:incbin "%ROMName%":3DF330-3DF530>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "GFX_AnimatedRollingLogBridge.bin"

if exist TEMP1.asm del TEMP1.asm

EXIT /B 0

:MergeSplitPalettes

if exist TEMP1.asm del TEMP1.asm

echo:Extracting and merging miscellaneous palettes...
echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C274C-2C276A>> TEMP1.asm
echo:incbin "%ROMName%":2C2770-2C278E>> TEMP1.asm
echo:incbin "%ROMName%":2C2794-2C27B2>> TEMP1.asm
echo:incbin "%ROMName%":2C27B8-2C27D6>> TEMP1.asm
echo:incbin "%ROMName%":2C27DC-2C27FA>> TEMP1.asm
echo:incbin "%ROMName%":2C2800-2C281E>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation00.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C282B-2C2849>> TEMP1.asm
echo:incbin "%ROMName%":2C284F-2C286D>> TEMP1.asm
echo:incbin "%ROMName%":2C2873-2C2891>> TEMP1.asm
echo:incbin "%ROMName%":2C2897-2C28B5>> TEMP1.asm
echo:incbin "%ROMName%":2C28BB-2C28D9>> TEMP1.asm
echo:incbin "%ROMName%":2C28DF-2C28FD>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation01.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C2AA0-2C2AC0>> TEMP1.asm
echo:incbin "%ROMName%":2C2AC6-2C2AE6>> TEMP1.asm
echo:incbin "%ROMName%":2C2AEC-2C2B0C>> TEMP1.asm
echo:incbin "%ROMName%":2C2B12-2C2B32>> TEMP1.asm
echo:incbin "%ROMName%":2C2B38-2C2B58>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation02.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C2B65-2C2B85>> TEMP1.asm
echo:incbin "%ROMName%":2C2B8B-2C2BAB>> TEMP1.asm
echo:incbin "%ROMName%":2C2BB1-2C2BD1>> TEMP1.asm
echo:incbin "%ROMName%":2C2BD7-2C2BF7>> TEMP1.asm
echo:incbin "%ROMName%":2C2BFD-2C2C1D>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation03.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C322B-2C3249>> TEMP1.asm
echo:incbin "%ROMName%":2C324F-2C326D>> TEMP1.asm
echo:incbin "%ROMName%":2C3273-2C3291>> TEMP1.asm
echo:incbin "%ROMName%":2C3297-2C32B5>> TEMP1.asm
echo:incbin "%ROMName%":2C32BB-2C32D9>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation04.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C32E6-2C3304>> TEMP1.asm
echo:incbin "%ROMName%":2C330A-2C3328>> TEMP1.asm
echo:incbin "%ROMName%":2C332E-2C334C>> TEMP1.asm
echo:incbin "%ROMName%":2C3352-2C3370>> TEMP1.asm
echo:incbin "%ROMName%":2C3376-2C3394>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation05.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C5AB4-2C5AD2>> TEMP1.asm
echo:incbin "%ROMName%":2C5AD8-2C5AF6>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation06.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C7E9F-2C7EA7>> TEMP1.asm
echo:incbin "%ROMName%":2C7EAD-2C7EB5>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation07.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C7EC2-2C7ECA>> TEMP1.asm
echo:incbin "%ROMName%":2C7ED0-2C7ED8>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation08.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2C7EE5-2C7EED>> TEMP1.asm
echo:incbin "%ROMName%":2C7EF3-2C7EFB>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation09.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2DBBEF-2DBC0D>> TEMP1.asm
echo:incbin "%ROMName%":2DBC13-2DBC31>> TEMP1.asm
echo:incbin "%ROMName%":2DBC37-2DBC55>> TEMP1.asm
echo:incbin "%ROMName%":2DBC5B-2DBC79>> TEMP1.asm
echo:incbin "%ROMName%":2DBC7F-2DBC9D>> TEMP1.asm
echo:incbin "%ROMName%":2DBCA3-2DBCC1>> TEMP1.asm
echo:incbin "%ROMName%":2DBCC7-2DBCE5>> TEMP1.asm
echo:incbin "%ROMName%":2DBCEB-2DBD09>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation0A.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2DEF33-2DEF51>> TEMP1.asm
echo:incbin "%ROMName%":2DEF57-2DEF75>> TEMP1.asm
echo:incbin "%ROMName%":2DEF7B-2DEF99>> TEMP1.asm
echo:incbin "%ROMName%":2DEF9F-2DEFBD>> TEMP1.asm
echo:incbin "%ROMName%":2DEFC3-2DEFE1>> TEMP1.asm
echo:incbin "%ROMName%":2DEFE7-2DF005>> TEMP1.asm
echo:incbin "%ROMName%":2DF00B-2DF029>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation0B.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2FDEC5-2FDEE3>> TEMP1.asm
echo:incbin "%ROMName%":2FDEE9-2FDF07>> TEMP1.asm
echo:incbin "%ROMName%":2FDF0D-2FDF2B>> TEMP1.asm
echo:incbin "%ROMName%":2FDF31-2FDF4F>> TEMP1.asm
echo:incbin "%ROMName%":2FDF55-2FDF73>> TEMP1.asm
echo:incbin "%ROMName%":2FDF79-2FDF97>> TEMP1.asm
echo:incbin "%ROMName%":2FDF9D-2FDFBB>> TEMP1.asm
echo:incbin "%ROMName%":2FDFC1-2FDFDF>> TEMP1.asm
echo:incbin "%ROMName%":2FDFE5-2FE003>> TEMP1.asm
echo:incbin "%ROMName%":2FE009-2FE027>> TEMP1.asm
echo:incbin "%ROMName%":2FE02D-2FE04B>> TEMP1.asm
echo:incbin "%ROMName%":2FE051-2FE06F>> TEMP1.asm
echo:incbin "%ROMName%":2FE075-2FE093>> TEMP1.asm
echo:incbin "%ROMName%":2FE099-2FE0B7>> TEMP1.asm
echo:incbin "%ROMName%":2FE0BD-2FE0DB>> TEMP1.asm
echo:incbin "%ROMName%":2FE0E1-2FE0FF>> TEMP1.asm
echo:incbin "%ROMName%":2FE105-2FE123>> TEMP1.asm
echo:incbin "%ROMName%":2FE129-2FE147>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation0C.bin"

if exist TEMP1.asm del TEMP1.asm

echo:%MemMap% >> TEMP1.asm
echo:org $C00000 >> TEMP1.asm
echo:check bankcross off >> TEMP1.asm
echo:incbin "%ROMName%":2FFFDA-2FFFE2>> TEMP1.asm
echo:incbin "%ROMName%":2FFFE8-2FFFF0>> TEMP1.asm
asar --fix-checksum=off --no-title-check "TEMP1.asm" "LevelPaletteAnimation0D.bin"

if exist TEMP1.asm del TEMP1.asm

EXIT /B 0