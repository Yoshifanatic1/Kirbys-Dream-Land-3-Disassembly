
%SPCDataBlockStart(0700)
	CLRP
	MOV X, #$FF
	MOV SP, X
	MOV A, #$00
	MOV X, A
CODE_0707:
	MOV (X+), A
	CMP X, #$E8
	BNE CODE_0707
	INC A
	CALL CODE_0CCF
	SET5 $39
	MOV $F2, #$0C
	MOV $F3, #$7F
	MOV $F2, #$1C
	MOV $F3, #$7F
	MOV $F2, #$5D
	MOV $F3, #$03
	MOV A, #$F0
	MOV $F1, A
	MOV A, #$10
	MOV $FA, A
	MOV $43, A
	MOV A, #$01
	MOV $F1, A
CODE_0732:
	MOV $F6, $02
	MOV $02, $F6
	MOV $F7, $03
	MOV $03, $F7
	MOV Y, #$0A
CODE_0740:
	CMP Y, #$05
	BEQ CODE_074B
	BCS CODE_074E
	CMP $3D, $3E
	BNE CODE_075A
CODE_074B:
	BBS7 $3D, CODE_075A
CODE_074E:
	MOV A, DATA_10A0+y
	MOV $F2, A
	MOV A, DATA_10AA+y
	MOV X, A
	MOV A, (X)
	MOV $F3, A
CODE_075A:
	DBNZ Y, CODE_0740
	MOV $36, Y
	MOV $37, Y
CODE_0760:
	MOV Y, $FD
	BEQ CODE_0760
	PUSH Y
	MOV A, #$20
	MUL YA
	CLRC
	ADC A, $19
	MOV $19, A
	BCC CODE_0787
	CALL CODE_0FC8
	MOV $F5, $05
	MOV Y, $F5
	MOV A, Y
	AND A, #$7F
	CMP A, #$75
	BCS CODE_0780
	MOV $01, Y
CODE_0780:
	CMP $3D, $3E
	BEQ CODE_0787
	INC $3D
CODE_0787:
	MOV A, $43
	POP Y
	MUL YA
	CLRC
	ADC A, $41
	MOV $41, A
	BCS CODE_07AA
	MOV A, $04
	BEQ CODE_0732
	MOV X, #$00
	MOV $38, #$01
CODE_079B:
	MOV A, $21+x
	BEQ CODE_07A2
	CALL CODE_0F25
CODE_07A2:
	INC X
	INC X
	ASL $38
	BNE CODE_079B
CODE_07A8:
	BRA CODE_0732

CODE_07AA:
	CALL CODE_091D
	MOV $F4, $04
	MOV A, $F4
	BEQ CODE_07C4
	CMP A, #$FF
	BEQ CODE_07C8
	CMP A, #$FD
	BCS CODE_07C4
	CMP A, #$75
	BEQ CODE_07C4
	CMP A, #$76
	BNE CODE_07C6
CODE_07C4:
	MOV $00, A
CODE_07C6:
	BRA CODE_07A8

CODE_07C8:
	CMP $F5, #$FE
	BNE CODE_07C6
	CMP $F6, #$00
	BNE CODE_07C6
	CMP $F7, #$78
	BNE CODE_07C6
	BRA CODE_07C4

CODE_07D9:
	CMP A, #$CA
	BCC CODE_07E4
	SBC A, #$A7
	CALL CODE_0B11
	MOV Y, #$A4
CODE_07E4:
	CMP Y, #$C8
	BCS CODE_07EE
	MOV A, $17
	AND A, $38
	BEQ CODE_07EF
CODE_07EE:
	RET

CODE_07EF:
	MOV A, Y
	AND A, #$7F
	CLRC
	ADC A, $40
	CLRC
	ADC A, $0101+x
	MOV $91+x, A
	MOV A, $02C1+x
	MOV $90+x, A
	MOV A, $0121+x
	LSR A
	MOV A, #$00
	ROR A
	MOV $02F0+x, A
	MOV A, #$00
	MOV $A0+x, A
	MOV $C0+x, A
	MOV $0110+x, A
	MOV $B0+x, A
	OR $4E, $38
	OR $36, $38
	MOV A, $02D0+x
	MOV $80+x, A
	BEQ CODE_083D
	MOV A, $02D1+x
	MOV $81+x, A
	MOV A, $02E0+x
	BNE CODE_0834
	MOV A, $91+x
	SETC
	SBC A, $02E1+x
	MOV $91+x, A
CODE_0834:
	MOV A, $02E1+x
	CLRC
	ADC A, $91+x
	CALL CODE_0D31
CODE_083D:
	CALL CODE_0D48
