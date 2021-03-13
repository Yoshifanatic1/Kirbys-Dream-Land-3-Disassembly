
!BWRAM_KDL3_Level_Sprite_XPosLo = $401A22
!BWRAM_KDL3_Level_Sprite_XPosHi = !BWRAM_KDL3_Level_Sprite_XPosLo+$01

!BWRAM_KDL3_Level_Sprite_YPosLo = $401AA2
!BWRAM_KDL3_Level_Sprite_YPosHi = !BWRAM_KDL3_Level_Sprite_YPosLo+$01

!BWRAM_KDL3_Level_Sprite_SubXPosLo = $401B22
!BWRAM_KDL3_Level_Sprite_SubXPosHi = !BWRAM_KDL3_Level_Sprite_SubXPosLo+$01

!BWRAM_KDL3_Level_Sprite_SubYPosLo = $401BA2
!BWRAM_KDL3_Level_Sprite_SubYPosHi = !BWRAM_KDL3_Level_Sprite_SubYPosLo+$01

!BWRAM_KDL3_Level_Sprite_XSpeedLo = $401D22
!BWRAM_KDL3_Level_Sprite_XSpeedHi = !BWRAM_KDL3_Level_Sprite_XSpeedLo+$01

!BWRAM_KDL3_Level_Sprite_YSpeedLo = $401DA2
!BWRAM_KDL3_Level_Sprite_YSpeedHi = !BWRAM_KDL3_Level_Sprite_YSpeedLo+$01

!BWRAM_KDL3_Level_Player_LifeCountLo = $4039CF
!BWRAM_KDL3_Level_Player_LifeCountHi = !BWRAM_KDL3_Level_Player_LifeCountLo+$01
!BWRAM_KDL3_Level_Player_KirbyHPLo = $4039D1
!BWRAM_KDL3_Level_Player_KirbyHPHi = !BWRAM_KDL3_Level_Player_KirbyHPLo+$01
!BWRAM_KDL3_Level_Player_GooeyHPLo = $4039D3
!BWRAM_KDL3_Level_Player_GooeyHPHi = !BWRAM_KDL3_Level_Player_GooeyHPLo+$01
!BWRAM_KDL3_Level_Player_BossHPLo = $4039D5
!BWRAM_KDL3_Level_Player_BossHPHi = !BWRAM_KDL3_Level_Player_BossHPLo+$01
!BWRAM_KDL3_Level_Player_StarPiecesCollectedLo = $4039D7
!BWRAM_KDL3_Level_Player_StarPiecesCollectedHi = !BWRAM_KDL3_Level_Player_StarPiecesCollectedLo+$01
!BWRAM_KDL3_Level_Player_KirbyDisplayedHPLo = $4039D9
!BWRAM_KDL3_Level_Player_KirbyDisplayedHPHi = !BWRAM_KDL3_Level_Player_KirbyDisplayedHPLo+$01
!BWRAM_KDL3_Level_Player_GooeyDisplayedHPLo = $4039DB
!BWRAM_KDL3_Level_Player_GooeyDisplayedHPHi = !BWRAM_KDL3_Level_Player_GooeyDisplayedHPLo+$01
!BWRAM_KDL3_Level_Player_BossDisplayedHPLo = $4039DD
!BWRAM_KDL3_Level_Player_BossDisplayedHPHi = !BWRAM_KDL3_Level_Player_BossDisplayedHPLo+$01

!BWRAM_KDL3_Level_StatusBarPalette = $405791
!BWRAM_KDL3_Level_StatusBarTilemap = $4057F1

!BWRAM_KDL3_Level_Player_KirbyCopyAbilityLo = $4054A9
!BWRAM_KDL3_Level_Player_KirbyCopyAbilityHi = !BWRAM_KDL3_Level_Player_KirbyCopyAbilityLo+$01
!BWRAM_KDL3_Level_Player_GooeyCopyAbilityLo = $4054AB
!BWRAM_KDL3_Level_Player_GooeyCopyAbilityHi = !BWRAM_KDL3_Level_Player_GooeyCopyAbilityLo+$01

!BWRAM_KDL3_Global_PaletteMirror = $406300

!BWRAM_KDL3_Global_CurrentMusic = $407350
!BWRAM_KDL3_Global_CurrentLocalSampleBank = $407351

struct KDL3_PaletteMirror !BWRAM_KDL3_Global_PaletteMirror
	.LowByte: skip $01
	.HighByte: skip $01
endstruct align $02
