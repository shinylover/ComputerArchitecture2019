;/**************************************************************************//**
; * @file     startup_LPC17xx.s
; * @brief    CMSIS Cortex-M3 Core Device Startup File for
; *           NXP LPC17xx Device Series
; * @version  V1.10
; * @date     06. April 2011
; *
; * @note
; * Copyright (C) 2009-2011 ARM Limited. All rights reserved.
; *
; * @par
; * ARM Limited (ARM) is supplying this software for use with Cortex-M
; * processor based microcontrollers.  This file can be freely distributed
; * within development tools that are supporting such ARM based processors.
; *
; * @par
; * THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
; * OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
; * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
; * ARM SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL, OR
; * CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
; *
; ******************************************************************************/

; *------- <<< Use Configuration Wizard in Context Menu >>> ------------------

; <h> Stack Configuration
;   <o> Stack Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Stack_Size      EQU     0x00000200

                AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
__initial_sp

				AREA    PROCESS_STACK, NOINIT, READWRITE, ALIGN=3
				SPACE   Stack_Size
initial_psp

; <h> Heap Configuration
;   <o>  Heap Size (in Bytes) <0x0-0xFFFFFFFF:8>
; </h>

Heap_Size       EQU     0x00000000

                AREA    HEAP, NOINIT, READWRITE, ALIGN=3
__heap_base
Heap_Mem        SPACE   Heap_Size
__heap_limit


                PRESERVE8
                THUMB


; Vector Table Mapped to Address 0 at Reset

                AREA    RESET, DATA, READONLY
                EXPORT  __Vectors

__Vectors       DCD     __initial_sp              ; Top of Stack
                DCD     Reset_Handler             ; Reset Handler
                DCD     NMI_Handler               ; NMI Handler
                DCD     HardFault_Handler         ; Hard Fault Handler
                DCD     MemManage_Handler         ; MPU Fault Handler
                DCD     BusFault_Handler          ; Bus Fault Handler
                DCD     UsageFault_Handler        ; Usage Fault Handler
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     0                         ; Reserved
                DCD     SVC_Handler               ; SVCall Handler
                DCD     DebugMon_Handler          ; Debug Monitor Handler
                DCD     0                         ; Reserved
                DCD     PendSV_Handler            ; PendSV Handler
                DCD     SysTick_Handler           ; SysTick Handler

                ; External Interrupts
                DCD     WDT_IRQHandler            ; 16: Watchdog Timer
                DCD     TIMER0_IRQHandler         ; 17: Timer0
                DCD     TIMER1_IRQHandler         ; 18: Timer1
                DCD     TIMER2_IRQHandler         ; 19: Timer2
                DCD     TIMER3_IRQHandler         ; 20: Timer3
                DCD     UART0_IRQHandler          ; 21: UART0
                DCD     UART1_IRQHandler          ; 22: UART1
                DCD     UART2_IRQHandler          ; 23: UART2
                DCD     UART3_IRQHandler          ; 24: UART3
                DCD     PWM1_IRQHandler           ; 25: PWM1
                DCD     I2C0_IRQHandler           ; 26: I2C0
                DCD     I2C1_IRQHandler           ; 27: I2C1
                DCD     I2C2_IRQHandler           ; 28: I2C2
                DCD     SPI_IRQHandler            ; 29: SPI
                DCD     SSP0_IRQHandler           ; 30: SSP0
                DCD     SSP1_IRQHandler           ; 31: SSP1
                DCD     PLL0_IRQHandler           ; 32: PLL0 Lock (Main PLL)
                DCD     RTC_IRQHandler            ; 33: Real Time Clock
                DCD     EINT0_IRQHandler          ; 34: External Interrupt 0
                DCD     EINT1_IRQHandler          ; 35: External Interrupt 1
                DCD     EINT2_IRQHandler          ; 36: External Interrupt 2
                DCD     EINT3_IRQHandler          ; 37: External Interrupt 3
                DCD     ADC_IRQHandler            ; 38: A/D Converter
                DCD     BOD_IRQHandler            ; 39: Brown-Out Detect
                DCD     USB_IRQHandler            ; 40: USB
                DCD     CAN_IRQHandler            ; 41: CAN
                DCD     DMA_IRQHandler            ; 42: General Purpose DMA
                DCD     I2S_IRQHandler            ; 43: I2S
                DCD     ENET_IRQHandler           ; 44: Ethernet
                DCD     RIT_IRQHandler            ; 45: Repetitive Interrupt Timer
                DCD     MCPWM_IRQHandler          ; 46: Motor Control PWM
                DCD     QEI_IRQHandler            ; 47: Quadrature Encoder Interface
                DCD     PLL1_IRQHandler           ; 48: PLL1 Lock (USB PLL)
                DCD     USBActivity_IRQHandler    ; 49: USB Activity interrupt to wakeup
                DCD     CANActivity_IRQHandler    ; 50: CAN Activity interrupt to wakeup


                IF      :LNOT::DEF:NO_CRP
                AREA    |.ARM.__at_0x02FC|, CODE, READONLY