CODE_0840:
	MOV Y, #$00
	MOV A, $1D
	SETC
	SBC A, #$34
	BCS CODE_0852
	MOV A, $1D
	SETC
	SBC A, #$13
	BCS CODE_0856
	DEC Y
	ASL A
CODE_0852:
	ADDW YA, $1C
	MOVW $1C, YA
CODE_0856:
	PUSH X
	MOV A, $1D
	ASL A
	MOV Y, #$00
	MOV X, #$18
	DIV YA, X
	MOV X, A
	MOV A, DATA_10B5+$01+y
	MOV $11, A
	MOV A, DATA_10B5+y
	MOV $10, A
	MOV A, DATA_10B5+$03+y
	PUSH A
	MOV A, DATA_10B5+$02+y
	POP Y
	SUBW YA, $10
	MOV Y, $1C
	MUL YA
	MOV A, Y
	MOV Y, #$00
	ADDW YA, $10
	MOV $11, Y
	ASL A
	ROL $11
	MOV $10, A
	BRA CODE_0889

CODE_0885:
	LSR $11
	ROR A
	INC X
CODE_0889:
	CMP X, #$06
	BNE CODE_0885
	MOV $10, A
	POP X
	MOV A, $0220+x
	MOV Y, $11
	MUL YA
	MOVW $12, YA
	MOV A, $0220+x
	MOV Y, $10
	MUL YA
	PUSH Y
	MOV A, $0221+x
	MOV Y, $10
	MUL YA
	ADDW YA, $12
	MOVW $12, YA
	MOV A, $0221+x
	MOV Y, $11
	MUL YA
	MOV Y, A
	POP A
	ADDW YA, $12
	MOVW $12, YA
	MOV A, X
	XCN A
	LSR A
	OR A, #$02
	MOV Y, A
	MOV A, $12
	CALL CODE_08C3
	INC Y
	MOV A, $13
CODE_08C3:
	PUSH A
	MOV A, $38
	AND A, $17
	POP A
	BNE CODE_08CF
CODE_08CB:
	MOV $F2, Y
	MOV $F3, A
CODE_08CF:
	RET

CODE_08D0:
	MOV Y, #$00
	MOV A, ($30)+y
	INCW $30
	PUSH A
	MOV A, ($30)+y
	INCW $30
	MOV Y, A
	POP A
	RET

CODE_08DE:
	MOV $04, A
	BEQ CODE_08F0
	ASL A
	MOV X, A
	MOV A, $32FF+x
	MOV Y, A
	MOV A, $32FE+x
	MOVW $30, YA
	MOV $0C, #$02
CODE_08F0:
	MOV A, $17
	EOR A, #$FF
	TSET $0037, A
	RET

CODE_08F8:
	MOV X, #$0E
	MOV $38, #$80
CODE_08FD:
	CALL CODE_0B5F
	DEC X
	DEC X
	LSR $38
	BNE CODE_08FD
	MOV $4A, A
	MOV $58, A
	MOV $44, A
	MOV $40, A
	MOV $18, A
	MOV $1F, A
	MOV Y, A
	CALL CODE_0CA6
	MOV $49, #$C0
	MOV $43, #$20
CODE_091C:
	RET

CODE_091D:
	MOV Y, $08
	MOV A, $00
	CMP A, #$FD
	BEQ CODE_0936
	CMP A, #$FE
	BEQ CODE_08F0
	CMP A, #$FF
	BNE CODE_0930
	JMP CODE_103A

CODE_0930:
	MOV $08, A
	CMP Y, $00
	BNE CODE_08DE
CODE_0936:
	MOV A, $04
	BEQ CODE_091C
	MOV A, $0C
	BEQ CODE_09A2
	DBNZ $0C, CODE_08F8
CODE_0941:
	CALL CODE_08D0
	BNE CODE_095A
	MOV Y, A
	BEQ CODE_08DE
	DEC $18
	BPL CODE_094F
	MOV $18, A
CODE_094F:
	CALL CODE_08D0
	MOV X, $18
	BEQ CODE_0941
	MOVW $30, YA
CODE_0958:
	BRA CODE_0941

CODE_095A:
	MOVW $12, YA
	MOV Y, #$00
	MOV $38, #$01
CODE_0961:
	MOV A, $32
	AND A, $38
	BNE CODE_0974
	MOV A, ($12)+y
	MOV $0020+y, A
	INC Y
	MOV A, ($12)+y
	MOV $0020+y, A
	BRA CODE_0975

CODE_0974:
	INC Y
CODE_0975:
	INC Y
	ASL $38
	BNE CODE_0961
	MOV X, #$00
	MOV $38, #$01
