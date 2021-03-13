@asar 1.81

; This will dump the data for an asar patch that will be applied to the USA KDL3 ROM. Said patch will set up the data tables for Kirby/Gooey/Rick/Kine/Coo/Nago/Chuchu/Pitch's graphics when applied to the ROM.
; The reason I'm generating a patch and not the tables directly is because of asar limitations. I don't think it's possible for asar to resolve commands through a define while in a print statement.
; Also, it may take a second before asar starts displaying anything on the command line. In addition, you'll need to replace the ' with " in the output patch, then % with " in the output's output , otherwise asar won't assemble the patch.

hirom

!KirbyStartOffset = $DEAF18
!KirbyEndOffset = $E24E00
!GooeyStartOffset = $E2F092
!GooeyEndOffset = $E68868
!RickStartOffset = $E69E62
!RickEndOffset = $E77380
!KineStartOffset = $E78400
!KineEndOffset = $E82348
!CooStartOffset = $E83954
!CooEndOffset = $E8BE7C
!NagoStartOffset = $E8D14E
!NagoEndOffset = $E9A8D8
!ChuchuStartOffset = $E9CE0C
!ChuchuEndOffset = $EAA8E0
!PitchStartOffset = $EACBDE
!PitchEndOffset = $EB43B0

!KirbyByteCount #= 0
!GooeyByteCount #= 0
!RickByteCount #= 0
!KineByteCount #= 0
!CooByteCount #= 0
!NagoByteCount #= 0
!ChuchuByteCount #= 0
!PitchByteCount #= 0
!LoopCounter = 0
!Offset = $E2F092
!EndOffset = $E68868

print "hirom"

macro PrintTable(StartOffset, EndOffset, CharName)
	!Input1 #= read2(<StartOffset>+!LoopCounter)
	!Input2 #= read2(<StartOffset>+!LoopCounter+2)
	!Input3 #= (read2(<StartOffset>+!LoopCounter+4)-$08)
	!input4 #= ((<StartOffset>+!LoopCounter)&$FF0000)>>16
	if !Input2 == $0001
		!Input2 #= $0000
	endif
	print "print 'DATA_',hex(<StartOffset>+!LoopCounter),':'"
	print "print '	dw $',hex(!Input1, 4),',$',hex(!Input2, 4),',DATA_',hex(!input4, 2),hex(!Input3, 4),'+$0008,DATA_',hex(!input4, 2),hex(!Input3, 4),'+$',hex(!Input1+$0008, 4)"
	print "print '	incbin %GFX/GFX_Sprite_<CharName>.bin%:',hex(!<CharName>ByteCount),'-',hex(!<CharName>ByteCount+!Input1+!Input2)"
	print "print ''"
	!LoopCounter #= !LoopCounter+!Input1+!Input2+8
	!<CharName>ByteCount #= !<CharName>ByteCount+!Input1+!Input2
endmacro

!Offset = !KirbyStartOffset
!EndOffset = !KirbyEndOffset
!CharName = "Kirby"
!CharCount = 0

while !CharCount < 8
if !Offset == !GooeyStartOffset
	%PrintTable($DFFFD0, $DFFFF9, Gooey)
elseif !Offset == !CooStartOffset
	%PrintTable($E7FE78, $E80000, Coo)
elseif !Offset == !PitchStartOffset
	%PrintTable($E2FFD2, $E2FFF9, Pitch)
endif
!LoopCounter #= 0
	while !Offset+!LoopCounter < !EndOffset
		%PrintTable(!Offset, !EndOffset, !CharName)
		if !Offset == !KirbyStartOffset
			if !Offset+!LoopCounter == $DEFFF8
				!LoopCounter #= !LoopCounter+8
			elseif !Offset+!LoopCounter == $DFFFD0
				!LoopCounter #= !LoopCounter+48
			elseif !Offset+!LoopCounter == $E0FFF0
				!LoopCounter #= !LoopCounter+16
			endif
		elseif !Offset == !GooeyStartOffset
			if !Offset+!LoopCounter == $E2FFD2
				!LoopCounter #= !LoopCounter+46
			elseif !Offset+!LoopCounter == $E3FFF8
				!LoopCounter #= !LoopCounter+8
			elseif !Offset+!LoopCounter == $E4FFC8
				!LoopCounter #= !LoopCounter+56
			elseif !Offset+!LoopCounter == $E5FF98
				!LoopCounter #= !LoopCounter+104
			endif
		elseif !Offset == !RickStartOffset
			if !Offset+!LoopCounter == $E6FFA2
				!LoopCounter #= !LoopCounter+94
			endif
		elseif !Offset == !KineStartOffset
			if !Offset+!LoopCounter == $E7FE78
				!LoopCounter #= !LoopCounter+392
			endif
		elseif !Offset == !NagoStartOffset
			if !Offset+!LoopCounter == $E8FFEE
				!LoopCounter #= !LoopCounter+18
			endif
		elseif !Offset == !ChuchuStartOffset
			if !Offset+!LoopCounter == $E9FFFC
				!LoopCounter #= !LoopCounter+4
			endif
		elseif !Offset == !PitchStartOffset
			if !Offset+!LoopCounter == $EAFFCE
				!LoopCounter #= !LoopCounter+50
			endif
		endif
	endif
	!CharCount #= !CharCount+1
	!LoopCounter #= 0
	if !CharCount == 1
		!Offset = !GooeyStartOffset
		!EndOffset = !GooeyEndOffset
		!CharName = "Gooey"
	elseif !CharCount == 2
		!Offset = !RickStartOffset
		!EndOffset = !RickEndOffset
		!CharName = "Rick"
	elseif !CharCount == 3
		!Offset = !KineStartOffset
		!EndOffset = !KineEndOffset
		!CharName = "Kine"
	elseif !CharCount == 4
		!Offset = !CooStartOffset
		!EndOffset = !CooEndOffset
		!CharName = "Coo"
	elseif !CharCount == 5
		!Offset = !NagoStartOffset
		!EndOffset = !NagoEndOffset
		!CharName = "Nago"
	elseif !CharCount == 6
		!Offset = !ChuchuStartOffset
		!EndOffset = !ChuchuEndOffset
		!CharName = "Chuchu"
	elseif !CharCount == 7
		!Offset = !PitchStartOffset
		!EndOffset = !PitchEndOffset
		!CharName = "Pitch"
	endif
	print "print ';========================================================================'"
	print "print ''"
endif