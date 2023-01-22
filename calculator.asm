
; Calculator program
; Read two numbers, encode in BCD
; Add two numbers
; Display

org $8000

main:
	call read_encode_number	; Read number


read_encode_number:
	call read_line		; Read line in buffer
	call encode_number	; Encode ASCII number number to BCD
	call bcd_display 	; Display BCD as ASCII
	ret

; SCM Specific Imp read_line
; OUT
; DE = start of line in memory
; A = chars in line
read_line:
	ld de, $9000		; Start of line, $9000
	ld a, $51		; Start of line = $50 + 1 for terminator
	ld c, $04		; Function 4 = Input line
	rst 30			; Call API
ret

; https://www.chibiakumas.com/z80/advanced.php
; https://smallcomputercentral.files.wordpress.com/2018/05/scmon-v1-0-reference-e1-0-0.pdf
; https://smallcomputercentral.files.wordpress.com/2018/05/scmon-v1-0-userguide-e1-0-0.pdf

;https://archive.org/details/Programming_the_Z-80_2nd_Edition_1980_Rodnay_Zaks/page/523/mode/2up 
; Contains ASCII -> BCD Routine
; First pass

bcd_get_end:
	push bc
		ld c,b
		dec c
		ld b,0
		add hl,bc
		ex hl,de
		add hl,de
		add hl,bc
		ex hl,de
	pop bc
ret

bcd_display:
	call bcd_get_end
bcd_show_direct:
	ld a,(de)
	and %11110000
	rrcca
	rrcca
	rrcca
	rrcca
	add '0'
	call print_char
	ld a,(de)
	dec de
	and %00001111
	add '0'
	call print_char
	djnz BCD_show_direct
ret

; Encode number held at DE to BCD
; IN
; DE = start of line in memory
; A = chars in line

encode_bcd:
	ld c, de	; Load address to c
	add a		; Get end address
	


	

	
	


