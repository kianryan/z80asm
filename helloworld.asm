
org $8000

	ld	de, text	; load address for text to display.
	call	display		; call display
	ret			; we're done

display:
	ld	c, $06		; load display routine from SCM API
	rst	$30		; exec display routing
	ret			; we're done

text:	
	dm	"Hello, World",0 ; define string to display

