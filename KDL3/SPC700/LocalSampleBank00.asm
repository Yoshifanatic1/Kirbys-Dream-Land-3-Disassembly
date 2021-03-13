
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$0AE6
	dw DATA_DFF7	:	dw DATA_DFF7+$05C4
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$FF,$E0,$B8,$07,$A0,$29,$FF,$EE,$B8,$11,$F0
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/19.brr"

DATA_DFF7:
	incbin "Samples/1A.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
