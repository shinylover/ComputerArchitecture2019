N EQU 150
    .model small
    .stack
    .data
    
EXPENSES    DB  10001010B
            DB  00010000B
            DB  00101110B
            DB  10001111B
            DB  00001001B
            DB  00110010B
            DB  10010100B
            DB  11101011B
            DB  01100001B
            DB  10011001B
            DB  10000000B
            DB  00100000B
            DB  00000000B   ;last entry empty (loop termination)
            DB  00000000B
            DB  00000000B
              
EXCHANGE    DB  00000001B   ;no day
            DB  00000001B
            DB  00000001B
            DB  00000000B   ;day 1
            DB  00000000B
            DB  00000000B
            DB  01110001B   ;day 2
            DB  01000000B
            DB  10000000B
            DB  00001000B   ;day 3
            DB  00000010B
            DB  10000000B
            DB  00000000B   ;day 4
            DB  00000000B
            DB  00000000B
            DB  01000000B   ;day 5
            DB  10000000B
            DB  11100000B
            DB  11000000B   ;day 6
            DB  11000000B
            DB  11100000B

CONVERTED   DB  21 DUP(0)

BUFFER      DB  8  DUP(0)
            
    .code
    .startup 
    
    xor si, si
convertLoop:
    mov al, EXPENSES[si]
    test al, 10000000B          ;check validity
    jz endofConversion
    and al, 00000011B
    cmp al, 00000011B           ;check if EUR
    je eurNoConversion
    mov al, EXPENSES[si]
    and al, 01111100B           ;keep date (index for EXCHANGE array)
    mov CONVERTED[si], al       ;store the date
    or CONVERTED[si], 10000011B  ;set v = 1 and cc = eur
    shr al, 1
    shr al, 1
    xor ah, ah
    mov cl, 3                   ;because each entry of EXCHANGE is on 3 bytes
    mul cl                      ;<AX> = base index of EXCHANGE entry
    xor di, di
    add di, ax
    mov al, EXPENSES[si]
    and al, 00000011B           ;select the correct exchange rate            
    add di, ax                                                               
    mov cl, EXCHANGE[di]
    xor ch, ch
    mov ah, EXPENSES[si+1]      ;integer part
    mov al, EXPENSES[si+2]      ;fractional part
    mul cx
    mov CONVERTED[si+1], dl     ;integer part
    mov CONVERTED[si+2], ah     ;fractional part
    jmp nextConversion
eurNoConversion:
    mov al, EXPENSES[si]
    mov CONVERTED[si], al
    mov al, EXPENSES[si+1]
    mov CONVERTED[si+1], al
    mov al, EXPENSES[si+2]
    mov CONVERTED[si+2], al  
nextConversion:
    ;first print to check: 
    call emptyRow
    lea ax, BUFFER
    push ax
    mov al, EXPENSES[si]
    and al, 01111100B
    mov cl, 2
    shr al, cl
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov al, EXPENSES[si+1]  ;integer part
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    mov al, EXPENSES[si+2]  ;fractional part
    xor ah, ah
    push ax
    call printFractional
    pop ax
    mov ah, 2
    mov dl, ' '
    int 21h
    mov dl, '-'
    int 21h
    mov dl, '>'
    int 21h
    mov dl, ' '
    int 21h
    mov al, CONVERTED[si]
    and al, 01111100B
    mov cl, 2
    shr al, cl
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov al, CONVERTED[si+1]  ;integer part
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    mov ah, 2
    mov dl, '.'
    int 21h
    mov al, CONVERTED[si+2]  ;fractional part
    xor ah, ah
    push ax
    call printFractional
    pop ax
    pop ax
    
    add si, 3
    jmp convertLoop

endOfConversion:
     
        
    .exit 
    

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
    push ax
    call printDecimalF
    pop ax 
    
    pop ax
    pop cx
    pop dx
    pop ax
    pop bp
    
    ret
printFractional endp
    
;Procedure to insert a empty row
emptyRow proc
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h 
    
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

    end