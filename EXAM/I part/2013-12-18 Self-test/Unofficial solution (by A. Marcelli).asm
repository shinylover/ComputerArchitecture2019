;
;		Computer Architecture 2013/2014	
;			Prof. Montuschi
;		Self Test questions 1st part 18/12/2014
;
;		© Andrea Marcelli  209051
;	
;	This is my working exam-test version, it was reviewed using the advices of
;	Prof. Montuschi and other class mates during the exam simulation. 	
;
;	note: 	This program is designed to work for 8086 machine. 
;	From 80186 some improvements have been inserted. For example they 
;	enabled the PUSHA, POPA instructions, and SHL, SHR can be used with 
;	any immediate. I didn’t know yet how to make them available in MASM.
;	So I used some (less-effective) tricks to escape from this limitations 
;	(eg. the usage of FIVE and EIGHT variables for SHL and SHR instructions).
;  
;	The input-output part (required) misses. 
;
;	I checked it multiple time with the debugger.. but something could missing.
; 	If you know any improvement, please let me know. 
;

.MODEL SMALL

.STACK
.DATA

N EQU 10

FIVE DW 5
EIGHT DW 8 

;FIRST DB N DUP (?)
;SECOND DB N DUP (?)

FIRST DB 00010001B, 00100010B, 01000100B, 01010101B, 01100000B, 01100110B, 10000001B, 10001000B, 10101010B, 10101010B

SECOND DB 10101010B, 10101010B, 10100100B, 10001000B, 01000100B, 00101001B, 00100010B, 00011000B, 00010001B, 00010001B


FIRST_SORTED_HI_TO_LO	DB N DUP (?)
SECOND_SORTED_LO_TO_HI 	DB N DUP (?)

ADDED DW N DUP (?)

BY_THREE_MULTIPLIED_FIRST DW N DUP (?)
BY_THREE_MULTIPLIED_SECOND DW N DUP (?)

BY_TWO_MULTIPLIED_FIRST DW N DUP (?)
BY_TWO_MULTIPLIED_SECOND DW N DUP (?)

MULTIPLIED DW N DUP (?)

MASKE DW 0000000000000011B, 0000000000001100B, 0000000000110000B, 0000000011000000B, 0000001100000000B, 0000110000000000B, 0011000000000000B, 1100000000000000B


.CODE
.STARTUP



;##### ITEM NUMBER 0 #####


	XOR SI, SI				; I copy all the values from the original array into the ones
	MOV CX, N				; that I will sort. 
loop00:	MOV AL, FIRST[SI]
	MOV BL, SECOND[SI]
	MOV FIRST_SORTED_HI_TO_LO[SI], AL
	MOV SECOND_SORTED_LO_TO_HI[SI], BL
	INC SI
	LOOP loop00



	
	MOV CX, N-1
	
loop01:	PUSH CX					; bubble sort requires two nested cycles			
	LEA SI, FIRST_SORTED_HI_TO_LO
	LEA DI, FIRST_SORTED_HI_TO_LO+1
				
loop02:	MOV AL, [SI]                            ; For each value in the array
	MOV BL, [DI]
        CMP AL, BL				; Is AX greater than BX? Yes, JUMP! Otherwise SWAP.
        JA next00					
	MOV [SI], BL				; SWAP
	MOV [DI], AL
next00:	INC DI	
	INC SI				; It’s a Byte.
	LOOP loop02				; Inner loop. 

	POP CX
	LOOP loop01				; Outer loop. 
	


       
	MOV CX, N-1
	
loop03:	PUSH CX					; bubble sort requires two nested cycles			
	LEA SI, SECOND_SORTED_LO_TO_HI
        LEA DI, SECOND_SORTED_LO_TO_HI+1

loop04:	MOV AL, [SI]
	MOV BL, [DI]
        CMP AL, BL				; Is AX minor than BX? Yes, JUMP! Otherwise, SWAP!
        JB next01
	MOV [SI], BL				; SWAP
	MOV [DI], AL
next01:	INC DI
	INC SI
	LOOP loop04				; Inner loop. 

	POP CX
	LOOP loop03				; Outer loop. 

	

;##### ITEM NUMBER 1 #####

	MOV CX, N
	XOR SI, SI				; SI is a byte index. 
	XOR DI, DI				; DI is a word index. 
loop1: 	MOV AL, FIRST_SORTED_HI_TO_LO[SI]	; For each number (4 digits) of the array..
	MOV BL, SECOND_SORTED_LO_TO_HI[SI]
	XOR AH, AH				; ..from 8 to 16 bit.
	XOR BH, BH

        MOV DX, 5				; 5 is the number of necessary cycles to complete the operation:
	PUSH DX					; 4 because I have 4 digits number + 1 due to the carry. 
	PUSH AX					; This makes the addition more flexible, so it can be used
	PUSH BX					; in the fourth item too.
	CALL ADDITION				 					
	POP AX
	
	MOV ADDED[DI], AX			; Move the result in the final position. 
	
	ADD DI, 2
	INC SI
	LOOP loop1


	
;### ITEM NUMBER 2

	MOV CX, N
	XOR SI, SI				; SI is a byte index. 
	XOR DI, DI				; DI is a word index. 
loop2:  PUSH CX					; CL is used in the shift instruction too.
        MOV AL, FIRST_SORTED_HI_TO_LO[SI]	; For each number of the array..
	MOV BL, SECOND_SORTED_LO_TO_HI[SI]
	XOR AH, AH				; ..from 8 to 16 bit.
	XOR BH, BH

	MOV CL, 2				; Multiplication by three is equal
	SHL AX, CL				; to a shift of one position in base 3.
	SHL BX, CL				; Because each digit is represented on 2 bits
						; a shift of one position is equal to a shift of 2 bits.

	MOV BY_THREE_MULTIPLIED_FIRST[DI], AX
	MOV BY_THREE_MULTIPLIED_SECOND[DI], BX

	ADD DI, 2
	INC SI
        POP CX
	LOOP loop2

