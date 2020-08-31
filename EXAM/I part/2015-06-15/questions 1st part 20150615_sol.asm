    .model small
    .stack
    .data

FFM DB  00000000B   ;Member 200
    DB  00000000B
    DB  00000000B
    DB  01100100B
    DB  00000010B   ;Member 201
    DB  00000000B
    DB  00100111B
    DB  00010101B
    DB  00000000B   ;Member 202
    DB  00000000B   
    DB  00000000B   
    DB  00000000B   
    DB  00000001B   ;Member 203
    DB  00000000B
    DB  00001110B
    DB  11011000B
        
FOM DB  150 DUP(0)

MULTIPLIER  DB 00110010B    ;multiplier of class A
            DB 00110001B    ;multiplier of class B
            DB 00000000B    ;multiplier of class C
            DB 00000000B    ;multiplier of class D
            DB 11110010B    ;multiplier of class E
            DB 11110001B    ;multiplier of class F
            DB 00000001B    ;multiplier of class G
            DB 00000001B    ;multiplier of class H
               
            
BONUS       DB 00000000B
            DB 00000010B
            DB 00000010B
            DB 00000001B
            
JT  DW  FILLFOM, DISPLAY, RESET
    
BUFFER      DB  5 DUP(0)
BIGBUFFER   DB  8 DUP(0)      

MENUmsg     DB  'User Menu:$'
MENU1msg    DB  ' [1] Fill the array FOM$'
MENU2msg    DB  ' [2] Compute and display new parameters for all members$'
MENU3msg    DB  ' [3] Reset all databases$'
MENU0msg    DB  ' [0] Exit the program$'
FILL1       DB  'Insert member number: $'
FILL2       DB  'Insert flight code: $'
FILL3       DB  'Insert class [A-H]: $'
FILL4       DB  'Insert miles flown: $' 
FILLend     DB  'Next FOM entry? [y/n] $'
STATUSmsg   DB  'Status change: new status of member $'
ISmsg       DB  ' is $'  
NOCHANGEmsg DB  'No status change: status of member $'   
MILESmsg    DB  'Total accumulated miles: $'
RESETmsg    DB  'Reset done$'   
    .code
    .startup
    
userMenu:
    call emptyRow 
    call emptyRow
    mov ah, 9
    mov dx, offset MENUmsg
    int 21h     
    call emptyRow            
    
    mov ah, 9
    mov dx, offset MENU1msg
    int 21h
    call emptyRow
    
    mov ah, 9
    mov dx, offset MENU2msg
    int 21h             
    call emptyRow  
    
    mov ah, 9
    mov dx, offset MENU3msg
    int 21h             
    call emptyRow  
    
    mov ah, 9
    mov dx, offset MENU0msg
    int 21h             
    call emptyRow
    
    mov ah, 1
    int 21h
    sub al, '0'
    cmp al, 0
    je exit
    mov bl, al
    xor bh, bh
    sub bx, 1
    add bx, bx
    jmp word ptr JT[bx] 
    
    
FILLFOM: 
    xor si, si
fillLoop: 
    call emptyRow
    mov ah, 9
    mov dx, offset FILL1
    int 21h             
    mov ax, 3   ;number of digits to be read
    push ax
    call readDecimal
    pop ax      ;ax contains the read number      
    mov FOM[si], al     ;member number
    
    call emptyRow
    mov ah, 9
    mov dx, offset FILL2
    int 21h             
    mov ax, 3   ;max number of digits to be read
    push ax
    call readDecimal
    pop ax      ;ax contains the read number      
    mov FOM[si+1], al   ;flight code
    
    call emptyRow
    mov ah, 9
    mov dx, offset FILL3
    int 21h             
    mov ah, 1
    int 21h
    sub al, 'A'
    mov FOM[si+2], al   ;class
    
    call emptyRow
    mov ah, 9
    mov dx, offset FILL4
    int 21h             
    mov ax, 5   ;max number of digits to be read
    push ax
    call readDecimal
    pop ax      ;ax contains the read number      
    mov FOM[si+3], ah   ;miles flown
    mov FOM[si+4], al
    
    call emptyRow
    mov ah, 9
    mov dx, offset FILLend
    int 21h             
    mov ah, 1
    int 21h
    cmp al, 'n'
    je  userMenu
    
    add si, 5    ;assume correct input: if no 'n', then 'y'
    jmp fillLoop
     
     
