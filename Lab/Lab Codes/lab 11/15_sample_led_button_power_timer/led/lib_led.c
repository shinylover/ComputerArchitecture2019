/*********************************************************************************************************
**--------------File Info---------------------------------------------------------------------------------
** File name:           lib_led.c
** Descriptions:        Atomic led init functions    
**--------------------------------------------------------------------------------------------------------       
*********************************************************************************************************/
#define LED_NUM     8                   /* Number of user LEDs                */
#include "LPC17xx.h"
#include "led.h"
#include "../timer/timer.h"

const unsigned long led_mask[] = {1UL << 7, 1UL << 6, 1UL << 5, 1UL << 4, 1UL << 3, 1UL << 2, 1UL << 1, 1UL};

/*----------------------------------------------------------------------------
  Function that initializes LEDs
 *----------------------------------------------------------------------------*/

void LED_init(void)
{
	LPC_PINCON->PINSEL4 &= 0xFFFF0000;	// PIN mode GPIO: P2.0-P2.7 are set to zero
	LPC_GPIO2->FIODIR |= 0x000000FF;		// P2.0-P2.7 on PORT2 defined as Output
}

void LED_deinit(void)
{
  LPC_GPIO2->FIODIR &= 0xFFFFFF00;
}

/*----------------------------------------------------------------------------
  Functions that turn on/off all led
 *----------------------------------------------------------------------------*/

void all_LED_on(void)
{
	LPC_GPIO2->FIOSET = 0x000000FF;
}

void all_LED_off(void)
{
	LPC_GPIO2->FIOCLR = 0x000000FF;
}

/*----------------------------------------------------------------------------
  Functions that turn on/off the requested led
 *----------------------------------------------------------------------------*/
void LED_On(unsigned int num)
{
  LPC_GPIO2->FIOPIN |= led_mask[num];
}

void LED_Off(unsigned int num)
{
  LPC_GPIO2->FIOPIN &= ~led_mask[num];
}

void Simon_LED_On(void)
{
	int getTimer = GetTimer0();
	if (getTimer == 0)
		LPC_GPIO2->FIOSET = 0x00000080;
	else if(getTimer == 1)
		LPC_GPIO2->FIOSET = 0x00000040;
	else 
		LPC_GPIO2->FIOSET = 0x00000020;
	
	timerValue = LPC_GPIO2->FIOPIN & 0x000000ff;
}
