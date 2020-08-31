N EQU 5
ZERO EQU '0'

.MODEL small
.STACK
.DATA
  FIRST DB 00000000b, 00000001b, 00000010b, 00000100b, 00000101b, 10101010b, 10101010b, 10101010b, 10101010b, 10101010b
  SECOND DB 00000101b, 00000100b, 00000010b, 00000001b, 00000000b, 10101010b, 10101010b, 10101010b, 10101010b, 10101010b
  
  FIRST_SORTED_HI_TO_LO DB N DUP (0)
  SECOND_SORTED_LO_TO_HI DB N DUP (0)
  ADDED DW N DUP (0)
  BY_THREE_MULTIPLIED_FIRST DW N DUP (0)
  BY_THREE_MULTIPLIED_SECOND DW N DUP (0)
  BY_TWO_MULTIPLIED_FIRST DW N DUP (0)
  BY_TWO_MULTIPLIED_SECOND DW N DUP (0)
  MULTIPLIED DW N DUP (0)
  
  MASKS_DB DB 00000011b, 00001100b, 00110000b, 11000000b
  MASKS_DW DW 0000000000000011b, 0000000000001100b, 0000000000110000b, 0000000011000000b, 0000001100000000b, 0000110000000000b, 0011000000000000b, 1100000000000000b
  
  ; Menu
  STRING1 DB 13, 10, "1 - Item 1", 13, 10, '$'
  STRING2 DB "2 - Item 2", 13, 10, '$'
  STRING3 DB "3 - Item 3", 13, 10, '$'
  STRING4 DB "4 - Item 4", 13, 10, '$'
  STRING5 DB "5 - exit", 13, 10, '$'
  STRING6 DB "Please choose an option: ", '$'
  STRING7 DB 13, 10, 13, 10,  "FIRST_SORTED_HI_TO_LO: ", '$'
  STRING8 DB 13, 10, "SECOND_SORTED_LO_TO_HI: ", '$'
  STRING9 DB 13, 10, "ADDED: ", '$'
  STRING10 DB 13, 10, "BY_THREE_MULTIPLIED_FIRST: ", '$'
  STRING11 DB 13, 10, "BY_THREE_MULTIPLIED_SECOND: ", '$'
  STRING12 DB 13, 10, "BY_TWO_MULTIPLIED_FIRST: ", '$'
  STRING13 DB 13, 10, "BY_TWO_MULTIPLIED_SECOND: ", '$'
  STRING14 DB 13, 10, "MULTIPLIED: ", '$'
  STRING15 DB 13, 10, '$'
  
.CODE
.STARTUP

start_of_program:
CALL ITEM0 ; Mandatory

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
CALL ITEM1
JMP print
cmp3:
CMP AL, '2'
JNE cmp4
CALL ITEM2
JMP print
cmp4:
CMP AL, '3'
JNE cmp5
CALL ITEM3
JMP print
cmp5:
;AL = '4'
CALL ITEM4

print:
; Print results
MOV AH, 9H

LEA DX, STRING7
INT 21H
LEA BX, FIRST_SORTED_HI_TO_LO
PUSH BX
CALL PRINT_ARRAY_DB

LEA DX, STRING8
INT 21H
LEA BX, SECOND_SORTED_LO_TO_HI
PUSH BX
CALL PRINT_ARRAY_DB

LEA DX, STRING9
INT 21H
LEA BX, ADDED
PUSH BX
CALL PRINT_ARRAY_DW

LEA DX, STRING10
INT 21H
LEA BX, BY_THREE_MULTIPLIED_FIRST
PUSH BX
CALL PRINT_ARRAY_DW

LEA DX, STRING11
INT 21H
LEA BX, BY_THREE_MULTIPLIED_SECOND
PUSH BX
CALL PRINT_ARRAY_DW

LEA DX, STRING12
INT 21H
LEA BX, BY_TWO_MULTIPLIED_FIRST
PUSH BX
CALL PRINT_ARRAY_DW

LEA DX, STRING13
INT 21H
LEA BX, BY_TWO_MULTIPLIED_SECOND
PUSH BX
CALL PRINT_ARRAY_DW

LEA DX, STRING14
INT 21H
LEA BX, MULTIPLIED
PUSH BX
CALL PRINT_ARRAY_DW

MOV AH, 9H
LEA DX, STRING15
INT 21H

JMP start_of_program


