// ==============================================================
// Vitis HLS - High-Level Synthesis from C, C++ and OpenCL v2021.2 (64-bit)
// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// ==============================================================
#ifndef XDMA_LB_AXIS_SWITCH_H
#define XDMA_LB_AXIS_SWITCH_H

#ifdef __cplusplus
extern "C" {
#endif

/***************************** Include Files *********************************/
#ifndef __linux__
#include "xil_types.h"
#include "xil_assert.h"
#include "xstatus.h"
#include "xil_io.h"
#else
#include <stdint.h>
#include <assert.h>
#include <dirent.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <unistd.h>
#include <stddef.h>
#endif
#include "xdma_lb_axis_switch_hw.h"

/**************************** Type Definitions ******************************/
#ifdef __linux__
typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
#else
typedef struct {
    u16 DeviceId;
    u32 Control_BaseAddress;
} XDma_lb_axis_switch_Config;
#endif

typedef struct {
    u64 Control_BaseAddress;
    u32 IsReady;
} XDma_lb_axis_switch;

typedef u32 word_type;

/***************** Macros (Inline Functions) Definitions *********************/
#ifndef __linux__
#define XDma_lb_axis_switch_WriteReg(BaseAddress, RegOffset, Data) \
    Xil_Out32((BaseAddress) + (RegOffset), (u32)(Data))
#define XDma_lb_axis_switch_ReadReg(BaseAddress, RegOffset) \
    Xil_In32((BaseAddress) + (RegOffset))
#else
#define XDma_lb_axis_switch_WriteReg(BaseAddress, RegOffset, Data) \
    *(volatile u32*)((BaseAddress) + (RegOffset)) = (u32)(Data)
#define XDma_lb_axis_switch_ReadReg(BaseAddress, RegOffset) \
    *(volatile u32*)((BaseAddress) + (RegOffset))

#define Xil_AssertVoid(expr)    assert(expr)
#define Xil_AssertNonvoid(expr) assert(expr)

#define XST_SUCCESS             0
#define XST_DEVICE_NOT_FOUND    2
#define XST_OPEN_DEVICE_FAILED  3
#define XIL_COMPONENT_IS_READY  1
#endif

/************************** Function Prototypes *****************************/
#ifndef __linux__
int XDma_lb_axis_switch_Initialize(XDma_lb_axis_switch *InstancePtr, u16 DeviceId);
XDma_lb_axis_switch_Config* XDma_lb_axis_switch_LookupConfig(u16 DeviceId);
int XDma_lb_axis_switch_CfgInitialize(XDma_lb_axis_switch *InstancePtr, XDma_lb_axis_switch_Config *ConfigPtr);
#else
int XDma_lb_axis_switch_Initialize(XDma_lb_axis_switch *InstancePtr, const char* InstanceName);
int XDma_lb_axis_switch_Release(XDma_lb_axis_switch *InstancePtr);
#endif


void XDma_lb_axis_switch_Set_dma_loopback_en(XDma_lb_axis_switch *InstancePtr, u32 Data);
u32 XDma_lb_axis_switch_Get_dma_loopback_en(XDma_lb_axis_switch *InstancePtr);
void XDma_lb_axis_switch_Set_dma_to_ps_counter_en(XDma_lb_axis_switch *InstancePtr, u32 Data);
u32 XDma_lb_axis_switch_Get_dma_to_ps_counter_en(XDma_lb_axis_switch *InstancePtr);

#ifdef __cplusplus
}
#endif

#endif
