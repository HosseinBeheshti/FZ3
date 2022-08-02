// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================
// control
// 0x00 : reserved
// 0x04 : reserved
// 0x08 : reserved
// 0x0c : reserved
// 0x10 : Data signal of dma_loopback_en
//        bit 0  - dma_loopback_en[0] (Read/Write)
//        others - reserved
// 0x14 : reserved
// 0x18 : Data signal of dma_to_ps_counter_en
//        bit 0  - dma_to_ps_counter_en[0] (Read/Write)
//        others - reserved
// 0x1c : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

#define XDMA_LB_AXIS_SWITCH_CONTROL_ADDR_DMA_LOOPBACK_EN_DATA      0x10
#define XDMA_LB_AXIS_SWITCH_CONTROL_BITS_DMA_LOOPBACK_EN_DATA      1
#define XDMA_LB_AXIS_SWITCH_CONTROL_ADDR_DMA_TO_PS_COUNTER_EN_DATA 0x18
#define XDMA_LB_AXIS_SWITCH_CONTROL_BITS_DMA_TO_PS_COUNTER_EN_DATA 1

