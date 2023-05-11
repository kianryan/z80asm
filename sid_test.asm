
org $8000

main:

	call clear_sid

	ld a, 0x18 ; Set volume
	ld d, 0x33 ; Set data
	ld e, 0x00 ; Set interrupt mode
	call sid_io

	ld a, 0x05 ; Set env
	ld d, 0x00 ; Attack/delay
	call sid_io

	ld a, 0x06 ; Set env
	ld d, 0xF0 ; Sustain/release
	call sid_io

	ld a, 0x04 ; Set waveform
	ld d, 0x11 ; Set data
	call sid_io

	ld a, 0x00 ; Set low freq
	ld d, 0x10 ; Set data
	call sid_io

	ld a, 0x01 ; Set high freq
	ld d, 0x10 ; Set data
	call sid_io

	ret

clear_sid: 
	LD C,0x54 ; BASE I/O ADDRESS
	LD B,0x98 ; SID REGISER 0x18, /CS=1 (BIT 7)
	; INTERRUPT CONTROLLER OFF
	XOR A ; OPTIMISED “LD A,0” (VOLUME 0)
	OUT (C),A ; FIRST OUT TO ENSURE /CS HIGH
	NOP
	NOP ; DELAY
	NOP
	RES 7,B ; /CS=0 (B BIT 7)
	OUT (C),A ; WRITE TO SID
	NOP
	NOP ; DELAY
	NOP
	SET 7,B ; /CS=1 (B BIT 7)
	OUT (C),A ; WRITE TO SID
	RET

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
