/*  =========================================================================
    dsbuffer - fixed-length circular buffer for windowed signal processing

    Copyright (c) 2016, Yang LIU <gloolar@gmail.com>
    =========================================================================
*/

#ifndef __DSBUFFER_H__
#define __DSBUFFER_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdbool.h>

typedef struct _dsbuffer_t dsbuffer_t;

typedef struct {
    float real;
    float imag;
} dsbuffer_complex;

// Create a new dsbuffer
// Set perform_fft to true if FFT will be performed on the buffer, otherwise
// set it to false so as to save memory.
dsbuffer_t *dsbuffer_new (size_t size, bool perform_fft);

// Destroy dsbuffer object
void dsbuffer_free (dsbuffer_t **self_p);

// Add new value to buffer
void dsbuffer_push (dsbuffer_t *self, float new_value);

// Dump buffer as array
void dsbuffer_dump (dsbuffer_t *self, float *output);

// Perform FFT on data buffer (real value time series)
// Return results in param output (size/2+1 complex points)
void dsbuffer_fftr (dsbuffer_t *self, dsbuffer_complex *output);

// Get FFT frequencies
// Return results in param output (size/2+1 points)
void dsbuffer_fft_freq (dsbuffer_t *self, float fs, float *output);

// Setup FIR filter
void dsbuffer_setup_fir (dsbuffer_t *self, const float *fir_taps, size_t num_taps);

// Get latest FIR filtered output
float dsbuffer_latest_fir_output (dsbuffer_t *self);

// Perform FIR filtering for the whole time series in buffer.
// Return results in param output which size is the same as the buffer.
void dsbuffer_fir_filter (dsbuffer_t *self, float *output);

// Reset buffer to zero values
void dsbuffer_clear (dsbuffer_t *self);

// Self test
void dsbuffer_test (void);

#ifdef __cplusplus
}
#endif

#endif
