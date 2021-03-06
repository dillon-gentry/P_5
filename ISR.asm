; ISR.asm
; Name: Dillon Gentry
; UTEid: djg2975
; Keyboard ISR runs when a key is struck
; Checks for a valid RNA symbol and places it at x4600
               
;Read i/p char
;(Do NOT call TRAP)
;validate it (A,U,G,C)
;Write it to a global location if valid (x4600)


;R0 holds char typed
	.ORIG x2600
	LDI R0, KBDR	;R0 has ASCII val of char
	LD R1, a	;R1 has negative ASCII value of capital a
	ADD R2,R1,R0	;if character typed equals a, then branch to valid
	BRz Valid
	LD R1, c	;R1 has negative ASCII value of capital c
	ADD R2,R1,R0
	BRz Valid
	LD R1, u	;R1 has negative ASCII value of capital u, etc.
	ADD R2,R1,R0
	BRz Valid
	LD R1, g
	ADD R2,R1,R0
	BRz Valid
	BRnp Done
Valid	STI R0, buff
Done	RTI
buff	.FILL x4600	;buff will be global variable for both ISR and Main to use together
a	.FILL x-41	;a holds -ascii of 'A'
c	.FILL x-43	;c holds -ascii of 'C'
u	.FILL x-55	;u holds -ascii of 'U'
g	.FILL x-47	;g holds -ascii of 'G'
KBDR	.FILL xFE02	;Data register for kb input
	.END
