#include "button.h"
#include "lpc17xx.h"
#include "../led/led.h"

void EINT0_IRQHandler (void)	    /* button 0 */
{
	LPC_GPIO2->FIOCLR = 0x000000FF;
	LED_On(5);
  LPC_SC->EXTINT |= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  	/* Button Key 1 */  
{
  //LED_On(1);
	
	/*
	int Current_Led_On, Led_Will_On;
	Current_Led_On = LPC_GPIO2->FIOPIN;
	Current_Led_On = Current_Led_On & 0x000000ff;
	if (Current_Led_On == 0x00000080)
		Led_Will_On = 0x00000001;
	else
		Led_Will_On = Current_Led_On << 1;
	LPC_GPIO2->FIOCLR = Current_Led_On;
	LPC_GPIO2->FIOSET = Led_Will_On;
	*/
	Deboucing();
	Get_led();
	int Led_Will_On;
	led_value = LPC_GPIO2->FIOPIN;
	led_value = led_value & 0x000000ff;
	if (led_value == 0x00000080)
		Led_Will_On = 0x00000001;
	else
		Led_Will_On = led_value << 1;
	LPC_GPIO2->FIOCLR = led_value;
	LPC_GPIO2->FIOSET = Led_Will_On;
	
	LPC_SC->EXTINT |= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  	/* Button Key 2 */
{
	//LED_Off(0);
	//LED_Off(1);
	
	/*
	int Current_Led_On, Led_Will_On;
	Current_Led_On = LPC_GPIO2->FIOPIN;
	Current_Led_On = Current_Led_On & 0x000000ff;
	if (Current_Led_On == 0x00000001)
		Led_Will_On = 0x00000080;
	else
		Led_Will_On = Current_Led_On >> 1;
	LPC_GPIO2->FIOCLR = Current_Led_On;
	LPC_GPIO2->FIOSET = Led_Will_On;
	*/
	
	Deboucing();
	Get_led();
	int Led_Will_On;
	led_value = LPC_GPIO2->FIOPIN;
	led_value = led_value & 0x000000ff;
	if (led_value == 0x00000001)
		Led_Will_On = 0x00000080;
	else
		Led_Will_On = led_value >> 1;
	LPC_GPIO2->FIOCLR = led_value;
	LPC_GPIO2->FIOSET = Led_Will_On;
  LPC_SC->EXTINT |= (1 << 2);     /* clear pending interrupt         */    
}


