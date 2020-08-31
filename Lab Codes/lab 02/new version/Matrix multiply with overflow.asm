N   EQU     4
M   EQU     7
P   EQU     5                       
R   EQU     20  

POS EQU     32768
NAT EQU     -32767

.MODEL  small

.STACK 

.DATA 
        MATRIX_A    DW      3, 14, -15, 9, 26, -53, 5, 89, 79, 3, 23, 84, -6, 26, 43, -3, 83, 27, -9, 50, 28, -88, 41, 97, -103, 69, 39, -9
        MATRIX_B    DW      37, -101, 0, 58, -20, 9, 74, 94, -4, 59, -23, 90, -78, 16, -4, 0, -62, 86, 20, 89, 9, 86, 28, 0, -34, 82, 5, 34, -21, 1, 70, -67, 9, 82, 14
        MATRIX_C    DW      R   DUP(0)
        
        POINTER_IA  DW      0 
        POINTER_IB  DW      0
        
        POINTER_C   DW      0
.CODE

.STARTUP    
            MOV CX, N 
            
outloop:    PUSH CX    
            MOV CX, P
            
midloop:    PUSH CX
            MOV CX, M
            MOV DI, POINTER_IA
            MOV SI, POINTER_IB
            AND BX, 0

innloop:    AND DX, 0
            MOV AX, MATRIX_A[DI]
            IMUL MATRIX_B[SI]
            CMP DX, 0               ; Check overflow or not
            JG  ovflg
            JL  ovfll
            
con:        ADD BX, AX
            JO ovflg 
            ADD DI, 2
            ADD SI, 10
               
        LOOP innloop
            
store:      MOV SI, POINTER_C
            MOV MATRIX_C[SI], BX
            ADD POINTER_C, 2            
            ADD POINTER_IB, 2
            POP CX  
        LOOP midloop
            
            ADD POINTER_IA, M*2
            AND POINTER_IB, 0
            POP CX
        LOOP outloop
            
            JMP over
            
ovflg:      CMP BX, 0
            JA  ovfll
            MOV BX, POS
            JMP store

ovfll:      CMP DX, -1
            JE  con
            MOV BX, NAT
            JMP store  
            
over:       NOP
             
            
                        
.EXIT

END