CODE_097F:
	MOV A, $32
	AND A, $38
	BNE CODE_099C
	MOV A, $21+x
	BEQ CODE_0991
	MOV A, $0211+x
	BNE CODE_0991
	CALL CODE_0B11
CODE_0991:
	MOV A, #$00
	MOV $C1+x, A
	MOV $70+x, A
	MOV $71+x, A
	INC A
	MOV $60+x, A
CODE_099C:
	INC X
	INC X
	ASL $38
	BNE CODE_097F
CODE_09A2:
	MOV X, #$00
	MOV $4E, X
	MOV $38, #$01
CODE_09A9:
	MOV $35, X
	MOV A, $21+x
	BEQ CODE_09EB
	DEC $60+x
	BNE CODE_0A2D
CODE_09B3:
	CALL CODE_0AB6
	BNE CODE_09ED
	MOV A, $C1+x
	BNE CODE_09D6
	MOV A, $32
	AND A, $38
	BEQ CODE_0958
	MOV A, #$00
	MOV $0020+x, A
	MOV $0021+x, A
	MOV $05, A
	MOV A, $38
	TSET $0037, A
	TCLR $0032, A
	BRA CODE_09EB

CODE_09D6:
	CALL CODE_0C67
	DEC $C1+x
	BNE CODE_09B3
	MOV A, $0230+x
	MOV $20+x, A
	MOV A, $0231+x
	MOV $21+x, A
	BRA CODE_09B3

CODE_09E9:
	BRA CODE_09A9

CODE_09EB:
	BRA CODE_0A33

CODE_09ED:
	BMI CODE_0A0F
	MOV $0200+x, A
	CALL CODE_0AB6
	BMI CODE_0A0F
	PUSH A
	XCN A
	AND A, #$07
	MOV Y, A
	MOV A, DATA_10CF+y
	MOV $0201+x, A
	POP A
	AND A, #$0F
	MOV Y, A
	MOV A, DATA_10D7+y
	MOV $0210+x, A
	CALL CODE_0AB6
CODE_0A0F:
	CMP A, #$E0
	BCC CODE_0A18
	CALL CODE_0AA4
	BRA CODE_09B3

CODE_0A18:
	CALL CODE_07D9
	MOV A, $0200+x
	MOV $60+x, A
	MOV Y, A
	MOV A, $0201+x
	MUL YA
	MOV A, Y
	BNE CODE_0A29
	INC A
CODE_0A29:
	MOV $61+x, A
	BRA CODE_0A30

CODE_0A2D:
	CALL CODE_0E3D
CODE_0A30:
	CALL CODE_0D11
CODE_0A33:
	INC X
	INC X
	ASL $38
	BNE CODE_09E9
	MOV A, $44
	BEQ CODE_0A48
	MOVW YA, $46
	ADDW YA, $42
	DBNZ $44, CODE_0A46
	MOVW YA, $44
CODE_0A46:
	MOVW $42, YA
CODE_0A48:
	MOV A, $58
	BEQ CODE_0A61
	MOVW YA, $54
	ADDW YA, $50
	MOVW $50, YA
	MOVW YA, $56
	ADDW YA, $52
	DBNZ $58, CODE_0A5F
	MOVW YA, $58
	MOVW $50, YA
	MOV Y, $5A
CODE_0A5F:
	MOVW $52, YA
CODE_0A61:
	MOV A, $4A
	BEQ CODE_0A73
	MOVW YA, $4C
	ADDW YA, $48
	DBNZ $4A, CODE_0A6E
	MOVW YA, $4A
CODE_0A6E:
	MOVW $48, YA
	MOV $4E, #$FF
CODE_0A73:
	MOV X, #$00
	MOV $38, #$01
CODE_0A78:
	MOV A, $21+x
	BEQ CODE_0A7F
	CALL CODE_0D6C
CODE_0A7F:
	MOV A, X
	LSR A
	XCN A
	MOV Y, $D1+x
	CALL CODE_0A94
	MOV Y, $D0+x
	INC A
	CALL CODE_0A94
	INC X
	INC X
	ASL $38
	BNE CODE_0A78
	RET

CODE_0A94:
	PUSH A
	MOV A, $32
	AND A, $38
	BNE CODE_0A9E
	MOV A, $02
	MUL YA
CODE_0A9E:
	POP A
	MOV $F2, A
	MOV $F3, Y
	RET

CODE_0AA4:
	ASL A
	MOV Y, A
	MOV A, DATA_0AC0-$BF+y
	PUSH A
	MOV A, DATA_0AC0-$C0+y
	PUSH A
	MOV A, Y
	LSR A
	MOV Y, A
	MOV A, DATA_0AF6-$60+y
	BEQ CODE_0ABE
