    .model small
    .stack
    .data

LINE  DB  4 DUP(?)    ;input array
RATES   DB  3 DUP(?)    ;cost units

DURATION_OF_RENTAL  DW  ?
COST_TO_BE_CHARGED  DW  ?
TAX                 DW  ?

BUFFER  DB  8  DUP(0)

INSERTmsg   DB  'Insert data of the rental: $'
STDmsg      DB  '  Starting Day = $'
STHmsg      DB  '  Starting Hour = $'
ENDmsg      DB  '  Ending Day = $'
ENHmsg      DB  '  Ending Hour = $'
NEWmsg      DB  '  Do you want evaluate a new rental [y/n]?$'
DURATIONmsg DB  'Duration: $'
Wmsg        DB  ' weeks, $'
Dmsg        DB  ' days, $'
Hmsg        DB  ' hours$'
COSTmsg     DB  'Cost = $'
TAXmsg      DB  'Tax = $'    
    .code
    .startup

    mov RATES[0], 2
    mov RATES[1], 11
    mov RATES[2], 50  
    
evaluateRental:
    call emptyRow
    mov ah, 9
    mov dx, offset INSERTmsg
    int 21h
    
    call emptyRow       ;read starting day
    mov ah, 9
    mov dx, offset STDmsg
    int 21h
    
    mov ax, 3                  
    push ax
    call readDecimal
    pop ax
    mov cl, 5
    shl ax, cl
    mov LINE[0], ah
    mov LINE[1], al

    call emptyRow       ;read starting hour
    mov ah, 9
    mov dx, offset STHmsg
    int 21h
    
    mov ax, 2                  
    push ax
    call readDecimal
    pop ax
    or LINE[1], al
    
    call emptyRow       ;read ending day
    mov ah, 9
    mov dx, offset ENDmsg
    int 21h
    
    mov ax, 3                  
    push ax
    call readDecimal
    pop ax
    mov cl, 5
    shl ax, cl
    mov LINE[2], ah
    mov LINE[3], al
    
    call emptyRow       ;read ending hour
    mov ah, 9
    mov dx, offset ENHmsg
    int 21h
    
    mov ax, 2                  
    push ax
    call readDecimal
    pop ax
    or LINE[3], al 
    
computeDuration:
    mov ah, LINE[0]   ;xxSSSSSS
    and ah, 00111111B
    mov al, LINE[1]   ;SSSHHHHH
    mov cl, 5
    shr ax, cl          ;<ax> = starting day
    mov dh, LINE[2]   ;xxEEEEEE
    and dh, 00111111B
    mov dl, LINE[3]   ;EEEhhhhh
    shr dx, cl          ;<dx> = ending day
    sub dx, ax
    sub dx, 1           ;<dx> = plenty days of rental
    
    mov ah, LINE[1]   ;SSSHHHHH    
    and ah, 00011111B   ;<ah> = starting hour
    mov al, LINE[3]   ;EEEhhhhh
    and al, 00011111B   ;<al> = ending hour
    sub al, ah          ;h-H
    cmp al, 0           ;starting hour equal to ending hour 
    je addOneDay        ;  => +1 complete day
    cmp al, 0
    jl storeHours       ;if h-H < 0 => incomplete day
    add dx, 1           ;if h-H > 0 => one complete day + some hours
    mov cl, al
    xor ch, ch
    mov DURATION_OF_RENTAL, cx  ;save hours (h-H)
    jmp computeWeeks
addOneDay:
    add dx, 1
    mov cx, 0
    mov DURATION_OF_RENTAL, cx  ;save 0 hours
    jmp computeWeeks
storeHours:
    add ah, 24
    mov cl, ah
    xor ch, ch
    mov DURATION_OF_RENTAL, cx  ;store hours (<24)
