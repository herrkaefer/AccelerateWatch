/*  =========================================================================
    vectord - 

    Copyright (c) 2016, Yang LIU <gloolar [at] gmail [dot] com>
    =========================================================================
*/

#ifndef __VECTORD_H__
#define __VECTORD_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdbool.h>

// Mean value
double vectord_mean (const double *self, size_t size);

// Summation
double vectord_sum (const double *self, size_t size);

// Length
double vectord_length (const double *self, size_t size);

// Square of length
double vectord_power (const double *self, size_t size);

// Sqrt
void vectord_sqrt (const double *self, size_t size, double *output);
    
// Add value
// Return results in param output.
void vectord_add (const double *self, size_t size, double value, double *output);

// Add value (in place)
void vectord_add_inplace (double *self, size_t size, double value);

// Multiply with value.
// Return results in param output.
void vectord_multiply (const double *self, size_t size, double value, double *output);

//  Multiply with value (in place)
void vectord_multiply_inplace (double *self, size_t size, double value);

// Centralize
void vectord_remove_mean (const double *self, size_t size, double *output);

// Centralize in place
void vectord_remove_mean_inplace (double *self, size_t size);

// Normalize vectord to have unit length.
// Return results in param output which size is the same as the buffer.
// Set remove_mean to true to centralize vectord.
void vectord_normalize_to_unit_length (const double *self, size_t size, bool remove_mean, double *output);

// Normalize vector to have unit length (in place)
void vectord_normalize_to_unit_length_inplace (double *self, size_t size, bool remove_mean);

// Dot product with vectord which size is same with buffer
double vectord_dot_product (const double *self, const double *vector2, size_t size);


#ifdef __cplusplus
}
#endif

#endif
