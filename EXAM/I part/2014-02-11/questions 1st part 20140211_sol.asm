N   EQU 150         ;maximum size of DATABASE variable (max records for each skier)
    .model small
    .stack
    .data  
DATABASE    DD    00000001011100101000000000000110B
            DD    00000001011101001000000100000010B
            DD    00000001011100101000001001000000B
            DD    00000001011101101000001111001110B
            DD    00000001011110001000010110111010B
            DD    00000001011101001000100011010110B
            DD    00000000000000000000000000000000B

STATISTICS  DB    3*N DUP(?)
STAT_COUNT  DW    0

MENU0   DB '[0] Exit $'                           
MENU1   DB '[1] Number of passages $' 
MENU2   DB '[2] Slowest passages $'
                     
DBmsg   DB 'Initial Database: $'  
OWNER   DB 'Owner: $'
STATION DB ', Station: $'
PASS_H  DB ', Passage hour: $' 
PASS_M  DB ':$'
PASS_S  DB ':$'      

ITEM0   DB 'Item 0: Statistics $'
TYPEmsg DB 'Type: $'          
DESCEND DB 'descend,$'
LIFT    DB 'lift,   $'
START   DB ' Start station: $'
ARRIVAL DB ', Arrival station: $'
TIME    DB ', Time: $'  

NLIFT   DB 'Number of lifts: $'
NDESC   DB 'Number of descends: $'    

SLIFT   DB 'Slowest lift: $'
SDESC   DB 'Slowest descend: $'

NUM_LIFT DW 0
NUM_DESC DW 0  

SLOWEST_LIFT DW 0001111000000000B
SLOWEST_DESC DW 0001111000000000B
                     
BUFFER  DB  5 DUP(0)   

JT DW ITEM1, ITEM2    
    .code
    .startup 

;At the beginning, print the content of the initial database 
    mov ah, 9
    mov dx, offset DBmsg
    int 21h
    call emptyRow
    lea ax, DATABASE
    push ax 
    lea ax, BUFFER
    push ax
    call printDB
    pop ax 
    pop ax  
    
;Solve Item0  
    call emptyRow
    mov ah, 9
    mov dx, offset ITEM0
    int 21h
    call emptyRow 
    
    xor di, di      ;index of STATISTICS
    xor si, si      ;index of DATABASE
    
    mov al, BYTE ptr DATABASE[2]     ;initialize "previous station"
    shr al, 1
    and al, 00000111B       ;store the first station as "previous stations"
    
    mov dl, BYTE ptr DATABASE[0]
    mov dh, BYTE ptr DATABASE[1]
    push dx
    mov dl, BYTE ptr DATABASE[2]
    mov dh, BYTE ptr DATABASE[3]
    push dx

statisticsLoop:
    add si, 4
    mov ch, BYTE ptr DATABASE[si+3]
    cmp ch, 0                ;check end of db
    JE  endOfDatabase        
    mov ch, BYTE ptr DATABASE[si+2]
    shr ch, 1
    and ch, 00000111B        ;ch = "current station"
    cmp ch, al               ;al = "previous station"
    JB descendType           ;if current station < previous stations => descend record
    mov cl, 01000000B        ;otherwise lift record (type) 
    jmp continueItem0
descendType: 
    xor cl, cl
continueItem0: 
    add cl, ch               ;set arrival station = "current station"
	push cx
	mov cl, 3
    shl al, cl
	pop cx
    add cl, al               ;set start station = "previous station"
    mov STATISTICS[di], cl
    
    mov dl, BYTE ptr DATABASE[si]     ;compute time 
    mov dh, BYTE ptr DATABASE[si+1]
    push dx              
    mov dl, BYTE ptr DATABASE[si+2]
    mov dh, BYTE ptr DATABASE[si+3]
    push dx
    call computeTimeDifference
    pop dx
    pop dx  ;time difference
    mov STATISTICS [di+1], dh
    mov STATISTICS [di+2], dl  
    inc STAT_COUNT
    add di, 3
    mov al, ch              ;new "previous station" = actual "current station"  
    jmp statisticsLoop
endOfDatabase:
    pop dx
    pop dx 
    mov ax, STAT_COUNT
    push ax
    lea ax, STATISTICS
    push ax
    lea ax, BUFFER
    push ax
    call printStatistics
    pop ax
    pop ax 
    pop ax

;Print user menu 
userMenu: 
    call emptyRow
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
    

ITEM1:
    mov NUM_LIFT, 0
    mov NUM_DESC, 0
    xor si, si
    mov cx, STAT_COUNT
countLoop:
    mov al, STATISTICS[si]
    and al, 01000000B
    cmp al, 0
    je descendCount
    add NUM_LIFT, 1
    jmp nextCount
