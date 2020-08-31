#include <stdint.h>
#include "LPC17xx.h"
#include "math.h"

int sumSuareRoot(int a, int b){
	double realnumber;
	int result;
	a = a*a;
	b = b*b;
	realnumber = a+b;
	realnumber = sqrt(realnumber);
	result = floor(realnumber + 0.5);
}