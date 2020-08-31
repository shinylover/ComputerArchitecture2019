				AREA myAsmFunctions, CODE, READONLY

concatenateString PROC
	; parameters:
	; - pointer to string 1 (r0)
	; - number of characters to copy from string 1 (r1)
	; - pointer to string 2 (r2)
	; - number of characters to copy from string 2 (r3)	
	; - pointer to string 3 (first value in the stack)
	; - length of string 3 (second value in the stack)
	; The subroutine copies string 1 and string 2 into string 3 and returns (in r0) the number of characters copied.
                EXPORT  concatenateString
				; save current SP for a faster access to parameters in the stack
				MOV   r12, sp
				; save volatile registers
				STMFD sp!,{r4-r8,r10-r11,lr}				
				; extract argument 4 and 5 into r4 and r5
				LDR   r4, [r12]
				LDR   r5, [r12, #4]
				SUB r5, r5, #1	; the last character must be the zero terminator
				
				MOV r6, #0	; num of bytes copied to string 3
				
string1copy		LDRB r7, [r0], #1 ; load byte and update address

				; check if there are still characters to copy from string 1
				CMP r7, #0 ; check for zero terminator
				BEQ string1End
				
				STRB r7, [r4], #1 ; store byte and update address
				ADD r6, r6, #1
				
				; check if string 3 is full
				CMP r6, r5
				BEQ string2End
				
				; check if enough characters are copied from string 1
				CMP r6, r1		
				BLO string1copy ; keep going if not

string1End		MOV r8, #0	; num of bytes copied from string 2

string2copy		LDRB r7, [r2], #1 ; load byte and update address

				; check if there are still characters to copy from string 2
				CMP r7, #0 ; check for zero terminator
				BEQ string2End
				
				STRB r7, [r4], #1 ; store byte and update address
				ADD r6, r6, #1
				ADD r8, r8, #1
				
				; check if string 3 is full
				CMP r6, r5
				BEQ string2End
				
				; check if enough characters are copied from string 2
				CMP r8, r3
				BLO string2copy ; keep going if not		
				
string2End		; insert the zero terminator
				MOV r7, #0
				STRB r7, [r4], #1 ; store byte and update address
			
				; set the return value
				MOV r0, r6		
				
				; restore volatile registers
				LDMFD sp!,{r4-r8,r10-r11,pc}
				
				ENDP
                END