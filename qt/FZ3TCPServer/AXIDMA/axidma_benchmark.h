#ifndef AXIDMA_BENCHMARK_H
#define AXIDMA_BENCHMARK_H

#ifdef __cplusplus
extern "C" {
#endif


#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h> // Strlen function

#include <fcntl.h>     // Flags for open()
#include <sys/stat.h>  // Open() system call
#include <sys/types.h> // Types for open()
#include <sys/mman.h>  // Mmap system call
#include <sys/ioctl.h> // IOCTL system call
#include <unistd.h>    // Close() system call
#include <sys/time.h>  // Timing functions and definitions
#include <getopt.h>    // Option parsing
#include <errno.h>     // Error codes

#include "libaxidma.h"  // Interface to the AXI DMA
#include "util.h"       // Miscellaneous utilities
#include "conversion.h" // Miscellaneous conversion utilities

/*----------------------------------------------------------------------------
 * Internal Definitons
 *----------------------------------------------------------------------------*/

// The size of data to send per transfer (1080p image, 7.24 MiB)
#define IMAGE_SIZE (1920 * 1080)
#define DEFAULT_TRANSFER_SIZE ((int)(IMAGE_SIZE * sizeof(int)))

// The default number of transfers to benchmark
#define DEFAULT_NUM_TRANSFERS 1000

// The pattern that we fill into the buffers
#define TEST_PATTERN(i) ((int)(0x1234ACDE ^ (i)))

// The DMA context passed to the helper thread, who handles remainder channels
/*----------------------------------------------------------------------------
 * Verification Test
 *----------------------------------------------------------------------------*/

/* Initialize the two buffers, filling buffers with a preset but "random"
 * pattern. */
void init_data(char *tx_buf, char *rx_buf, size_t tx_buf_size,
                      size_t rx_buf_size);

/* Verify the two buffers. For transmit, verify that it is unchanged. For
 * receive, we don't know the PL fabric function, so the best we can
 * do is check if it changed and warn the user if it is not. */
int verify_data(char *tx_buf, char *rx_buf, size_t tx_buf_size,
                       size_t rx_buf_size);

#ifdef __cplusplus
}
#endif

#endif
