M EQU 3
    .model small
    .stack
    .data
WGF_RACE    DB 00000000B
            DB 00000001B
            DB 00000010B
            DB 00000011B
            DB 00000100B
            DB 00000101B
            DB 00000110B
            DB 00000111B
            DB 53 DUP(0)  
            
DIE_VAL        DB ?            
 
PLAYERS     DB 0
            DB 0
            DB 0
            
STAT_VAL       DB 6 DUP(0)
STAT_PLAYERS   DB 6 DUP(0)
 
JT          DW A1, A2, A3, P1, P2, P3, P4

PLAYERmsg   DB 'Player $'
INPUTmsg    DB ' please throw the die and enter the number (1-6): $'
CELLmsg     DB '   Cell $'
HASmsg      DB ' has a penalty/award$'
POSmsg      DB ' is in cell $'
HASNOmsg    DB ' has no penalty/award$'
WINmsg      DB 'The winner is Player $'

A1msg       DB '   Award: Double the number shown by the die$' 
A2msg       DB '   Award: Go forward by two cells$'
A3msg       DB '   Award: Throw the die once more and go forward$'

AP3msg      DB '   Please throw the die and enter the number (1-6): $'

P1msg       DB '   Penalty: Miss a turn of die throwing$'
P2msg       DB '   Penalty: Go backward by two cells$'
P3msg       DB '   Penalty: Throw the die once more and go backward$'
P4msg       DB '   Penalty: said loudly "I love to play this crazy game and I am a liar!!!"$'
P4Bmsg      DB '     I LOVE TO PLAY THIS CRAZY GAME AND I AM A LIAR$'

STATmsg     DB '-- Statistics --$'
ONEmsg      DB 'Number of thrown "1": $'
TWOmsg      DB 'Number of thrown "2": $'
THRmsg      DB 'Number of thrown "3": $'
FOUmsg      DB 'Number of thrown "4": $'
FIVmsg      DB 'Number of thrown "5": $'
SIXmsg      DB 'Number of thrown "6": $' 
                                          
BALmsg      DB 'Net balance of awards/penalties steps gained:$'
EQmsg       DB ' = $'
DIESmsg     DB 'Dies thrown by each player:$'

                                         
BUFFER      DB 5 DUP(0) 
    .code
    .startup
    
;Implement game and relative statistics
    xor si, si
gameLoop: 
    mov cl, PLAYERS[si]
    test cl, 11000000B
    jnz missTurn
    
    call emptyRow
	xor al, al
    mov ah, 9
    mov dx, offset PLAYERmsg
    int 21h   
    mov ah, 2
	xor dx, dx
    add dx, si 
    add dx, 1
    add dx, '0'       ;dx now contains player number
    int 21h
    mov ah, 9
    mov dx, offset INPUTmsg 
    int 21h
    
    mov ah, 1
    int 21h         
    sub al, '0'         ;al <= value of the die
    mov DIE_VAL, al     ;to be used after (just in case)
    call emptyRow
    
	cmp al, 6			;check input value
	jg gameLoop
	cmp al, 1
	jl gameLoop
	
	
    mov dl, al      ;update statistics (count of values)    
    xor dh, dh
    dec dx 
    mov di, dx
    add STAT_VAL[di], 1     
    
    xor di, di
    add di, si
    add di, di
    add STAT_PLAYERS[di+1], 1   ;increment #dies thrown by this player
    
    add cl, al      ;compute the "new position"
    cmp cl, 60
    je endOfGame
    mov al, cl
    cmp al, 60
    jl updatePosition   ;if next position < 60
    mov al, 60      ;otherwise, next pos > 60 => move backward
    sub cl, al      ;next position - 60 = value (<0)
    sub al, cl      ;AL <= 60 - value (actual new position)                                    
updatePosition:
    mov PLAYERS[si], al
    cmp al, 7
    jg noPenaltyOrAward
    mov ah, 9
    mov dx, offset CELLmsg
    int 21h 
    lea dx, BUFFER
    push dx
    mov al, PLAYERS[si]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    mov ah, 9
    mov dx, offset HASmsg
    int 21h                 
    call emptyRow
    xor bh, bh      ;start the code relative to a penalty/award 
    mov bl, PLAYERS[si]
    sub bx, 1
    add bx, bx
    jmp WORD ptr JT[bx]
    
