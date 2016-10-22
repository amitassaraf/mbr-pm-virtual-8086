[bits 16]
[org 0x7C00]


mbr:						; Main sequence
	nop


times 510 - ($ - $$) db 0
dw 0xAA55                  ; MBR Magic