
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$07CE
	dw DATA_DD03	:	dw DATA_DD03+$0642
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$FF,$E0,$B8,$04,$00,$29,$FF,$E0,$B8,$11,$F0
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/21.brr"

DATA_DD03:
	incbin "Samples/22.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
