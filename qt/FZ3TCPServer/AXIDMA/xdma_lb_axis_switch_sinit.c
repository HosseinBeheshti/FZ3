// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef __linux__

#include "xstatus.h"
#include "xparameters.h"
#include "xdma_lb_axis_switch.h"

extern XDma_lb_axis_switch_Config XDma_lb_axis_switch_ConfigTable[];

XDma_lb_axis_switch_Config *XDma_lb_axis_switch_LookupConfig(u16 DeviceId) {
	XDma_lb_axis_switch_Config *ConfigPtr = NULL;

	int Index;

	for (Index = 0; Index < XPAR_XDMA_LB_AXIS_SWITCH_NUM_INSTANCES; Index++) {
		if (XDma_lb_axis_switch_ConfigTable[Index].DeviceId == DeviceId) {
			ConfigPtr = &XDma_lb_axis_switch_ConfigTable[Index];
			break;
		}
	}

	return ConfigPtr;
}

int XDma_lb_axis_switch_Initialize(XDma_lb_axis_switch *InstancePtr, u16 DeviceId) {
	XDma_lb_axis_switch_Config *ConfigPtr;

	Xil_AssertNonvoid(InstancePtr != NULL);

	ConfigPtr = XDma_lb_axis_switch_LookupConfig(DeviceId);
	if (ConfigPtr == NULL) {
		InstancePtr->IsReady = 0;
		return (XST_DEVICE_NOT_FOUND);
	}

	return XDma_lb_axis_switch_CfgInitialize(InstancePtr, ConfigPtr);
}

#endif

