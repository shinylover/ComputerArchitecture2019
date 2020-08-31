#include <stdint.h>
#include "LPC17xx.h"

extern int myUADD8(int, int);

int main(){
		int var1 = 0x7A30458D;
		int var2 = 0xC3159EAA;
		int sum;
		sum = myUADD8(var1, var2);
		return sum;
}