CRP_Key         DCD     0xFFFFFFFF
                ENDIF


HardFaultStatus			EQU 0xE000ED2C
SystemHandlerControl	EQU 0xE000ED24
UsageFaultStatus		EQU 0xE000ED2A
ConfigurationControl	EQU 0xE000ED14
BusFaultStatus			EQU 0xE000ED29
MemoryFaultStatus		EQU 0xE000ED28	
BusFaultAddressRegister	EQU 0xE000ED38
SYSTICKcontrolAndStatusRegister	EQU 0xE000E010
SYSTICKreloadValueRegister		EQU 0xE000E014
SYSTICKcurrentValueRegister		EQU 0xE000E018
	

                AREA    |.text|, CODE, READONLY


; Reset Handler

Reset_Handler   PROC
                EXPORT  Reset_Handler             [WEAK]
				
		

				; enables specific faults (otherwise a hard fault occurs)		
				LDR r7, =SystemHandlerControl 
				LDR r3, [r7]
				ORR r3, #0x40000	; enable usage fault
				ORR r3, #0x20000	; enable the bus fault
				ORR r3, #0x10000	; enable the memory management fault
				; with one instruction only
				;ORR r3, #0x70000
				STR r3, [r7]
				
				;CHANGE THE NEXT INSTRUCTION WITH THE LABEL OF THE EXCEPTION THAT YOU WANT TO TEST
				B SYSTICKtimer
				
ARMstate		; Example of usage fault caused by trying to switch to the ARM state.
				; Switch to ARM state is obtained with BLX and a register with the least significant bit equal to 0.
				; Cortex-M3 does not support the ARM state, so a usage fault takes place.
				ADRL r0, stop
				BLX r0
						
divisionByZero	MOV r0, #0
				MOV r1, #0x11111111
				; this division does not cause an exception because divide-by-zero trap is not enabled
				UDIV r2, r1, r0
				
				; enable the divide-by-zero trap located in the NVIC
				LDR r7, =ConfigurationControl
				LDR r3, [r7]
				ORR r3, #0x10
				STR r3, [r7]
		
				UDIV r2, r1, r0

unalignedAccess LDR r1, =myVar1
				LDR r2, =myVar2
				; no fault, because unaligned access trap is not enabled
				LDR r3, [r1]	; r3 = 0x44332211
				LDR r4, [r2]	; r4 = 0x55443322

				; enable the unaligned access trap located in the NVIC
				LDR r7, =ConfigurationControl
				LDR r3, [r7]
				ORR r3, #0x8
				STR r3, [r7]
				
				LDR r3, [r1]	; r3 = 0x44332211	; the address is even, but it may generate an exception if it is not a multiple of 4
				LDR r4, [r2]	; r4 = 0x55443322	; the address is odd, so an exception is surely generated

coprocessor		LDC p1, c0, [r1]
				; another example
				; MRC p15, 0, r1, c0, c0, 0

undefinedInstruction		
				; usage fault is generated only if debugging with the board!
				; when simulating the board, the word is present in code memory but not executed
				DCD 0xe7f0def0
				

PSPstack		; Selecting PSP as stack
				MRS r8, CONTROL
				ORR r8, r8, #2
				MSR CONTROL, r8	
				MOV r1, #1
				
				; The initial value of PSP is undefined, and therefore the PSP must be initialized by software before using it.
				; Uncommenting the following instruction will avoid the bus fault 
				LDR SP, =initial_psp

				PUSH {r1}	; bus fault is generated only if debugging with the board!

preciseDataAccessViolation
				; access to a privileged memory location with user level
				; move to user level
				MRS r8, CONTROL
				ORR r8, r8, #1
				MSR CONTROL, r8
				
				LDR r0, =0xE000ED92
				LDR r1, [r0]

branchToNonexecutableRegion
				; branches to 0x40000000: it is the starting address of the Peripheral region, not executable
				LDR r0, =0x40000001
				BX r0 
				
