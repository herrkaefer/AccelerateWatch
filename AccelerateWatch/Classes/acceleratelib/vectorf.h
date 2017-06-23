/*  =========================================================================
    vectorf -

    Copyright (c) 2016, Yang LIU <gloolar [at] gmail [dot] com>
    =========================================================================
*/

#ifndef __VECTORF_H__
#define __VECTORF_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdbool.h>

// Mean value
float vectorf_mean (const float *self, size_t size);

// Summation
float vectorf_sum (const float *self, size_t size);
    
// Length
float vectorf_length (const float *self, size_t size);

// Square of length
float vectorf_power (const float *self, size_t size);

// Sqrt
void vectorf_sqrt (const float *self, size_t size, float *output);

// Add value
// Return results in param output.
void vectorf_add (const float *self, size_t size, float value, float *output);

// Add value (in place)
void vectorf_add_inplace (float *self, size_t size, float value);

// Multiply with value.
// Return results in param output.
void vectorf_multiply (const float *self, size_t size, float value, float *output);

//  Multiply with value (in place)
void vectorf_multiply_inplace (float *self, size_t size, float value);

// Centralize
void vectorf_remove_mean (const float *self, size_t size, float *output);

// Centralize in place
void vectorf_remove_mean_inplace (float *self, size_t size);

// Normalize vectorf to have unit length.
// Return results in param output which size is the same as the vector
// Set remove_mean to true to centralize vectorf.
void vectorf_normalize_to_unit_length (const float *self, size_t size, bool remove_mean, float *output);

// Normalize vectorf to have unit length (in place)
void vectorf_normalize_to_unit_length_inplace (float *self, size_t size, bool remove_mean);

// Dot product with another vector which size is same with vector
float vectorf_dot_product (const float *self, const float *vector2, size_t size);


#ifdef __cplusplus
}
#endif

#endif
