DIM     EQU     15
.MODEL  small

.STACK

.DATA  

VETT    DW  2, 5, 16, 12, 34, 7, 20, 11, 31, 44, 70, 69, 2, 4, 23
RES     DW  ?

.CODE

.STARTUP  
        MOV   AX, 0
        MOV   CX, DIM
        MOV   DI, 0         ;DI is a general Register 

lab:    ADD   AX, VETT[DI]
        ADD   DI, 2
        DEC   CX
        CMP   CX, 0
        JNZ   lab
        MOV   RES, AX 

.EXIT

END