ITEM0 PROC
  PUSH BP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI

  ; Copy FIRST into FIRST_SORTED_HI_TO_LO and SECOND into SECOND_SORTED_LO_TO_HI
  MOV CX, N
  MOV DI, 0
  item0_copy:
  MOV AL, SECOND[DI]
  MOV SECOND_SORTED_LO_TO_HI[DI], AL
  MOV AL, FIRST[DI]
  MOV FIRST_SORTED_HI_TO_LO[DI], AL
  INC DI
  LOOP item0_copy
  
  MOV AL, N
  XOR AH, AH
  PUSH AX
  LEA AX, FIRST_SORTED_HI_TO_LO
  PUSH AX
  CALL SORT
  POP AX ; dummy
  POP AX ; dummy

  MOV AL, N
  XOR AH, AH
  PUSH AX
  LEA AX, FIRST_SORTED_HI_TO_LO
  PUSH AX
  CALL REVERSE_ARRAY
  POP AX ; dummy
  POP AX ; dummy

  MOV AL, N
  XOR AH, AH
  PUSH AX
  LEA AX, SECOND_SORTED_LO_TO_HI
  PUSH AX
  CALL SORT
  POP AX ; dummy
  POP AX ; dummy

  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM0 ENDP


ITEM1 PROC
  PUSH BP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI

  MOV CX, N
  XOR DI, DI
  XOR SI, SI
  
  item1_next:
  XOR AH, AH
  MOV AL, FIRST_SORTED_HI_TO_LO[DI] ; First operand
  PUSH AX
  MOV AL, SECOND_SORTED_LO_TO_HI[DI] ; Second operand
  PUSH AX
  CALL ADDITION_DB
  POP AX ; Result
  POP BX ; dummy
  MOV ADDED[SI], AX
  INC DI
  INC SI
  INC SI
  LOOP item1_next

  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM1 ENDP


ITEM2 PROC
  ; multiplication by 3 = shift by 1 3-bit digits, that is shift by 2 bits
  PUSH BP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI

  MOV CX, N
  XOR DI, DI
  XOR SI, SI
  
  item2_loop:
  MOV AL, FIRST_SORTED_HI_TO_LO[DI]
  XOR AH, AH
  SHL AX, 1
  SHL AX, 1
  MOV BY_THREE_MULTIPLIED_FIRST[SI], AX
  
  MOV AL, SECOND_SORTED_LO_TO_HI[DI]
  XOR AH, AH
  SHL AX, 1
  SHL AX, 1
  MOV BY_THREE_MULTIPLIED_SECOND[SI], AX
  
  INC DI
  INC SI
  INC SI
  LOOP item2_loop
  
  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM2 ENDP


ITEM3 PROC
  ; x * 2 = x + x
  PUSH BP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  
  ; First
  MOV CX, N
  XOR DI, DI
  XOR SI, SI
  
  item3_next:
  XOR AH, AH
  MOV AL, FIRST_SORTED_HI_TO_LO[DI]
  PUSH AX ; First operand
  PUSH AX ; Second operand
  CALL ADDITION_DB
  POP AX ; Result
  POP BX ; dummy
  MOV BY_TWO_MULTIPLIED_FIRST[SI], AX
  INC DI
  INC SI
  INC SI
  LOOP item3_next
  
  
  ; Second
  MOV CX, N
  XOR DI, DI
  XOR SI, SI
  
  item3_next2:
  XOR AH, AH
  MOV AL, SECOND_SORTED_LO_TO_HI[DI]
  PUSH AX ; First operand
  PUSH AX ; Second operand
  CALL ADDITION_DB
  POP AX ; Result
  POP BX ; dummy
  MOV BY_TWO_MULTIPLIED_SECOND[SI], AX
  INC DI
  INC SI
  INC SI
  LOOP item3_next2

  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM3 ENDP


