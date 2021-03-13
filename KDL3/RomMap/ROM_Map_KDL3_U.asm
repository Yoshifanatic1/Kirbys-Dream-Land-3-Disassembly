
macro KDL3_GameSpecificAssemblySettings()
	!ROM_KDL3_U = $0001							;\ These defines assign each ROM version with a different bit so version difference checks will work. Do not touch them!
	!ROM_KDL3_J = $0002							;/

!Define_KDL3_Global_EnableDebugFunctions = !FALSE

	%SetROMToAssembleForHack(KDL3_U, !ROMID)
endmacro

macro KDL3_LoadGameSpecificMainSNESFiles()
	incsrc ../Misc_Defines_KDL3.asm
	incsrc ../RAM_Map_KDL3.asm
	incsrc ../Routine_Macros_KDL3.asm
	incsrc ../SNES_Macros_KDL3.asm
endmacro

macro KDL3_LoadGameSpecificMainSPC700Files()
	incsrc ../SPC700/ARAM_Map_KDL3.asm
	incsrc ../Misc_Defines_KDL3.asm
	incsrc ../SPC700/SPC700_Macros_KDL3.asm
endmacro

macro KDL3_LoadGameSpecificMainExtraHardwareFiles()
endmacro

macro KDL3_LoadGameSpecificMSU1Files()
endmacro

macro KDL3_GlobalAssemblySettings()
	!Define_Global_ApplyAsarPatches = !FALSE
	!Define_Global_InsertRATSTags = !TRUE
	!Define_Global_IgnoreCodeAlignments = !FALSE
	!Define_Global_IgnoreOriginalFreespace = !FALSE
	!Define_Global_CompatibleControllers = !Controller_StandardJoypad
	!Define_Global_DisableROMMirroring = !FALSE
	!Define_Global_CartridgeHeaderVersion = $02
	!Define_Global_FixIncorrectChecksumHack = !TRUE
	!Define_Global_ROMFrameworkVer = 1
	!Define_Global_ROMFrameworkSubVer = 0
	!Define_Global_ROMFrameworkSubSubVer = 1
	!Define_Global_AsarChecksum = $0000
	!Define_Global_LicenseeName = "Nintendo"
	!Define_Global_DeveloperName = "HAL Laboratory"
	!Define_Global_ReleaseDate = "November 27, 1997"
	!Define_Global_BaseROMMD5Hash = "4fa31bca65a46f2675a861bfe6385486"

	!Define_Global_MakerCode = "01"
	!Define_Global_GameCode = "AFJE"
	!Define_Global_ReservedSpace = $00,$00,$00,$00,$00,$00
	!Define_Global_ExpansionFlashSize = !ExpansionMemorySize_0KB
	!Define_Global_ExpansionRAMSize = !ExpansionMemorySize_0KB
	!Define_Global_IsSpecialVersion = $00
	!Define_Global_InternalName = "KIRBY'S DREAM LAND 3 "
	!Define_Global_ROMLayout = !ROMLayout_SA1_LoROM
	!Define_Global_ROMType = !ROMType_ROM_RAM_SRAM_Chip
	!Define_Global_CustomChip = !Chip_SA1
	!Define_Global_ROMSize = !ROMSize_4MB
	!Define_Global_SRAMSize = !SRAMSize_32KB
	!Define_Global_Region = !Region_NorthAmerica
	!Define_Global_LicenseeID = $33
	!Define_Global_VersionNumber = $00
	!Define_Global_ChecksumCompliment = !Define_Global_Checksum^$FFFF
	!Define_Global_Checksum = $247C
	!UnusedNativeModeVector1 = $0000
	!UnusedNativeModeVector2 = $0000
	!NativeModeCOPVector = $0000
	!NativeModeBRKVector = $5FFF
	!NativeModeAbortVector = $0000
	!NativeModeNMIVector = CODE_0082F6
	!NativeModeResetVector = $0000
	!NativeModeIRQVector = CODE_008363
	!UnusedEmulationModeVector1 = $0000
	!UnusedEmulationModeVector2 = $0000
	!EmulationModeCOPVector = $0000
	!EmulationModeBRKVector = $0000
	!EmulationModeAbortVector = $0000
	!EmulationModeNMIVector = $0000
	!EmulationModeResetVector = CODE_008000
	!EmulationModeIRQVector = $0000
	%LoadExtraRAMFile("BWRAM_Map_KDL3.asm")
endmacro