CODE_0AB6:
	MOV A, ($20+x)
CODE_0AB8:
	INC $20+x
	BNE CODE_0ABE
	INC $21+x
CODE_0ABE:
	MOV Y, A
CODE_0ABF:
	RET

DATA_0AC0:
	dw CODE_0B11
	dw CODE_0B77
	dw CODE_0B85
	dw CODE_0B9E
	dw CODE_0BAA
	dw CODE_0BC5
	dw CODE_0BCA
	dw CODE_0BDE
	dw CODE_0BE3
	dw CODE_0BF5
	dw CODE_0BF8
	dw CODE_0BFC
	dw CODE_0C08
	dw CODE_0C29
	dw CODE_0C32
	dw CODE_0C4F
	dw CODE_0BB5
	dw CODE_0C0B
	dw CODE_0C0F
	dw CODE_0C25
	dw CODE_0C4B
	dw CODE_0C72
	dw CODE_0CA6
	dw CODE_0CAD
	dw CODE_0C85
	dw CODE_0D21
	dw CODE_0ABF

DATA_0AF6:
	db $01,$01,$02,$03,$00,$01,$02,$01,$02,$01,$01,$03,$00,$01,$02,$03
	db $01,$03,$03,$00,$01,$03,$00,$03,$03,$03,$01

CODE_0B11:
	MOV $0211+x, A
	MOV Y, #$06
	MUL YA
	MOVW $10, YA
	CLRC
	ADC $10, #$00
	ADC $11, #$05
	MOV A, $17
	AND A, $38
	BNE CODE_0B5E
	PUSH X
	MOV A, X
	XCN A
	LSR A
	OR A, #$04
	MOV X, A
	MOV Y, #$00
	MOV A, ($10)+y
	BPL CODE_0B41
	AND A, #$1F
	AND $39, #$20
	TSET $0039, A
	OR $3A, $38
	MOV A, Y
	BRA CODE_0B48

CODE_0B41:
	MOV A, $38
	TCLR $003A, A
CODE_0B46:
	MOV A, ($10)+y
CODE_0B48:
	MOV $F2, X
	MOV $F3, A
	INC X
	INC Y
	CMP Y, #$04
	BNE CODE_0B46
	POP X
	MOV A, ($10)+y
	MOV $0221+x, A
	INC Y
	MOV A, ($10)+y
	MOV $0220+x, A
CODE_0B5E:
	RET

CODE_0B5F:
	MOV A, #$00
	MOV $0211+x, A
	MOV $02C1+x, A
	MOV $0101+x, A
	MOV $02D0+x, A
	MOV $A1+x, A
	MOV $B1+x, A
	DEC A
	MOV $0251+x, A
	MOV A, #$0A
CODE_0B77:
	MOV $02A1+x, A
	AND A, #$1F
	MOV $0281+x, A
	MOV A, #$00
	MOV $0280+x, A
	RET

CODE_0B85:
	MOV $71+x, A
	PUSH A
	CALL CODE_0AB6
	MOV $02A0+x, A
	SETC
	SBC A, $0281+x
	POP X
	CALL CODE_0D50
	MOV $0290+x, A
	MOV A, Y
	MOV $0291+x, A
	RET

CODE_0B9E:
	MOV $0100+x, A
	CALL CODE_0AB6
	MOV $02F1+x, A
	CALL CODE_0AB6
CODE_0BAA:
	MOV $A1+x, A
	MOV $0130+x, A
	MOV A, #$00
	MOV $0121+x, A
	RET

CODE_0BB5:
	MOV $0121+x, A
	PUSH A
	MOV Y, #$00
	MOV A, $A1+x
	POP X
	DIV YA, X
	MOV X, $35
	MOV $0131+x, A
	RET

CODE_0BC5:
	MOV A, #$00
	MOVW $48, YA
	RET

CODE_0BCA:
	MOV $4A, A
	CALL CODE_0AB6
	MOV $4B, A
	SETC
	SBC A, $49
	MOV X, $4A
	CALL CODE_0D50
	MOVW $4C, YA
	MOV X, $35
	RET

CODE_0BDE:
	MOV A, #$00
	MOVW $42, YA
	RET

CODE_0BE3:
	MOV $44, A
	CALL CODE_0AB6
	MOV $45, A
	SETC
	SBC A, $43
	MOV X, $44
	CALL CODE_0D50
	MOVW $46, YA
	RET

CODE_0BF5:
	MOV $40, A
	RET

CODE_0BF8:
	MOV $0101+x, A
	RET