supervisorCall	; move to user level and then call a system function to return to privileged mode
				MRS r8, CONTROL
				ORR r8, r8, #1
				MSR CONTROL, r8
				
				; Trying to swith to privileded level does nots work. 
				; the CONTROL register can only be written in a privileged level.
				; Values written to CONTROL register in user level are ignored (should tbey causes a usage fault instead?)
				MRS r8, CONTROL
				BIC r8, r8, #1
				MSR CONTROL, r8
				
				SVC #4	; returns in user level (system call not implemented)
				SVC #7	; returns with privileged level

SYSTICKtimer
				; execute a loop 10 times. The iteration counter is r4; it is incremented with the SYSTICK timer.
				MOV r4, #0
				
				;Enable SYSTICK timer operation and enable SYSTICK interrupt
				
				; 1) Stop counter to prevent interrupt triggered accidentally.
				; SYSTICK is disabled by writing 0 to the SYSTICK Control and Status register.
				LDR r0, =SYSTICKcontrolAndStatusRegister
				MOV r1, #0
				STR r1, [r0] 
				
				; 2) Write new reload value to the SYSTICK Reload Value register.
				LDR r0, =SYSTICKreloadValueRegister
				LDR r1, =1023 ; Trigger every 1024 cycles (since counter decrement from 1023 to 0, total of 1024 cycles, reload value is set to 1023)
				STR r1, [r0] 
				
				; 3) Write any value to the SYSTICK Current Value register to clear the current value to 0
				; and clear COUNTFLAG (which is bit 16 of SYSTICK Control and Status Register)
				LDR r0, =SYSTICKcurrentValueRegister
				STR r1, [r0] 
				
				; 4) Write to the SYSTICK Control and Status register to start the SYSTICK timer
				LDR r0, =SYSTICKcontrolAndStatusRegister
				MOV r1, #0x7 ; Clock source = core clock, Enable Interrupt, Enable SYSTICK counter
				STR r1, [r0] ; Start counter
				
timerLoop		CMP r4, #10
				BLT timerLoop
				
				
stop			B stop
myVar1			DCB	0x11
myVar2			DCB 0x22
myVar3			DCB 0x33, 0x44, 0x55


                ENDP


; Dummy Exception Handlers (infinite loops which can be modified)

NMI_Handler     PROC
                EXPORT  NMI_Handler               [WEAK]
                B       .
                ENDP
HardFault_Handler\
                PROC
				EXPORT  HardFault_Handler         [WEAK]
				
				; In the NVIC, there is a hard fault status register that can be used 
				; to determine whether the fault was caused by a vector fetch.
				; If not, the hard fault handler will need to check the other FSRs to determine the cause of the hard fault.	
				LDR r7, =HardFaultStatus
				LDR r1, [r7]
				
                BX       LR
                ENDP
MemManage_Handler\
                PROC
                EXPORT  MemManage_Handler         [WEAK]
                
				LDR r7, =MemoryFaultStatus
				LDRB r1, [r7]
				
				B       .
                ENDP
BusFault_Handler\
                PROC
                EXPORT  BusFault_Handler          [WEAK]
                
				LDR r7, =BusFaultStatus
				LDRB r1, [r7]
				
				; if the exception is a recise data access violation, read the fault address in BFAR
				LDR r7, =BusFaultAddressRegister
				LDR r2, [r7]
				
				B       .
                ENDP
UsageFault_Handler\
				PROC
				EXPORT  UsageFault_Handler        [WEAK]
										
				; The NVIC provides a Usage Fault Status register (UFSR) for the usage fault handler 
				; to determine the cause of the fault. Inside the handler, the program code 
				; that causes the error can also be located using the stacked program counter value.
				LDR r7, =UsageFaultStatus
				LDRH r1, [r7]

				BX       LR
                ENDP
