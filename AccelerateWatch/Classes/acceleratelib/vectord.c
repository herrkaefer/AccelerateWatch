/*  =========================================================================
    vectord -

    Copyright (c) 2016, Yang LIU <gloolar [at] gmail [dot] com>
    =========================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <assert.h>

#include "vectord.h"


double vectord_mean (const double *self, size_t size) {
    assert (self);
    double sum = 0.0;
    for (size_t i = 0; i < size; i++)
        sum += self[i];
    return sum / size;
}


double vectord_sum (const double *self, size_t size) {
    assert (self);
    double sum = 0.0;
    for (size_t i = 0; i < size; i++)
        sum += self[i];
    return sum;
}


double vectord_length (const double *self, size_t size) {
    assert (self);
    double ss = 0.0;
    for (size_t i = 0; i < size; i++)
        ss += self[i] * self[i];
    return sqrtf (ss);
}


double vectord_power (const double *self, size_t size) {
    assert (self);
    double ss = 0.0;
    for (size_t i = 0; i < size; i++)
        ss += self[i] * self[i];
    return ss;
}


void vectord_sqrt (const double *self, size_t size, double *output) {
    assert (self);
    assert (output);
    for (size_t i = 0; i < size; i++)
        output[i] = sqrt(self[i]);
}


void vectord_add (const double *self, size_t size, double value, double *output) {
    assert (self);
    assert (output);
    for (size_t i = 0; i < size; i++)
        output[i] = self[i] + value;
}


void vectord_add_inplace (double *self, size_t size, double value) {
    assert (self);
    for (size_t i = 0; i < size; i++)
        self[i] += value;
}


void vectord_multiply (const double *self, size_t size, double value, double *output) {
    assert (self);
    assert (output);
    for (size_t i = 0; i < size; i++)
        output[i] = self[i] * value;
}


void vectord_multiply_inplace (double *self, size_t size, double value) {
    assert (self);
    for (size_t i = 0; i < size; i++)
        self[i] *= value;
}


void vectord_remove_mean (const double *self, size_t size, double *output) {
    assert (self);
    assert (output);
    double mean = vectord_mean (self, size);
    for (size_t i = 0; i < size; i++)
        output[i] = self[i] - mean;
}


void vectord_remove_mean_inplace (double *self, size_t size) {
    assert (self);
    double mean = vectord_mean (self, size);
    for (size_t i = 0; i < size; i++)
        self[i] -= mean;
}


void vectord_normalize_to_unit_length (const double *self,
                                       size_t size,
                                       bool remove_mean,
                                       double *output) {
    assert (self);
    assert (output);

    if (remove_mean) {
        vectord_remove_mean (self, size, output);

        double length = 0.0;
        for (size_t i = 0; i < size; i++)
            length += output[i] * output[i];
        length = sqrt (length);

        if (length > 0) {
            for (size_t i = 0; i < size; i++)
                output[i] /= length;
        }
    }
    else {
        double length = vectord_length (self, size);
        if (length > 0)
            vectord_multiply (self, size, 1/length, output);
        else
            vectord_multiply (self, size, 1, output);
    }
}


void vectord_normalize_to_unit_length_inplace (double *self,
                                               size_t size,
                                               bool remove_mean) {
    assert (self);
    if (remove_mean)
        vectord_remove_mean_inplace (self, size);

    double length = vectord_length (self, size);
    vectord_multiply_inplace (self, size, 1/length);
}


double vectord_dot_product (const double *self, const double *vector2, size_t size) {
    assert (self);
    assert (vector2);
    double result = 0.0;
    for (size_t i = 0; i < size; i++)
        result += self[i] * vector2[i];
    return result;
}
