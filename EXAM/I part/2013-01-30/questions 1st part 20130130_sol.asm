N   EQU   142
    .model small
    .stack
    .data  
    
JT      DW  ITEM1, ITEM2, ITEM3, ITEM4, ITEM5, ITEM6

LAMBDA  DB ?            ; is the seed, with 0<= LAMBDA < 30 received in input by the program 

CLEAR   DB N DUP (?)    ; is the array of the N characters (N from 5 to 140) to be encrypted in its full length 
ENC_E   DB N DUP (?)    ; is the array of the encrypted text, according to ALGO_E 
ENC_D   DB N DUP (?)    ; is the array of the encrypted text, according to ALGO_D 
DEC_E   DB N DUP (?)    ; is the array of the decrypted text, according to ALGO_E and array ENC_E 
DEC_D   DB N DUP (?)    ; is the array of the decrypted text, according to ALGO_D and array ENC_D 

I       DB  ?           ; position of a character either in the encrypted or decrypted array 
DX_I    DB  ?     
LEN     DB  0

BUFFER  DB  8   DUP(0)

MENUmsg     DB  'Menu: $'
MENU1msg    DB  '  [1] Item 1: computes ENC_E$'
MENU2msg    DB  '  [2] Item 2: computes DEC_E$'
MENU3msg    DB  '  [3] Item 3: computes DX_I (algo E)$'
MENU4msg    DB  '  [4] Item 4: computes ENC_D$'
MENU5msg    DB  '  [5] Item 5: computes DEC_D$'
MENU6msg    DB  '  [6] Item 6: computes DX_I (algo D)$'
MENU0msg    DB  '  [0] Exit the program$' 

LAMBDAmsg   DB  'Insert value of lambda: $'
CLEARmsg    DB  'Insert clear message by using chars [A-Z]: $'
ENCmsg      DB  'Encrypted message: $'
ENCINmsg    DB  'Insert encrypted message (as numbers): $' 
ANOTHER     DB  'Insert another number [y/n]? $'
NUM         DB  'Insert number: $'
DECmsg      DB  'Decrypted message: $'
POSmsg      DB  'Insert position I: $'
DECCHAR     DB  'Decrypted char: $'  
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
    mov dx, offset MENU4msg
    int 21h
    call emptyRow
    
    mov ah, 9
    mov dx, offset MENU5msg
    int 21h             
    call emptyRow  
    
    mov ah, 9
    mov dx, offset MENU6msg
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
     
     
ITEM1:                  ;compute ENC_E
    call emptyRow
    mov ah, 9
    mov dx, offset LAMBDAmsg
    int 21h
    mov ax, 2           ;max number of digits to be read
    push ax
    call readDecimal
    pop ax              ;contains the value of lambda
    mov LAMBDA, al
    
    call emptyRow
    xor ch, ch
    mov cl, 0           ;used to compute the lenght of the input message
    mov ah, 9
    mov dx, offset CLEARmsg
    int 21h
    xor si, si
readLoop1:
    mov ah, 1
    int 21h
    cmp al, 13
    je enc_E_wrap
    mov CLEAR[si], al
    add cl, 1
    add si, 1
    jmp readLoop1
    
enc_E_wrap:
    mov LEN, cl
    xor si, si
    mov dl, LAMBDA
enc_E_loop:
    xor ah, ah
    mov al, CLEAR[si]
    add al, dl
    push cx
    mov cl, 7
    ror al, cl
    shr al, 1
    pop cx
    mov ENC_E[si], al
    mov dl, al
    inc si
    loop enc_E_loop
    
    call emptyRow           ;print encrypted message
    mov ah, 9
    mov dx, offset ENCmsg
    int 21h
    lea ax, BUFFER     
    push ax
    xor ah, ah
    mov al, LEN
    push ax
    lea ax, ENC_E
    push ax
    call printArray
    pop ax
    pop ax
    pop ax 
    call emptyRow
    call emptyRow
    
    jmp userMenu      
     
ITEM2:
    call emptyRow
    mov ah, 9
    mov dx, offset LAMBDAmsg
    int 21h
    mov ax, 2           ;max number of digits to be read
    push ax
    call readDecimal
    pop ax              ;contains the value of lambda
    mov LAMBDA, al
    
    call emptyRow
    xor ch, ch
    mov cl, 0           ;used to compute the lenght of the input message
    mov ah, 9
    mov dx, offset ENCINmsg
    int 21h
    xor si, si
