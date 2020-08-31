    .model small
    .stack
    .data
COEFF_A DB 0
COEFF_B DB 0
COEFF_C DB 0
COEFF_D DB 0
COEFF_E DB 0
COEFF_F DB 0

DET     DB 0
DET_X   DB 0
DET_Y   DB 0 

X_INT   DB 0
Y_INT   DB 0   

SQ_ERR  DW 0
TMP     DW 0 
BUFFER  DB 5 DUP(0)

MENU0   DB '[0] Exit $'                           
MENU1   DB '[1] Insert coefficients $' 
MENU2   DB '[2] Solve system $' 
MENU3   DB '[3] Compute overall squared error $'   
 
INSERTa DB 'Insert coefficient a: $'
INSERTb DB 'Insert coefficient b: $'
INSERTc DB 'Insert coefficient c: $'
INSERTd DB 'Insert coefficient d: $'
INSERTe DB 'Insert coefficient e: $'
INSERTf DB 'Insert coefficient f: $' 

SOLmsg  DB 'Solution: $'
Xmsg    DB 'x_int = $'
Ymsg    DB ', y_int = $'

IMPmsg  DB 'Impossible system $'
UNDmsg  DB 'Undetermined system $'   

SEmsg   DB 'Squared Error = $'

JT DW L1, L2, L3  

    .code
    .startup

userMenu:
    mov ah, 9
    mov dx, offset MENU0
    int 21h     
    call emptyRow            
    
    mov ah, 9
    mov dx, offset MENU1
    int 21h
    call emptyRow
    
    mov ah, 9
    mov dx, offset MENU2
    int 21h             
    call emptyRow
    
    mov ah, 9
    mov dx, offset MENU3
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
    

L1:                         ;Insert coefficients
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTa 
    int 21h      
    lea ax, COEFF_A 
    push ax
    call insertCoefficient
    pop ax 
    
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTb 
    int 21h      
    lea ax, COEFF_B 
    push ax
    call insertCoefficient
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTc 
    int 21h      
    lea ax, COEFF_C 
    push ax
    call insertCoefficient
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTd 
    int 21h      
    lea ax, COEFF_D 
    push ax
    call insertCoefficient
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTe 
    int 21h      
    lea ax, COEFF_E 
    push ax
    call insertCoefficient
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTf 
    int 21h      
    lea ax, COEFF_F 
    push ax
    call insertCoefficient
    pop ax
    
    call emptyRow
    call emptyRow
    jmp userMenu   
     
       
L2:                         ;Solve the system     
   ;Compute DET = a*e - b*d
   mov al, COEFF_A
   mov cl, COEFF_E
   imul cl                  ;al = a*e
   mov DET, al
   mov al, COEFF_B
   mov cl, COEFF_D
   imul cl                  ;al = b*d
   sub DET, al              ;DET = a*e - b*d
   
   ;Compute DET_X = c*e - b*f  
   mov al, COEFF_C
   mov cl, COEFF_E
   imul cl                  ;al = c*e
   mov DET_X, al
   mov al, COEFF_B
   mov cl, COEFF_F
   imul cl                  ;al = b*f
   sub DET_X, al            ;DET_X = c*e - b*f   
   
   ;Compute DET_Y = a*f - c*d  
   mov al, COEFF_A
   mov cl, COEFF_F
   imul cl                  ;al = a*f
   mov DET_Y, al
   mov al, COEFF_C
   mov cl, COEFF_D
   imul cl                  ;al = c*d
   sub DET_Y, al            ;DET_Y = a*f - c*d  
                                
   cmp DET, 0
   je verifyType
   
   call emptyRow            ;det != 0 => compute x and y
   mov ah, 9
   mov dx, offset SOLmsg 
   int 21h 
   mov al, DET_X            ;compute x
   cbw
   mov cl, DET
   idiv cl
   mov X_INT, al
   mov ah, 9
   mov dx, offset Xmsg 
   int 21h   
   mov ah, 2
   mov dl, X_INT
   add dl, '0'
   int 21h  
   mov al, DET_Y            ;compute y
   cbw
   mov cl, DET
   idiv cl
   mov Y_INT, al
   mov ah, 9
   mov dx, offset Ymsg 
   int 21h   
   mov ah, 2
   mov dl, Y_INT
   add dl, '0'
   int 21h 
    
   call emptyRow
   call emptyRow
   jmp userMenu                   
   
verifyType: 
   call emptyRow
   cmp DET_X, 0
   je undetermined
   mov ah, 9                ;impossible
   mov dx, offset IMPmsg 
   int 21h                           
   call emptyRow
   call emptyRow
   jmp userMenu 
undetermined:
   mov ah, 9                ;undetermined
   mov dx, offset UNDmsg 
   int 21h                           
   call emptyRow
   call emptyRow
   jmp userMenu  
   
                            
                            
L3:                         ;Compute overall squared error 
   mov al, COEFF_A
   mov cl, X_INT
   imul cl                  ;ax = a*x_int
   mov SQ_ERR, ax    
   mov al, COEFF_B
   mov ch, Y_INT
   imul ch                  ;ax = b*y_int
   add SQ_ERR, ax           ;a*x_int + b*y_int
   mov al, COEFF_C
   cbw
   sub SQ_ERR, ax           ;a*x_int + b*y_int - c
   mov ax, SQ_ERR
   push cx
   mov cx, SQ_ERR
   imul cx
   mov SQ_ERR, ax
   pop cx
   mov al, COEFF_D
   imul cl
   mov TMP, ax
   mov al, COEFF_E
   imul ch
   add TMP, ax
   mov al, COEFF_F
   cbw
   sub TMP, ax
   mov ax, TMP
   mov cx, TMP
   imul cx
   add SQ_ERR, ax 
   
   call emptyRow 
   mov ah, 9                
   mov dx, offset SEmsg 
   int 21h                           
   
   
   mov ax, SQ_ERR 
   lea cx, BUFFER
   push cx
   push ax       
   call printSE
   pop ax 
   pop cx
   
   call emptyRow
   jmp userMenu         
    
    
exit:            
    .exit    
    
    
;Procedure to insert a empty row
emptyRow proc
    mov ah, 2
    mov dl, 10
    int 21h
    mov dl, 13
    int 21h 
    
    ret                  
emptyRow endp  
  
;Procedure used to read a coefficient from standard input
insertCoefficient proc
    push bp
    mov bp, sp
    
    push si
    push ax
    
    mov si, [bp+4]
    
    mov ah, 01h
    int 21h
    cmp al, '-'
    je negativeNumber 
    sub al, '0'
    mov [si], al  
    jmp exit1
negativeNumber:
    int 21h 
    sub al, '0'
    neg al
    mov [si], al
    
exit1:    
    pop ax
    pop si
    
    pop bp
    ret
insertCoefficient endp     


;Procedure used to print the computed Squared Error
printSE proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push di
    push bx
    
    mov di, [bp+6]      ;buffer
    mov ax, [bp+4]      ;squared error value  
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
    
    call emptyRow
    
    pop bx
    pop di
    pop dx
    pop ax
    
    pop bp
    call emptyRow
    ret
printSE endp

    end