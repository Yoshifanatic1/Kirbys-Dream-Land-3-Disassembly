
%SPCDataBlockStart(03A0)
	dw DATA_D511	:	dw DATA_D511+$056A
	dw DATA_DB1D	:	dw DATA_DB1D+$0654
	dw DATA_E213	:	dw DATA_E213+$0666
%SPCDataBlockEnd(03A0)

%SPCDataBlockStart(05F0)
	db $28,$FF,$B2,$B8,$12,$00,$29,$FF,$E0,$B8,$04,$80,$2A,$FF,$E0,$B8
	db $04,$00
%SPCDataBlockEnd(05F0)

%SPCDataBlockStart(D511)
DATA_D511:
	incbin "Samples/1E.brr"

DATA_DB1D:
	incbin "Samples/1F.brr"

DATA_E213:
	incbin "Samples/20.brr"
%SPCDataBlockEnd(D511)

dw $0000			; Note: This is used to mark the end of this file.
