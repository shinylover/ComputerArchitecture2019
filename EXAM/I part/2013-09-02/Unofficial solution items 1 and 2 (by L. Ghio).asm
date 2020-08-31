N_EMPLOYEES EQU 30
N_MAX_WORKING_DAYS_PER_MONTH EQU 23
N_MAX_RECORDS_PER_MONTH EQU N_EMPLOYEES * N_MAX_WORKING_DAYS_PER_MONTH
N_MONTHS EQU 12
N_RECORDS EQU N_MAX_RECORDS_PER_MONTH * N_MONTHS
N_BYTES_PER_RECORD EQU 3
N_BYTES_OF_RECORD EQU N_BYTES_PER_RECORD * N_RECORDS

print_dd MACRO first_byte_offset
  MOV AL, BYTE PTR first_byte_offset[2]
  XOR AH, AH
  CALL DISPLAY_BYTE

  MOV AH, 2
  MOV DL, '+'
  INT 21H

  MOV AL, BYTE PTR first_byte_offset[3]
  XOR AH, AH
  CALL DISPLAY_BYTE

  MOV AH, 9H
  LEA DX, STRING8
  INT 21H

  MOV AL, BYTE PTR first_byte_offset
  XOR AH, AH
  CALL DISPLAY_BYTE

  MOV AH, 9H
  LEA DX, STRING9
  INT 21H
ENDM

.MODEL small
.STACK
.DATA
  ; Input data
  CANTEEN_CHARGES_DATABASE DB N_BYTES_OF_RECORD DUP (?)
  
  ; Output data
  GRAND_TOTAL DD 0 ; Result of item 1*
  GRAND_TOTAL_PER_EMPLOYEE DD 0 ; Result of item 2*
  
  ;*24 bits used in this way:
  ;<first 8 bits> <dummy 8 bits> <last 8 bits> <middle 8 bits>

  ; Menu
  STRING1 DB 13, 10, "1 - Item 2", 13, 10, '$'
  STRING2 DB "2 - Item 3", 13, 10, '$'
  STRING3 DB "3 - Item 4", 13, 10, '$'
  STRING4 DB "4 - Item 5", 13, 10, '$'
  STRING5 DB "5 - exit", 13, 10, '$'
  STRING6 DB "Please choose an option: ", '$'
  STRING7 DB 13, 10, 13, 10, "GRAND_TOTAL: ", '$'
  STRING8 DB "*256+", '$'
  STRING9 DB "*256*256", '$'
  STRING10 DB 13, 10, "GRAND_TOTAL_PER_EMPLOYEE: ", '$'
  STRING11 DB 13, 10, 13, 10, "Please type an employee", 39, "s code, then press Enter: ", '$'
  
  CARRIAGE_RETURN DB 13, 10, '$'
  
.CODE
.STARTUP

start_of_program:

; Initialization of CANTEEN_CHARGES_DATABASE

; Record 1: date = January 1st, employee = 1, amount charged = 10
MOV CANTEEN_CHARGES_DATABASE[0], 00010000b ; first 8 bits
MOV CANTEEN_CHARGES_DATABASE[1], 00001010b ; last 8 bits
MOV CANTEEN_CHARGES_DATABASE[2], 10000100b ; middle 8 bits

; Record 2: date = November 10th, employee = 2, amount charged = 1000
MOV CANTEEN_CHARGES_DATABASE[3], 10110101b ; first 8 bits
MOV CANTEEN_CHARGES_DATABASE[4], 11101000b ; last 8 bits
MOV CANTEEN_CHARGES_DATABASE[5], 00001011b ; middle 8 bits

; Record 3: invalid
MOV CANTEEN_CHARGES_DATABASE[6], 00000000b
MOV CANTEEN_CHARGES_DATABASE[7], 00000000b
MOV CANTEEN_CHARGES_DATABASE[8], 00000000b

CALL ITEM1 ; Mandatory

; Menu
MOV AH, 9H
LEA DX, STRING1
INT 21H
LEA DX, STRING2
INT 21H
LEA DX, STRING3
INT 21H
LEA DX, STRING4
INT 21H
LEA DX, STRING5
INT 21H
LEA DX, STRING6
INT 21H

MOV AH, 1
INT 21H ; AL = '1', '2', '3', '4', '5'

CMP AL, '5'
JE end_of_program

CMP AL, '1'
JNE cmp3

; Acquisition for item 2
MOV AH, 9H
LEA DX, STRING11
INT 21H

; First digit
MOV AH, 1
INT 21H ; AL = typed character
SUB AL, '0'
MOV CL, AL

; Second digit
INT 21H ; AL = typed character
CMP AL, 13 ; Enter
JE skip_second_digit

SUB AL, '0'
MOV DL, AL
MOV AL, CL
MOV BL, 10
MUL BL ; AL = AL * 10
ADD AL, DL ; First digit + second digit
MOV CL, AL

; Enter
INT 21H

skip_second_digit:
XOR CH, CH
PUSH CX
CALL ITEM2
POP CX ; dummy
JMP print

cmp3:
CMP AL, '2'
JNE cmp4
CALL ITEM3
JMP print
cmp4:
CMP AL, '3'
JNE cmp5
CALL ITEM4
JMP print
cmp5:
;AL = '4'
CALL ITEM5

print:
; Print results
MOV AH, 9H
LEA DX, STRING7
INT 21H