ITEM4 PROC
  PUSH BP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH SI
  PUSH DI
  
  ; Set all the items in MULTIPLIED to 0
  MOV CX, N
  XOR DI, DI
  multiplied_to_0:
  MOV MULTIPLIED[DI], 0
  INC DI
  INC DI
  LOOP multiplied_to_0
  
  MOV CX, N
  MOV DI, 0
  MOV SI, 0
  
  item4_loop:
  XOR BX, BX
  
  item4_loop2:
  MOV DL, SECOND_SORTED_LO_TO_HI[DI]
  
  AND DL, MASKS_DB[BX]
  
  ; Shift right the digit
  XOR AL, AL
  item4_loop3:
  CMP AL, BL
  JE item4_loop3_end
  SHR DL, 1
  SHR DL, 1
  INC AL
  JMP item4_loop3
  
  item4_loop3_end:
  PUSH DX ; Digit
  MOV AL, FIRST_SORTED_HI_TO_LO[DI]
  XOR AH, AH
  PUSH AX ; Byte
  ; AL = first operand
  ; DL = second operand
  CALL MULTIPLICATION_ONE_DIGIT_BY_DB
  POP DX
  POP AX ; dummy
  
  ; Shift left the result
  XOR AL, AL
  item4_loop4:
  CMP AL, BL
  JE item4_loop4_end
  SHL DX, 1
  SHL DX, 1
  INC AL
  JMP item4_loop4
  
  item4_loop4_end:
  PUSH DX
  MOV AX, MULTIPLIED[SI]
  PUSH AX
  CALL ADDITION_DW
  POP DX ; Result
  POP AX ; Dummy
  
  MOV MULTIPLIED[SI], DX
  
  INC BX
  CMP BX, 4
  JNE item4_loop2
  
  INC SI
  INC SI
  INC DI
  LOOP item4_loop

  POP DI
  POP SI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ITEM4 ENDP


SORT PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH CX
  PUSH DX
  PUSH DI

  sort_init: ; Outer loop
  MOV DL, 1 ; DL is a flag, which tells us if at least one swap has been performed in the inner loop
  MOV CX, [BP]+6 ; CX is initialized with the length of the array
  
  CMP CX, 1
  JE sort_end ; Particular case: 1-item-long array
  
  DEC CX
  MOV DI, [BP]+4 ; DI is initialized with the offset of the first element of the array

  sort_next: ; Inner loop
  MOV AL, [DI]
  CMP [DI+1], AL ; If ([DI] <=[DI+1])
  JAE sort_continue ; then don't swap and jump to sort_continue

  ; else swap the two elements [DI] and [DI+1]
  XCHG [DI+1], AL
  MOV [DI], AL
  XOR DL, DL ; DL=0, one swap has been performed

  sort_continue:
  INC DI ; Go to the next element of the array
  LOOP sort_next

  CMP DL, 0 ; If (DL=0) then at least one swap has been performed
  JE sort_init ; therefore continue with the outer loop
  ; else no swaps performed -> all the items are in order -> the sorting ends.

  sort_end:
  POP DI
  POP DX
  POP CX
  POP AX
  POP BP
  RET
SORT ENDP


REVERSE_ARRAY PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DI
  PUSH SI

  MOV DI, [BP]+6 ; Length of array
  MOV BX, [BP]+4 ; Offset to the first item in the array

  MOV CX, DI
  SHR CX, 1 ; Division by 2: I don't need to scan the whole array but just its half

  XOR SI, SI ; Index of the first item as left item
  DEC DI ; Index of the last item as right item

  reverse_array_next:
  ; Swap the item [BX][DI] and the item [BX][SI]
  MOV AL, [BX][DI]
  XCHG [BX][SI], AL
  MOV [BX][DI], AL

  INC SI ; Next left item
  DEC DI ; Previous right item
  LOOP reverse_array_next ; Loop n/2 times (for odd arrays the middle item is not considered)

  POP SI
  POP DI
  POP CX
  POP BX
  POP AX
  POP BP
  RET
REVERSE_ARRAY ENDP


