
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$08E5
	dw DATA_E41D	:	dw DATA_E41D+$0195
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$FF,$E0,$B8,$04,$70,$29,$FF,$E0,$B8,$08,$F0
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/2B.brr"

DATA_E41D:
	incbin "Samples/2C.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