CODE_0BFC:
	MOV $0120+x, A
	CALL CODE_0AB6
	MOV $0111+x, A
	CALL CODE_0AB6
CODE_0C08:
	MOV $B1+x, A
	RET

CODE_0C0B:
	MOV A, #$01
	BRA CODE_0C11

CODE_0C0F:
	MOV A, #$00
CODE_0C11:
	MOV $02E0+x, A
	MOV A, Y
	MOV $02D1+x, A
	CALL CODE_0AB6
	MOV $02D0+x, A
	CALL CODE_0AB6
	MOV $02E1+x, A
	RET

CODE_0C25:
	MOV $02D0+x, A
	RET

CODE_0C29:
	MOV $0251+x, A
	MOV A, #$00
	MOV $0250+x, A
	RET

CODE_0C32:
	MOV $70+x, A
	PUSH A
	CALL CODE_0AB6
	MOV $0270+x, A
	SETC
	SBC A, $0251+x
	POP X
	CALL CODE_0D50
	MOV $0260+x, A
	MOV A, Y
	MOV $0261+x, A
	RET

CODE_0C4B:
	MOV $02C1+x, A
	RET

CODE_0C4F:
	MOV $0240+x, A
	CALL CODE_0AB6
	MOV $0241+x, A
	CALL CODE_0AB6
	MOV $C1+x, A
	MOV A, $20+x
	MOV $0230+x, A
	MOV A, $21+x
	MOV $0231+x, A
CODE_0C67:
	MOV A, $0240+x
	MOV $20+x, A
	MOV A, $0241+x
	MOV $21+x, A
	RET

CODE_0C72:
	MOV $3B, A
	CALL CODE_0AB6
	MOV A, #$00
	MOVW $50, YA
	CALL CODE_0AB6
	MOV A, #$00
	MOVW $52, YA
	CLR5 $39
	RET

CODE_0C85:
	MOV $58, A
	CALL CODE_0AB6
	MOV $59, A
	SETC
	SBC A, $51
	MOV X, $58
	CALL CODE_0D50
	MOVW $54, YA
	CALL CODE_0AB6
	MOV $5A, A
	SETC
	SBC A, $53
	MOV X, $58
	CALL CODE_0D50
	MOVW $56, YA
	RET

CODE_0CA6:
	MOVW $50, YA
	MOVW $52, YA
	SET5 $39
	RET

CODE_0CAD:
	CALL CODE_0CCF
	CALL CODE_0AB6
	MOV $3F, A
	CALL CODE_0AB6
	MOV Y, #$08
	MUL YA
	MOV X, A
	MOV Y, #$0F
CODE_0CBE:
	MOV A, DATA_1081+x
	CALL CODE_08CB
	INC X
	MOV A, Y
	CLRC
	ADC A, #$10
	MOV Y, A
	BPL CODE_0CBE
	MOV X, $35
	RET

CODE_0CCF:
	MOV $3E, A
	MOV Y, #$7D
	MOV $F2, Y
	MOV A, $F3
	CMP A, $3E
	BEQ CODE_0D03
	AND A, #$0F
	EOR A, #$FF
	BBC7 $3D, CODE_0CE5
	CLRC
	ADC A, $3D
CODE_0CE5:
	MOV $3D, A
	MOV Y, #$04
CODE_0CE9:
	MOV A, DATA_10A0+y
	MOV $F2, A
	MOV $F3, #$00
	DBNZ Y, CODE_0CE9
	MOV A, $39
	OR A, #$20
	MOV $F2, #$6C
	MOV $F3, A
	MOV $F2, #$7D
	MOV A, $3E
	MOV $F3, A
CODE_0D03:
	ASL A
	ASL A
	ASL A
	EOR A, #$FF
	SETC
	ADC A, #$33
	MOV $F2, #$6D
	MOV $F3, A
	RET

CODE_0D11:
	MOV A, $80+x
	BNE CODE_0D47
	MOV A, ($20+x)
	CMP A, #$F9
	BNE CODE_0D47
	CALL CODE_0AB8
	CALL CODE_0AB6
CODE_0D21:
	MOV $81+x, A
	CALL CODE_0AB6
	MOV $80+x, A
	CALL CODE_0AB6
	CLRC
	ADC A, $40
	ADC A, $0101+x
CODE_0D31:
	AND A, #$7F
	MOV $02C0+x, A
	SETC
	SBC A, $91+x
	MOV Y, $80+x
	PUSH Y
	POP X
	CALL CODE_0D50
	MOV $02B0+x, A
	MOV A, Y
	MOV $02B1+x, A
CODE_0D47:
	RET

