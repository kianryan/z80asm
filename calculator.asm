
; Calculator program
; Read two numbers, encode in BCD
; Add two numbers
; Display

org $8000

read_buf: equ $9000
write_buf: equ $9010
calc_buf: equ $9020

main:
	call init_buf
	main_loop:
		ld de, write_buf
		call clear_buf
		call read_encode_number		
		call add_numbers
		ld de, calc_buf		; Set output
		ld b, $4		; Set temp length
		call bcd_display
		call new_line
		jp main_loop
ret

; Init all buff memory
init_buf:
	ld de, read_buf
	call clear_buf
	ld de, write_buf
	call clear_buf
	ld de, calc_buf
	call clear_buf
ret

; Clear buf memory
clear_buf:
	push bc
		ld b, $0f
		inc b
		clear_buf_loop:
			ld a, $0
			ld (de), a
			inc de
			djnz clear_buf_loop
	pop bc
ret

read_encode_number:
	call read_line		; Read line in buffer
	call encode_bcd		; Encode ASCII number number to BCD
	call pack_bcd		; Pack BCD
ret

; SCM Specific Imp read_line
; OUT
; DE = start of line in memory
; A = chars in line
read_line:
	ld de, $9000		; Start of line, $9000
	ld a, $52		; Start of line = $50 + 1 for terminator
	ld c, $04		; Function 4 = Input line
	rst $30			; Call API
ret

new_line:
	push bc
		ld c, $07		; Function 7 = New Line
		rst $30			; Call API
	pop bc
ret

; Print individual char to display
; Input a -> ascii char
; Output a -> ascii char
print_char:
	push af
	push bc
	push de
		ld c, $02		; Print individual char
		rst $30			; Call API
	pop de
	pop bc
	pop af
ret

; input de - address for packed bytes
; input hl - address for packed bytes
; input b - end bytes
; moves de, hl by b bytes
bcd_get_end:
	push bc
		ld c,b
		dec c
		ld b,0
		add hl,bc
		ex de,hl
		add hl,bc
		ex de,hl
	pop bc
ret

; input de - address for packed bytes
; input b - number of bytes
bcd_display:
	call bcd_get_end
bcd_show_direct:
	ld a,(de)
	and %11110000
	rrca
	rrca
	rrca
	rrca
	add '0'
	call print_char
	ld a,(de)
	dec de
	and %00001111
	add '0'
	call print_char
	djnz bcd_show_direct
ret

; Encode number held at DE to BCD
; IN
; DE = start of line in memory
; A = chars in line

encode_bcd:
	push hl
	push de
	push bc
	push af

	ex de, hl		; Switch so we can operate on hl
	ld b, 0
	ld c, a
	add hl, bc		; Add a to hl to find end

	ld b, a			; Load b to a for loop
	inc b			; 

	encode_bcd_loop:
		call asc_bcd		; Encode char at HL to BCD
		dec hl			; Dec hl register
		djnz encode_bcd_loop	; Dec b, jump if non zero
	pop af
	pop bc
	pop de
	pop hl
ret

; Pack single byte BCD to double byte
; BCD
; input DE = start of memory
; input A = number of bytes
; output de = start of memory
; output b = number of bytes
pack_bcd:
	push af			; Keep

		ex de, hl		; Switch to operate on hl
		ld b, 0
		ld c, a
		add hl, bc		; Move to end
		dec hl

		ld b, a			; Count down for bytes

		ld de, write_buf	; Set write buf

		pack_bcd_loop:
		
			; Read first byte
			ld c, (hl)
			dec hl

			; Read second byte, add
			ld a, (hl)
			rrca
			rrca
			rrca
			rrca
			add a, c
			dec hl

			ld (de), a
			inc de

			dec b
			jr z, exit_loop

			dec b
			jr z, exit_loop

			jr pack_bcd_loop
		
		exit_loop:
			nop

		ld de, write_buf	

	pop af		; Restore
	ld b, a		; Set number of bytes - we want half of this
	sra b		; div 2
ret

; Convert ascii to BCD
; output a -> BCD
asc_bcd:
	; call brack	; Check that char is 0-9
	; jp nz,illegal	; Exit if illegal char
	ld a,(hl)	; get char
	and $0F		; mash high nibble
	ld (hl),a	; write char
ret

; Set-up addition of write_buf and calc_buf
add_numbers:
	ld de, calc_buf
	ld hl, write_buf
	ld b, $0f
	call bcd_add
ret

; Add Packed BCD val at HL to Packed BCD val at DE
; input hl -> packed BCD val
; input de -> packed BCD val
; input b -> bytes length
bcd_add:
	or a
bcd_add_loop:
	ld a, (de)
	adc a,(hl) ; check
	daa
	ld (de), a
	inc de
	inc hl
	djnz bcd_add_loop
ret