readLoop2:
    call emptyRow
    mov ah, 9
    mov dx, offset NUM
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov ENC_E[si], al
    add cl, 1
    add si, 1
anotherNumber:
    call emptyRow
    mov ah, 9
    mov dx, offset ANOTHER
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je readLoop2
    cmp al, 'n'
    je dec_E_wrap
    jmp anotherNumber
    
    
dec_E_wrap:
    mov LEN, cl
    xor si, si
    mov dl, LAMBDA
dec_E_loop:
    xor ah, ah
    mov al, ENC_E[si]
    sub al, dl
    cmp al, 0
    jge updateDec_E
    add al, 128
updateDec_E:
    mov DEC_E[si], al
    mov dl, ENC_E[si]
    inc si
    loop dec_E_loop
    
    call emptyRow           ;print encrypted message
    mov ah, 9
    mov dx, offset DECmsg
    int 21h
    xor ah, ah
    mov al, LEN
    push ax
    lea ax, DEC_E
    push ax
    call printArrayChars
    pop ax
    pop ax
    
    call emptyRow
    call emptyRow
    jmp userMenu  
         
ITEM3:
    call emptyRow
    mov ah, 9
    mov dx, offset LAMBDAmsg
    int 21h
    mov ax, 2           ;max number of digits to be read
    push ax
    call readDecimal
    pop ax              ;contains the value of lambda
    mov LAMBDA, al
    
    call emptyRow
    xor ch, ch
    mov cl, 0           ;used to compute the lenght of the input message
    mov ah, 9
    mov dx, offset ENCINmsg
    int 21h
    xor si, si
readLoop3:
    call emptyRow
    mov ah, 9
    mov dx, offset NUM
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov ENC_E[si], al
    add cl, 1
    add si, 1
anotherNumber3:
    call emptyRow
    mov ah, 9
    mov dx, offset ANOTHER
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je readLoop3
    cmp al, 'n'
    je insertPosition3
    jmp anotherNumber3

insertPosition3:    
    call emptyRow
    mov ah, 9
    mov dx, offset POSmsg
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov I, al
    
    cmp al, 0
    je decryptWithLambdaE
    xor di, di
    xor ah, ah
    add di, ax  ;position I
    sub di, 1   ;position I - 1
    mov dl, ENC_E[di]
    jmp decryptOneCharE
decryptWithLambdaE:
    mov dl, LAMBDA
decryptOneCharE:
    xor si, si
    add si, ax  ;position I
    mov al, ENC_E[si]
    sub al, dl
    cmp al, 0
    jge update_DX_Ie
    add al, 128
update_DX_Ie:
    mov DX_I, al
    
    call emptyRow
    mov ah, 9
    mov dx, offset DECCHAR
    int 21h
    mov dl, DX_I
    mov ah, 2
    int 21h    
    
    call emptyRow
    call emptyRow
    jmp userMenu  
     
ITEM4:
    call emptyRow
    mov ah, 9
    mov dx, offset LAMBDAmsg
    int 21h
    mov ax, 2           ;max number of digits to be read
    push ax
    call readDecimal
    pop ax              ;contains the value of lambda
    mov LAMBDA, al
    
    call emptyRow
    xor ch, ch
    mov cl, 0           ;used to compute the lenght of the input message
    mov ah, 9
    mov dx, offset CLEARmsg
    int 21h
    xor si, si
readLoop4:
    mov ah, 1
    int 21h
    cmp al, 13
    je enc_D_wrap
    mov CLEAR[si], al
    add cl, 1
    add si, 1
    jmp readLoop4
    
enc_D_wrap:
    mov LEN, cl
    xor si, si
    mov dl, LAMBDA
enc_D_loop:
    xor ah, ah
    mov al, CLEAR[si]
    add al, dl
    push cx
    mov cl, 7
    ror al, cl
    shr al, 1
    pop cx
    mov ENC_D[si], al
    add dl, al
    inc si
    loop enc_D_loop
    
    call emptyRow           ;print encrypted message
    mov ah, 9
    mov dx, offset ENCmsg
    int 21h
    lea ax, BUFFER     
    push ax
    xor ah, ah
    mov al, LEN
    push ax
    lea ax, ENC_D
    push ax
    call printArray
    pop ax
    pop ax
    pop ax 
    call emptyRow
    call emptyRow
    
    jmp userMenu        
         
