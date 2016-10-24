[bits 16]
[org 0x7C00]


mbr_main:						; Main sequence
	mov sp, 0xffff
	call enable_protected_mode	

enable_protected_mode:
	cli       
	lgdt [gdtr]  
	mov eax, cr0 
	or al, 1     
	mov cr0, eax
	jmp 08h:protected_mode_main


[bits 32]
protected_mode_main:
	mov esp, 0xffff  			; Reset stack
	call start_vm86_mode		; Enter vm8086 mode

	mov al, '!'					; Character to print
	push 0x0e
	call bios_interrupt


start_vm86_mode:
	xor eax, eax
	mov ax, 0x??                ; The descriptor of the tss in the gdt
	ltr ax						; load the task register
	ret


bios_interrupt:					; Function used to call an interrupt in v8086 mode
	push ebp
	mov ebp, esp

	mov ah, [ebp + 4]			; Set the function number 
	int 0x10					; Call the bios interrupt

	pop ebp
	add esp, 4
	call start_vm86_mode		; Restart vm8086 mode
	add esp, 2
	ret

gdt: 
	dd 0x00000000, 0x00000000
	dd 0x0000FFFF, 0x00CF9C00    ; Code segment
	dd 0x0000FFFF, 0x00CF9200    ; Data segment
gdt_end:

gdtr:
	dw gdt_end - gdt - 1    ; gdt size - 1
	dd gdt   				; gdt linear address

times 510 - ($ - $$) db 0
dw 0xAA55                  ; MBR Magic