/*  =========================================================================
    vectorf -

    Copyright (c) 2016, Yang LIU <gloolar [at] gmail [dot] com>
    =========================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <assert.h>

#include "vectorf.h"


float vectorf_mean (const float *self, size_t size) {
    assert (self);
    float sum = 0.0;
    for (size_t i = 0; i < size; i++)
        sum += self[i];
    return sum / size;
}


float vectorf_sum (const float *self, size_t size) {
    assert (self);
    float sum = 0.0;
    for (size_t i = 0; i < size; i++)
        sum += self[i];
    return sum;
}


float vectorf_length (const float *self, size_t size) {
    assert (self);
    float ss = 0.0;
    for (size_t i = 0; i < size; i++)
        ss += self[i] * self[i];
    return sqrtf (ss);
}


float vectorf_power (const float *self, size_t size) {
    assert (self);
    float ss = 0.0;
    for (size_t i = 0; i < size; i++)
        ss += self[i] * self[i];
    return ss;
}


void vectorf_sqrt (const float *self, size_t size, float *output) {
    assert (self);
    assert (output);
    for (size_t i = 0; i < size; i++)
        output[i] = sqrtf(self[i]);
}


void vectorf_add (const float *self, size_t size, float value, float *output) {
    assert (self);
    assert (output);
    for (size_t i = 0; i < size; i++)
        output[i] = self[i] + value;
}


void vectorf_add_inplace (float *self, size_t size, float value) {
    assert (self);
    for (size_t i = 0; i < size; i++)
        self[i] += value;
}


void vectorf_multiply (const float *self, size_t size, float value, float *output) {
    assert (self);
    assert (output);
    for (size_t i = 0; i < size; i++)
        output[i] = self[i] * value;
}


void vectorf_multiply_inplace (float *self, size_t size, float value) {
    assert (self);
    for (size_t i = 0; i < size; i++)
        self[i] *= value;
}


void vectorf_remove_mean (const float *self, size_t size, float *output) {
    assert (self);
    assert (output);
    float mean = vectorf_mean (self, size);
    for (size_t i = 0; i < size; i++)
        output[i] = self[i] - mean;
}


void vectorf_remove_mean_inplace (float *self, size_t size) {
    assert (self);
    float mean = vectorf_mean (self, size);
    for (size_t i = 0; i < size; i++)
        self[i] -= mean;
}


void vectorf_normalize_to_unit_length (const float *self,
                                       size_t size,
                                       bool remove_mean,
                                       float *output) {
    assert (self);
    assert (output);

    if (remove_mean) {
        vectorf_remove_mean (self, size, output);

        float length = 0.0;
        for (size_t i = 0; i < size; i++)
            length += output[i] * output[i];
        length = sqrt (length);
        
        if (length > 0) {
            for (size_t i = 0; i < size; i++)
                output[i] /= length;
        }
    }
    else {
        float length = vectorf_length (self, size);
        if (length > 0)
            vectorf_multiply (self, size, 1/length, output);
        else
            vectorf_multiply (self, size, 1, output);
    }
}


void vectorf_normalize_to_unit_length_inplace (float *self,
                                               size_t size,
                                               bool remove_mean) {
    assert (self);
    if (remove_mean)
        vectorf_remove_mean_inplace (self, size);

    float length = vectorf_length (self, size);
    vectorf_multiply_inplace (self, size, 1/length);
}


float vectorf_dot_product (const float *self, const float *vector2, size_t size) {
    assert (self);
    assert (vector2);
    float result = 0.0;
    for (size_t i = 0; i < size; i++)
        result += self[i] * vector2[i];
    return result;
}

