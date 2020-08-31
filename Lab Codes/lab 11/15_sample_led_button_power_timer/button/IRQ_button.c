#include "button.h"
#include "lpc17xx.h"
#include "../led/led.h"
#include "../timer/timer.h"



void EINT0_IRQHandler (void)	  // INCT 0
{
	//LED_On(0);
	if(Deoucing()==1)
	{
		if (i != n)
			Simon_LED_On_Off();
		else
		{
			LED_On(0);
			int temp = LPC_GPIO2->FIOPIN & 0x000000ff;
			Check(temp);
		}
	}
	LPC_SC->EXTINT |= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  // Key 1
{
	//LED_On(1);
	if(Deoucing()==1)
	{
		if (i != n)
			Simon_LED_On_Off();
		else
		{
			LED_On(1);
			int temp = LPC_GPIO2->FIOPIN & 0x000000ff;
			Check(temp);
		}
	}
	LPC_SC->EXTINT |= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  // Key 2
{
	//LED_Off(0);
	//LED_Off(1);
	if(Deoucing()==1)
	{
		if (i != n)
			Simon_LED_On_Off();
		else
		{
			LED_On(2);
			int temp = LPC_GPIO2->FIOPIN & 0x000000ff;
			Check(temp);
		}
	}
	LPC_SC->EXTINT |= (1 << 2);     /* clear pending interrupt         */    
}