ADDITION_DW PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  XOR AX, AX ; AX = result
  XOR CX, CX ; Carry at the beginning
  
  XOR SI, SI ; from 0 to 14
  XOR DI, DI ; from 0 to 7
  
  addition_dw_loop:
  ; Carry
  PUSH CX

  
  ; Second digit
  MOV DX, [BP]+6 ; First operand
  AND DX, MASKS_DW[SI] ; First digit from second operand
  
  ; Shift
  MOV BX, DI
  addition_dw_shift_loop:
  CMP BX, 0
  JE addition_dw_shift_end
  SHR DX, 1
  SHR DX, 1
  DEC BX
  JMP addition_dw_shift_loop
  
  addition_dw_shift_end:
  XOR DH, DH
  PUSH DX
  
  
  ; First digit
  MOV DX, [BP]+4 ; Second operand
  AND DX, MASKS_DW[SI] ; First digit from first operand
  
  ; Shift
  MOV BX, DI
  addition_dw_shift_loop2:
  CMP BX, 0
  JE addition_dw_shift_end2
  SHR DX, 1
  SHR DX, 1
  DEC BX
  JMP addition_dw_shift_loop2
  
  addition_dw_shift_end2:
  XOR DH, DH
  PUSH DX
  
  
  CALL ADDITION_ONE_DIGIT
  POP DX ; Result
  POP CX ; Next carry
  POP BX ; dummy
  
  ; Shift
  MOV BX, DI
  addition_dw_loop2:
  CMP BX, 0
  JE addition_dw_loop2_end
  SHL DX, 1
  SHL DX, 1
  DEC BX
  JMP addition_dw_loop2
  
  addition_dw_loop2_end:
  ADD AX, DX
  INC DI
  INC SI
  INC SI
  CMP DI, 8
  JNE addition_dw_loop
  
  MOV [BP]+4, AX
  
  ;Ignore the last carry
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ADDITION_DW ENDP


ADDITION_DB PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI

  MOV AX, [BP]+6 ; AL = first operand
  MOV BX, [BP]+4
  MOV AH, BL ; Second operand
  MOV [BP]+4, WORD PTR 0 ; Result
  XOR SI, SI ; Carry at the beginning
  
  MOV CX, 4 ; Counter
  XOR DI, DI ; Digit number (from 0 to 3)
  
  addition_loop:
  ; Carry
  PUSH SI

  
  ; Second digit
  MOV DL, AH
  AND DL, MASKS_DB[DI] ; First digit from second operand
  
  ; Shift
  MOV BX, DI
  addition_shift_loop:
  CMP BX, 0
  JE addition_shift_end
  SHR DL, 1
  SHR DL, 1
  DEC BX
  JMP addition_shift_loop
  
  addition_shift_end:
  XOR DH, DH
  PUSH DX
  
  
  ; First digit
  MOV DL, AL
  AND DL, MASKS_DB[DI] ; First digit from first operand
  
  ; Shift
  MOV BX, DI
  addition_shift_loop2:
  CMP BX, 0
  JE addition_shift_end2
  SHR DL, 1
  SHR DL, 1
  DEC BX
  JMP addition_shift_loop2
  
  addition_shift_end2:
  XOR DH, DH
  PUSH DX
  
  
  CALL ADDITION_ONE_DIGIT
  POP DX ; Result
  POP SI ; Next carry
  POP BX ; dummy
  
  ; Shift
  MOV BX, DI
  addition_loop2:
  CMP BX, 0
  JE addition_loop2_end
  SHL DL, 1
  SHL DL, 1
  DEC BX
  JMP addition_loop2
  
  addition_loop2_end:
  ADD [BP]+4, DX
  INC DI
  LOOP addition_loop
  
  ; Last carry
  CMP SI, 1
  JE last_carry_one
  
  ;last_carry_zero:
  MOV [BP]+5, BYTE PTR 0
  JMP addition_end
  
  last_carry_one:
  MOV [BP]+5, BYTE PTR 1
  
  addition_end:
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ADDITION_DB ENDP