;### ITEM NUMBER 3				; The multiplication by two can be easily converted into an addition. 

	MOV CX, N	
	XOR SI, SI				; SI is a byte index. 
	XOR DI, DI				; DI is a word index. 
loop3: 	MOV AL, FIRST_SORTED_HI_TO_LO[SI]	; For each number of the array..
	MOV BL, SECOND_SORTED_LO_TO_HI[SI]
	XOR AH, AH				; ..from 8 to 16 bit. 
	XOR BH, BH
	
	PUSH FIVE				; 5 is the number of necessary cycles to complete the operation:
	PUSH AX					; 4 because I have 4 digits number + 1 due to the carry. 
	PUSH AX					; This makes the addition more flexible, so it can be used
	CALL ADDITION				; in the fourth item too. 	
	POP AX
	MOV BY_TWO_MULTIPLIED_FIRST[DI], AX
	
	PUSH FIVE				; Same as before. 
	PUSH BX
	PUSH BX
	CALL ADDITION
	POP BX
	MOV BY_TWO_MULTIPLIED_SECOND[DI], BX

	INC SI
	ADD DI, 2
	LOOP loop3

;### ITEM NUMBER 4
	
	XOR BX, BX				; BX is a word index. 
	XOR SI, SI				; Si is a byte index. 
	MOV CX, N				

loop40: PUSH CX 				; For each value (4 digits) of the FIRST sorted array (multiplicand)
	MOV CX, 4					
	MOV AL, FIRST_SORTED_HI_TO_LO[SI]	
	XOR AH, AH				; from 8 to 16 bit. 
	MOV MULTIPLIED[BX], 0			; This is where I store the intermediate and of course, the final value.  

	
	XOR DI, DI				; DI is a word index. 
loop41:	PUSH CX					; CL is used in the shift instruction too.
	MOV DL, SECOND_SORTED_LO_TO_HI[SI]	; For each digit of value of the SECOND sorted array (multiplier)..
	XOR DH, DH
	AND DX, MASKE[DI]			; ..I extract the 2 bit of the digit..
	MOV CX, DI
	SHR DX, CL				; ..left shift a number of time it’s necessary to bring them in the Less Signif. Position.
	CMP DX, 0				; I have only 3 cases: 	multiplication by 0 -> all zeros
	JE zero					;			multiplication by 1 -> result=multiplicand
	CMP DX, 1				; 			
	JE one					; 			
						;			multiplication by 2 -> 2* multiplicand
	PUSH FIVE				; 5 is the number of necessary cycles to complete the operation:
	PUSH DX					; 4 because I have 4 digits number + 1 due to the carry.
	PUSH DX
	CALL ADDITION
	POP DX
	JMP finish

zero:	MOV DX, 0				; multiplication by 0
	JMP finish
	
one:	MOV DX, AX				; multiplication by 1

finish:	SHL DX, CL				; DX is where I have the result of the multiplication. DX has to be
						; left shifted a number in order to follow the multiplication rule. 
	
	PUSH EIGHT				; 8 is a way to simplify the addition. Each time I need to add
	PUSH MULTIPLIED[BX]			; the current result with a number shifted by one digit (2 bit). 
	PUSH DX					; The right sequence (for each cycle) would be 5,6,7,8…. 8 is the most general case. 
	CALL ADDITION
	POP MULTIPLIED[BX]

	ADD DI, 2				; next digit
	POP CX
	LOOP loop41				; internal loop	

	INC SI
	ADD BX, 2
	POP CX
	LOOP loop40				; external loop
        JMP theend

ADDITION PROC NEAR
	PUSH BP
	MOV BP, SP
	PUSH AX					; All of these can be replaced by POPA (>=80186 processor). 
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH DI
        PUSH SI

	MOV CX, [BP+8]				; This makes the addition procedure as much flexible as possible. The number of iterations
						; required to compute the result can be chosen. 
	XOR DI, DI				; WORD index.
	XOR DX, DX				; Where I save the current carry, at the beginning, no carry.
	XOR SI, SI				; Where I save the current result. 

cycle:	PUSH CX					; CL is used in the shift instruction too. 
	MOV AX, [BP+6]
	MOV BX, [BP+4]
	AND AX, MASKE[DI]			; I extract a single digit.
	AND BX, MASKE[DI]			; I extract a single digit.
	MOV CX, DI				; Only CL can be used in 8086 SHL and SHR. 
	SHR AX, CL				; 
	SHR BX, CL				; Each digit is represented on 2 bit. DI is a word index and at each time it’s incremented by 2. 
	ADD AX, BX				; Add the two operands. 
	ADD AX, DX				; Add the carry.
	CMP AX, 3				; Base three requires only 0,1,2 as possible digits. 
	JB next
	SUB AX, 3				; In the worst case it’s 5-3=> result=2 carry=1
	MOV DX, 1				; Set the carry. 
	JMP forward

next: 	MOV DX, 0				; Set no carry. 

forward:SHL AX, CL				; AX contains the result. AX has to be shifted on the left, so it returns in the 
	XOR SI, AX				; original position. Update of the current result. 
	ADD DI, 2 
	POP CX
	LOOP cycle
	
	MOV [BP+8], SI				; The result is stored in the stack.

        POP SI
        POP DI
        POP DX
        POP CX
        POP BX
        POP AX
	POP BP
	RET 4					; 3 words in, only 1 word out. 
ADDITION ENDP 

theend: NOP

.EXIT
END
