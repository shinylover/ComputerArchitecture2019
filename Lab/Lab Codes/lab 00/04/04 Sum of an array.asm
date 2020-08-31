.MODEL  small

.STACK

.CODE

.DATA 
VETT    DW  5, 7, 3, 4, 3
RES     DW  ?

.STARTUP     
    MOV AX, 0
    ADD AX, VETT
    ADD AX, VETT+2         ;word type is 16 bits
    ADD AX, VETT+4
    ADD AX, VETT+6 
    ADD AX, VETT+8
    MOV RES, AX

.EXIT

END