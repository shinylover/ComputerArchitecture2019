    .model small
    .stack
    .data
    
JT          DW  UPDATEjob, DISPLAYjob, REFUELjob
UPDATEmsg   DB  '[1] Enter an update$'
DISPLAYmsg  DB  '[2] Display current available parameters$'
REFUELmsg   DB  '[3] Completely refuel the tank and reset all parameters$'
EXITmsg     DB  '[0] Exit the program$'
MENUmsg     DB  'User Menu:$'

UPDATE1     DB  'Insert deciliters burned: $'
UPDATE2     DB  'Insert km driven: $'
UPDATE3     DB  'Insert minutes driven: $'

DISPLAY1    DB  '- Overall number of Km driven: $'
DISPLAY2    DB  '- Overall duration of the drive in minutes: $'   
DISPLAY3    DB  '- Overall used deciliters of fuel: $'
DISPLAY4    DB  '- Number of liters still in the tank: $'
DISPLAY5    DB  '- Average speed in km/hour: $'
DISPLAY6    DB  '- Overall duration of the drive in hours and minutes: $'
DISPLAY7    DB  '- km/liter: $'
DISPLAY8    DB  '- deciliters per 100 km: $'
DISPLAY9    DB  '- Further drivable Km with the available fuel in the tank: $' 

REFDONEmsg  DB  'Tank refilled and parameters reset$'  

UPDATE      DB  3 DUP(?)    ;[0] <- dl, [1] <- km, [2] <- min

KM_DRIVEN       DW  0
DRIVE_DURATION  DB  0   ;overal duration in minutes
DL_USED         DW  0   
L_TANK          DB  32  ;liters still in the tank (at the beginning: 32)    
AVERAGE_SPEED   DB  0  
DURATION_HOUR   DB  0
DURATION_MIN    DB  0 
KM_PER_L        DB  0
DL_PER_100KM    DB  0
DRIVABLE_KM     DW  0

BUFFER  DB  5 DUP(0)  

    .code
    .startup    
    
;Print User Menu
userMenu: 
    call emptyRow
    mov ah, 9
    mov dx, offset MENUmsg
    int 21h     
    call emptyRow            
    
    mov ah, 9
    mov dx, offset UPDATEmsg
    int 21h
    call emptyRow
    
    mov ah, 9
    mov dx, offset DISPLAYmsg
    int 21h             
    call emptyRow  
    
    mov ah, 9
    mov dx, offset REFUELmsg
    int 21h             
    call emptyRow  
    
    mov ah, 9
    mov dx, offset EXITmsg
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
    

UPDATEjob:
    mov cx, 0
    call emptyRow  
    mov ah, 9
    mov dx, offset UPDATE1
    int 21h 
    
    mov ah, 1
    int 21h   
    sub al, '0'
    add cl, al    
    int 21h
    cmp al, 13
    je insertKm
    sub al, '0'
    mov dl, al
    mov al, 10
    mul cl
    mov cx, ax
    add cl, dl
    mov ah, 1
    int 21h
    cmp al, 13
    je insertKm
    sub al, '0'
    mov dl, al
    mov al, 10
    mul cl
    mov cx, ax
    add cl, dl    

insertKm:
    mov UPDATE[0], cl   ;save deciliters  
    mov cl, 0
    call emptyRow  
    mov ah, 9
    mov dx, offset UPDATE2
    int 21h 
    
    mov ah, 1
    int 21h   
    sub al, '0'
    add cl, al    
    int 21h
    cmp al, 13
    je insertMin
    sub al, '0'
    mov dl, al
    mov al, 10
    mul cl
    mov cl, al
    add cl, dl
    mov ah, 1
    int 21h
    cmp al, 13
    je insertMin
    sub al, '0'
    mov dl, al
    mov al, 10
    mul cl
    mov cl, al
    add cl, dl

insertMin:
    mov UPDATE[1], cl   ;save kilometers     
    mov cl, 0
    call emptyRow  
    mov ah, 9
    mov dx, offset UPDATE3
    int 21h 
    
    mov ah, 1
    int 21h   
    sub al, '0'
    add cl, al    
    int 21h
    cmp al, 13
    je computeParameters
    sub al, '0'
    mov dl, al
    mov al, 10
    mul cl
    mov cl, al
    add cl, dl
    mov ah, 1
    int 21h
    cmp al, 13
    je computeParameters
    sub al, '0'
    mov dl, al
    mov al, 10
    mul cl
    mov cl, al
    add cl, dl   

