#include <hls_math.h>
#include <ap_int.h>

float update_rms(float rms, ap_uint<12> sample)
{
	const float calc = (6.72e-3 * 4096/3);
	float res = 0;
	if (sample > 2048)
		res = sample - 2048;
	else
		res = 2048 - sample;
	res = res / calc;
	res = res * res;
	res += rms;

	return res;
}

float finilize_rms(float rms, unsigned char n)
{
	float res = 0;
	res = rms / n;
	res = sqrt(res);
	return res;
}


void rms(
	volatile ap_uint<12> sample,
	volatile unsigned char n,
	volatile bool zero_cross,
	ap_uint<12> *d_out
		)
{
	float old_rms[2] = {0};
	float rms = 0;

	main_loop: for(;;)
	{
		ap_uint<12> s = sample; // waiting infinitly for new samples

		rms = update_rms(rms, s);
		if (zero_cross)
		{
			rms = finilize_rms(rms, n);
			*d_out = (rms + old_rms[0] + old_rms[1])/3;
			old_rms[1] = old_rms[0];
			old_rms[0] = rms;
			rms = 0;
		}
	}
}
