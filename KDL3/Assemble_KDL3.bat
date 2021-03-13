@echo off

set PATH="../Global"
set Input1=
set asarVer=asar
set GAMDID="KDL3"
set ROMVer=
set ROMExt=.sfc
set HackCheck=""
set HackName=""

setlocal EnableDelayedExpansion

echo Enter the ROM version you want to assemble.
echo Valid options: "KDL3_U" "KDL3_J"
echo For custom ROM versions, use "HACK_<HackName>, where <HackName> is the rest of the custom ROM Map file's name before the extension."

:Input
set /p Input1="%Input1%"
set HackCheck=%Input1:~0,5%
if "%Input1%" equ "" goto :Exit
if "%HackCheck%" equ "HACK_" goto :Hack
if "%Input1%" equ "KDL3_U" goto :USA
if "%Input1%" equ "KDL3_J" goto :Japan

echo. "%Input1%" is not a valid ROM version.
set Input1=
goto :Input

:Hack
set ROMNAME=%Input1:~5,100%
set ROMVer=(Hack)
goto :Assemble

:USA
set ROMVer=(U)
set ROMNAME=Kirby's Dream Land 3
goto :Assemble

:Japan
set ROMVer=(J)
set ROMNAME=Hoshi no Kirby 3

:Assemble

set output="%ROMNAME% %ROMVer%%ROMExt%"

if exist %output% del %output%
echo Assembling "%ROMNAME% %ROMVer%%ROMExt%" ... this may take a minute.
echo.

%asarVer% --fix-checksum=on --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=0 ..\Global\AssembleFile.asm %output%

echo Assembling %ROMNAME% SPC700 engine...
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/Engine.asm" ..\Global\AssembleFile.asm SPC700\Engine.bin

echo Assembling %ROMNAME% sample banks...
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/GlobalSampleBank.asm" ..\Global\AssembleFile.asm SPC700\GlobalSampleBank.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank00.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank00.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank01.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank01.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank02.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank02.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank03.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank03.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank04.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank04.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank05.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank05.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank06.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank06.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank07.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank07.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank08.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank08.bin
%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/LocalSampleBank09.asm" ..\Global\AssembleFile.asm SPC700\LocalSampleBank09.bin

::echo Assembling %ROMNAME% sound effect banks...
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/GlobalSoundBank.asm" ..\Global\AssembleFile.asm SPC700\GlobalSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/FireSoundBank.asm" ..\Global\AssembleFile.asm SPC700\FireSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/IceSoundBank.asm" ..\Global\AssembleFile.asm SPC700\IceSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/SplashScreenSoundBank.asm" ..\Global\AssembleFile.asm SPC700\SplashScreenSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/StoneSoundBank.asm" ..\Global\AssembleFile.asm SPC700\StoneSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/NeedleSoundBank.asm" ..\Global\AssembleFile.asm SPC700\NeedleSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/BroomSoundBank.asm" ..\Global\AssembleFile.asm SPC700\BroomSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/SparkSoundBank.asm" ..\Global\AssembleFile.asm SPC700\SparkSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/ParasolSoundBank.asm" ..\Global\AssembleFile.asm SPC700\ParasolSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/CutterSoundBank.asm" ..\Global\AssembleFile.asm SPC700\CutterSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/GoodEndingSoundBank.asm" ..\Global\AssembleFile.asm SPC700\GoodEndingSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/KingDededeSoundBank.asm" ..\Global\AssembleFile.asm SPC700\KingDededeSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/MinibossSoundBank.asm" ..\Global\AssembleFile.asm SPC700\MinibossSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/AdoSoundBank.asm" ..\Global\AssembleFile.asm SPC700\AdoSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/MinigameSoundBank.asm" ..\Global\AssembleFile.asm SPC700\MinigameSoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/ZeroPhase1SoundBank.asm" ..\Global\AssembleFile.asm SPC700\ZeroPhase1SoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/ZeroPhase2SoundBank.asm" ..\Global\AssembleFile.asm SPC700\ZeroPhase2SoundBank.bin
::%asarVer% --no-title-check --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=4 --define PathToFile="SPC700/PurificationSoundBank.asm" ..\Global\AssembleFile.asm SPC700\PurificationSoundBank.bin

echo Assembling ROM...
%asarVer% --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=1 ..\Global\AssembleFile.asm %output%
goto :NoFirmware

if exist ..\%GAMDID%\Temp.txt del ..\%GAMDID%\Temp.txt
%asarVer% --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=6 ..\Global\AssembleFile.asm Temp.txt
for /f "delims=" %%x in (Temp.txt) do set Firmware=%%x
if "%Firmware%" equ "NULL" goto :NoFirmware
if exist %Firmware% goto :NoFirmware
if exist ..\Firmware\%Firmware% goto :CopyFirmware
goto :NoFirmware

