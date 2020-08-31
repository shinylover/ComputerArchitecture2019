    .model small
    .stack
    .data
    
TIMES   DB  00000001B   ;A = 1, T = 3m:39s.99c
        DB  11000111B
        DB  00111011B
        DB  00000010B   ;A = 2, T = 3m:50s.50c
        DB  01100101B
        DB  10010011B
        DB  00000011B   ;A = 3, T = 3m:43s.10c
        DB  00010101B
        DB  01011011B
        DB  00000100B   ;A = 4, T = 3m:51s.20c
        DB  00101001B
        DB  10011011B
        DB  00000101B   ;A = 5, T = 3m:44s.30c
        DB  00111101B
        DB  01100011B
        DB  00000110B   ;A = 6, T = 3m:52s.70c
        DB  10001101B
        DB  10100011B
        DB  00000111B   ;A = 7, T = 3m:45s.57c
        DB  01110011B
        DB  01101011B
        DB  00001000B   ;A = 8, T = 3m:38s.2c
        DB  00000101B
        DB  00110011B

STANDINGS   DB  24  DUP(?)  ;output <= ordered times
DIFF_PREV   DW  8   DUP(?)  ;
WR          DW  0000111101000011B   ;3m:40s.7c 
DIFF_WR     DW  0

TIMESmsg    DB  'Times: $'
STANDmsg    DB  'Standing: $'
DIFFmsg     DB  'Differences of times: $'   
ACTWRmsg    DB  'Actual WR is still the best time: $'
NEWWRmsg    DB  'New WR: $'
TIMEEQmsg   DB  'Fastest athlete time = actual WR: $'
DIFFWRmsg   DB  'Difference of WR: $'

BIG DW 0
SMALL DW 0

BUFFER      DB  8   DUP(?)

    .code
    .startup   
    
    
;ITEM 1
    mov cx, 24      ;first copy TIMES in STANDINGS
    xor si, si
copyEntries:
    mov al, TIMES[si]
    mov STANDINGS[si], al
    inc si
    loop copyEntries 
    
    mov ah, 9
    mov dx, offset TIMESmsg
    int 21h
    call emptyRow 
    lea ax, BUFFER
    push ax
    lea ax, STANDINGS
    push ax
    call printStandings
    pop ax 
    pop ax

sortingWrapper:    
    mov cx, 7       ;sort STANDINGS array
    xor si, si
    mov bx, 0
sortStandings:
    mov ah, STANDINGS[si+1]
    mov al, STANDINGS[si+2]
    cmp ax, 0                    
    je exchangeEntries      ;if T1 = 0 => disqualified (at the end of STANDINGS)
    mov dh, STANDINGS[si+4]
    mov dl, STANDINGS[si+5]
    cmp dx, 0
    je nextEntry            ;if T2 = 0 => disqualified (relative order is ok)
                            
                            ;first compare minutes
    and al, 00000111B       ;M1 = minutes of athlete 1
    and dl, 00000111B       ;M2 = minutes of athlete 2
    cmp al, dl
    je compareSeconds       ;if M1 = M2 => compare seconds
    cmp al, dl              
    ja exchangeEntries      ;if M1 > M2 => exchange because A2 athlete is faster
    jmp nextEntry           ;otherwise A1 is faster => no change
                            
compareSeconds:                            
    mov al, STANDINGS[si+2] ;<ah> = [si+1]
    mov dl, STANDINGS[si+5] ;<dh> = [si+4]
    push cx
    mov cl, 3
    shr ax, cl
    shr dx, cl
    pop cx
    and al, 00111111B       ;S1
    and dl, 00111111B       ;S2
    cmp al, dl
    je compareCents         ;if also seconds are equal => compare cents of second
    cmp al, dl
    ja exchangeEntries      ;if S1 > S2 => A1 slower => exchange
    jmp nextEntry           ;otherwise A2 slower => do nothing

compareCents:   
    mov al, STANDINGS[si+1]
    mov dl, STANDINGS[si+4]
    shr al, 1               ;C1
    shr dl, 1               ;C2
    cmp al, dl
    je nextEntry            ;times are equal, order is not important
    cmp al, dl         
    ja exchangeEntries      ;if C1 > C2 => A1 slower => exchange
    jmp nextEntry

