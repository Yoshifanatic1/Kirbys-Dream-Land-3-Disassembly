
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$001B
	dw DATA_D511	:	dw DATA_D511+$001B
	dw DATA_DB92	:	dw DATA_DB92+$0B91
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$88,$87,$B8,$02,$40,$29,$FF,$E0,$B8,$02,$40,$2A,$FF,$E0,$B8
	db $05,$B0
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/28.brr"

DATA_DB92:
	incbin "Samples/29.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