DISPLAY: 
    xor si, si
computeLoop: 
    xor ah, ah
    mov al, FOM[si]     ;if member number = 0 => empty entry
    cmp al, 0
    je statusCheckAndPrint
    mov al, FOM[si+2]   ;class to be used as index in MULTIPLIER array
    xor di, di
    xor ah, ah
    add di, ax
    mov cl, MULTIPLIER[di] 
    and cl, 00001111B   ;how many shifts
    cmp cl, 0
    je checkAdd
    mov dh, FOM[si+3]   ;flown miles
    mov dl, FOM[si+4]
    mov al, MULTIPLIER[di]
    test al, 00110000B
    jz multiply
    shr dx, cl          ;otherwise divide
    jmp checkAdd
multiply:
    shl dx, cl

checkAdd:
    test al, 11000000B
    jz computeBonus
    mov ch, FOM[si+3]
    mov cl, FOM[si+4]
    add dx, cx          ;<DX> = M * X

computeBonus:    
    mov al, FOM[si]     ;member number to be used as index in FFM array to retrieve the status
    sub al, 200
    xor di, di
    xor ah, ah
    push dx
    xor dx, dx
    mov bx, 4
    mul bx
    add di, ax
    pop dx
    mov al, FFM[di]     ;status used as index in BONUS array 
    xor ah, ah
    cmp ax, 0
    je totalMiles
    xor di, di
    add di, ax
    mov cl, BONUS[di]
    mov ah, FOM[si+3]
    mov al, FOM[si+4]
    shr ax, cl          ;<AX> = M * B

totalMiles:    
    add ax, dx          
    
    mov cx, ax          ;<CX> = M * X + M * B
    mov al, FOM[si]     ;member number to be used as index in FFM array
    sub al, 200
    xor di, di
    xor ah, ah
    xor dx, dx
    mov bx, 4
    mul bx
    add di, ax
    add FFM[di+3], cl
    adc FFM[di+2], ch
    adc FFM[di+1], 0    ;miles updated
    
    add si, 5           ;next entry in FOM
    jmp computeLoop

statusCheckAndPrint:
    xor si, si
    xor di, di
checkAndPrint:
    mov dl, FFM[si+1]
    mov ah, FFM[si+2]
    mov al, FFM[si+3]
    cmp dl, 0           ;find new status
    jne status3
    cmp ax, 40000       
    jae status3
    cmp ax, 10000
    jae status2
    cmp ax, 3000
    jae status1
    mov ch, 0           ;otherwise status 0
    jmp compareStatus
status3:
    mov ch, 3
    jmp compareStatus
status2:
    mov ch, 2
    jmp compareStatus
status1:
    mov ch, 1
    
compareStatus:  
    call emptyRow
    call emptyRow
    mov cl, FFM[si]
    cmp ch, cl
    je noChange
    mov FFM[si], ch     ;update status and print new status  
    mov ah, 9
    mov dx, offset STATUSmsg
    int 21h
    lea ax, BUFFER
    push ax
    mov ax, di
    add ax, 200
    push ax
    call printDecimal
    pop ax
    mov ah, 9
    mov dx, offset ISmsg
    int 21h
    mov al, ch
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    pop ax
    jmp printMiles
