ORG $8000

LD   C,1       ;API call 1 = Input character
RST  $30       ;API call inputs a character
PUSH AF        ;Remember the key character
LD   C,+10     ;API call 10 = Delay by DE milliseconds
LD   DE,+1000  ;Delay in milliseconds
RST  $30       ;API call delays for 1 seconds
POP  AF        ;Restore the key character
LD   C,2       ;API call 2 = Output character
RST  $30       ;API call outputs character
RET