CODE_0D48:
	MOV A, $91+x
	MOV Y, A
	MOV A, $90+x
	MOVW $1C, YA
	RET

CODE_0D50:
	NOTC
	ROR $1E
	BPL CODE_0D58
	EOR A, #$FF
	INC A
CODE_0D58:
	MOV Y, #$00
	DIV YA, X
	PUSH A
	MOV A, #$00
	DIV YA, X
	POP Y
	MOV X, $35
CODE_0D62:
	BBC7 $1E, CODE_0D6B
	MOVW $10, YA
	MOVW YA, $1A
	SUBW YA, $10
CODE_0D6B:
	RET

CODE_0D6C:
	MOV A, $70+x
	BEQ CODE_0D94
	OR $4E, $38
	DEC $70+x
	BNE CODE_0D81
	MOV A, #$00
	MOV $0250+x, A
	MOV A, $0270+x
	BRA CODE_0D91

CODE_0D81:
	CLRC
	MOV A, $0250+x
	ADC A, $0260+x
	MOV $0250+x, A
	MOV A, $0251+x
	ADC A, $0261+x
CODE_0D91:
	MOV $0251+x, A
CODE_0D94:
	MOV Y, $B1+x
	BEQ CODE_0DBB
	MOV A, $0120+x
	CBNE $B0+x, CODE_0DB9
	OR $4E, $38
	MOV A, $0110+x
	BPL CODE_0DAD
	INC Y
	BNE CODE_0DAD
	MOV A, #$80
	BRA CODE_0DB1

CODE_0DAD:
	CLRC
	ADC A, $0111+x
CODE_0DB1:
	MOV $0110+x, A
	CALL CODE_0FAB
	BRA CODE_0DC0

CODE_0DB9:
	INC $B0+x
CODE_0DBB:
	MOV A, #$FF
	CALL CODE_0FB6
CODE_0DC0:
	MOV A, $71+x
	BEQ CODE_0DE8
	OR $4E, $38
	DEC $71+x
	BNE CODE_0DD5
	MOV A, #$00
	MOV $0280+x, A
	MOV A, $02A0+x
	BRA CODE_0DE5

CODE_0DD5:
	CLRC
	MOV A, $0280+x
	ADC A, $0290+x
	MOV $0280+x, A
	MOV A, $0281+x
	ADC A, $0291+x
CODE_0DE5:
	MOV $0281+x, A
CODE_0DE8:
	MOV A, $38
	AND A, $4E
	BEQ CODE_0E15
	MOV A, $03
	BEQ CODE_0DFA
	MOV $1D, #$0A
	MOV $1C, #$00
	BRA CODE_0E03

CODE_0DFA:
	MOV A, $0281+x
	MOV Y, A
	MOV A, $0280+x
	MOVW $1C, YA
CODE_0E03:
	CALL CODE_0E16
	MOV $D0+x, A
	MOV Y, #$14
	MOV A, #$00
	SUBW YA, $1C
	MOVW $1C, YA
	CALL CODE_0E16
	MOV $D1+x, A
CODE_0E15:
	RET

CODE_0E16:
	MOV Y, $1D
	MOV A, DATA_10E7+$01+y
	SETC
	SBC A, DATA_10E7+y
	MOV Y, $1C
	MUL YA
	MOV A, Y
	MOV Y, $1D
	CLRC
	ADC A, DATA_10E7+y
	MOV Y, A
	MOV A, $0271+x
	MUL YA
	MOV A, $02A1+x
	ASL A
	BBC0 $1E, CODE_0E36
	ASL A
CODE_0E36:
	MOV A, Y
	BCC CODE_0E3C
	EOR A, #$FF
	INC A
CODE_0E3C:
	RET

CODE_0E3D:
	MOV A, $61+x
	BEQ CODE_0EA4
	DEC $61+x
	BEQ CODE_0E4A
	MOV A, #$02
	CBNE $60+x, CODE_0EA4
CODE_0E4A:
	MOV A, $C1+x
	MOV $13, A
	MOV A, $20+x
	MOV Y, $21+x
CODE_0E52:
	MOVW $10, YA
	MOV Y, #$00
CODE_0E56:
	MOV A, ($10)+y
	BEQ CODE_0E78
	BMI CODE_0E63
CODE_0E5C:
	INC Y
	BMI CODE_0E9D
	MOV A, ($10)+y
	BPL CODE_0E5C
CODE_0E63:
	CMP A, #$C8
	BEQ CODE_0EA4
	CMP A, #$EF
	BEQ CODE_0E92
	CMP A, #$E0
	BCC CODE_0E9D
	PUSH Y
	MOV Y, A
	POP A
	ADC A, $0A16+y
	MOV Y, A
	BRA CODE_0E56

