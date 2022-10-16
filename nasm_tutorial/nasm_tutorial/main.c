#include <stdio.h>
#include <stdlib.h>
#include "calc.h"

int main(int argc, char* argv[]) {
	int a, b;
	if (argc >= 3) {
		a = atoi(argv[1]);
		b = atoi(argv[2]);
	}
	else
	{
		a = 12;
		b = 3;
	}
	int add = addition(a, b);
	int sub = subtraktion(a, b);
	int mul = multiplikation(a, b);
	int div = division(a, b);
	printf("%i + %i = %i\n", a, b, add);
	printf("%i - %i = %i\n", a, b, sub);
	printf("%i * %i = %i\n", a, b, mul);
	printf("%i / %i = %i\n", a, b, div);
	
}