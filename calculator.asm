
; Calculator program
; Read two numbers, encode in BCD
; Add two numbers
; Display

org $8000

read_buf: equ $9000

main:
	call read_encode_number		
	; call read_char_display_char	; Read number
ret


read_encode_number:
	call read_line		; Read line in buffer
	call disp_line		; Display line in memory
	call encode_bcd		; Encode ASCII number number to BCD
	call pack_bcd		; Pack BCD
	; call bcd_display 	; Display BCD as ASCII
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

disp_line:
	push de
	push af
		; ld c, $07		; Function 7 = New Line
		; rst $30			; Call API
		; ld de, read_buf		; Start of line $9000
		ld c, $06		; Function 6 = Display line
		rst $30			; Call API
	pop af
	pop de

; Print individual char to display
; Input a -> ascii char
; Output a -> ascii char
print_char:
	ld c, $02		; Print individual char
	rst $30			; Call API
ret

; moves de by b bytes
bcd_get_end:
	push bc
		ld c,b
		dec c
		ld b,0
		add hl,bc
		ex de,hl
		add hl,de
		add hl,bc
		ex de,hl
	pop bc
ret

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
pack_bcd:
	ex de, hl	; Switch to operate on hl
	ld b, 0
	ld c, a
	add hl, bc	; Move to end
	dec hl

	ld b, a		; Count down for bytes
	; inc b

	ld de, $9010    ; Set location for write

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