:CopyFirmware
echo Copied %Firmware% to the disassembly folder
copy ..\Firmware\%Firmware% %Firmware%
:NoFirmware
if exist ..\%GAMDID%\Temp.txt del ..\%GAMDID%\Temp.txt

%asarVer% --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=2 ..\Global\AssembleFile.asm %output%

%asarVer% --fix-checksum=off --define GameID="%GAMDID%" --define ROMID="%Input1%" --define FileType=3 ..\Global\AssembleFile.asm %output%

echo Cleaning up...
if exist ..\%GAMDID%\SPC700\Engine.bin del ..\%GAMDID%\SPC700\Engine.bin
if exist ..\%GAMDID%\SPC700\GlobalSampleBank.bin del ..\%GAMDID%\SPC700\GlobalSampleBank.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank00.bin del ..\%GAMDID%\SPC700\LocalSampleBank00.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank01.bin del ..\%GAMDID%\SPC700\LocalSampleBank01.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank02.bin del ..\%GAMDID%\SPC700\LocalSampleBank02.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank03.bin del ..\%GAMDID%\SPC700\LocalSampleBank03.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank04.bin del ..\%GAMDID%\SPC700\LocalSampleBank04.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank05.bin del ..\%GAMDID%\SPC700\LocalSampleBank05.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank06.bin del ..\%GAMDID%\SPC700\LocalSampleBank06.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank07.bin del ..\%GAMDID%\SPC700\LocalSampleBank07.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank08.bin del ..\%GAMDID%\SPC700\LocalSampleBank08.bin
if exist ..\%GAMDID%\SPC700\LocalSampleBank09.bin del ..\%GAMDID%\SPC700\LocalSampleBank09.bin
::if exist ..\%GAMDID%\SPC700\GlobalSoundBank.bin del ..\%GAMDID%\SPC700\GlobalSoundBank.bin
::if exist ..\%GAMDID%\SPC700\FireSoundBank.bin del ..\%GAMDID%\SPC700\FireSoundBank.bin
::if exist ..\%GAMDID%\SPC700\IceSoundBank.bin del ..\%GAMDID%\SPC700\IceSoundBank.bin
::if exist ..\%GAMDID%\SPC700\SplashScreenSoundBank.bin del ..\%GAMDID%\SPC700\SplashScreenSoundBank.bin
::if exist ..\%GAMDID%\SPC700\NeedleSoundBank.bin del ..\%GAMDID%\SPC700\NeedleSoundBank.bin
::if exist ..\%GAMDID%\SPC700\StoneSoundBank.bin del ..\%GAMDID%\SPC700\StoneSoundBank.bin
::if exist ..\%GAMDID%\SPC700\BroomSoundBank.bin del ..\%GAMDID%\SPC700\BroomSoundBank.bin
::if exist ..\%GAMDID%\SPC700\SparkSoundBank.bin del ..\%GAMDID%\SPC700\SparkSoundBank.bin
::if exist ..\%GAMDID%\SPC700\ParasolSoundBank.bin del ..\%GAMDID%\SPC700\ParasolSoundBank.bin
::if exist ..\%GAMDID%\SPC700\CutterSoundBank.bin del ..\%GAMDID%\SPC700\CutterSoundBank.bin
::if exist ..\%GAMDID%\SPC700\GoodEndingSoundBank.bin del ..\%GAMDID%\SPC700\GoodEndingSoundBank.bin
::if exist ..\%GAMDID%\SPC700\KingDededeSoundBank.bin del ..\%GAMDID%\SPC700\KingDededeSoundBank.bin
::if exist ..\%GAMDID%\SPC700\MinibossSoundBank.bin del ..\%GAMDID%\SPC700\MinibossSoundBank.bin
::if exist ..\%GAMDID%\SPC700\AdoSoundBank.bin del ..\%GAMDID%\SPC700\AdoSoundBank.bin
::if exist ..\%GAMDID%\SPC700\MinigameSoundBank.bin del ..\%GAMDID%\SPC700\MinigameSoundBank.bin
::if exist ..\%GAMDID%\SPC700\ZeroPhase1SoundBank.bin del ..\%GAMDID%\SPC700\ZeroPhase1SoundBank.bin
::if exist ..\%GAMDID%\SPC700\ZeroPhase2SoundBank.bin del ..\%GAMDID%\SPC700\ZeroPhase2SoundBank.bin
::if exist ..\%GAMDID%\SPC700\PurificationSoundBank.bin del ..\%GAMDID%\SPC700\PurificationSoundBank.bin

echo.
echo Done^^!
echo.
echo Press Enter to re-assemble the chosen ROM.
goto :Input

:Exit
exit