SVC_Handler     PROC
                EXPORT  SVC_Handler               [WEAK]
                
				TST LR, #0x4 		; Test EXC_RETURN number in LR bit 2
				ITE EQ 				; if zero (equal) then
				MRSEQ r0, MSP 		; Main Stack was used, put MSP in R0
				MRSNE r0, PSP 		; else, Process Stack was used, put PSP in R0
				LDR r1, [r0, #24]	; Get stacked PC from stack
				LDRB r0, [r1, #-2]	; Get the immediate data from the instruction
				
				CMP r0, #7
				BNE nextSVC
				; SVC 7 changes to privileged level
				MRS r8, CONTROL
				BIC r8, r8, #1
				MSR CONTROL, r8
				B endSVC_Handler
nextSVC			; test with another immediate value, e.g., 5

endSVC_Handler	BX LR ; Return to calling function
                ENDP
DebugMon_Handler\
                PROC
                EXPORT  DebugMon_Handler          [WEAK]
                B       .
                ENDP
PendSV_Handler  PROC
                EXPORT  PendSV_Handler            [WEAK]
                B       .
                ENDP
SysTick_Handler PROC
                EXPORT  SysTick_Handler           [WEAK]
                
				ADD r4, r4, #1
				BX LR	; Return to calling function
                ENDP

Default_Handler PROC

                EXPORT  WDT_IRQHandler            [WEAK]
                EXPORT  TIMER0_IRQHandler         [WEAK]
                EXPORT  TIMER1_IRQHandler         [WEAK]
                EXPORT  TIMER2_IRQHandler         [WEAK]
                EXPORT  TIMER3_IRQHandler         [WEAK]
                EXPORT  UART0_IRQHandler          [WEAK]
                EXPORT  UART1_IRQHandler          [WEAK]
                EXPORT  UART2_IRQHandler          [WEAK]
                EXPORT  UART3_IRQHandler          [WEAK]
                EXPORT  PWM1_IRQHandler           [WEAK]
                EXPORT  I2C0_IRQHandler           [WEAK]
                EXPORT  I2C1_IRQHandler           [WEAK]
                EXPORT  I2C2_IRQHandler           [WEAK]
                EXPORT  SPI_IRQHandler            [WEAK]
                EXPORT  SSP0_IRQHandler           [WEAK]
                EXPORT  SSP1_IRQHandler           [WEAK]
                EXPORT  PLL0_IRQHandler           [WEAK]
                EXPORT  RTC_IRQHandler            [WEAK]
                EXPORT  EINT0_IRQHandler          [WEAK]
                EXPORT  EINT1_IRQHandler          [WEAK]
                EXPORT  EINT2_IRQHandler          [WEAK]
                EXPORT  EINT3_IRQHandler          [WEAK]
                EXPORT  ADC_IRQHandler            [WEAK]
                EXPORT  BOD_IRQHandler            [WEAK]
                EXPORT  USB_IRQHandler            [WEAK]
                EXPORT  CAN_IRQHandler            [WEAK]
                EXPORT  DMA_IRQHandler            [WEAK]
                EXPORT  I2S_IRQHandler            [WEAK]
                EXPORT  ENET_IRQHandler           [WEAK]
                EXPORT  RIT_IRQHandler            [WEAK]
                EXPORT  MCPWM_IRQHandler          [WEAK]
                EXPORT  QEI_IRQHandler            [WEAK]
                EXPORT  PLL1_IRQHandler           [WEAK]
                EXPORT  USBActivity_IRQHandler    [WEAK]
                EXPORT  CANActivity_IRQHandler    [WEAK]

WDT_IRQHandler
TIMER0_IRQHandler
TIMER1_IRQHandler
TIMER2_IRQHandler
TIMER3_IRQHandler
UART0_IRQHandler
UART1_IRQHandler
UART2_IRQHandler
UART3_IRQHandler
PWM1_IRQHandler
I2C0_IRQHandler
I2C1_IRQHandler
I2C2_IRQHandler
SPI_IRQHandler
SSP0_IRQHandler
SSP1_IRQHandler
PLL0_IRQHandler
RTC_IRQHandler
EINT0_IRQHandler
EINT1_IRQHandler
EINT2_IRQHandler
EINT3_IRQHandler
ADC_IRQHandler
BOD_IRQHandler
USB_IRQHandler
CAN_IRQHandler
DMA_IRQHandler
I2S_IRQHandler
ENET_IRQHandler
RIT_IRQHandler
MCPWM_IRQHandler
QEI_IRQHandler
PLL1_IRQHandler
USBActivity_IRQHandler
CANActivity_IRQHandler

                B       .

                ENDP


                ALIGN


; User Initial Stack & Heap

                IF      :DEF:__MICROLIB

                EXPORT  __initial_sp
                EXPORT  __heap_base
                EXPORT  __heap_limit

                ELSE

                IMPORT  __use_two_region_memory
                EXPORT  __user_initial_stackheap
__user_initial_stackheap

                LDR     R0, =  Heap_Mem
                LDR     R1, =(Stack_Mem + Stack_Size)
                LDR     R2, = (Heap_Mem +  Heap_Size)
                LDR     R3, = Stack_Mem
                BX      LR

                ALIGN

                ENDIF


                END