nextEntry:
    add si, 3
    loop sortStandings
	jmp cnt
exchangeEntries:
    mov al, STANDINGS[si]
    mov dl, STANDINGS[si+3]
    mov STANDINGS[si+3], al
    mov STANDINGS[si], dl
    mov al, STANDINGS[si+1]
    mov dl, STANDINGS[si+4]
    mov STANDINGS[si+4], al
    mov STANDINGS[si+1], dl
    mov al, STANDINGS[si+2]
    mov dl, STANDINGS[si+5]
    mov STANDINGS[si+5], al
    mov STANDINGS[si+2], dl
    mov bx, 1               ;signal the swap	
    jmp nextEntry
cnt:	
    cmp bx, 0
    jne sortingWrapper      ;SORTING array sorted from fastest to slowest athlete
    
    call emptyRow
    call emptyRow
    mov ah, 9
    mov dx, offset STANDmsg
    int 21h     
    call emptyRow
    lea ax, BUFFER
    push ax
    lea ax, STANDINGS
    push ax
    call printStandings
    pop ax 
    pop ax 
    
    
;ITEM 2
    mov ax, 0
    mov DIFF_PREV[0], ax
    
    mov cx, 7               ;loop counter
    xor di, di              ;used ax index for DIFF_PREV
    add di, 2               ;DIFF_PREV[0] already set
    xor si, si              ;used ax index for STANDINGS array
    
computeDifference:
    push cx                 ;used to build the next entry of DIFF_PREV
    xor cx, cx
    mov ah, STANDINGS[si+1]
    mov al, STANDINGS[si+2]
    shr ax, 1               ;<ah> = cents of athlete 1 (C1)
    shr al, 1
    shr al, 1               ;<al> = S1
    mov dh, STANDINGS[si+4]
    mov dl, STANDINGS[si+5]
    shr dx, 1               ;<dh> = cents of athlete 2 (C2)
    shr dl, 1
    shr dl, 1               ;<dl> = S1
    cmp dh, ah
    jae computeCentsDiff    ;if C2 >= C1 => ok, otherwise borrow is needed
    add dh, 100             ;add 100 cents to C2
    sub dl, 1               ;subtract 1 second from S1
computeCentsDiff:
    sub dh, ah              ;difference of cents
    mov ch, dh
    shl ch, 1               ;store difference of cents
                            ;compute difference of seconds contained in DL and AL
    mov dh, STANDINGS[si+5]
    and dh, 00000111B       ;M2
    mov ah, STANDINGS[si+2] 
    and ah, 00000111B       ;M1
    cmp dl, al
    jae computeSecondsDiff  
    add dl, 60              ;add 60 seconds to S2
    sub dh, 1               ;subtract 1 minute from M2
computeSecondsDiff:
    sub dl, al              ;difference of seconds
    mov cl, dl
    shl cl, 1
    shl cl, 1
    shl cl, 1
    adc ch, 0
    
    sub dh, ah              ;difference of minutes
    or cl, dh
    
    mov DIFF_PREV[di], cx
    pop cx
    add si, 3
    add di, 2
    loop computeDifference
    
    call emptyRow
    call emptyRow
    mov ah, 9
    mov dx, offset DIFFmsg
    int 21h
    call emptyRow
    lea ax, BUFFER
    push ax
    lea ax, DIFF_PREV
    push ax
    call printDiffTimes
    pop ax
    pop ax
      
                                   
;ITEM 3  
                            ;first check which is the bigger time
    mov ax, WR
    mov dh, STANDINGS[1]
    mov dl, STANDINGS[2]
                            ;compare minutes
    and al, 00000111B
    and dl, 00000111B
    cmp al, dl
    je compareSeconds3
    ja newWR
    jmp noChange
compareSeconds3:
    mov ax, WR
    mov dl, STANDINGS[2]
    mov cl, 3
    shr ax, cl
    shr dx, cl
    and al, 00111111B
    and dl, 00111111B
    cmp al, dl
    je compareCents3
    cmp al, dl
    ja newWR
    jmp noChange
