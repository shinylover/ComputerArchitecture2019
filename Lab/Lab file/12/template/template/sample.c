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
#include "ADC_DAC/adc_dac.h"

#define MAX 50

unsigned int PriceList[60] = {0x004, 20, 0x006, 15, 0x007, 10, 0x00A, 5, 0x010, 8,
			0x012, 7, 0x016, 22, 0x017, 17, 0x018, 38, 0x01A, 22,
			0x01B, 34, 0x01E, 11, 0x022, 3, 0x023, 9, 0x025, 40,
			0x027, 12, 0x028, 11, 0x02C, 45, 0x02D, 10, 0x031, 40,
			0x033, 45, 0x035, 9, 0x036, 11, 0x039, 12, 0x03C, 19,
			0x03E, 1, 0x041, 20, 0x042, 30, 0x045, 12, 0x047, 7};

unsigned int ItemList[8] = {0x022, 4, 0x006, 1, 0x03E, 10, 0x017, 2};

/*----------------------------------------------------------------------------
  Main Program
 *----------------------------------------------------------------------------*/
int main (void)
{  
	// Uncomment the instructions (and add others) according to your needs
	//LED_init();					/* LED Initialization */
	//BUTTON_init();				/* BUTTON Initialization */
	//init_timer(0,0x0EE6B280);		/* TIMER0 Initialization */
	//enable_timer(0);
	//ADC_init();
	//DAC_init();
	
	LPC_SC->PCON |= 0x1;	/* power-down mode */								
	LPC_SC->PCON &= 0xFFFFFFFFD; 
	SCB->SCR |= 0x2;			/* set SLEEPONEXIT */	
	
	//ADC_start_conversion();

	__ASM("wfi");
}