computeWeeks:
    mov ax, dx
    mov cl, 7          
    div cl                      ;<ah> = days of rental (remainder), <al> = weeks of rental (result)
                                ;build DURATION_OF_RENTAL value
    mov dx, DURATION_OF_RENTAL  ;already containing hours of rental in the last 5 bits
    mov cl, 5
    shl ah, cl          ;DDD00000
    or dl, ah           ;DDDHHHHH
    mov dh, al          ;00WWWWWW
    mov DURATION_OF_RENTAL, dx
    
    call emptyRow
    lea ax, BUFFER
    push ax
    mov ah, 9
    mov dx, offset DURATIONmsg
    int 21h
    mov ax, DURATION_OF_RENTAL
    mov al, ah
    xor ah, ah
    push ax
    call printDecimal
    pop ax 
    mov ah, 9
    mov dx, offset Wmsg
    int 21h
    mov ax, DURATION_OF_RENTAL
    xor ah, ah
    mov cl, 5
    shr al, cl
    push ax
    call printDecimal
    pop ax
    mov ah, 9
    mov dx, offset Dmsg
    int 21h
    mov ax, DURATION_OF_RENTAL
    xor ah, ah
    and al, 00011111B
    push ax
    call printDecimal
    pop ax
    pop ax
    mov ah, 9
    mov dx, offset Hmsg
    int 21h
    
computeCost:
    mov dx, DURATION_OF_RENTAL
    xor dh, dh
    and dl, 00011111B   ;keep only hours
    mov al, RATES[0]    ;hourly rate
    mul dl              ;hourly rate * hours => <ax> = cost from hours
    mov dl, RATES[1]    ;daily rate
    xor dh, dh
    cmp ax, dx          ;if cost from hours < daily rate 
    jb maintainHours    ;  => maintain this cost
                        ;otherwise add 1 to #days and compute cost from days and hours
    mov dx, DURATION_OF_RENTAL
    mov ax, 0           ;no cost from hours previously computed
    xor dh, dh
    and dl, 11100000B
    mov cl, 5
    shr dx, cl          ;<dh> = 0, <dl> = #days (duration)
    add dl, 1           ;#days updated
    jmp computeCostFromDays
maintainHours:
    mov dx, DURATION_OF_RENTAL
    xor dh, dh
    and dl, 11100000B
    mov cl, 5
    shr dx, cl          ;<dh> = 0, <dl> = #days (duration)

computeCostFromDays:
    mov cx, ax          ;maintain cost from hours
    mov al, RATES[1]    ;daily rate
    mul dl              ;<ax> = days * daily rate
    add cx, ax          ;add cost from days to previously computed cost from hours
    mov dl, RATES[2]    ;weekly rate
    xor dh, dh
    cmp cx, dx          ;if cost from days and hours < weekly rate
    jb maintainDaysHours ;  => maintain this cost
                        ;otherwise add 1 to #weeks and compute total cost
    mov cx, 0
    mov dx, DURATION_OF_RENTAL
    xor dl, dl
    and dh, 00111111B    ;<dh> = #weeks
    add dh, 1           ;weeks updated
    jmp computeTotalCost
maintainDaysHours:
    mov dx, DURATION_OF_RENTAL
    xor dl, dl
    and dh, 00111111B    ;<dh> = #weeks (original)
computeTotalCost:
    mov al, RATES[2]    ;weekly rate
    mul dh              ;<ax> = weekly rate * weeks
    add cx, ax          ;<cx> = find total cost
    mov COST_TO_BE_CHARGED, cx
    
    call emptyRow
    lea ax, BUFFER
    push ax
    mov ah, 9
    mov dx, offset COSTmsg
    int 21h 
    mov ax, COST_TO_BE_CHARGED
    push ax
    call printDecimal
    pop ax
    pop ax
    
computeTax:
    xor dx, dx
    mov ax, COST_TO_BE_CHARGED
    shr ax, 1
    adc dl, 0   ;0000000CF1
    mov cl, 6
    shl dl, cl  ;0CF1000000
    shr ax, 1
    adc dh, 0   ;0000000CF2
    mov cl, 7
    shl dh, cl  ;CF20000000
    or dh, dl   ;<dh> = CF2CF1000000
    mov dl, 10000000B   ;0.5 = 10000000B
    cmp dh, dl
    jb saveTax
    add ax, 1
saveTax:
    mov TAX, ax
    
    call emptyRow
    lea ax, BUFFER
    push ax
    mov ah, 9
    mov dx, offset TAXmsg
    int 21h 
    mov ax, TAX
    push ax
    call printDecimal
    pop ax
    pop ax
    
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