ADDITION_ONE_DIGIT PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV AX, [BP]+4 ; First digit
  MOV BX, [BP]+6 ; Second digit
  MOV SI, [BP]+8 ; Carry
  
  CMP AL, BL
  JBE addition_skip_swap
  XCHG AL, BL
  
  ; At this point: AL <= BL
  addition_skip_swap:
  CMP AL, 2
  JNE addition_skip_extreme_case
  CMP SI, 1
  JNE addition_skip_extreme_case
  
  ; Extreme case: 2 + 2 + carry 1 = 2 + carry 1
  MOV BL, 2
  MOV SI, 1 ; Carry
  JMP addition_one_digit_return
  
  addition_skip_extreme_case:
  ; Add the carry to one of the operands, then I do not think of it anymore
  ; In particular, avoid adding the carry to an operand = 2
  CMP BX, 2
  JE addition_one_digit_add_carry_to_AX
  ; BX < 2
  ADD BX, SI
  JMP addition_one_digit_add_carry_end
  addition_one_digit_add_carry_to_AX:
   ; AX <> 2 && BX = 2 && AX <= BX -> AX < 2
  ADD AX, SI
  
  addition_one_digit_add_carry_end:
  CMP AL, 0
  JE addition_zero
  CMP AL, 1
  JE addition_one
  
  ;addition_two ; AL = 2
  ; BL = 2 (because BL >= AL)
  MOV BL, 1
  MOV SI, 1 ; Carry
  JMP addition_one_digit_return
  
  addition_one: ; AL = 1
  CMP BL, 1
  JE addition_one_one
  
  ;addition_one_two ; BL = 2
  MOV BL, 0
  MOV SI, 1 ; Carry
  JMP addition_one_digit_return
  
  addition_one_one: ; BL = 1
  MOV BL, 2
  MOV SI, 0
  JMP addition_one_digit_return
  
  addition_zero: ; AL = 0
  MOV SI, 0 ; Carry always 0
  CMP BL, 0
  JE addition_zero_zero
  CMP BL, 1
  JE addition_zero_one
  
  ;addition_zero_two ; BL = 2
  MOV BL, 2
  JMP addition_one_digit_return
  
  addition_zero_one: ; BL = 1
  MOV BL, 1
  JMP addition_one_digit_return
  
  addition_zero_zero: ; BL = 0
  MOV BL, 0
  
  addition_one_digit_return:
  XOR BH, BH
  MOV [BP]+4, BX ; Result
  MOV [BP]+6, SI ; Next carry
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
ADDITION_ONE_DIGIT ENDP


MULTIPLICATION_ONE_DIGIT_BY_DB PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV AX, [BP]+4 ; byte
  MOV BX, [BP]+6 ; digit
  
  ; The digit can be 0, 1 or 2
  CMP BL, 1
  JE multiplication_one_digit_by_db_one
  CMP BL, 0
  JE multiplication_one_digit_by_db_zero
  
  ;multiplication_one_digit_by_db_two:
  ; AX = AX * 2 = AX + AX
  PUSH AX
  PUSH AX
  CALL ADDITION_DB
  POP AX
  POP BX ; dummy
  JMP multiplication_one_digit_by_db_one
  
  multiplication_one_digit_by_db_zero:
  ; AX = AX * 0 = 0
  MOV AL, 0
  
  multiplication_one_digit_by_db_one:
  ; AX = AX * 1 = AX
  
  MOV [BP]+4, AX
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
MULTIPLICATION_ONE_DIGIT_BY_DB ENDP


PRINT_DB PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV SI, [BP]+4 ; Address of the item to be printed
  MOV DI, 4
  
  print_db_loop2:
  DEC DI
  MOV DL, [SI]
  AND DL, MASKS_DB[DI]
  
  MOV BX, DI
  print_db_loop3:
  CMP BX, 0
  JE print_db_loop3_end
  SHR DL, 1
  SHR DL, 1
  DEC BX
  JMP print_db_loop3
  
  print_db_loop3_end:
  ADD DL, '0'
  MOV AH, 2
  INT 21H
  
  CMP DI, 0
  JG print_db_loop2
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
PRINT_DB ENDP


PRINT_ARRAY_DB PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV SI, [BP]+4 ; Address of the first item of the array to be printed
  MOV CX, N
  
  print_array_db_loop:
  PUSH SI
  CALL PRINT_DB
  POP BX ; dummy
  
  ; Print comma
  MOV DL, ','
  MOV AH, 2
  INT 21H
  
  INC SI
  LOOP print_array_db_loop
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
PRINT_ARRAY_DB ENDP


PRINT_ARRAY_DW PROC
  PUSH BP
  MOV BP, SP
  PUSH AX
  PUSH BX
  PUSH CX
  PUSH DX
  PUSH DI
  PUSH SI
  
  MOV SI, [BP]+4 ; Address of the first item of the array to be printed
  MOV CX, N
  
  print_array_dw_loop:
  INC SI
  
  PUSH SI
  CALL PRINT_DB
  POP BX ; dummy
  
  DEC SI
  
  PUSH SI
  CALL PRINT_DB
  POP BX ; dummy
  
  INC SI
  INC SI
  
  ; Print comma
  MOV DL, ','
  MOV AH, 2
  INT 21H
  
  LOOP print_array_dw_loop
  
  POP SI
  POP DI
  POP DX
  POP CX
  POP BX
  POP AX
  POP BP
  RET
PRINT_ARRAY_DW ENDP


end_of_program:
.EXIT
END