descendCount:
    add NUM_DESC, 1
nextCount:   
    add si, 3
    dec cx
    cmp cx, 0
    jne countLoop
    
    call emptyRow            
    mov ah, 9  
    mov dx, offset NLIFT
    int 21h
    mov cx, NUM_LIFT
    push cx
    call printDecimal
    pop cx
    
    call emptyRow
    mov ah, 9
    mov dx, offset NDESC
    int 21h
    mov cx, NUM_DESC
    push cx
    call printDecimal
    pop cx
    
    call emptyRow               
    jmp userMenu 
    

ITEM2:  
    xor si, si
    mov cx, STAT_COUNT
foundSlowestLoop:
    mov al, STATISTICS[SI] 
    test al, 01000000B
    jz descendRec
    add si, 1               ;otherwise lift record
    mov ah, STATISTICS[SI]
    mov al, STATISTICS[SI+1]
    cmp SLOWEST_LIFT, ax    ;if SLOWEST_LIST < current time => no changes
    jb nextRecord   
    mov SLOWEST_LIFT, ax    ;otherwise, update slowest lift
    jmp nextRecord
descendRec:
    add si, 1 
    mov ah, STATISTICS[si]
    mov al, STATISTICS[si+1]
    cmp SLOWEST_DESC, ax
    jb nextRecord
    mov SLOWEST_DESC, ax
nextRecord:
    add si, 2
    dec cx
    cmp cx, 0
    jne foundSlowestLoop 
    
    call emptyRow            
    mov ah, 9  
    mov dx, offset SLIFT
    int 21h
    mov cx, SLOWEST_LIFT
	push ax
	mov ax, cx
	mov cl, 8
    shr ax, cl
	mov cx, ax
	pop ax
    push cx
    call printDecimal
    pop cx  
    mov ah, 2
    mov dl, ':'
    int 21h
    mov cx, SLOWEST_LIFT
    xor ch, ch
    push cx
    call printDecimal
    pop cx 
    
    call emptyRow            
    mov ah, 9  
    mov dx, offset SDESC
    int 21h
    mov cx, SLOWEST_DESC
    push ax
	mov ax, cx
	mov cl, 8
    shr ax, cl
	mov cx, ax
	pop ax
    push cx
    call printDecimal
    pop cx  
    mov ah, 2
    mov dl, ':'
    int 21h
    mov cx, SLOWEST_DESC
    xor ch, ch
    push cx
    call printDecimal
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

;Procedure to print the initial database 
printDB proc
    push bp
    mov bp, sp 
    
    push ax 
    push cx
    push dx
    push si
    
    mov si, [bp+6] 
    mov ax, [bp+4]          ;buffer
    push ax
printDBLoop:
    mov ch, [si+3]
    mov cl, [si+2]
    cmp cx, 0
    je endOfPrintDB
    
    mov ah, 9
    mov dx, offset OWNER    ;print owner
    int 21h
    shr cx, 1
	shr cx, 1
	shr cx, 1
	shr cx, 1
    push cx 
    call printDecimal
    pop cx
    
    mov dx, offset STATION  ;print station
    int 21h
    mov cl, [si+2] 
    shr cl, 1 
    and cl, 00000111B
    xor ch, ch
    push cx
    call printStation
    pop cx

printPassageHour:
    mov dx, offset PASS_H   ;print passage hour
    int 21h
    mov ch, [si+2] 
    mov cl, [si+1] 
    shr cx, 1
	shr cx, 1
	shr cx, 1
	shr cx, 1
    and cx, 0000000000011111B
    push cx
    call printDecimal
    pop cx
    
    mov dx, offset PASS_M   
    int 21h
    mov ch, [si+1]
    mov cl, [si]
    shr cx, 1
	shr cx, 1
	shr cx, 1
	shr cx, 1
	shr cx, 1
	shr cx, 1
    and cx, 0000000000111111B
    push cx
    call printDecimal
    pop cx
    
    mov dx, offset PASS_S
    int 21h
    mov cl, [si]
    and cx, 0000000000111111B
    push cx
    call printDecimal
    pop cx
    
    add si, 4
    call emptyRow
    jmp printDBLoop 

endOfPrintDB:
    pop ax  
    pop si
    pop dx
    pop cx
    pop ax
    pop bp
    
    ret
printDB endp
            

;Procedure to print statistics database
printStatistics proc      
    push bp
    mov bp, sp 
    
    push ax 
    push cx
    push dx
    push si
    
    mov cx, [bp+8]          ;statistics database size
    mov si, [bp+6] 
    mov ax, [bp+4]          ;buffer 
    push ax 
      
