#include "dma_lb_axis_switch.h"
void dma_lb_axis_switch(
	ap_uint<1> dma_loopback_en,
	hls::stream<trans_pkt> &from_dma,
	hls::stream<trans_pkt> &to_pl,
	hls::stream<trans_pkt> &from_pl,
	hls::stream<trans_pkt> &to_dma)
{
#pragma HLS INTERFACE ap_ctrl_none port = return
#pragma HLS INTERFACE s_axilite port = dma_loopback_en
#pragma HLS INTERFACE axis port = from_dma
#pragma HLS INTERFACE axis port = to_pl
#pragma HLS INTERFACE axis port = from_pl
#pragma HLS INTERFACE axis port = to_dma

	trans_pkt tmp1;
	trans_pkt tmp2;
	trans_pkt tmp3;
	if (dma_loopback_en == 1)
	{
		from_dma.read(tmp1);
		to_dma.write(tmp1);
	}
	else
	{
		from_dma.read(tmp2);
		to_pl.write(tmp2);
		from_pl.read(tmp3);
		to_dma.write(tmp3);
	}
}
