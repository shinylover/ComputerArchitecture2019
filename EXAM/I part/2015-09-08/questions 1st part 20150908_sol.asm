    .model small
    .stack
    .data
    
POLIBOW DB  57 DUP(0)
EXTRA   DB  0

MIN     DB  2 DUP(0)
MAX     DB  2 DUP(0)

BUFFER  DB  5 DUP(0) 

FRAMEmsg    DB  'Frame #$'
ROLL1       DB  '  First Roll: $'
ROLL2       DB  '  Second Roll: $' 
EXTRAROLL   DB  '  Extra Roll: $' 
EXTRAmsg    DB  ' ** extra = $'
Fpoints     DB  'frame points = $'
Tpoints     DB  'total points = $'

    .code
    .startup  
    
    mov cx, 0
    xor si, si
game:
    add cx, 1
    mov POLIBOW[si], cl
    mov ah, 9
    mov dx, offset FRAMEmsg
    int 21h
    lea ax, BUFFER
    push ax
    push cx
    call printDecimal
    pop cx
    pop ax
    mov ah, 2
    mov dl, ':'
    int 21h

roll1Step:    
    call emptyRow
    mov ah, 9
    mov dx, offset ROLL1
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    cmp al, 8
    jg roll1Step
    mov POLIBOW[si+1], al
	mov dl, POLIBOW[si+5]
	add dl, al
	mov POLIBOW[si+5], dl
    mov dl, POLIBOW[si+6]
	add dl, al
	mov POLIBOW[si+6], dl
    cmp al, 8
    je strikeFrame

roll2Step:    
    call emptyRow
    mov ah, 9
    mov dx, offset ROLL2
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    mov dl, POLIBOW[si+1]
    add dl, al
    cmp dl, 8
    jg roll2Step
    mov POLIBOW[si+2], al
    mov dl, POLIBOW[si+5]
	add dl, al
	mov POLIBOW[si+5], dl
    mov dl, POLIBOW[si+6]
	add dl, al
	mov POLIBOW[si+6], dl
    cmp POLIBOW[si+5], 8
    je spareFrame
    jmp nextFrame

strikeFrame: 
    mov POLIBOW[si+2], 0
    mov POLIBOW[si+4], 2    ;to print 's' 
    mov POLIBOW[si+3], 2    ;to signal a no completed mark
    jmp nextFrame
    
spareFrame:
    mov POLIBOW[si+4], 1
    mov POLIBOW[si+3], 1

nextFrame:
    call emptyRow
    lea ax, BUFFER
    push ax   
    lea ax, POLIBOW
    push ax
    call printAll
    pop ax 
    pop ax
    call emptyRow
    mov al, POLIBOW[si+6]
	mov dl, POLIBOW[si+13]
	add dl, al
    mov POLIBOW[si+13], al          ;add the current total tot the total of the next frame
    add si, 7
    cmp cx, 7
    jne game
    
    ;last frame 
    add cx, 1
    mov POLIBOW[si], cl
    mov ah, 9
    mov dx, offset FRAMEmsg
    int 21h
    lea ax, BUFFER
    push ax
    push cx
    call printDecimal
    pop cx
    pop ax
    mov ah, 2
    mov dl, ':'
    int 21h

roll1StepLast:    
    call emptyRow
    mov ah, 9
    mov dx, offset ROLL1
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    cmp al, 8
    jg roll1StepLast
    mov POLIBOW[si+1], al 
    add POLIBOW[si+5], al
    add POLIBOW[si+6], al

roll2StepLast:    
    call emptyRow
    mov ah, 9
    mov dx, offset ROLL2
    int 21h
    mov ah, 1
    int 21h 
    sub al, '0'
    mov dl, POLIBOW[si+1]
    add dl, al
    cmp dl, 8
    jg roll2StepLast
    mov POLIBOW[si+2], al
    add POLIBOW[si+5], al
    add POLIBOW[si+6], al
    cmp POLIBOW[si+5], 8
    jne endOfGame
    
extraStep:
    call emptyRow
    mov ah, 9
    mov dx, offset EXTRAROLL
    int 21h 
    mov ah, 1
    int 21h 
    sub al, '0'
    cmp al, 8
    jg extraStep
    mov EXTRA, al         
    add POLIBOW[si+5], al
    add POLIBOW[si+6], al
    
        
endOfGame:
    call emptyRow
    lea ax, BUFFER
    push ax
    lea ax, POLIBOW
    push ax
    call printAll
    pop ax 
    pop ax
    
    mov ah, 9
    mov dx, offset EXTRAmsg
    int 21h
    lea ax, BUFFER
    push ax
    xor ah, ah
    mov al, EXTRA
    push ax
    call printDecimal
    pop ax
    pop ax
        
    .exit 
    
