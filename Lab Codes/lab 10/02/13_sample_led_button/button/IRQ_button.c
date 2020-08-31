#include "button.h"
#include "lpc17xx.h"
#include "../led/led.h"

int counter;

void EINT0_IRQHandler (void)	  	// 0
{
	
		if(randomly == 1)
			LED_On(4);
		else
			LED_On(5);

			int ledOn = LPC_GPIO2->FIOSET & 0x000000ff;
			
			if(ledOn == 0x00000015)
				LED_On(7);
			else if (ledOn == 0x0000002A)
				LED_On(7);
			else
			{
			LED_On(6);
			}		
  LPC_SC->EXTINT |= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  	// Button Key 1
{
  all_LED_off();
	if(randomly == 1)
		LED_On(0);
	else
		LED_On(1);

	LPC_SC->EXTINT |= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  	// Button Key 2
{
	if(randomly == 1)
		LED_On(2);
	else
		LED_On(3);

	
  LPC_SC->EXTINT |= (1 << 2);     /* clear pending interrupt         */    
}


