#include "button.h"
#include "lpc17xx.h"
#include "../timer/timer.h"

extern unsigned int PriceList[];
extern unsigned int ItemList[];
extern int sequentialSearch (unsigned int[], unsigned int[]);
extern int binarySearch (unsigned int[], unsigned int[]);
extern unsigned int expense;
extern unsigned int IR;
extern unsigned int MAX_val;

void EINT0_IRQHandler (void)	  
{
	LPC_SC->EXTINT |= (1 << 0);     /* clear pending interrupt         */
}


void EINT1_IRQHandler (void)	  
{
	expense = sequentialSearch(PriceList, ItemList);
	if (expense > MAX_val){
		IR = 5000;
		enable_timer(0);    // for voice 2 sec
	}
	
	LPC_SC->EXTINT |= (1 << 1);     /* clear pending interrupt         */
}

void EINT2_IRQHandler (void)	  
{
	expense = binarySearch(PriceList, ItemList);
	
	LPC_SC->EXTINT |= (1 << 2);     /* clear pending interrupt         */    
}


