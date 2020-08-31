    .model small
    .stack
    .data
    
DECKS   DB  00111101B
        DB  00000100B
        DB  00111100B
        DB  00010010B
        DB  00011101B
        DB  00101011B
        DB  00000001B
        DB  00100001B
        DB  00001000B

STUDENTS    DB  0   ;number of students evaluated (to check max 30)        
        
TOKENS      DB  ?   ;number of tokens owned by the current student
SENIORITY   DB  ?   ;attendance year of the current student
OMP         DB  ?   ;Not used, because SUPERBONUS RULE not implemented
VOTE        DB  ?

CARDS       DB  3   DUP(0)  ;values of cards of the current student

NTOKENSmsg  DB  'Insert number of tokens [1-3]: $'
ATTYEARmsg  DB  'Insert attendance year [1-5]: $' 
NEWCARDmsg  DB  'Do you want to draw the next card [y/n]?  $' 
ADDENDUMmsg DB  'Do you want to apply the ADDENDUM RULE (all chars bring 10) [y/n]? $'
EXTRAmsg    DB  'Do you want to apply the EXTRA RULE (all aces bring 14) [y/n]? $'
SUPERmsg    DB  'Select SUPER RULE ([1] points added to 6, [2] points subtracted by 52): $'
VOTEmsg     DB  'Vote = $'
REJmsg      DB  ' => Rejected$'
PASmsg      DB  ' => Exam passed$'
NEXTSTUDmsg DB  'New student [y/n]? $'

SPADESmsg   DB  'spades$'
HEARTHSmsg  DB  'hearths$'
DIAMONDSmsg DB  'diamonds$'
CLUBSmsg    DB  'clubs$'
 

BUFFER  DB  5   DUP(?)

    .code
    .startup
    
    xor di, di      ;used as index for DECKS
    mov STUDENTS, 0 
    
examVote:
    mov VOTE, 0
    add STUDENTS, 1
    
    call emptyRow
    mov ah, 9               ;ask for number of tokens
    mov dx, offset NTOKENSmsg
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    mov TOKENS, al
    
    call emptyRow                  
    mov ah, 9               ;ask for attendance year
    mov dx, offset ATTYEARmsg
    int 21h
    mov ah, 1
    int 21h
    sub al, '0'
    mov SENIORITY, al
    
    mov CARDS[0], 0         ;set CARDS array to all zeros
    mov CARDS[1], 0
    mov CARDS[2], 0
    
    xor cx, cx      ;draw cards
    mov cl, TOKENS
    xor si, si      ;used as index for CARDS array 
    call emptyRow
    
drawCards:
    call emptyRow
    mov dl, DECKS[di]
    add di, 1
    mov CARDS[si], dl  
    and CARDS[si], 00001111B    ;store only the value of the card
    lea ax, BUFFER
    push ax
    xor ah, ah
    mov al, CARDS[si]
    push ax
    call printValue
    pop ax
    pop ax
    and dl, 00110000B   ;keep the suit
    shr dl, 1
    shr dl, 1
    shr dl, 1
    shr dl, 1          ;<DL> = 000000ss
    mov ah, 9
    cmp dl, 0
    je printSpades
    cmp dl, 1
    je printHearths
    cmp dl, 2
    je printDiamonds
    mov dx, offset CLUBSmsg     
    int 21h
    jmp continueDrawCards
printSpades:
    mov dx, offset SPADESmsg
    int 21h
    jmp continueDrawCards
printHearths:
    mov dx, offset HEARTHSmsg
    int 21h
    jmp continueDrawCards
printDiamonds:
    mov dx, offset DIAMONDSmsg
    int 21h

continueDrawCards:  
    call emptyRow
    sub cx, 1
    cmp cx, 0
    je computeVote
askForNewCard:    
    mov ah, 9
    mov dx, offset NEWCARDmsg
    int 21h    
    mov ah, 1
    int 21h
    cmp al, 'y'
    je nextCard
    cmp al, 'n'
    je computeVote
    jmp askForNewCard
nextCard:
    inc si  ;index of CARDS
    jmp drawCards
    
computeVote:
    mov al, 1
    cmp SENIORITY, al
    je computeBasic
                        ;all students from 2 to 5 year can be asked for addendum rule
askAddendumRule:
    call emptyRow 
    mov ah, 9
    mov dx, offset ADDENDUMmsg
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'n'
    je askExtraRule
    cmp al, 'y'
    je applyAddendumRule
    jmp askAddendumRule

applyAddendumRule:
    lea ax, CARDS
    push ax
    call addendumRuleProc
    pop ax
    