computeParameters:
    mov UPDATE[2], cl   ;save minutes    
    ;***Item1***
    ;- Compute the overall km driven (UPDATE[1] = kkkkkkkk)
    xor ah, ah
    mov al, UPDATE[1]
    add KM_DRIVEN, ax
    
    ;- Compute the overall duration of the drive in minutes (UPDATE[2] = 00mmmmmm)
    mov al, UPDATE[2]
    add DRIVE_DURATION, al
    
    ;- Compute the total used deciliters of fuel (UPDATE[0] = dddddddd)
    mov al, UPDATE[0] 
    xor ah, ah
    add DL_USED, ax
    
    ;- Compute the total liters still in the tank
    mov ax, 320     ;max capacity
    sub ax, DL_USED 
    mov cl, 10
    div cl          ;deciliters to liters
    mov L_TANK, al  ;al = liters still in the tank
    
    ;***Item2*** 
    ;- Compute average speed
    mov ax, 60
    mov cx, KM_DRIVEN
    mul cx          
    mov cl, DRIVE_DURATION
    xor ch, ch
    div cx
    mov AVERAGE_SPEED, al
    
    ;***Item3***
    ;- Compute duration of the drive in hour and minutes
    xor ah, ah
    mov al, DRIVE_DURATION
    mov cl, 60
    div cl
    mov DURATION_HOUR, al
    mov DURATION_MIN, ah
    
    ;***Item4***
    ;- Compute number of km/l   
    mov ax, KM_DRIVEN
    mov cx, 10
    mul cx
    mov cx, DL_USED
    div cx
    MOV KM_PER_L, al
    
    ;***Item5***  
    ;- Compute dl/100km
    mov ax, DL_USED
    mov cx, 100
    mul cx
    mov cx, KM_DRIVEN
    div cx
    mov DL_PER_100KM, al
    
    ;***Item6***
    ;- Compute further drivable Km with the available fuel in the tank     
    mov ax, 320
    sub ax, DL_USED
    mov cx, KM_DRIVEN
    mul cx
    mov cx, DL_USED
    div cx
    mov DRIVABLE_KM, ax   
    
    call emptyRow
    jmp userMenu


DISPLAYjob: 
    lea ax, BUFFER   
    push ax          
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY1
    int 21h     
    mov ax, KM_DRIVEN
    push ax
    call printDecimal
    pop ax 
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY2
    int 21h     
    mov al, DRIVE_DURATION
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY3
    int 21h     
    mov ax, DL_USED
    push ax
    call printDecimal
    pop ax  
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY4
    int 21h     
    mov al, L_TANK
    xor ah, ah
    push ax
    call printDecimal
    pop ax 
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY5
    int 21h     
    mov al, AVERAGE_SPEED
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY6
    int 21h     
    mov al, DURATION_HOUR
    xor ah, ah
    push ax
    call printDecimal
    pop ax 
    mov ah, 2
    mov dl, 'h'
    int 21h
    mov dl, ' '
    int 21h
    mov al, DURATION_MIN
    xor ah, ah
    push ax
    call printDecimal
    pop ax 
    mov ah, 2
    mov dl, 'm'
    int 21h
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY7
    int 21h     
    mov al, KM_PER_L
    xor ah, ah
    push ax
    call printDecimal
    pop ax
    
    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY8
    int 21h     
    mov al, DL_PER_100KM
    xor ah, ah
    push ax
    call printDecimal
    pop ax

    call emptyRow
    mov ah, 9
    mov dx, offset DISPLAY9
    int 21h     
    mov ax, DRIVABLE_KM
    push ax
    call printDecimal
    pop ax
  
  
    pop ax
    call emptyRow     
    jmp userMenu
       
       
REFUELjob:         
    mov KM_DRIVEN, 0
    mov DRIVE_DURATION, 0   
    mov DL_USED, 0   
    mov L_TANK, 32  
    mov AVERAGE_SPEED, 0  
    mov DURATION_HOUR, 0
    mov DURATION_MIN, 0 
    mov KM_PER_L, 0
    mov DL_PER_100KM, 0
    mov DRIVABLE_KM, 0  
    
    call emptyRow  
    mov ah, 9
    mov dx, offset REFDONEmsg
    int 21h  
    
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