compareCents3:
    mov ax, WR
    mov dh, STANDINGS[1]
    shr ah, 1
    shr dh, 1
    cmp ah, dh
    je equalTimes           ;actual WR = time of the fastest athlete
    cmp ah, dh
    ja newWR
    
noChange:
                            ;actual WR (AX) is the best time 
                            ;  => time of fastest athlete (DX) is bigger
                            ;The difference will be computed as BIG - SMAL
    call emptyRow
    mov ah, 9
    mov dx, offset ACTWRmsg
    int 21h
    lea ax, BUFFER
    push ax                         
    mov ax, WR
    push ax
    call printTime
    pop ax
    pop ax
    mov ax, WR
    mov dh, STANDINGS[1]
    mov dl, STANDINGS[2]
    mov BIG, dx
    mov SMALL, ax
                           
    jmp computeDiffWR

newWR:
                            ;actual WR (AX) is no more the best time
                            ;exchange AX and DX
                            ;update WR
     
    call emptyRow
    mov ah, 9
    mov dx, offset NEWWRmsg
    int 21h
    lea ax, BUFFER
    push ax                         
    mov ah, STANDINGS[1]
    mov al, STANDINGS[2]
    push ax
    call printTime
    pop ax
    pop ax
    
    mov ah, STANDINGS[1]
    mov al, STANDINGS[2]
    mov dx, WR
    mov WR, ax              ;update WR
    mov BIG, dx
    mov SMALL, ax
    jmp computeDiffWR                    

equalTimes:
    call emptyRow
    mov ah, 9
    mov dx, offset TIMEEQmsg
    int 21h
    lea ax, BUFFER
    push ax                         
    mov ax, WR
    push ax
    call printTime
    pop ax
    pop ax
    jmp endOfProgram
             
computeDiffWR:
    xor cx, cx              ;used to build DIFF_WR
    mov ax, SMALL
    shr ax, 1               ;<ah> = cents of athlete 1 (C1)
    shr al, 1
    shr al, 1               ;<al> = S1
    mov dx, BIG
    shr dx, 1               ;<dh> = cents of athlete 2 (C2)
    shr dl, 1
    shr dl, 1               ;<dl> = S1
    cmp dh, ah
    jae computeCentsDiffWR  ;if C2 >= C1 => ok, otherwise borrow is needed
    add dh, 100             ;add 100 cents to C2
    sub dl, 1               ;subtract 1 second from S1
computeCentsDiffWR:
    sub dh, ah              ;difference of cents
    mov ch, dh
    shl ch, 1               ;store difference of cents
                            ;compute difference of seconds contained in DL and AL
    mov ax, SMALL
    ror ax, 1               
    ror ax, 1
    ror ax, 1               ;<al> = S1
    shr ah, 1
    shr ah, 1
    shr ah, 1
    shr ah, 1
    shr ah, 1               ;<ah> = M1
    mov dx, BIG
    ror dx, 1               
    ror dx, 1
    ror dx, 1               ;<dl> = S2
    shr dh, 1
    shr dh, 1
    shr dh, 1
    shr dh, 1
    shr dh, 1               ;<dh> = M2
    cmp dl, al
    jae computeSecondsDiffWR  
    add dl, 60              ;add 60 seconds to S2
    sub dh, 1               ;subtract 1 minute from M2
computeSecondsDiffWR:
    sub dl, al              ;difference of seconds
    mov cl, dl
    shl cl, 1
    shl cl, 1
    shl cl, 1
    adc ch, 0
    
    sub dh, ah              ;difference of minutes
    or cl, dh
    
    mov DIFF_WR, cx
    
    
    call emptyRow
    call emptyRow
    mov ah, 9
    mov dx, offset DIFFWRmsg
    int 21h
    call emptyRow
    lea ax, BUFFER
    push ax
    mov ax, DIFF_WR
    push ax
    call printTime
    pop ax
    pop ax
             
endOfProgram:        
    .exit

