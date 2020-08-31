/*********************************************************************************************************
**--------------File Info---------------------------------------------------------------------------------
** File name:           IRQ_adc.c
** Descriptions:        functions to manage A/D interrupts
** Correlated files:    adc.h
**--------------------------------------------------------------------------------------------------------       
*********************************************************************************************************/

#include "lpc17xx.h"
#include "adc_dac.h"
#include "../led/led.h"
#include "../timer/timer.h"

/*----------------------------------------------------------------------------
  A/D IRQ: Executed when A/D Conversion is ready (signal from ADC peripheral)
 *----------------------------------------------------------------------------*/

unsigned short AD_current;   
unsigned short AD_last = 0xFF;     /* Last converted value               */

/* k = 1 / f' * f / n =  
	= f / (f' * n) =
	= 25MHz/(f' * 45) */

const int freqs[8]={2120,1890,1684,1592,1417,1263,1125,1062};
/*
262Hz	k=2120		c4
294Hz	k=1890		d4
330Hz	k=1684		e4
349Hz	k=1592		f4
392Hz	k=1417		g4
440Hz	k=1263		a5
494Hz	k=1125		b5
523Hz	k=1062		c5
*/

void ADC_IRQHandler(void) {
	unsigned short led_last, led_current;
  /* Use either one of these instructions to read conversion result */	
  // AD_current = ((LPC_ADC->ADGDR>>4) & 0xFFF);	/* if global interrupts are enabled */
	AD_current = ((LPC_ADC->ADDR5 >> 4) & 0xFFF);	/* if interrupts on channel 5 are enabled */
	
	led_last = AD_last * 7/ 0xFFF;				// ad_last : AD_max = x : 7
	led_current = AD_current * 7/ 0xFFF;	// ad_current : AD_max = x : 7
  if(led_current != led_last){
		LED_Off(led_last);	  	
		LED_On(led_current);	
		disable_timer(0);
		reset_timer(0);
		init_timer(0,freqs[led_current]);
		enable_timer(0);
		
		AD_last = AD_current;
  }
	
}
