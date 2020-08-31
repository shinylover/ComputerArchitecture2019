    .model small
    .stack
    .data
 
SCORES  DW  0001101000101100B
        DW  0001110110101110B
        DW  0001101101100101B
        DW  0001101000100000B
        DW  0010010001001010B
        DW  0010001001001000B
        DW  0011010011010010B
        DW  0011011100010011B
        DW  0011010100011011B
        DW  0011010010001010B
        DW  0000000000000000B
        DW  0000000000000000B
        
COMPUTATIONS    DB  144 DUP(0)  ;oversized to leave the last entry equal to all zeros
RESULTS         DB  105 DUP(0)  ;;oversized to leave the last entry equal to all zeros

SUM     DW  0   ;sum of votes of all criteria for the current prof (used to compute PS)
COUNT   DB  0   ;students voting for the current prof (used to compute PS)

MAX     DB  2 DUP(0)    ;used to compute the max value of PS and store correspondinf prof

BUFFER  DB  8 DUP(0)    ;used to print number

PROFmsg DB  'Prof: $'
ACmsg   DB  ' - AC = $'
AAmsg   DB  ', AA = $'
ASmsg   DB  ', AS = $'
AEmsg   DB  ', AE = $'
PSmsg   DB  ', PS = $'
MAXmsg  DB  'Prof with max PS: $'
PSMAX   DB  ' - PS = $'
    .code
    .startup
    
    mov si, si  ;used as index for SCORES (input) array
readValues:
    mov dx, SCORES[si]
    cmp dx, 0
    je computeResultsWrap
    mov al, dh  ;ppppccca
    mov cl, 4
    shr al, cl  ;0000pppp   ;prof code
    sub al, 1   ;use prof code as index for COMPUTATIONS array
    mov cl, 9
    mul cl      ;because each entry of COMPUTATIONS is on 9 bytes
    xor di, di  ;used as index for COMPUTATIONS array
    add di, ax
    
    mov al, dh
    mov cl, 4
    shr al, cl
    mov COMPUTATIONS[di], al    ;store prof code
    
    mov al, dh          ;ppppccca
    and al, 00001110B   ;0000ccc0
    shr al, 1           ;00000ccc
    cmp al, 0
    je addAvailability
    add COMPUTATIONS[di+1], al  ;store CCC
    mov cl, 1
    add COMPUTATIONS[di+5], cl  ;increment number of students voting for clarity
    
addAvailability:
    mov ax, dx          ;ppppccca|aassseee
    and ah, 00000001B   ;0000000a
    mov cl, 6
    shr ax, cl          ;ah = 0, al = 00000aaa
    cmp al, 0
    je addStudInvolvment
    add COMPUTATIONS[di+2], al
    mov cl, 1
    add COMPUTATIONS[di+6], cl
    
addStudInvolvment:
    mov al, dl          ;aassseee
    and al, 00111000B   ;00sss000
    mov cl, 3
    shr al, cl          ;00000sss
    cmp al, 0
    je addEfficiency
    add COMPUTATIONS[di+3], al
    mov cl, 1
    add COMPUTATIONS[di+7], cl

addEfficiency:
    mov al, dl          ;aassseee
    and al, 00000111B   ;00000eee
    cmp al, 0
    je nextEntry
    add COMPUTATIONS[di+4], al
    mov cl, 1
    add COMPUTATIONS[di+8], cl
    
nextEntry:
    add si, 2
    jmp readValues
    
computeResultsWrap:
    xor si, si      ;used as index for COMPUTATIONS and RESULTS 
    xor di, di
computeResults:
    mov al, COMPUTATIONS[si]    ;prof code (if 0 => end of valid entries)
    cmp al, 0
    je endOfProgram
    mov SUM, 0
    mov COUNT, 0
    mov RESULTS[di], al     ;store prof code     
    
    mov cx, 4
computeAverages:
    add si, 1
    add di, 1
    xor ah, ah
    mov al, COMPUTATIONS[si]
    cmp al, 0
    je nextAverage
    add SUM, ax
    push cx
    mov cl, 5
    shl ax, cl          ;000iiiiiiiifffff
    pop cx
    mov dl, COMPUTATIONS[si+4]  
    add COUNT, dl
    div dl              ;al = xxx.yyyyy
    mov RESULTS[di], al
nextAverage:
    loop computeAverages
    
    add di, 1           ;compute PS 
    mov ax, SUM
    mov cl, 5
    shl ax, cl
    mov cl, COUNT
    div cl
    mov RESULTS[di], al ;al = xxx.yyyyy
    
    add si, 5       ;nextProfessor 
    add di, 1
    jmp computeResults
    
endOfProgram:
    xor si, si
    
maxPS:
    mov dl, RESULTS[si]
    cmp dl, 0
    je printResultsWrap
    mov al, RESULTS[si+5]
    cmp al, MAX[1]
    jbe checkNextPS
    mov MAX[1], al  ;update max PS value...
    mov MAX[0], dl  ;...and corresponding professor code