;Procedure to print TIME
printTime proc
    push bp
    mov bp, sp
    
    push si
    push ax
    push cx
    push dx
    
    mov ax, [bp+6]  ;buffer address   
    push ax
    mov dx, [bp+4]  ;time 
    
    
    and dl, 00000111B 
    xor dh, dh
    push dx
    call printDecimal
    pop dx
    
    mov ah, 2
    mov dl, 'm'
    int 21h
    mov dl, '.'
    int 21h
    
     mov dx, [bp+4]
    push cx
    mov cl, 3
    shr dx, cl 
    pop cx
    xor dh, dh
    and dl, 00111111B
    push dx
    call printDecimal
    pop dx
    
    mov ah, 2
    mov dl, 's'
    int 21h
    mov dl, '.'
    int 21h
    
     mov dx, [bp+4]
    shr dh, 1
    mov dl, dh
    xor dh, dh
    push dx
    call printDecimal
    pop dx 
    
    mov ah, 2
    mov dl, 'c'
    int 21h
    
    pop ax
    pop dx
    pop cx
    pop ax
    pop si
    pop bp    
    ret
printTime endp

     
;Procedure to print DIFF_PREV array     
printDiffTimes proc
    push bp
    mov bp, sp
    
    push si
    push ax
    push cx
    push dx
    
    mov ax, [bp+6]  ;buffer address   
    push ax
    mov si, [bp+4]  ;DIFF_PREV address
    mov cx, 8
printDiffTimesLoop:
    mov dx, [si]
    and dl, 00000111B 
    xor dh, dh
    push dx
    call printDecimal
    pop dx
    
    mov ah, 2
    mov dl, 'm'
    int 21h
    mov dl, '.'
    int 21h
    
    mov dx, [si]
    push cx
    mov cl, 3
    shr dx, cl 
    pop cx
    xor dh, dh
    and dl, 00111111B
    push dx
    call printDecimal
    pop dx
    
    mov ah, 2
    mov dl, 's'
    int 21h
    mov dl, '.'
    int 21h
    
    mov dx, [si]
    shr dh, 1
    mov dl, dh
    xor dh, dh
    push dx
    call printDecimal
    pop dx 
    
    mov ah, 2
    mov dl, 'c'
    int 21h
    
    call emptyRow
    add si, 2
    loop printDiffTimesLoop
    
    pop ax
    pop dx
    pop cx
    pop ax
    pop si
    pop bp    
    ret
printDiffTimes endp


;Procedure to print SORTING array     
printStandings proc
    push bp
    mov bp, sp
    
    push si
    push ax
    push cx
    push dx
    
    mov ax, [bp+6]  ;buffer address   
    push ax
    mov si, [bp+4]  ;STANDINGS address
    mov cx, 8
printStandingsLoop:
    mov ah, 2       ;print athlete number
    mov dl, '('
    int 21h
    mov dl, [si]
    add dl, '0'
    int 21h
    mov dl, ')'
    int 21h 
    mov dl, ' '
    int 21h
    mov dl, '-'
    int 21h
    mov dl, ' '
    int 21h
    
    xor dh, dh
    mov dl, [si+2]
    and dl, 00000111B
    push dx
    call printDecimal
    pop dx
    
    mov ah, 2
    mov dl, 'm'
    int 21h
    mov dl, '.'
    int 21h
    
    mov dh, [si+1]
    mov dl, [si+2]
    push cx
    mov cl, 3
    shr dx, cl 
    pop cx
    xor dh, dh
    and dl, 00111111B
    push dx
    call printDecimal
    pop dx
    
    mov ah, 2
    mov dl, 's'
    int 21h
    mov dl, '.'
    int 21h
    
    mov dl, [si+1]
    shr dl, 1
    xor dh, dh
    push dx
    call printDecimal
    pop dx  
    
    mov ah, 2
    mov dl, 'c'
    int 21h
    
    call emptyRow
    add si, 3
    loop printStandingsLoop
    
    pop ax
    pop dx
    pop cx
    pop ax
    pop si
    pop bp    
    ret
printStandings endp

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
       
    end