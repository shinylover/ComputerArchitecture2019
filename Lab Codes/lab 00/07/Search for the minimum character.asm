DIM         EQU     20

.MODEL      small

.STACK

.DATA
        TAB     DB   DUP(0)

.CODE

.STARTUP                              
        MOV     CX, DIM
        LEA     DI, TAB         ; Through pass the address to avoid use TAB
        MOV     AH, 1           ; reading

lab1:   INT     21H
        MOV     [DI], AL
        INC     DI
        DEC     CX
        CMP     CX, 0
        JNE     lab1
        MOV     CL, 0FFH        ; Set the max Number for CMP
        MOV     DI, 0

ciclo:  CMP     CL, TAB[DI] 
        JB      dopo            ; Unsigned compare 
        MOV     CL, TAB[DI]

dopo:   INC     DI
        CMP     DI, DIM
        JB      ciclo

output: MOV     DL, CL
        MOV     AH, 2           ;Interrupt for displaying
        INT     21H                                           
                                         
.EXIT

END