;Procedure to update incomplete marks and print the entries of POLIBOW     
printAll proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push si
    push di
    
    mov di, [bp+6]  ;address of BUFFER
    mov si, [bp+4]  ;address of POLIBOW variable   
    push di         ;for "printDecimal" procedure
printPolibow:
	mov al, 0
    cmp [si], al
    je endPrintPolibow
    mov ah, 9
    mov dx, offset FRAMEmsg
    int 21h
    mov al, [si]
    xor ah, ah
    push ax
    call printDecimal   ;print number of frame
    pop ax
    mov ah, 2
    mov dl, ':'
    int 21h
    mov dl, ' '
    int 21h
    mov al, [si+1]
    xor ah, ah
    push ax
    call printDecimal   ;print first roll
    pop ax
    call comma
    mov al, [si+2]
    cmp al, 0
    je printVoid
    xor ah, ah
    push ax
    call printDecimal   ;print second roll
    pop ax   
    jmp cnt
printVoid:
    mov ah, 2
    mov dl, '-'
    int 21h
cnt: 
    call comma    
    mov al, [si+4]
    cmp al, 1
    je printE           ;spare
    cmp al, 2
    je printS           ;strike
    mov ah, 2
    mov dl, 'n'         ;otherwise print nothing
    int 21h
    jmp continuePrintPolibow
printE:
    mov ah, 2
    mov dl, 'e'
    int 21h    
    jmp continuePrintPolibow
printS:
    mov ah, 2
    mov dl, 's'
    int 21h          
    
continuePrintPolibow:    
    call comma
    mov al, [si+3]
    cmp al, 2
    je strikeManagement
    cmp al, 1
    je spareManagement 
    cmp al, 3
    je secondNext
    jmp printPoints
    
strikeManagement:
    mov al, [si+7]
    cmp al, 0
    je printPoints      ;no next record
    mov al, [si+8]
    add [si+5], al
    add [si+6], al
    add [si+13], al
	mov al, 3
    mov [si+3], al      ;still one roll to complete the mark of the strike
    mov al, [si+9]
    cmp al, 0
    je secondNext       ;in the next frame there was a strike, so no mark for second roll          
    add [si+5], al
    add [si+6], al
    add [si+13], al 
	mov al, 0
    mov [si+3], al      ;completed mark
    jmp printPoints
    
secondNext:
    mov al, [si+14]
    cmp al, 0
    je printPoints
    mov al, [si+15]
    add [si+5], al
    add [si+6], al
    add [si+13], al
	mov al, 0
    mov [si+3], al
    jmp printPoints

spareManagement:
    mov al, [si+7] 
    cmp al, 0
    je printPoints
    mov al, [si+8]
    add [si+5], al
    add [si+6], al
    add [si+13], al
	mov al, 0
    mov [si+3], al
    
printPoints:
    mov ah, 9
    mov dx, offset Fpoints
    int 21h
    mov al, [si+5]
    xor ah, ah
    push ax
    call printDecimal
    pop ax  
	mov dl, 0
    cmp [si+3], dl
    je printTotal
	mov dl, 1
    cmp [si+3], dl
    je FprintOneQuestionMark 
	mov dl, 3
    cmp [si+3], dl
	je FprintOneQuestionMark
    call questionMark  ;otherwise print 2 question marks
FprintOneQuestionMark:
    call questionMark
    
printTotal: 
    call comma
    mov ah, 9
    mov dx, offset Tpoints
    int 21h
    mov al, [si+6]
    xor ah, ah
    push ax
    call printDecimal
    pop ax  
	mov dl, 0
    cmp [si+3], dl
    je nextPrintPolibow
	mov dl, 1
    cmp [si+3], dl
    je TprintOneQuestionMark
	mov dl, 3
    cmp [si+3], dl
    je TprintOneQuestionMark
    call questionMark  ;otherwise print 2 question marks
TprintOneQuestionMark:
    call questionMark

nextPrintPolibow: 
    call emptyRow
    add si, 7
    jmp printPolibow       
    
endPrintPolibow:
    call emptyRow        
        
    pop di       
    pop di      
    pop si
    pop dx
    pop ax
    pop bp
     
    ret
printAll endp 

;Procedure to insert a comma
comma proc
    mov ah, 2
    mov dl, ','
    int 21h
    mov dl, ' '
    int 21h 
    
    ret                  
comma endp

;Procedure to print one question mark
questionMark proc
    mov ah, 2
    mov dl, '?'
    int 21h
    
    ret                  
questionMark endp

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
    
    end