ITEM5:
    call emptyRow
    mov ah, 9
    mov dx, offset LAMBDAmsg
    int 21h
    mov ax, 2           ;max number of digits to be read
    push ax
    call readDecimal
    pop ax              ;contains the value of lambda
    mov LAMBDA, al
    
    call emptyRow
    xor ch, ch
    mov cl, 0           ;used to compute the lenght of the input message
    mov ah, 9
    mov dx, offset ENCINmsg
    int 21h
    xor si, si
readLoop5:
    call emptyRow
    mov ah, 9
    mov dx, offset NUM
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov ENC_D[si], al
    add cl, 1
    add si, 1
anotherNumber5:
    call emptyRow
    mov ah, 9
    mov dx, offset ANOTHER
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je readLoop5
    cmp al, 'n'
    je dec_D_wrap
    jmp anotherNumber5
    
    
dec_D_wrap:
    mov LEN, cl
    xor si, si
    mov dl, LAMBDA
dec_D_loop:
    xor ah, ah
    mov al, ENC_D[si]
    sub al, dl
    add dl, ENC_D[si]
    cmp al, 0
    jge update_dec_D
    add al, 128
update_dec_D:
    mov DEC_D[si], al
    add si, 1
    loop dec_D_loop
    
    call emptyRow           ;print encrypted message
    mov ah, 9
    mov dx, offset DECmsg
    int 21h
    xor ah, ah
    mov al, LEN
    push ax
    lea ax, DEC_D
    push ax
    call printArrayChars
    pop ax
    pop ax
    
    call emptyRow
    call emptyRow
    jmp userMenu   
         
ITEM6: 
    call emptyRow
    mov ah, 9
    mov dx, offset LAMBDAmsg
    int 21h
    mov ax, 2           ;max number of digits to be read
    push ax
    call readDecimal
    pop ax              ;contains the value of lambda
    mov LAMBDA, al
    
    call emptyRow
    xor ch, ch
    mov cl, 0           ;used to compute the lenght of the input message
    mov ah, 9
    mov dx, offset ENCINmsg
    int 21h
    xor si, si
readLoop6:
    call emptyRow
    mov ah, 9
    mov dx, offset NUM
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov ENC_D[si], al
    add cl, 1
    add si, 1
anotherNumber6:
    call emptyRow
    mov ah, 9
    mov dx, offset ANOTHER
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je readLoop6
    cmp al, 'n'
    je insertPosition6
    jmp anotherNumber6

insertPosition6:    
    call emptyRow
    mov ah, 9
    mov dx, offset POSmsg
    int 21h
    mov ax, 3
    push ax
    call readDecimal
    pop ax
    mov I, al
    
    mov dl, LAMBDA
    cmp al, 0
    je decryptOneCharD
    xor si, si
    mov cl, I
    xor ch, ch
addLoop:
    add dl, ENC_D[si]
    add si, 1
    loop addLoop
decryptOneCharD:
    xor ah, ah
    xor di, di       
    add di, ax       ;position I
    mov al, ENC_D[di]           
    sub al, dl
    cmp al, 0
    jge saveDecryptedCharD
    add al, 128
saveDecryptedCharD:
    mov DX_I, al
    
    call emptyRow
    mov ah, 9
    mov dx, offset DECCHAR
    int 21h
    mov dl, DX_I
    mov ah, 2
    int 21h    
    
    call emptyRow
    call emptyRow
    jmp userMenu  
    
exit:        
    .exit


;Procedure to print the decrypted array (as chars)
printArrayChars proc
    push bp
    mov bp, sp
    
    push ax
    push cx
    push dx
    push si
    
    mov si, [bp+4]  ;array's address
    mov cx, [bp+6]  ;length of the array
    
printCharsLoop:
    mov ah, 2
    mov dl, [si]
    int 21h
    add si, 1
    loop printCharsLoop
    
    pop si
    pop dx
    pop cx
    pop ax
    
    pop bp
    ret
printArrayChars endp

;Procedure to print the encrypted array (as numbers)
printArray proc
    push bp
    mov bp, sp
    
    push ax
    push cx
    push dx
    push si
    
    mov cx, [bp+6]  ;length of the array
    mov si, [bp+4]  ;array's address
printArrayLoop:
    mov ax, [bp+8]  ;buffer address
    push ax
    xor ah, ah
    mov al, [si]
    push ax
    call printDecimal
    pop ax
    pop ax
    mov ah, 2
    mov dl, ' '
    int 21h
    add si, 1
    loop printArrayLoop
    
    
    pop si
    pop dx
    pop cx
    pop ax
    
    pop bp
    ret
printArray endp

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

    end