checkNextPS:
    add si, 6
    jmp maxPS

printResultsWrap:    
    xor si, si
    lea ax, BUFFER
    push ax
printResults:
    call emptyRow
    mov al, RESULTS[si]
    cmp al, 0
    je printMax 
    mov ah, 9
    mov dx, offset PROFmsg
    int 21h
    xor ah, ah
    mov al, RESULTS[si]
    push ax
    call printDecimal
    pop ax
    
    mov ah, 9
    mov dx, offset ACmsg
    int 21h
    xor ah, ah
    mov al, RESULTS[si+1]
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    xor ah, ah
    mov al, RESULTS[si+1]
    and al, 00011111B 
    mov cl, 3
    shl al, cl
    push ax
    call printFractional
    pop ax
    
    mov ah, 9
    mov dx, offset AAmsg
    int 21h
    xor ah, ah
    mov al, RESULTS[si+2]
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    xor ah, ah
    mov al, RESULTS[si+2]
    and al, 00011111B
    mov cl, 3
    shl al, cl
    push ax
    call printFractional
    pop ax
    
    mov ah, 9
    mov dx, offset ASmsg
    int 21h
    xor ah, ah
    mov al, RESULTS[si+3]
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    xor ah, ah
    mov al, RESULTS[si+3]
    and al, 00011111B
    mov cl, 3
    shl al, cl
    push ax
    call printFractional
    pop ax

    mov ah, 9
    mov dx, offset AEmsg
    int 21h
    xor ah, ah
    mov al, RESULTS[si+4]
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    xor ah, ah
    mov al, RESULTS[si+4]
    and al, 00011111B
    mov cl, 3
    shl al, cl
    push ax
    call printFractional
    pop ax
    
    mov ah, 9
    mov dx, offset PSmsg
    int 21h
    xor ah, ah
    mov al, RESULTS[si+5]
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    xor ah, ah
    mov al, RESULTS[si+5]
    and al, 00011111B 
    mov cl, 3
    shl al, cl
    push ax
    call printFractional
    pop ax
    
    add si, 6
    jmp printResults

printMax:
    call emptyRow    
    mov ah, 9
    mov dx, offset MAXmsg
    int 21h
    xor ah, ah
    mov al, MAX[0]
    push ax
    call printDecimal
    pop ax
    mov ah, 9
    mov dx, offset PSMAX
    int 21h
    xor ah, ah
    mov al, MAX[1]
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    xor ah, ah
    mov al, MAX[1]
    and al, 00011111B
    push ax
    call printFractional
    pop ax
    
    pop ax
          
    
        
    .exit

;Procedure to insert a empty row
emptyRow proc
    push ax
    push dx
    
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h 
    
    pop dx
    pop ax
    ret                  
emptyRow endp

;Procedure to print a decimal number
printDecimal proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push di
    push bx
    
    mov di, [bp+6]      ;buffer address
    mov ax, [bp+4]      ;number 
conv:
    xor dx, dx
    mov bx, 10
loopDiv:
    div bx
    add dl, '0'         ;remainder: binary -> ascii
    mov [di], dl
    inc di
    xor dx, dx
    cmp ax, 0
    jne loopDiv

loopPrint:
    dec di
    mov dl, [di]
    mov ah, 2
    int 21h
    cmp di, [bp+6]
    jne loopPrint
    
    pop bx
    pop di
    pop dx
    pop ax
    
    pop bp
    ret
printDecimal endp 

;Procedure to print a fractional part on 8 bits 
printFractional proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push cx
    
    mov ax, [bp+6]  ;buffer address
    push ax
    
    mov ax, [bp+4]  ;fractional part to be printed
    xor dx, dx
    mov cx, 10000
    mul cx
    mov cx, 256
    div cx
    push ax
    call printDecimalF
    pop ax 
    
    mov ax, dx
    mov cx, 10000
    mul cx
    mov cx, 256
    div cx 
    cmp ax, 0
    je endPrintDecimalF
    push ax
    call printDecimalF
    pop ax       
    
endPrintDecimalF:    
    pop ax
    pop cx
    pop dx
    pop ax
    pop bp
    
    ret
printFractional endp


;Procedure to print a decimal number on a fixed number of digits
printDecimalF proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push di
    push bx
    push cx
    
    mov di, [bp+6]      ;buffer address
    mov ax, [bp+4]      ;number  
    mov cx, 4
convF:
    xor dx, dx
    mov bx, 10
loopDivF:
    div bx
    add dl, '0'         ;remainder: binary -> ascii
    mov [di], dl
    inc di
    xor dx, dx
    loop loopDivF

loopPrintF:
    dec di
    mov dl, [di]
    mov ah, 2
    int 21h
    cmp di, [bp+6]
    jne loopPrintF
    
    pop cx
    pop bx
    pop di
    pop dx
    pop ax
    
    pop bp
    ret
printDecimalF endp     



        end                             
