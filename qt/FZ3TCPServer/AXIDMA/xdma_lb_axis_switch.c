// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================
/***************************** Include Files *********************************/
#include "xdma_lb_axis_switch.h"

/************************** Function Implementation *************************/
#ifndef __linux__
int XDma_lb_axis_switch_CfgInitialize(XDma_lb_axis_switch *InstancePtr, XDma_lb_axis_switch_Config *ConfigPtr) {
    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(ConfigPtr != NULL);

    InstancePtr->Control_BaseAddress = ConfigPtr->Control_BaseAddress;
    InstancePtr->IsReady = XIL_COMPONENT_IS_READY;

    return XST_SUCCESS;
}
#endif

void XDma_lb_axis_switch_Set_dma_loopback_en(XDma_lb_axis_switch *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDma_lb_axis_switch_WriteReg(InstancePtr->Control_BaseAddress, XDMA_LB_AXIS_SWITCH_CONTROL_ADDR_DMA_LOOPBACK_EN_DATA, Data);
}

u32 XDma_lb_axis_switch_Get_dma_loopback_en(XDma_lb_axis_switch *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDma_lb_axis_switch_ReadReg(InstancePtr->Control_BaseAddress, XDMA_LB_AXIS_SWITCH_CONTROL_ADDR_DMA_LOOPBACK_EN_DATA);
    return Data;
}

void XDma_lb_axis_switch_Set_dma_to_ps_counter_en(XDma_lb_axis_switch *InstancePtr, u32 Data) {
    Xil_AssertVoid(InstancePtr != NULL);
    Xil_AssertVoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    XDma_lb_axis_switch_WriteReg(InstancePtr->Control_BaseAddress, XDMA_LB_AXIS_SWITCH_CONTROL_ADDR_DMA_TO_PS_COUNTER_EN_DATA, Data);
}

u32 XDma_lb_axis_switch_Get_dma_to_ps_counter_en(XDma_lb_axis_switch *InstancePtr) {
    u32 Data;

    Xil_AssertNonvoid(InstancePtr != NULL);
    Xil_AssertNonvoid(InstancePtr->IsReady == XIL_COMPONENT_IS_READY);

    Data = XDma_lb_axis_switch_ReadReg(InstancePtr->Control_BaseAddress, XDMA_LB_AXIS_SWITCH_CONTROL_ADDR_DMA_TO_PS_COUNTER_EN_DATA);
    return Data;
}