missTurn:
    and PLAYERS[si], 00111111B

nextPlayer:
    call emptyRow
    mov ah, 9
    mov dx, offset PLAYERmsg
    int 21h   
    mov ah, 2
    mov dx, si 
    add dx, 1
    add dx, '0'       ;dx now contains player number
    int 21h
    mov ah, 9
    mov dx, offset POSmsg 
    int 21h 
    lea dx, BUFFER
    push dx
    mov al, PLAYERS[si] 
    and al, 00111111B
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow
    
    cmp si, 2
    je restartPlayers
    add si, 1
    jmp gameLoop
    
restartPlayers:
    mov si, 0
    jmp gameLoop
    
noPenaltyOrAward:
    mov ah, 9
    mov dx, offset CELLmsg
    int 21h
    lea dx, BUFFER
    push dx
    mov al, PLAYERS[si]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    mov ah, 9
    mov dx, offset HASNOmsg
    int 21h                  
    jmp nextPlayer
    
endOfGame: 
    mov ah, 9
    mov dx, offset WINmsg
    int 21h
    mov ah, 2
    mov dx, si 
    add dx, 1
    add dx, '0'       ;dx now contains player number
    int 21h
    call emptyRow
    jmp exit
          

A1:   
    mov ah, 9
    mov dx, offset A1msg 
    int 21h    
    
    xor dx, dx
    mov dl, DIE_VAL
    xor di, di
    add di, si
    add di, di                  ;index for STAT_PLAYERS
    add STAT_PLAYERS[di], dl    ;update #steps depending on awards/penalties
    
    mov cl, PLAYERS[si]         ;compute the "new position"
    add cl, DIE_VAL
    cmp cl, 60
    je endOfGame  
    mov al, cl
    cmp al, 60
    jl updatePositionA1   ;if next position < 60
    mov al, 60      ;otherwise, next pos > 60 => move backward
    sub cl, al      ;next position - 60 = value (<0)
    sub al, cl      ;AL <= 60 - value (actual new position)                                    
updatePositionA1:
    mov PLAYERS[si], al
    jmp nextPlayer
      
      
A2:     
    mov ah, 9
    mov dx, offset A2msg 
    int 21h       
    
    add PLAYERS[si], 2   
    
    xor di, di                  ;update #steps depending on awards/penalties
    add di, si
    add di, di                  ;index for STAT_PLAYERS
    add STAT_PLAYERS[di], 2
    
    jmp nextPlayer
      
      
A3: 
    mov ah, 9                                   
    mov dx, offset A3msg 
    int 21h  
    call emptyRow
    mov ah, 9
    mov dx, offset AP3msg 
    int 21h     
    
    mov ah, 1
    int 21h         
    sub al, '0'         ;al <= value of the die
    
    mov dl, al          ;update statistics (count of values)    
    xor dh, dh
    dec dx 
    mov di, dx
    add STAT_VAL[di], 1     
    
    xor di, di
    add di, si
    add di, di
    add STAT_PLAYERS[di+1], 1  ;update count of dies thrown
    
    add STAT_PLAYERS[di], al   ;update #steps depending on awards/penalties
    
    mov cl, PLAYERS[si]
    add cl, al      ;compute the "new position"
    cmp cl, 60
    je endOfGame
    mov al, cl
    cmp al, 60
    jl updatePositionA3     ;if next position < 60
    mov al, 60              ;otherwise, next pos > 60 => move backward
    sub cl, al              ;next position - 60 = value (<0)
    sub al, cl              ;AL <= 60 - value (actual new position)                                    
updatePositionA3:
    mov PLAYERS[si], al
    
    jmp nextPlayer
     
     
P1:   
    mov ah, 9
    mov dx, offset P1msg 
    int 21h  
    
    mov cl, 11000000B
    mov al, PLAYERS[si]
    or cl, al
    mov PLAYERS[si], cl
    
    xor di, di
    add di, si
    add di, di   
    sub STAT_PLAYERS[di], 4   ;update #steps depending on awards/penalties
       
    jmp nextPlayer    
    

