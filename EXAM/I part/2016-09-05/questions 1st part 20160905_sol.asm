    .model small
    .stack
    .data

XA      DB  ?
XB      DB  ?
XC      DB  ?
YC      DB  ?
AREA    DW  ?

BUFFER  DB 5 DUP(0) 

INPUTmsg    DB  'Insert coordinates:$'
XAmsg       DB  'Xa = $'
XBmsg       DB  'Xb = $'
XCmsg       DB  'Xc = $'
YCmsg       DB  'Yc = $' 
NEWmsg      DB  'Compute new area [y/n]?  $' 
AREAmsg     DB  'AREA = $'                                           
                                           

    .code
    .startup
    
areaProgram:                                                   
    call emptyRow
    call emptyRow
    mov ah, 9
    mov dx, offset INPUTmsg
    int 21h     
   
    call emptyRow
    mov ah, 9
    mov dx, offset XAmsg
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov XA, al
    
    call emptyRow
    mov ah, 9
    mov dx, offset XBmsg
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov XB, al
    
    call emptyRow
    mov ah, 9
    mov dx, offset XCmsg
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov XC, al
    
    call emptyRow
    mov ah, 9
    mov dx, offset YCmsg
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov YC, al
    
    mov al, XB
    mov cl, 5
    mul cl          ;<AX> = 5 * Xb
    mov dx, ax      ;maintain this result
    
    mov al, XA
    mul cl          ;<AX> = 5 * Xa
    
    sub dx, ax      ;<DX> = 5 * Xb - 5 * Xa
    cmp dx, 0
    jge computeSecondPart
    neg dx
    
computeSecondPart:  ;<DX> = |5 * Xb - 5 * Xa|  
    push dx         ;maintain this result
    
    mov al, YC
    mov cl, 4
    mul cl          ;<AX> = 4 * Yc
    mov dx, ax      ;maintain this result
    
    mov al, XC
    mov cl, 3
    mul cl          ;<AX> = 3 * Xc
    
    sub dx, ax      ;<DX> = 4 * Yc - 3 * Xc
    cmp dx, 0
    jge computeArea ;if 4 * Yc - 3 * Xc >= 0 => ok
    neg dx          ;otherwise invert the sign

computeArea:        ;at this point, <DX> = |4 * Yc - 3 * Xc|
    mov cx, dx      ;<CX> = |4 * Yc - 3 * Xc|  
    pop dx
    mov ax, dx      ;<AX> = 5 * Xb - 5 * Xa
    mul cx          ;<DX><AX> = |5 * Xb - 5 * Xa| * |4 * Yc - 3 * Xc|
    mov cx, 40
    div cx
    mov area, ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset AREAmsg
    int 21h
    lea ax, BUFFER
    push ax
    mov ax, AREA
    push ax
    call printDecimal
    pop ax 
    pop ax

newArea:    
    call emptyRow
    call emptyRow
    mov ah, 9
    mov dx, offset NEWmsg
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je areaProgram
    cmp al, 'n'
    je endOfTheProgram
    jmp newArea
        
endOfTheProgram:
    
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

    end