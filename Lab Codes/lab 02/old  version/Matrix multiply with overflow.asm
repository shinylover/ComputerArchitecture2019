N EQU 4
M EQU 7
P EQU 5 
R EQU 20

.MODEL small
    .STACK
    .DATA
    
    ARR_A DW    3, 14, -15, 9, 26, -53, 5, 89, 79, 3, 23, 84, -6, 26, 43, -3, 83, 27, -9, 50, 28, -88, 41, 97, -103, 69, 39, -9    
                
    ARR_B DW    37, -101, 0, 58, -20, 9, 74, 94, -4, 59, -23, 90, -78, 16, -4, 0, -62, 86, 20, 89, 9, 86, 28, 0, -34, 82, 5, 34, -21, 1, 70, -67, 9, 82, 14
                
    CHECK DW 0 
    
    Pos_re DW -32768
    Neg_re DW  32767  
    
    point_i DW 0
    point_j DW 0
    point_i1 DW 0
    point_j1 DW 0
    point_add_cou DW 0
    
    ARR_RES DW R  DUP(0)
    
    .CODE
    .STARTUP 
     
    MOV CX, N 
    MOV DI, 0 
    

OUTLOOP:
    PUSH CX
    MOV CX, P 
    
MIDLOOP:
    PUSH CX
    MOV CX, M 
    MOV BX, 0 
    
    MOV AX, point_i1
    MOV DL, M
    MUL DL
    MOV DI, AX

INNERLOOP:
    MOV AX, point_i 
    MOV DL, P
    MUL DL  
    ADD AX, point_j
    MOV SI, AX
    
    MOV AX, ARR_A[DI]
    MUL ARR_B[SI]
    ADD BX, AX
     
    JO Lab0
    JNO Return 
Lab0:
    CMP BX, 0
    JBE Lab2    
Lab1:
    MOV BX, Neg_re
    JMP Return  
Lab2:
    MOV BX, Pos_re 
    JMP Return 
Return:    
    INC DI
    INC DI
    INC point_i
    INC point_i    
LOOP INNERLOOP  

    POP CX 
    MOV SI, point_add_cou   
    MOV ARR_RES[SI], BX
    INC point_add_cou
    INC point_add_cou
    INC point_j
    INC point_j
    MOV AX, 0
    MOV point_i, AX
LOOP MIDLOOP
   
    
    POP CX
    MOV AX, 0
    MOV point_j, AX
    INC point_i1
    INC point_i1
LOOP OUTLOOP
    
    
    
    .EXIT
END