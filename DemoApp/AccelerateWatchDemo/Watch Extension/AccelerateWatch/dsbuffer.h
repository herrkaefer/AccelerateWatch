/*  =========================================================================
    dsbuffer - fixed-length circular digital signal buffer

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

// Perform FFT on data buffer (real value time series)
// Return array of size/2+1 complex points
const dsbuffer_complex *dsbuffer_fftr (dsbuffer_t *self);

// Get FFT frequencies
const float *dsbuffer_fft_freq (dsbuffer_t *self, float fs);

// Get the square of FFT magnitudes.
// Return array of size/2+1 points.
// Note that this function does not perform FFT, it is computed from the last
// fft results.
const float *dsbuffer_fft_magnitudes_square (dsbuffer_t *self);

void dsbuffer_setup_fir (dsbuffer_t *self, const float *fir_taps, size_t num_taps);

// Get latest FIR filtered output
float dsbuffer_lastest_fir_output (dsbuffer_t *self);

// Perform FIR filtering for the whole time series in buffer.
// Return output array which size is the same as the signal. The caller is
// responsible for freeing it after use.
float *dsbuffer_fir_filter (dsbuffer_t *self);

// Reset buffer to zero values
void dsbuffer_clear (dsbuffer_t *self);

// Self test
void dsbuffer_test (void);

#ifdef __cplusplus
}
#endif

#endif
