[org 0x7C00]
[bits 16]

PRINT_CHAR_BIOS equ 0x0e
BIOS_INTERRUPT equ 0x10

mbr_main:						; Main sequence
	mov sp, 0xffff
	call enter_protected_mode	

enter_protected_mode:
	cli   						; Clear interrupts
	lgdt [global_descriptor_table_register]  
	mov eax, cr0 
	or al, 1     
	mov cr0, eax
	jmp 08h:protected_mode_main


[bits 32]

protected_mode_main:
	sti								; Restore interrupts
	mov esp, 0xffffffff  			; Reset stack
	call start_vm86_mode		; Enter vm8086 mode

	mov al, '!'					; Character to print
	push PRINT_CHAR_BIOS
	call bios_interrupt


start_vm86_mode:
	xor eax, eax
	mov ax, 0x00                ; The descriptor of the tss in the gdt //TODO
	ltr ax						; load the task register
	ret


bios_interrupt:					; Function used to call an interrupt in v8086 mode
	push ebp
	mov ebp, esp

	mov ah, [ebp + 4]			; Set the function number 
	int BIOS_INTERRUPT					; Call the bios interrupt

	pop ebp
	add esp, 4
	call start_vm86_mode		; Restart vm8086 mode
	add esp, 2
	ret

global_descriptor_table: 
	dd 0x00000000, 0x00000000
	dd 0xFFFFFFFF, 0x00CF9C00    ; Code segment
	dd 0xFFFFFFFF, 0x00CF9200    ; Data segment
global_descriptor_table_end:

global_descriptor_table_register:
	dw global_descriptor_table_end - global_descriptor_table - 1    		; gdt size - 1
	dd global_descriptor_table   											; gdt linear address

times 510 - ($ - $$) db 0
dw 0xAA55                  ; MBR Magic