P2: 
    mov ah, 9
    mov dx, offset P2msg
    int 21h 
    
    sub PLAYERS[si], 2
    cmp PLAYERS[si], 0
    jg continueP2
    mov PLAYERS[si], 0   

continueP2:
    xor di, di                  ;update #steps depending on awards/penalties
    add di, si
    add di, di                  ;index for STAT_PLAYERS
    sub STAT_PLAYERS[di], 2
    
    jmp nextPlayer
    
    
P3: 
    mov ah, 9
    mov dx, offset P3msg
    int 21h   
    
    call emptyRow
    mov ah, 9
    mov dx, offset AP3msg 
    int 21h     
    
    mov ah, 1
    int 21h         
    sub al, '0'
    
    mov dl, al          ;update statistics (count of values)    
    xor dh, dh
    dec dx 
    mov di, dx
    add STAT_VAL[di], 1     
    
    xor di, di
    add di, si
    add di, di
    add STAT_PLAYERS[di+1], 1  ;update count of dies thrown
    
    sub STAT_PLAYERS[di], al   ;update #steps depending on awards/penalties
    
    mov cl, PLAYERS[si]
    sub cl, al      ;compute the "new position"
    cmp cl, 0
    jg updatePositionP3
    mov cl, 0
                                   
updatePositionP3:
    mov PLAYERS[si], cl
    
    jmp nextPlayer 

P4: 
    mov ah, 9
    mov dx, offset P4msg
    int 21h
    
    call emptyRow
    
    mov ah, 9
    mov dx, offset P4Bmsg
    int 21h   
    
    jmp nextPlayer
    
exit:   
    call emptyRow
    mov ah, 9       ;print statistics
    mov dx, offset STATmsg
    int 21h
    call emptyRow
    
    mov ah, 9
    mov dx, offset ONEmsg
    int 21h
    lea dx, BUFFER
    push dx
    mov al, STAT_VAL[0]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow
                 
    mov ah, 9             
    mov dx, offset TWOmsg
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_VAL[1]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow
    
    mov ah, 9             
    mov dx, offset THRmsg
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_VAL[2]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow 
    
    mov ah, 9             
    mov dx, offset FOUmsg
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_VAL[3]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow 
    
    mov ah, 9             
    mov dx, offset FIVmsg
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_VAL[4]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow
    
    mov ah, 9             
    mov dx, offset SIXmsg
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_VAL[5]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax
    call emptyRow  
    
    call emptyRow   ; print number of steps
    mov ah, 9
    mov dx, offset BALmsg
    int 21h
    call emptyRow 
    mov cx, 1
    xor si, si 
balanceLoop:
    mov ah, 9
    mov dx, offset PLAYERmsg  
    int 21h
    mov ah, 2
    mov dx, cx
    add dl, '0'
    int 21h 
    mov ah, 9
    mov dx, offset EQmsg  
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_PLAYERS[si]
    cmp al, 0
    jge goToPositivePrint
    mov ah, 2
    mov dl, '-'
    int 21h
	mov al, STAT_PLAYERS[si]
	cbw
	neg ax
	jmp goToPrint
goToPositivePrint:
	mov al, STAT_PLAYERS[si]
	cbw
	jmp goToPrint
goToPrint:
    push ax
    call printDecimal
    pop dx
    pop ax 
    call emptyRow
    
    add si, 2
    add cx, 1
    cmp cx,4
    jne balanceLoop   
    
    call emptyRow   ; print number of dies thrown
    mov ah, 9
    mov dx, offset DIESmsg
    int 21h
    call emptyRow 
    mov cx, 1
    mov si, 1 
diesLoop:
    mov ah, 9
    mov dx, offset PLAYERmsg  
    int 21h
    mov ah, 2
    mov dx, cx
    add dl, '0'
    int 21h 
    mov ah, 9
    mov dx, offset EQmsg  
    int 21h
    lea dx, BUFFER 
    push dx
    mov al, STAT_PLAYERS[si]
    cbw
    push ax
    call printDecimal
    pop dx
    pop ax 
    call emptyRow
    add si, 2
    add cx, 1
    cmp cx, 4
    jne diesLoop
    
        
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
    
    mov di, [bp+6]      ;buffer
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