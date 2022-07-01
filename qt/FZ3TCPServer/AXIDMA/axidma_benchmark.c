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

/*----------------------------------------------------------------------------
 * Verification Test
 *----------------------------------------------------------------------------*/

/* Initialize the two buffers, filling buffers with a preset but "random"
 * pattern. */
void init_data(char *tx_buf, char *rx_buf, size_t tx_buf_size,
               size_t rx_buf_size)
{
    size_t i;
    int *transmit_buffer, *receive_buffer;

    transmit_buffer = (int *)tx_buf;
    receive_buffer = (int *)rx_buf;

    // Fill the buffer with integer patterns
    for (i = 0; i < tx_buf_size / sizeof(int); i++)
    {
        transmit_buffer[i] = TEST_PATTERN(i);
    }

    // Fill in any leftover bytes if it's not aligned
    for (i = 0; i < tx_buf_size % sizeof(int); i++)
    {
        tx_buf[i] = TEST_PATTERN(i + tx_buf_size / sizeof(int));
    }

    // Fill the buffer with integer patterns
    for (i = 0; i < rx_buf_size / sizeof(int); i++)
    {
        receive_buffer[i] = TEST_PATTERN(i + tx_buf_size);
    }

    // Fill in any leftover bytes if it's not aligned
    for (i = 0; i < rx_buf_size % sizeof(int); i++)
    {
        rx_buf[i] = TEST_PATTERN(i + tx_buf_size + rx_buf_size / sizeof(int));
    }

    return;
}

/* Verify the two buffers. For transmit, verify that it is unchanged. For
 * receive, we don't know the PL fabric function, so the best we can
 * do is check if it changed and warn the user if it is not. */
int verify_data(char *tx_buf, char *rx_buf, size_t tx_buf_size,
                size_t rx_buf_size)
{
    int *transmit_buffer, *receive_buffer;
    size_t i, rx_data_same, rx_data_units;
    double match_fraction;

    transmit_buffer = (int *)tx_buf;
    receive_buffer = (int *)rx_buf;

    // Verify words in the transmit buffer
    for (i = 0; i < tx_buf_size / sizeof(int); i++)
    {
        if (transmit_buffer[i] != TEST_PATTERN(i))
        {
            return -EINVAL;
        }
    }

    // Verify any leftover bytes in the buffer
    for (i = 0; i < tx_buf_size % sizeof(int); i++)
    {
        if (tx_buf[i] != TEST_PATTERN(i + tx_buf_size / sizeof(int)))
        {
            return -EINVAL;
        }
    }

    // Verify words in the receive buffer
    rx_data_same = 0;
    for (i = 0; i < rx_buf_size / sizeof(int); i++)
    {
        if (receive_buffer[i] == TEST_PATTERN(i + tx_buf_size))
        {
            rx_data_same += 1;
        }
    }

    // Verify any leftover bytes in the buffer
    for (i = 0; i < rx_buf_size % sizeof(int); i++)
    {
        if (rx_buf[i] == TEST_PATTERN(i + tx_buf_size + rx_buf_size / sizeof(int)))
        {
            rx_data_same += 1;
        }
    }

    // Warn the user if more than 10% of the pixels match the test pattern
    rx_data_units = rx_buf_size / sizeof(int) + rx_buf_size % sizeof(int);
    if (rx_data_same == rx_data_units)
    {
        printf("Test Failed! The receive buffer was not updated.\n");
        return -EINVAL;
    }
    else if (rx_data_same >= rx_data_units / 10)
    {
        match_fraction = ((double)rx_data_same) / ((double)rx_data_units);
    }

    return 0;
}
