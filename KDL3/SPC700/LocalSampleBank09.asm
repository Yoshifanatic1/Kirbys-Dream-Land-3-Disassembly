
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$0D2F
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$8F,$E0,$B8,$07,$A0
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/2D.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