macro KDL3_LoadROMMap()
	%KDL3Bank00Macros(!BANK_00, !BANK_00)
	%KDL3Bank01Macros(!BANK_01, !BANK_01)
	%KDL3BankC1Macros(!BANK_C1, !BANK_C1)
	%KDL3BankC2Macros(!BANK_C2, !BANK_C2)
	%KDL3BankC3Macros(!BANK_C3, !BANK_C3)
	%KDL3BankC4Macros(!BANK_C4, !BANK_C4)
	%KDL3BankC5Macros(!BANK_C5, !BANK_C5)
	%KDL3BankC6Macros(!BANK_C6, !BANK_C6)
	%KDL3BankC7Macros(!BANK_C7, !BANK_C7)
	%KDL3BankC8Macros(!BANK_C8, !BANK_C8)
	%KDL3BankC9Macros(!BANK_C9, !BANK_C9)
	%KDL3BankCAMacros(!BANK_CA, !BANK_CA)
	%KDL3BankCBMacros(!BANK_CB, !BANK_CB)
	%KDL3BankCCMacros(!BANK_CC, !BANK_CC)
	%KDL3BankCDMacros(!BANK_CD, !BANK_CD)
	%KDL3BankCEMacros(!BANK_CE, !BANK_CE)
	%KDL3BankCFMacros(!BANK_CF, !BANK_CF)
	%KDL3BankD0Macros(!BANK_D0, !BANK_D0)
	%KDL3BankD1Macros(!BANK_D1, !BANK_D1)
	%KDL3BankD2Macros(!BANK_D2, !BANK_D2)
	%KDL3BankD3Macros(!BANK_D3, !BANK_D3)
	%KDL3BankD4Macros(!BANK_D4, !BANK_D4)
	%KDL3BankD5Macros(!BANK_D5, !BANK_D5)
	%KDL3BankD6Macros(!BANK_D6, !BANK_D6)
	%KDL3BankD7Macros(!BANK_D7, !BANK_D7)
	%KDL3BankD8Macros(!BANK_D8, !BANK_D8)
	%KDL3BankD9Macros(!BANK_D9, !BANK_D9)
	%KDL3BankDAMacros(!BANK_DA, !BANK_DA)
	%KDL3BankDBMacros(!BANK_DB, !BANK_DB)
	%KDL3BankDCMacros(!BANK_DC, !BANK_DC)
	%KDL3BankDDMacros(!BANK_DD, !BANK_DD)
	%KDL3BankDEMacros(!BANK_DE, !BANK_DE)
	%KDL3BankDFMacros(!BANK_DF, !BANK_DF)
	%KDL3BankE0Macros(!BANK_E0, !BANK_E0)
	%KDL3BankE1Macros(!BANK_E1, !BANK_E1)
	%KDL3BankE2Macros(!BANK_E2, !BANK_E2)
	%KDL3BankE3Macros(!BANK_E3, !BANK_E3)
	%KDL3BankE4Macros(!BANK_E4, !BANK_E4)
	%KDL3BankE5Macros(!BANK_E5, !BANK_E5)
	%KDL3BankE6Macros(!BANK_E6, !BANK_E6)
	%KDL3BankE7Macros(!BANK_E7, !BANK_E7)
	%KDL3BankE8Macros(!BANK_E8, !BANK_E8)
	%KDL3BankE9Macros(!BANK_E9, !BANK_E9)
	%KDL3BankEAMacros(!BANK_EA, !BANK_EA)
	%KDL3BankEBMacros(!BANK_EB, !BANK_EB)
	%KDL3BankECMacros(!BANK_EC, !BANK_EC)
	%KDL3BankEDMacros(!BANK_ED, !BANK_ED)
	%KDL3BankEEMacros(!BANK_EE, !BANK_EE)
	%KDL3BankEFMacros(!BANK_EF, !BANK_EF)
	%KDL3BankF0Macros(!BANK_F0, !BANK_F0)
	%KDL3BankF1Macros(!BANK_F1, !BANK_F1)
	%KDL3BankF2Macros(!BANK_F2, !BANK_F2)
	%KDL3BankF3Macros(!BANK_F3, !BANK_F3)
	%KDL3BankF4Macros(!BANK_F4, !BANK_F4)
	%KDL3BankF5Macros(!BANK_F5, !BANK_F5)
	%KDL3BankF6Macros(!BANK_F6, !BANK_F6)
	%KDL3BankF7Macros(!BANK_F7, !BANK_F7)
	%KDL3BankF8Macros(!BANK_F8, !BANK_F8)
	%KDL3BankF9Macros(!BANK_F9, !BANK_F9)
	%KDL3BankFAMacros(!BANK_FA, !BANK_FA)
	%KDL3BankFBMacros(!BANK_FB, !BANK_FB)
	%KDL3BankFCMacros(!BANK_FC, !BANK_FC)
	%KDL3BankFDMacros(!BANK_FD, !BANK_FD)
	%KDL3BankFEMacros(!BANK_FE, !BANK_FE)
	%KDL3BankFFMacros(!BANK_FF, !BANK_FF)
endmacro
