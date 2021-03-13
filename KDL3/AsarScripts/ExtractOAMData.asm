; This will dump the data for an asar patch that will be applied to the USA KDL3 ROM. Said patch will dump the hundreds of OAM related tables at the specified location when applied to the ROM.
; The reason I'm generating a patch and not the tables directly is because of asar limitations. I don't think it's possible for asar to resolve commands through a define while in a print statement.
; Also, it may take a second before asar starts displaying anything on the command line. In addition, you'll need to replace the ' with " in the output patch, otherwise asar won't assemble the patch.

hirom

!Offset = $EAB240
!EndOffset = $EACBDE

macro HandleVariableDefine(ID)
	!Output<ID> #= !Input3
	if !Input3 < 16
		!LZ<ID> += "0"
	else
		!LZ<ID> += ""
	endif
endmacro

macro ClearDefines()
	!Output0 = ""
	!Output1 = ""
	!Output2 = ""
	!Output3 = ""
	!Output4 = ""
	!Output5 = ""
	!Output6 = ""
	!Output7 = ""
	!Output8 = ""
	!Output9 = ""
	!Output10 = ""
	!Output11 = ""
	!Output12 = ""
	!Output13 = ""
	!Output14 = ""
	!Output15 = ""
	!LZ0 = ""
	!LZ1 = ""
	!LZ2 = ""
	!LZ3 = ""
	!LZ4 = ""
	!LZ5 = ""
	!LZ6 = ""
	!LZ7 = ""
	!LZ8 = ""
	!LZ9 = ""
	!LZ10 = ""
	!LZ11 = ""
	!LZ12 = ""
	!LZ13 = ""
	!LZ14 = ""
	!LZ15 = ""
endmacro

macro HandleLineOfData(ID)
	if <ID> == 0
		!PrintData += "	db $!LZ<ID>',hex(!Output<ID>)"
	else
		!PrintData += ",',$!LZ<ID>',hex(!Output<ID>)"
	endif
endmacro

macro PrintVariableData(Data)
	print "print '<Data>"
endmacro

!SkipBytes = 0
!LoopCounter = 0
print "hirom"

while !Offset+!LoopCounter < !EndOffset
	!Input1 #= !Offset+!LoopCounter
	%ClearDefines()
	!ByteCount = 0
	!RowByteCount = 0
	!FinishDataBlock #= 0
	!PrintData = ""
	print "print 'DATA_',hex(!Input1),':'"
	while !FinishDataBlock != $01
		!Input3 = read1(!Input1+!ByteCount)
		%HandleVariableDefine(!RowByteCount)
		%HandleLineOfData(!RowByteCount)
		!ByteCount #= !ByteCount+1
		!RowByteCount #= !RowByteCount+1
		!LoopCounter #= !LoopCounter+1
		if !RowByteCount == 6
			%PrintVariableData("!PrintData")
			%ClearDefines()
			!PrintData = ""
			!RowByteCount #= $00
			!Input3 = read1(!Input1+!ByteCount-1)
			if !Input3&$80 == $80
				!FinishDataBlock #= 1
			endif
		endif
	endif
	print "print ''"
endif
