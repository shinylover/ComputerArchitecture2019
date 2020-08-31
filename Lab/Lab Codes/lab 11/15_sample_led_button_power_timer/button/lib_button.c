#include "button.h"
#include "lpc17xx.h"
#include "../timer/timer.h"
#include "../led/led.h"

/**
 * @brief  Function that initializes Button INT0
 */
void BUTTON_init(void) {

  LPC_PINCON->PINSEL4    |= (1 << 20);		 /* External interrupt 0 pin selection */
  LPC_GPIO2->FIODIR      &= ~(1 << 10);    /* PORT2.10 defined as input          */

  LPC_PINCON->PINSEL4    |= (1 << 22);     /* External interrupt 0 pin selection */
  LPC_GPIO2->FIODIR      &= ~(1 << 11);    /* PORT2.11 defined as input          */
  
  LPC_PINCON->PINSEL4    |= (1 << 24);     /* External interrupt 0 pin selection */
  LPC_GPIO2->FIODIR      &= ~(1 << 12);    /* PORT2.12 defined as input          */

  LPC_SC->EXTMODE = 0x7;

  NVIC_EnableIRQ(EINT2_IRQn);              /* enable irq in NVIC                 */
	/* NVIC_SetPriority(EINT2_IRQn, 1); */
  NVIC_EnableIRQ(EINT1_IRQn);              /* enable irq in NVIC                 */
	/* NVIC_SetPriority(EINT1_IRQn, 2); */
  NVIC_EnableIRQ(EINT0_IRQn);              /* enable irq in NVIC                 */
	/* NVIC_SetPriority(EINT0_IRQn, 3); */
}


/**************************************************************************************/


int i=0, n = 1, j = 0, counter;
int interrupt=1; 							//indicate cuuent intrupt is even or ood
int arr_source[255];							//used to store the random light sequence


void Check(int temp)					//check current led is right or not 
{
	if(arr_source[j] == temp)
		{
			int delayTimes1 = 0x001fffff;
					while(delayTimes1)
						delayTimes1--;
			j++;
			if(j == n)
			{
				all_LED_off();
				LPC_GPIO2->FIOSET = n;
				int delayTimes = 0x001fffff;
					while(delayTimes)
						delayTimes--;
				n++;
				i = 0;
				j = 0;
			}
			all_LED_off();
		}
		else 
		{
				for(; j < n; j++)
				{
					LPC_GPIO2->FIOSET = arr_source[j];
					//all_LED_on();
					int delayTimes = 0x000fffff;
					while(delayTimes)
						delayTimes--;
					all_LED_off();
				}
				i = 0;
				j = 0;
				n = 1;
		}
}

void Simon_LED_On_Off(void)    // light on led4, 5, 6 randomly, light off all led 
{
	if (interrupt == 1)
	{
		Simon_LED_On();
		interrupt = 0;
		arr_source[i] = timerValue;
	
	}else
	{
		all_LED_on();
		int delayTimes = 0x000fffff;
		while(delayTimes)
			delayTimes--;
		all_LED_off();
		interrupt = 1;
		i++;
	}
}