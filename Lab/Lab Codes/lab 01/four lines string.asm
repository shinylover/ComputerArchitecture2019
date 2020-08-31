;This program only consider the character A-Z, a-z and Enter button, please input right characters

DIM     EQU     20   
MAX     EQU     50  
GAP     EQU     65      ;The result of ascii 'A' - 0

.MODEL      small

.STACK

.DATA 
first_line  DB 50 DUP(0)
second_line DB 50 DUP(0)
third_line  DB 50 DUP(0)
fourth_line DB 50 DUP(0) 

first_count     DB  58  DUP(48)      ;the result of ascii 'a' - 'A' + 1
second_count    DB  58  DUP(48)
third_count     DB  58  DUP(48)
fouth_count     DB  58  DUP(48) 

fou_count       DB  4   DUP(0) 

display         DB  116 DUP(48)      ; Two dimensions, one is ASCII, one is occurrence times

.CODE

.STARTUP   

;-----------------------------------------------INPUT-------------------------------------------
     
        XOR DH, DH           ; as a characters counter
        XOR DL, DL           ; AS a strings counter
        MOV AH, 1 
        XOR CX, CX                               
        JMP cho

read:   INT 21H  
        CMP AL, 13
        JNE con             ; not equal enter button, continue
        CMP DH, DIM
        JB  read            ;bellow 20, read a new value from keyborad buffer
        JMP cho
        
con:    MOV [DI], AL        ; Store the keyboard buffer into memory
        INC CX  
        INC DH    
        MOV BX, SI
        ADD SI, [DI]
        SUB SI, GAP
        INC [SI]            ; conter the charter  
        MOV SI, BX
        INC DI
        CMP DH, MAX
        JB  read    
;int20:  CMP DH, DIM

cho:    INC DL              ; choose a string_line to read the keyboard buffer
        XOR DH, DH 
        CMP DL,1
        JE  fir
        CMP DL, 2
        JE  sec
        CMP DL, 3
        JE  thi 
        CMP DL, 4
        JE  fou
        LEA SI, fou_count
        MOV [SI+3], CX
        XOR CX, CX 
        JMP output

fir:    LEA DI, first_line
        LEA SI, first_count  
        JMP read 
                   
sec:    LEA SI, fou_count
        MOV [SI], CX
        XOR CX, CX 
        LEA DI, second_line 
        LEA SI, second_count 
        JMP read

thi:    LEA SI, fou_count
        MOV [SI+1], CX
        XOR CX, CX 
        LEA DI, third_line 
        LEA SI, third_count
        JMP read

fou:    LEA SI, fou_count
        MOV [SI+2], CX
        XOR CX, CX 
        LEA DI, fourth_line  
        LEA SI, fouth_count
        JMP read  
 
;----------------------------------------------------OUTPUT----------------------------------------- 
        
output: 
        XOR DX, DX
        XOR BX, BX 
        XOR AX, AX
        XOR SP, SP 
        INC CH

cho2:   CMP CH, 1
        JE  fir2
        CMP CH, 2
        JE  sec2
        CMP CH, 3
        JE  thi2
        CMP CH, 4
        JE  fou2 
 
 
        
fir2:   LEA SI, fou_count
        MOV CL, [SI] 
        MOV AH, CL
        LEA SI, first_count
        LEA DI, display
        JMP order
        
sec2:   LEA SI, fou_count
        MOV CL, [SI+1]
        MOV AH, CL 
        LEA SI, second_count 
        LEA DI, display
        JMP order

thi2:   LEA SI, fou_count
        MOV CL, [SI+2]
        MOV AH, CL
        LEA SI, third_count 
        LEA DI, display
        JMP order

fou2:   LEA SI, fou_count
        MOV CL, [SI+3]
        MOV AH, CL 
        LEA SI, fouth_count
        LEA DI, display
        JMP order      
        
order:  CMP CL, 0
        JE  list 
        DEC CL
        MOV AL, [SI]
        INC SP                       
        INC SI
        CMP DL, AL
        JAE order
        MOV DL, AL
        MOV [DI], SP
        DEC [DI]
        MOV [DI+1], AL
        JMP order 

list:   SUB DL, 48                 ;change the ASCII 
        SHR DL, 1   
        ADD DL, 48     
        MOV CL, AH
        MOV BX, 2 
        
list2:  CMP CL, 0
        JE  displ
        DEC CL
        MOV AL, [SI]
        DEC SI
        DEC SP
        CMP DL, AL
        JA  list2
        MOV [DI+BX], SP
        INC [DI+BX]
        INC BX
        MOV [DI+BX], AL 
        INC BX
        JMP list2    

displ:  MOV CL, BL 
        SHR CL, 1
        XOR BX, BX
        INC CH
        
disp2:  CMP CL, 0
        JE  over
        DEC CL
        MOV DL, [DI+BX]
        ADD DL, GAP
        MOV AH, 2
        INT 21H 
        MOV DL, 45                  ;insert symbol '-'
        INT 21H 
        INC BX
        MOV DL, [DI+BX]
        INC BX
        INT 21H
        MOV DL, 31                  ;insert symbol ' '
        INT 21H        
        JMP disp2 

over:   CMP CH, 4
        JNA cho2
        
        

.EXIT

END