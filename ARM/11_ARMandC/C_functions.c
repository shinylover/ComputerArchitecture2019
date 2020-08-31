# include <math.h>
#define MAX_LENGTH 20
extern int concatenateString(const char *, 	int, const char *, int, char *, int);
int inlineAssembly(int);
int embeddedAssembly(int);

int intSquareRoot(int intNumber)
{
	double realNumber;
	int result;
	realNumber = sqrt(intNumber);
	result = floor(realNumber + 0.5);
	return result;
}

int solution1_grade4 (int a, int b, int c, int d, int e)
{
	/* fake implementation */
	int f;
	f = a + b - c + d - e;
	return f;
}

int main(void)
{
  const char *string1 = "problem solving";
  const char *string2 = "grammar book";
  char string3[MAX_LENGTH];
  int len1 = 3, len2 = 4;
	volatile int len3;	/* the volatile keyword is added to the definition, so the compiler forces the update of len3 with the value returned from concatenateString() */
  int myNumber;
	volatile int sumFirstAndLast;
	
	
	len3 = concatenateString(string1, len1, string2, len2, string3, MAX_LENGTH);
	
	/* instead of declaring len3 as volatile, another possibility to force its updating consists in using it later. */
	/*for (; len3 > 0; len3 --)
		string3[len3 - 1] += 'A' - 'a';*/
	
	/* If len3 is neither declared as volatile or used later, the Call Stack + Locals windows does not show its value */

	__asm("ADD len1, len1, 1");	/* assembly instruction is replaced with a NOP by the compiler because len1 is not used after */
	__asm{MVN len3, len3; ADD len3, 1}
	
	myNumber = 0x7A30458D;
	sumFirstAndLast = inlineAssembly(myNumber);
	
	sumFirstAndLast = 0;
	sumFirstAndLast = embeddedAssembly(myNumber);
	
  while(1);
}

int inlineAssembly(int value)
{
	int var1, var2, res;
	__asm 
	{
		LSR var1, value, 24	/* move the most significant byte */
		AND var2, value, 0x000000FF	/* reset the bytes different from the most significant one */
		ADD res, var1, var2
	}
	return res;
}

/* the X symbol besides the line number is not meaningful*/
__asm int embeddedAssembly(int value)
{
	LSR r1, r0, #24			; move the most significant byte
	AND r2, r0, #0x000000FF		; reset the bytes different from the most significant one
	ADD r0, r1, r2	
	BX lr
}
