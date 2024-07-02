#include <ap_int.h>

void rms_syn(
	short * sample,
	bool * zero_cross,
	short *d_out,
	int cnt
);

const short in_buff[26*3] = {
		0  ,
		18 ,
		36 ,
		51 ,
		63 ,
		71 ,
		74 ,
		73 ,
		67 ,
		57 ,
		44 ,
		27 ,
		9  ,
		-10,
		-28,
		-45,
		-58,
		-68,
		-74,
		-75,
		-72,
		-64,
		-52,
		-37,
		-19,
		-1 ,
		0  ,
		18 ,
		36 ,
		51 ,
		63 ,
		71 ,
		74 ,
		73 ,
		67 ,
		57 ,
		44 ,
		27 ,
		9  ,
		-10,
		-28,
		-45,
		-58,
		-68,
		-74,
		-75,
		-72,
		-64,
		-52,
		-37,
		-19,
		-1 ,
		0  ,
		18 ,
		36 ,
		51 ,
		63 ,
		71 ,
		74 ,
		73 ,
		67 ,
		57 ,
		44 ,
		27 ,
		9  ,
		-10,
		-28,
		-45,
		-58,
		-68,
		-74,
		-75,
		-72,
		-64,
		-52,
		-37,
		-19,
		-1
};

int main()
{
	int ret = 0;
	bool zero_cross[26 * 3] = {false};
	short d_out[3];
	short d_calc[3];
	short s[26*3];
	float old_rms[2] = {0};
	zero_cross[25] = zero_cross[51] = zero_cross[77] = true;

	for(int i = 0; i < 26*3; i++)
	{
		s[i] = in_buff[i];
//		printf("s[%d]=%d ",i,s[i]);
	}

	rms_syn(s, zero_cross, d_out,3);

	float rms = 0;
	float tmp;
	for(int i = 0; i< 26; i++)
	{
		tmp = s[i];
		rms += tmp*tmp;
	}
	rms = sqrt(rms/26);
	d_calc[0] = (rms + old_rms[0] + old_rms[1])/3;
	old_rms[1] = old_rms[0];
	old_rms[0] = rms;
	rms = 0;

	for(int i = 26; i< 52; i++)
	{
		tmp = s[i];
		rms += tmp*tmp;
	}
	rms = sqrt(rms/26);
	d_calc[1] = (rms + old_rms[0] + old_rms[1])/3;
	old_rms[1] = old_rms[0];
	old_rms[0] = rms;
	rms = 0;

	for(int i = 52; i< 78; i++)
	{
		tmp = s[i];
		rms += tmp*tmp;
	}
	rms = sqrt(rms/26);
	d_calc[2] = (rms + old_rms[0] + old_rms[1])/3;
	old_rms[1] = old_rms[0];
	old_rms[0] = rms;
	rms = 0;

	for(int j = 0; j < 3; j++)
	{
		if (d_out[j] != d_calc[j])
		{
			printf("expected: %d, found %d\n",d_calc[j], d_out[j]);
			ret++;
		}
	}
	if(ret==0)
		printf("RMS test OK\n");
	else
		printf("RMS test failed errors: %d\n",ret);

	return ret;
}
