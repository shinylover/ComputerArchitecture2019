/*----------------------------------------------------------------------------
 * Name:    sample.c
 *
 * This software is supplied "AS IS" without warranties of any kind.
 *
 * Copyright (c) 2019 Politecnico di Torino. All rights reserved.
 *----------------------------------------------------------------------------*/
                  
#include <stdio.h>
#include "LPC17xx.h"                    /* LPC17xx definitions                */
#include "led/led.h"
#include "button/button.h"
#include "timer/timer.h"

/*----------------------------------------------------------------------------
  Main Program
 *----------------------------------------------------------------------------*/
int main (void)
{  
	LED_init();							/* LED Initialization                 */
	BUTTON_init();						/* BUTTON Initialization              */
	init_timer(0,0x0EE6B280);			/* TIMER0 Initialization              */
	enable_timer(0);
	//LED_On(0);
	//LPC_GPIO2->FIOSET = 0x00000001;
	
	
	//LPC_SC->PCON |= 0x1;	/* power-down mode */								
	//LPC_SC->PCON &= 0xFFFFFFFFD; 
	//SCB->SCR |= 0x2;			/* set SLEEPONEXIT */	
		
	//__ASM("wfi");
	while(1);
}
