; Main.asm
; Name: Dillon Gentry
; UTEid: djg2975
; Continuously reads from x4600 making sure its not reading duplicate
; symbols. Processes the symbol based on the program description
; of mRNA processing.

;1st incr: Write and test Main.asm with setup steps and ISR.asm is empty (Good)
;Test: Set bkpt in ISR
;2nd incr: Write validation steps in ISR.asm and put validated char in x4600
;Test: Strike a key and watch x4600 to see if it shows char typed
;3rd incr: In Main.asm you have continous loop, but modify it to where mem[x4600] holds 0 before entering loop
; and get the contents of x4600 before going into the loop
;loop	LDI R0, Buffer
;	BRz loop
;	TRAP x21
;	AND R1,R1,0
;	STI R1, Buffer
;	;Process R0
;	;FSM code goes here
;Buffer .FILL x4600
;4th incr: Check for Start Codon 
;When you see AUG print a pipe to the console
;5th incr: Skip until Stop Codon
;When you see UAA,UAG,UGA halt machine
;Code for possibilities that lead to a solution rather than all possibilities


;Notes:
;Reading character from a buffer (global variable)
;Setup (3 step)
;Write 0 to x4600
;Read i/p from x4600 (Loop if 0)
;New char
;Write 0 to x4600
;Processing (FSM from doc)

               .ORIG x4000
; initialize the stack pointer
	LD R6, Stack


; enable keyboard interrupts
	LD R0, KBIEN
	STI R0, KBSR

; set up the keyboard interrupt vector table entry
	LD R0, ISR
	STI R0, KBIVE


; start of actual program
	AND R3,R3,0		;R3 holds status of codon
	AND R5,R5,0		;R5 holds start vs. stop
loop	LDI R0, Buffer
	BRz loop 
	TRAP x21
	AND R1,R1,#0
	STI R1, Buffer
;Process R0?
;Start Codon code (R5=0)	;This section will only look for AUG
Check5	ADD R5,R5,#0
	BRnp Stop
	LD R1, ach
	ADD R2,R1,R0
	BRz CheckA
	LD R1, uch
	ADD R2,R1,R0
	BRz CheckU
	LD R1, gch
	ADD R2,R1,R0
	BRz CheckG
	LD R1, cch
	ADD R2,R1,R0
	BRz CheckC
	BRnzp loop

CheckC	AND R3,R3,#0		;C doesn't matter in this section
	ST R3, astr
	ST R3, ustr
	BRnzp loop


CheckA	AND R2,R2,0		;Anytime A pops up, set R3 to 1
	ST R2, ustr
	LD R2, astr
	NOT R2,R2
	ADD R2,R2,#1
	ADD R2,R0,R2
	BRz Dup	
	ADD R3,R3,#1
Leave	ST R0, astr
Leave2	BRnzp loop
Dup	ADD R4,R3,#-1		;Deals with multiple A's
	BRz Leave 
	ADD R3,R3,#1
	BRnzp Leave2
	
CheckU	LD R2, ustr		;Anytime U pops up, R3 must equal 1
	NOT R2,R2		;in order to advance
	ADD R2,R2,#1
	ADD R2,R0,R2
	BRz Dupu	
	ADD R3,R3,#1
Leave3	ST R0, ustr
	BRnzp loop
Dupu	ADD R4,R3,#-2		;Deals with multiple U's
	BRz Clr
	ADD R4,R3,#-1
	BRz Upd
Clr	AND R3,R3,#0		;When U pops up and R3 not equal to 1
	BRnzp Leave3
Upd	ADD R3,R3,#1		;When U pops up and R3 equal to 1
	BRnzp loop

CheckG	ADD R4,R3,#-2		;Anytime G pops up, R3 must be 2 otherwise clear R3
	BRnp loop
	LD R0, pipe		;Prints pipe when R3 equal 2
	TRAP x21
	ADD R5,R5,#1
	AND R3,R3,0
	BRnzp Check5


;Stop Codon code (R5=1)
Stop	AND R1,R1,#0
	ST R1, astr
	ST R1, ustr
	ST R1, gstr
	LD R1, ach
	ADD R2,R1,R0
	BRz ChckA
	LD R1, uch
	ADD R2,R1,R0
	BRz ChckU
	LD R1, gch
	ADD R2,R1,R0
	BRz ChckG
	LD R1, cch
	ADD R2,R1,R0
	BRz ChckC
	BRnzp loop

ChckC	AND R3,R3,#0
	ST R3, astr
	ST R3, ustr
	ST R3, gstr
	BRnzp loop

ChckU	LD R2, ustr
	NOT R2,R2
	ADD R2,R2,#1
	ADD R2,R0,R2
	BRz Dupu2
	ADD R4,R3,#-2
	BRz Upd6	
	ADD R3,R3,#1
Leave6	ST R0, ustr
	BRnzp loop
Dupu2	ADD R4,R3,#-2
	BRz Upd5
	ADD R4,R3,#-1
	BRz Leave6 
	ADD R3,R3,#1
	BRnzp loop
Upd5	ADD R3,R3,#-1
	BRnzp loop
Upd6	ADD R3,R3,#-1
	BRnzp loop

ChckG	LD R2, gstr
	NOT R2,R2
	ADD R2,R2,#1
	ADD R2,R0,R2
	BRz Clear
	ST R0, gstr
	ADD R4,R3,#-2
	BRz Done
	ADD R4,R3,#-1
	BRz Upd2
	ADD R3,R3,0
	BRz loop
Upd2	AND R2,R2,0
	ST R2, ustr
	ADD R3,R3,#1
	BRnzp loop
Clear	ADD R4,R3,#-1
	BRz Upd2
	ADD R4,R3,#-2
	BRz Done
	AND R3,R3,0
	ST R3, astr
	ST R3, ustr
	BRnzp loop
 

ChckA	LD R2, astr
	NOT R2,R2
	ADD R2,R2,#1
	ADD R2,R0,R2
	BRz Dupu3
	ADD R4,R3,#-1
	BRn loop
	ADD R4,R3,#-2
	BRz Done	
	ADD R3,R3,#1	
Leave4	ST R0, astr
	BRnzp loop
Dupu3	ADD R4,R3,#-2
	BRz Done
	ADD R4,R3,#-1
	BRz Upd3	
	BRnzp Leave4
Upd3	ADD R3,R3,#1
	BRnzp loop	

Done	TRAP x25
pipe	.FILL x7C
astr	.BLKW 1
ustr	.BLKW 1
gstr	.BLKW 1
ach	.FILL x-41
uch	.FILL x-55
gch	.FILL x-47
cch	.FILL x-43
Stack	.FILL x4000
ISR	.FILL x2600
KBIVE	.FILL x0180
KBSR	.FILL xFE00
KBIEN	.FILL x4000
Buffer	.FILL x4600

	.END
