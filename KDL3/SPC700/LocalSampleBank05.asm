
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$001B
	dw DATA_DBEC	:	dw DATA_DBEC+$06C9
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$FF,$E0,$B8,$03,$D0,$29,$FF,$EE,$B8,$0F,$00
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/26.brr"

DATA_DBEC:
	incbin "Samples/27.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.