noChange:
    mov ah, 9
    mov dx, offset NOCHANGEmsg
    int 21h
    lea ax, BUFFER
    push ax
    mov ax, di
    add ax, 200
    push ax
    call printDecimal
    pop ax
    mov ah, 9
    mov dx, offset ISmsg
    int 21h
    mov al, ch
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    pop ax
printMiles:
    call emptyRow    
    mov ah, 9
    mov dx, offset MILESmsg
    int 21h  
    xor dh, dh
    mov dl, FFM[si+1]    
    mov ah, FFM[si+2]
    mov al, FFM[si+3] 
    lea cx, BIGBUFFER
    push cx
    push dx
    push ax
    call printBigDecimal
    pop ax
    pop dx
    pop cx
    
    add si, 4
    add di, 1
    cmp di, 4
    jne checkAndPrint
    
    jmp userMenu
    
             
RESET: 
    xor si, si
    mov cx, 150
resetLoop:   
    mov FOM[si], 0
    inc si
    loop resetLoop
    
    mov FFM[0], 0
    mov FFM[1], 0
    mov FFM[2], 0
    mov FFM[3], 01100100B
    
    mov FFM[4], 00000010B   
    mov FFM[5], 0
    mov FFM[6], 00100111B
    mov FFM[7], 00010101B
    
    mov FFM[8], 0
    mov FFM[9], 0
    mov FFM[10], 0
    mov FFM[11], 0
    
    mov FFM[12], 00000001B   
    mov FFM[13], 0
    mov FFM[14], 00001110B
    mov FFM[15], 11011000B
                
    call emptyRow
    mov ah, 9
    mov dx, offset RESETmsg
    int 21h
    
    jmp userMenu            

exit:    
    .exit
    
;Procedure to read a decimal number up to 65'536 (16 bits)
readDecimal proc
    push bp
    mov bp, sp
    
    push ax
    push cx
    push dx
    
    mov cx, [bp+4]  ;max number of digits to be read
    mov dx, 0
readLoop:
    mov ah, 1
    int 21h
    cmp al, 13
    je endReadLoop
    
    sub al, '0'
    mov ch, al
    
    mov ax, dx
    mov dx, 10
    mul dx
    mov dx, ax
    
    add dl, ch
    adc dh, 0
    
    xor ch, ch
    loop readLoop

endReadLoop:    
    mov [bp+4], dx
          
    pop dx
    pop cx
    pop ax
    pop bp
    ret
readDecimal endp        
    
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


;Procedure to print BIG decimal numbers
printBigDecimal proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push di
    push bx
    push cx
    
    mov di, [bp+8]      ;buffer address
    
    mov dx, [bp+6]      ;number (high part)
    mov ax, [bp+4]      ;number (low part)
    mov bx, 1000
    div bx
    cmp ax, 0
    je printSmall
    
    mov cx, 3           ;convert remainder (low part)
    mov ax, dx
convLow:                
    xor dx, dx
    mov bx, 10
loopDivLow:
    div bx
    add dl, '0'         ;remainder: binary -> ascii
    mov [di], dl
    inc di
    xor dx, dx
    loop loopDivLow
    
    mov dx, [bp+6]      
    mov ax, [bp+4]
    mov bx, 1000
    div bx    
             
convHigh:               ;convert result (high part)
    xor dx, dx
    mov bx, 10
loopDivHigh:
    div bx
    add dl, '0'         ;remainder: binary -> ascii
    mov [di], dl
    inc di
    xor dx, dx
    cmp ax, 0
    jne loopDivHigh 
    
loopPrintBig:
    dec di
    mov dl, [di]
    mov ah, 2
    int 21h
    cmp di, [bp+8]
    jne loopPrintBig 
    jmp exitPrintBigNumber

printSmall:
    push di
    push dx
    call printDecimal
    pop dx 
    pop di
    
exitPrintBigNumber:    
    pop cx
    pop bx
    pop di
    pop dx
    pop ax
    
    pop bp
    ret
printBigDecimal endp

    
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
        
    end