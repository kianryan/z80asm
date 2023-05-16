
org $8000

main:

	call clear_sid

	ld a, 0x04 ; Set waveform
	ld d, 0x00 ; Set data
	call sid_io

	ld a, 0x18 ; Set volume
	ld d, 0x0F ; Set data
	ld e, 0x00 ; Set interrupt mode
	call sid_io

	ld a, 0x0C ; Set env
	ld d, 0x00 ; Attack/delay
	call sid_io

	ld a, 0x0D ; Set env
	ld d, 0xF0 ; Sustain/release
	call sid_io

	ld a, 0x0B ; Set waveform
	ld d, 0x11 ; Set data
	call sid_io

	ld a, 0x07 ; Set low freq
	ld d, 0x10 ; Set data
	call sid_io

	ld a, 0x08 ; Set high freq
	ld d, 0x10 ; Set data
	call sid_io

	ret

clear_sid:	   ; Updated clear_sid from Quazar
	xor a
	ld b, a
	ld d, a
	ld c, 0x54 ; base addr
	set 7, b
	out (c), d
	nop
	nop

clear_loop:
	res 7, b
	out (c), d
	nop
	nop
	nop
	set 7, b
	out (c), d

	inc b
	inc a
	cp 25
	jr nz, clear_loop
	ret


; ENTER WITH: A = SID REGISTER (0x00 - 0x18)
; D = DATA BYTE
; E = INTERRUPT CONTROLLER MODE - BITS 5/6
; (0x00 = OFF, 0x20 = ‘50Hz’, 0x40 = ‘60Hz’ 0x60 = ‘100Hz’)
sid_io: 
	LD C,0x54 ; BASE I/O ADDRESS
	OR E
	LD B,A
	OUT (C),D ; WRITE TO SID. /CS=0 (B BIT 7)
	NOP
	NOP ; DELAY
	NOP
	SET 7,B ; /CS=1 (B BIT 7)
	OUT (C),D ; WRITE TO SID
	RET