print_dd GRAND_TOTAL

MOV AH, 9H
LEA DX, STRING10
INT 21H

print_dd GRAND_TOTAL_PER_EMPLOYEE

MOV AH, 9H
LEA DX, CARRIAGE_RETURN
INT 21H

JMP start_of_program


ITEM1 PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV CX, N_EMPLOYEES * N_MAX_WORKING_DAYS_PER_MONTH * N_MONTHS ; maximum number of records in a year
  LEA SI, CANTEEN_CHARGES_DATABASE
  
  item1_start:
  MOV DL, BYTE PTR [SI]
  INC SI
  MOV BX, [SI]
  ; current record = [DL BH BL]
  
  ; Check whether the current record is valid
  AND DL, 11110000b ; Extract number of month
  CMP DL, 0
  JE item1_end ; The current record is invalid, and the following ones are too because the array is well sorted
  
  ; The current record is valid
  ; Move the variable GRAND_TOTAL into registers
  MOV AX, WORD PTR GRAND_TOTAL[2] ; last 16 bits of the grand total
  MOV DL, BYTE PTR GRAND_TOTAL ; first 8 bits of the grand total
  ; GRAND_TOTAL = [DL AX]
  
  AND BX, 0000001111111111b ; Extract amount charged
  ADD AX, BX ; last 16 bits of the grand total + amount charged from current record
  ADC DL, 0 ; carry from previous add
  
  ; Store the result into the variable GRAND_TOTAL
  MOV BYTE PTR GRAND_TOTAL, DL
  MOV WORD PTR GRAND_TOTAL[2], AX
  
  INC SI
  INC SI
  LOOP item1_start
  
  item1_end:
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM1 ENDP


ITEM2 PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV WORD PTR GRAND_TOTAL_PER_EMPLOYEE, 0
  MOV WORD PTR GRAND_TOTAL_PER_EMPLOYEE[2], 0
  
  MOV CX, N_EMPLOYEES * N_MAX_WORKING_DAYS_PER_MONTH * N_MONTHS ; maximum number of records in a year
  LEA SI, CANTEEN_CHARGES_DATABASE
  
  item2_start:
  MOV DL, BYTE PTR [SI]
  
  ; Check whether the current record is valid
  AND DL, 11110000b ; Extract number of month
  CMP DL, 0
  JE item2_end ; The current record is invalid, and the following ones are too because the array is well sorted
  
  ; The current record is valid
  INC SI
  MOV BX, [SI]
  MOV AX, [BP]+4 ; AL = employee's code in input
  
  ; Check the employee's code
  AND BH, 01111100b ; Extract employee's code
  SHR BH, 1
  SHR BH, 1
  CMP BH, AL ; Compare the employee's code
  JNE item2_next_employee
  
  ; Move the variable GRAND_TOTAL into registers
  MOV AX, WORD PTR GRAND_TOTAL_PER_EMPLOYEE[2] ; last 16 bits of the grand total
  MOV DL, BYTE PTR GRAND_TOTAL_PER_EMPLOYEE ; first 8 bits of the grand total
  ; GRAND_TOTAL = [DL AX]
  
  MOV BX, [SI]
  AND BX, 0000001111111111b ; Extract amount charged
  ADD AX, BX ; last 16 bits of the grand total + amount charged from current record
  ADC DL, 0 ; carry from previous add
  
  ; Store the result into the variable GRAND_TOTAL
  MOV BYTE PTR GRAND_TOTAL_PER_EMPLOYEE, DL
  MOV WORD PTR GRAND_TOTAL_PER_EMPLOYEE[2], AX
  
  item2_next_employee:
  INC SI
  INC SI
  LOOP item2_start
  
  item2_end:
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM2 ENDP


ITEM3 PROC
  RET
ITEM3 ENDP


ITEM4 PROC
  RET
ITEM4 ENDP


ITEM5 PROC
  RET
ITEM5 ENDP


; Source: http://showmecodes.blogspot.it/2013/01/program-to-display-multiple-digit.html
DISPLAY_BYTE 		proc
			PUSH BP
			PUSH AX
			PUSH BX
			PUSH CX
			PUSH DX
			PUSH SI
			PUSH DI

			CMP AX, 0
			JE display_byte_print_zero

			MOV BX, 10			;Initializes divisor
			XOR DX, DX			;Clears DX
			XOR CX, CX			;Clears CX
				
							;Splitting process starts here
Dloop1:		XOR DX, DX			;Clears DX during jump
			DIV BX				;Divides AX by BX
			PUSH DX				;Pushes DX(remainder) to stack
			INC CX				;Increments counter to track the number of digits
			CMP AX, 0			;Checks if there is still something in AX to divide
			JNE Dloop1			;Jumps if AX is not zero
				
Dloop2:		POP DX				;Pops from stack to DX
			ADD DX, 30H			;Converts to it's ASCII equivalent
			MOV AH, 02H				
			INT 21H				;calls DOS to display character
			LOOP Dloop2			;Loops till CX equals zero
			JMP display_byte_end
			
			display_byte_print_zero:
			MOV DL, '0'
			MOV AH, 2
			INT 21H
			
			display_byte_end:
			POP BP
			POP AX
			POP BX
			POP CX
			POP DX
			POP SI
			POP DI
			RET				;returns control
DISPLAY_BYTE		ENDP

end_of_program:
.EXIT
END
