
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$001B
	dw DATA_D53E	:	dw DATA_D53E+$0B1C
	dw DATA_E05A	:	dw DATA_E05A+$0183
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$FF,$E0,$B8,$02,$00,$29,$FF,$E0,$B8,$07,$A0,$2A,$FF,$E0,$B8
	db $11,$F0
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/23.brr"

DATA_D53E:
	incbin "Samples/24.brr"

DATA_E05A:
	incbin "Samples/25.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