printStatsLoop:
    push cx    
    mov ah, 9
    mov dx, offset TYPEmsg    ;print type
    int 21h
    xor ch, ch
    mov cl, [si]
    and cl, 01000000B
    cmp cl, 0
    je printDescend
    mov dx, offset LIFT
    int 21h 
    jmp printStartStation 
printDescend:
    mov dx, offset DESCEND
    int 21h
    
printStartStation:
    mov dx, offset START   ;print start station
    int 21h
    mov cl, [si]
    and cl, 00111000B
    shr cl, 1
	shr cl, 1
	shr cl, 1
    push cx
    call printStation
    pop cx
    
    mov dx, offset ARRIVAL ;print arrival station
    int 21h
    mov cl, [si]
    and cl, 00000111B
    push cx
    call printStation
    pop cx
    
    mov dx, offset TIME    ;print time
    int 21h
    mov cl, [si+1]         ;minutes
    push cx 
    call printDecimal
    pop cx
    
    mov ah, 2
    mov dl, ":"
    int 21h
    
    mov cl, [si+2]         ;seconds
    push cx
    call printDecimal
    pop cx
    
    call emptyRow
    add si, 3    
    pop cx
    dec cx
    cmp cx, 0
    je endPrintStats 
    jmp printStatsLoop    
        
endPrintStats:
    call emptyRow 
    pop ax   
    pop si
    pop dx
    pop cx
    pop ax
    pop bp
    ret
printStatistics endp   


;Procedure to compute time difference
computeTimeDifference proc 
    push bp         
    mov bp, sp
    
    push ax
    push cx
    push dx      
    
    mov ax, [bp+4]      ;keep current hour
    mov dx, [bp+6]
	mov cl, 4
    shr dh, cl           ;0000hhhh
    shl al, cl          ;xxxh0000
    and al, dh
    and al, 00011111B   ;al <= 000hhhhh (current hour)
    
	push ax
    mov ax, [bp+8]      ;keep previous hour
    mov dx, [bp+10]
	mov cl, 4
    shr dh, cl
    shl al, cl
    and al, dh
    and al, 00011111B   
	mov cl, al			;cl <= 000hhhhh (previou hour)
	pop ax
    
    xor ch, ch          ;check hour
    cmp al, cl
    je computeMinDiff   ;if current hour > previous hour...
    mov ch, 60          ;...add 60 to current minutes
    
computeMinDiff:
    mov ax, [bp+6]      ;keep current minutes
    shl ax, 1           ;ah <= xxmmmmmm
    shl ax, 1
	and ah, 00111111B	;ah <= 00mmmmmm
	add ch, ah
    
    mov dx, [bp+10]     ;keep previous minutes
    shl dx, 1           ;dh = xxmmmmmm
    shl dx, 1
	and dh, 00111111B	;dh = 00mmmmmm	
	sub ch, dh          ;difference of minutes
    
    mov ax, [bp+6]      ;keep current seconds
    and al, 00111111B   ;al <= 00ssssss       
        
    mov dx, [bp+10]     ;keep previous seconds
    and dl, 00111111B   ;dl <= 00ssssss
    
    cmp al, dl          ;if current seconds >= previous seconds...
    jae computeSecDiff  ;...compute difference of seconds
    sub ch, 1           ;otherwise decrease minutes...
    add al, 60          ;...and add 60 to current seconds

computeSecDiff:
    sub al, dl
    mov cl, al          ;cx <= 00mmmmmm00ssssss
    
    mov ax, [bp+6]      ;new previous time = this current time
    mov [bp+10], ax
    mov ax, [bp+4]
    mov [bp+8], ax
    
    mov [bp+6], cx      ;store result
              
    pop dx
    pop cx
    pop ax      
    pop bp
    ret
computeTimeDifference endp    


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


;Procedure to print station code
printStation proc
    push bp
    mov bp, sp
                 
    push cx  
    push ax
    push dx
    
    mov cx, [bp+4]
    cmp cl, 1
    je printA
    cmp cl, 2
    je printB
    cmp cl, 3
    je printC
    cmp cl, 4
    je printD
    cmp cl, 5
    je printE
printA:
    mov ah, 2
    mov dl, 'A'
    int 21h
    jmp exitPrintStation
printB:
    mov ah, 2
    mov dl, 'B'
    int 21h
    jmp exitPrintStation
printC:
    mov ah, 2
    mov dl, 'C'
    int 21h
    jmp exitPrintStation
printD:
    mov ah, 2
    mov dl, 'D'
    int 21h
    jmp exitPrintStation
printE:
    mov ah, 2
    mov dl, 'E'
    int 21h

exitPrintStation: 
    pop dx
    pop ax
    pop cx
    pop bp 
    
    ret
printStation endp

    
    end    