CODE_0E78:
	MOV A, $13
	BEQ CODE_0E9D
	DEC $13
	BNE CODE_0E89
	MOV A, $0231+x
	MOV Y, A
	MOV A, $0230+x
	BRA CODE_0E52

CODE_0E89:
	MOV A, $0241+x
	MOV Y, A
	MOV A, $0240+x
	BRA CODE_0E52

CODE_0E92:
	INC Y
	MOV A, ($10)+y
	PUSH A
	INC Y
	MOV A, ($10)+y
	MOV Y, A
	POP A
	BRA CODE_0E52

CODE_0E9D:
	MOV A, $38
	MOV Y, #$5C
	CALL CODE_08C3
CODE_0EA4:
	CLR7 $1F
	MOV A, $80+x
	BEQ CODE_0ED1
	MOV A, $81+x
	BEQ CODE_0EB2
	DEC $81+x
	BRA CODE_0ED1

CODE_0EB2:
	SET7 $1F
	DEC $80+x
	BNE CODE_0EC2
	MOV A, $02C1+x
	MOV $90+x, A
	MOV A, $02C0+x
	BRA CODE_0ECF

CODE_0EC2:
	CLRC
	MOV A, $90+x
	ADC A, $02B0+x
	MOV $90+x, A
	MOV A, $91+x
	ADC A, $02B1+x
CODE_0ECF:
	MOV $91+x, A
CODE_0ED1:
	CALL CODE_0D48
	MOV A, $A1+x
	BEQ CODE_0F21
	MOV A, $0100+x
	CBNE $A0+x, CODE_0F1F
	MOV A, $C0+x
	CMP A, $0121+x
	BNE CODE_0EEA
	MOV A, $0130+x
	BRA CODE_0EF5

CODE_0EEA:
	INC $C0+x
	MOV Y, A
	BEQ CODE_0EF1
	MOV A, $A1+x
CODE_0EF1:
	CLRC
	ADC A, $0131+x
CODE_0EF5:
	MOV $A1+x, A
	MOV A, $02F0+x
	CLRC
	ADC A, $02F1+x
	MOV $02F0+x, A
CODE_0F01:
	MOV $1E, A
	ASL A
	ASL A
	BCC CODE_0F09
	EOR A, #$FF
CODE_0F09:
	MOV Y, A
	MOV A, $A1+x
	CMP A, #$F1
	BCC CODE_0F15
	AND A, #$0F
	MUL YA
	BRA CODE_0F19

CODE_0F15:
	MUL YA
	MOV A, Y
	MOV Y, #$00
CODE_0F19:
	CALL CODE_0F96
CODE_0F1C:
	JMP CODE_0840

CODE_0F1F:
	INC $A0+x
CODE_0F21:
	BBS7 $1F, CODE_0F1C
	RET

CODE_0F25:
	CLR7 $1F
	MOV A, $B1+x
	BEQ CODE_0F34
	MOV A, $0120+x
	CBNE $B0+x, CODE_0F34
	CALL CODE_0F9E
CODE_0F34:
	MOV A, $0281+x
	MOV Y, A
	MOV A, $0280+x
	MOVW $1C, YA
	MOV A, $71+x
	BEQ CODE_0F4B
	MOV A, $0291+x
	MOV Y, A
	MOV A, $0290+x
	CALL CODE_0F80
CODE_0F4B:
	BBC7 $1F, CODE_0F51
	CALL CODE_0E03
CODE_0F51:
	CLR7 $1F
	CALL CODE_0D48
	MOV A, $80+x
	BEQ CODE_0F68
	MOV A, $81+x
	BNE CODE_0F68
	MOV A, $02B1+x
	MOV Y, A
	MOV A, $02B0+x
	CALL CODE_0F80
CODE_0F68:
	MOV A, $A1+x
	BEQ CODE_0F21
	MOV A, $0100+x
	CBNE $A0+x, CODE_0F21
	MOV Y, $41
	MOV A, $02F1+x
	MUL YA
	MOV A, Y
	CLRC
	ADC A, $02F0+x
	JMP CODE_0F01

CODE_0F80:
	SET7 $1F
	MOV $1E, Y
	CALL CODE_0D62
	PUSH Y
	MOV Y, $41
	MUL YA
	MOV $10, Y
	MOV $11, #$00
	MOV Y, $41
	POP A
	MUL YA
	ADDW YA, $10
CODE_0F96:
	CALL CODE_0D62
	ADDW YA, $1C
	MOVW $1C, YA
	RET

CODE_0F9E:
	SET7 $1F
	MOV Y, $41
	MOV A, $0111+x
	MUL YA
	MOV A, Y
	CLRC
	ADC A, $0110+x
