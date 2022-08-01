#include "dma_lb_axis_switch.h"
void dma_lb_axis_switch(
	ap_uint<1> dma_loopback_en,
	ap_uint<1> dma_to_ps_counter_en,
	hls::stream<trans_pkt> &from_dma,
	hls::stream<trans_pkt> &to_pl,
	hls::stream<trans_pkt> &from_pl,
	hls::stream<trans_pkt> &to_dma)
{
#pragma HLS INTERFACE ap_ctrl_none port = return
#pragma HLS INTERFACE s_axilite port = dma_loopback_en
#pragma HLS INTERFACE s_axilite port = dma_to_ps_counter_en
#pragma HLS INTERFACE axis port = from_dma
#pragma HLS INTERFACE axis port = to_pl
#pragma HLS INTERFACE axis port = from_pl
#pragma HLS INTERFACE axis port = to_dma

	int send_counter_data = 0;
	ap_uint<16> counter1 = 0;
	ap_uint<32> counter2 = 0;
	if (counter1 < 100)
	{
		counter1++;
		send_counter_data = 0;
	}
	else
	{
		counter1 = 0;
		counter2++;
		send_counter_data = 1;
	}

	trans_pkt tmp1;
	trans_pkt tmp2;
	trans_pkt tmp3;
	if (dma_loopback_en == 1)
	{
		from_dma.read(tmp1);
		to_dma.write(tmp1);
	}
	else if (dma_to_ps_counter_en == 1)
	{
		if (send_counter_data == 1)
		{
			tmp3.data = counter2;
			to_dma.write(tmp3);
		}
	}
	else
	{
		if (!from_dma.empty())
		{
			from_dma.read(tmp2);
			to_pl.write(tmp2);
		}
		if (!from_pl.empty())
		{
			from_pl.read(tmp3);
			to_dma.write(tmp3);
		}
	}
}
