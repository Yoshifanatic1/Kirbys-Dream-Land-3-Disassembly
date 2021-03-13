
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$001B
	dw DATA_D511	:	dw DATA_D511+$001B
	dw DATA_DB2F	:	dw DATA_DB2F+$0681
	dw DATA_E252	:	dw DATA_E252+$0654
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$8A,$E0,$B8,$03,$C0,$29,$FF,$E0,$B8,$03,$C0,$2A,$FF,$EE,$B8
	db $11,$F0,$2B,$FF,$E0,$B8,$04,$00
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/1B.brr"

DATA_DB2F:
	incbin "Samples/1C.brr"

DATA_E252:
	incbin "Samples/1D.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