askExtraRule:
    cmp SENIORITY, 3
    jl computeBasic
                        ;all students from 3 to 5 year can be asked for extra rule                           
    call emptyRow 
    mov ah, 9
    mov dx, offset EXTRAmsg
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'n'
    je askSuperRule
    cmp al, 'y'
    je applyExtraRule
    jmp askExtraRule

applyExtraRule:
    lea ax, CARDS
    push ax
    call extraRuleProc
    pop ax
    
askSuperRule:
    cmp SENIORITY, 4
    jl computeBasic 
                        ;all students from 4 to 5 year can be asked for super rule  
    call emptyRow
    mov ah, 9
    mov dx, offset SUPERmsg
    int 21h 
    mov ah, 1
    int 21h
    cmp al, '1'
    je computeBasic
    cmp al, '2'
    je computeSuper
    jmp askSuperRule
    
computeBasic:
    mov al, CARDS[0]
    add VOTE, al
    mov al, CARDS[1]
    add VOTE, al
    mov al, CARDS[2]
    add VOTE, al
    mov al, 6
    add VOTE, al
    jmp showVote

computeSuper:
    mov al, 52
    add VOTE, al
    mov al, CARDS[0]
    sub VOTE, al
    mov al, CARDS[1]
    sub VOTE, al
    mov al, CARDS[2]
    sub VOTE, al
    
showVote:
    call emptyRow
    call emptyRow
    mov ah, 9
    mov dx, offset VOTEmsg
    int 21h    
    lea ax, BUFFER
    push ax
    xor ah, ah
    mov al, VOTE
    push ax
    call printDecimal
    pop ax
    pop ax    
    xor ah, ah
    mov al, 18
    cmp VOTE, al
    jl printRejected
    mov al, 30
    cmp VOTE, al
    jg printRejected
    mov ah, 9
    mov dx, offset PASmsg
    int 21h 
    jmp nextStudent
printRejected:
    mov ah, 9
    mov dx, offset REJmsg
    int 21h           
    
nextStudent:
    call emptyRow
    call emptyRow
    mov al, 30
    cmp STUDENTS, al
    jl askForNextStudent
    jmp endOfProgram
askForNextStudent:
    call emptyRow
    mov ah, 9
    mov dx, offset NEXTSTUDmsg
    int 21h
    mov ah, 1
    int 21h
    cmp al, 'y'
    je examVote
    cmp al, 'n'
    je endOfProgram
    jmp askForNextStudent

endOfProgram:        
    
    .exit 
 
;Procedure to apply the addendum rule
addendumRuleProc proc
    push bp
    mov bp, sp
    
    push ax
    push cx
    push si
    
    mov si, [bp+4]  ;base address of CARDS array
    mov cx, 3
    mov al, 10
resizeTen:
    cmp [si], al
    jle nextCardTen     ;if value <= 10 => do nothing...
    mov [si], al        ;...otherwise set it to 10
nextCardTen:
    add si, 1
    loop resizeTen    
    
    pop si
    pop cx
    pop ax
    pop bp
    ret
addendumRuleProc endp

;Procedure to apply extra rule
extraRuleProc proc
    push bp
    mov bp, sp
    
    push ax
    push cx
    push si
    
    mov si, [bp+4]  ;base address of CARDS array
    mov cx, 3
    mov al, 14
resizeOne:
	mov ah, 1
    cmp [si], ah
    jne nextCardOne     ;if value != 1 => do nothing...
    mov [si], al        ;...otherwise set it to 14
nextCardOne:
    add si, 1
    loop resizeOne 
    
    pop si
    pop cx
    pop ax
    pop bp
    ret
extraRuleProc endp     
    

;Procedure to print the value of the card
printValue proc
    push bp
    mov bp, sp
    
    push ax
    push dx
    push di
    
    mov di, [bp+6]
    mov ax, [bp+4]
    
    cmp ax, 10
    jle callPrintDecimal
    cmp ax, 11
    je printJack
    cmp ax, 12
    je printQueen
    mov ah, 2       ;otherwise print King
    mov dl, 'K'
    int 21h
    jmp endPrintValue

callPrintDecimal:
    push di
    push ax
    call printDecimal
    pop di
    pop ax
    jmp endPrintValue
    
printJack:
    mov ah, 2       
    mov dl, 'J'
    int 21h
    jmp endPrintValue            

printQueen:
    mov ah, 2       ;otherwise print King
    mov dl, 'Q'
    int 21h
    jmp endPrintValue

endPrintValue:
    mov ah, 2
    mov dl, ' '
    int 21h    
    
    pop di
    pop dx
    pop ax
  
    pop bp
    ret
printValue endp
    
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