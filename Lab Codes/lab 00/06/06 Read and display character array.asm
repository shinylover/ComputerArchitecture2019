DIM     EQU     20

.MODEL      small

.STACK

.DATA
VETT    DB      DIM     DUP(0)

.CODE

.STARTUP                      
        MOV CX, DIM
        MOV DI, 0
        MOV AH, 1       ; SET HA FOR READING

lab1:   INT 21H         ; read a character from keyboard 
        MOV VETT[DI], AL
        INC DI          ; Because of DB, plus 1
        DEC CX
        CMP CX, 0
        JNZ lab1
        MOV CX, DIM     ; Reset the CX for display 
        MOV AH, 2       ; Set for writing 
        
lab2:   DEC DI
        MOV DL, VETT[DI]; DX is general Register and AX is occupied 
        INT 21H         ; Interrupt to display the character 
        DEC CX
        CMP CX, 0
        JNZ lab2
        
.EXIT

END