CODE_0FAB:
	ASL A
	BCC CODE_0FB0
	EOR A, #$FF
CODE_0FB0:
	MOV Y, $B1+x
	MUL YA
	MOV A, Y
	EOR A, #$FF
CODE_0FB6:
	MOV Y, $49
	MUL YA
	MOV A, $0210+x
	MUL YA
	MOV A, $0251+x
	MUL YA
	MOV A, Y
	MUL YA
	MOV A, Y
	MOV $0271+x, A
	RET

CODE_0FC8:
	MOV Y, $09
	MOV A, $01
	MOV $09, A
	CMP Y, $01
	BEQ CODE_0FF8
	MOV $05, A
	ASL A
	BNE CODE_0FF9
	MOV $38, #$01
	MOV X, #$00
CODE_0FDC:
	MOV A, $32
	AND A, $38
	BEQ CODE_0FF2
	TSET $0037, A
	MOV A, #$00
	MOV $0020+x, A
	MOV $0021+x, A
	MOV A, $38
	TCLR $0032, A
CODE_0FF2:
	INC X
	INC X
	ASL $38
	BNE CODE_0FDC
CODE_0FF8:
	RET

CODE_0FF9:
	MOV X, A
	MOV A, $32FF+x
	MOV Y, A
	MOV A, $32FE+x
	MOVW $33, YA
	MOV Y, #$00
	MOV A, ($33)+y
	MOV X, A
	INC Y
	MOV A, ($33)+y
	MOV $33, X
	MOV $34, A
	MOV $38, #$01
	MOV X, #$00
CODE_1014:
	MOV A, X
	MOV Y, A
	INC Y
	MOV A, ($33)+y
	BEQ CODE_1033
	MOV $0020+y, A
	DEC Y
	MOV A, ($33)+y
	MOV $0020+y, A
	CALL CODE_0B5F
	MOV $C1+x, A
	MOV $70+x, A
	MOV $71+x, A
	INC A
	MOV $60+x, A
	OR $32, $38
CODE_1033:
	INC X
	INC X
	ASL $38
	BNE CODE_1014
	RET

CODE_103A:
	MOV X, #$FE
	MOV $F4, X
CODE_103E:
	CMP X, $F4
	BNE CODE_103E
	MOVW YA, $F6
	BNE CODE_105C
	CMP X, #$FE
	BNE CODE_1051
	INC X
	MOV $F4, X
CODE_104D:
	CMP X, $F4
	BNE CODE_104D
CODE_1051:
	MOV A, #$FE
	MOV $F4, A
CODE_1055:
	CMP A, $F4
	BNE CODE_1055
	JMP CODE_08F0

CODE_105C:
	INC X
	MOV $F4, X
	MOVW $1C, YA
CODE_1061:
	CMP X, $F4
	BNE CODE_1061
	MOVW YA, $F6
	INC X
	MOV $F4, X
	MOVW $10, YA
	MOV Y, #$00
CODE_106E:
	CMP X, $F4
	BNE CODE_106E
	MOV A, $F6
	INC X
	MOV $F4, X
	MOV ($10)+y, A
	INCW $10
	DECW $1C
	BNE CODE_106E
	BRA CODE_103E

DATA_1081:
	db $7F,$00,$00,$00,$00,$00,$00,$00,$58,$BF,$DB,$F0,$FE,$07,$0C,$0C
	db $0C,$21,$2B,$2B,$13,$FE,$F3,$F9,$34,$33,$00,$D9,$E5,$01,$FC

DATA_10A0:
	db $EB,$2C,$3C,$0D,$4D,$6C,$4C,$5C,$3D,$2D

DATA_10AA:
	db $5C,$51,$53,$3F,$3B,$39,$36,$1A,$3A,$3C,$37

DATA_10B5:
	dw $085F,$08DE,$0965,$09F4,$0A8C,$0B2C,$0BD6,$0C8B
	dw $0D4A,$0E14,$0EEA,$0FCD,$10BE

DATA_10CF:
	db $65,$7F,$98,$B2,$CB,$E5,$F2,$FC
 
DATA_10D7:
	db $4C,$59,$6D,$7F,$87,$8E,$98,$A0,$A8,$B2,$BF,$CB,$D8,$E5,$F2,$FC

DATA_10E7:
	db $00,$01,$03,$07,$0D,$15,$1E,$29,$34,$42,$51,$5E,$67,$6E,$73,$77
	db $7A,$7C,$7D,$7E,$7F

%SPCDataBlockEnd(0700)

%EndSPCUploadAndJumpToEngine($0700)
