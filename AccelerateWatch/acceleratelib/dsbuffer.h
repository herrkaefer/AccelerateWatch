/*  =========================================================================
    dsbuffer - fixed-length circular buffer for windowed signal processing

    Copyright (c) 2016, Yang LIU <gloolar [at] gmail [dot] com>
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

// Create a new dsbuffer object
// Set perform_fft to true if FFT will be performed on the buffer, otherwise
// set it to false so as to save memory.
dsbuffer_t *dsbuffer_new (size_t size, bool perform_fft);

// Destroy dsbuffer object
void dsbuffer_free (dsbuffer_t **self_p);

// Destroy dsbuffer object
void dsbuffer_free_unsafe (dsbuffer_t *self);

// Get data at index
float dsbuffer_at (dsbuffer_t *self, size_t idx);
    
// Add new value to buffer
void dsbuffer_push (dsbuffer_t *self, float new_value);

// Dump buffer as array
void dsbuffer_dump (dsbuffer_t *self, float *output);

// Reset buffer to zero values
void dsbuffer_clear (dsbuffer_t *self);

// Print buffer
void dsbuffer_print (dsbuffer_t *self);
    
// Self test
void dsbuffer_test (void);

// ---------------------------------------------------------------------------
// Perform FFT on data buffer (real value time series)
// Return results in param output (size/2+1 complex points)
void dsbuffer_fftr (dsbuffer_t *self, dsbuffer_complex *output);

// Get FFT frequencies
// Return results in param output (size/2+1 points)
void dsbuffer_fft_freq (dsbuffer_t *self, float fs, float *output);

// ---------------------------------------------------------------------------
// Setup FIR filter
void dsbuffer_setup_fir (dsbuffer_t *self, const float *fir_taps, size_t num_taps);

// Get latest FIR filtered output
float dsbuffer_latest_fir_output (dsbuffer_t *self);

// Perform FIR filtering for the whole time series in buffer.
// Return results in param output which size is the same as the buffer.
void dsbuffer_fir_filter (dsbuffer_t *self, float *output);

// ---------------------------------------------------------------------------
// Get mean value of buffer data
float dsbuffer_mean (dsbuffer_t *self);

// Get summation of buffer data
float dsbuffer_sum (dsbuffer_t *self);
    
// Length of buffer data as vector
float dsbuffer_length (dsbuffer_t *self);

// Squared length of buffer data as vector
float dsbuffer_energy (dsbuffer_t *self);
    
// Max value
float dsbuffer_max (dsbuffer_t *self);
    
// Min value
float dsbuffer_min (dsbuffer_t *self);

// Variance
float dsbuffer_variance (dsbuffer_t *self);

// Standard deviation
float dsbuffer_std (dsbuffer_t *self);
    
// Add value to dsbuffer data.
// Return results in param output.
void dsbuffer_add (dsbuffer_t *self, float value, float *output);

// Multiply dsbuffer data with value.
// Return results in param output.
void dsbuffer_multiply (dsbuffer_t *self, float value, float *output);
    
// modulus by value on dsbuffer data.
// Return results in param output.
void dsbuffer_mod (dsbuffer_t *self, float value, float *output);

// Square root of each dsbuffer data.
// Return results in param output.
void dsbuffer_sqrt (dsbuffer_t *self, float *output);
    
// Centralize buffer data as vector
void dsbuffer_remove_mean (dsbuffer_t *self, float *output);

// Normalize buffer data as vector to have unit length.
// Return results in param output which size is the same as the buffer.
// Set remove_mean to true to centralize.
void dsbuffer_normalize_to_unit_length (dsbuffer_t *self, bool remove_mean, float *output);

// Normalize buffer data as vector to have unit variance.
// Return results in param output which size is the same as the buffer.
// Set remove_mean to true to centralize.
void dsbuffer_normalize_to_unit_variance (dsbuffer_t *self, bool remove_mean, float *output);
    
// Dot product with vector which size is same with buffer
float dsbuffer_dot_product (dsbuffer_t *self, const float *vector);


#ifdef __cplusplus
}
#endif

#endif
