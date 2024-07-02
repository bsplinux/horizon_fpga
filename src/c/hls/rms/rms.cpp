#include <hls_math.h>
#include <ap_int.h>

float update_rms(float rms, short sample)
{
	float res;
	res = sample;
	res = res * res;
	res += rms;

	return res;
}

float finilize_rms(float rms, unsigned char sample_cnt)
{
	float res = 0;
	res = rms / sample_cnt;
	res = sqrt(res);
	return res;
}


void rms_syn(
	short *sample,
	bool *zero_cross,
	short *d_out,
	int cnt // set to 0 (running infinitely) for synthesis
)
{
	float old_rms[2] = {0};
	float rms = 0;
	unsigned char sample_cnt = 0;
	main_loop: for(;;)
	{
		short s = *sample++; // waiting infinitely for new samples
		sample_cnt++;
		rms = update_rms(rms, s);
		if (*zero_cross++)
		{
			rms = finilize_rms(rms, sample_cnt);
			*d_out++ = (rms + old_rms[0] + old_rms[1])/3;
			old_rms[1] = old_rms[0];
			old_rms[0] = rms;
			rms = 0;
			sample_cnt = 0;
			// for simulation set the number of outputs needed, for synthesis set to 0 for infinite
			if(cnt != 0)
			{
				if (cnt-- == 1)
					return;
			}
		}
	}
}


