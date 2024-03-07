#include "uarts.h"

int main()
{
	int ret = 0;
	volatile unsigned int * axi;
	volatile unsigned int regs[NUM_REGS];
	unsigned long long uarts_d[MAX_UARTS];

	uarts(axi, 1, uarts_d);
	uarts(axi, 3, uarts_d);

	return ret;
}
