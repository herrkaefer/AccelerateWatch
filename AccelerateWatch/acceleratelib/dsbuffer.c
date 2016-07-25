/*  =========================================================================
    dsbuffer - fixed-length circular buffer for windowed signal processing

    Copyright (c) 2016, Yang LIU <gloolar [at] gmail [dot] com>
    =========================================================================
*/

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>
#include <assert.h>

#include "dsbuffer.h"
#include "kissfft/kiss_fftr.h"


struct _dsbuffer_t {
    float *data;
    size_t size;
    size_t head; // position of first value
    void (*pusher)(dsbuffer_t *f, float new_value); // func for pushing value

    // for FFT
    bool fft_supported;
    kiss_fftr_cfg fft_cfg; // fft configuration

    // for FIR filter
    const float *fir_taps;
    size_t num_fir_taps;
    float (*fir_getter)(dsbuffer_t *buf); // func of getting filtered signal
};


// Check if x is power of 2
static bool is_power_of_2 (size_t x) {
   return x && !(x & (x - 1));
}


static void dsbuffer_push_fast_with_fft (dsbuffer_t *self, float new_value) {
    self->data[self->head] = new_value;
    self->data[self->head + self->size] = new_value;
    self->head = (++self->head) & (self->size-1);
}


static void dsbuffer_push_normal_with_fft (dsbuffer_t *self, float new_value) {
    self->data[self->head] = new_value;
    self->data[self->head + self->size] = new_value;
    if (++self->head == self->size)
        self->head = 0;
}


static void dsbuffer_push_fast (dsbuffer_t *self, float new_value) {
    self->data[self->head] = new_value;
    self->head = (++self->head) & (self->size-1);
}


static void dsbuffer_push_normal (dsbuffer_t *self, float new_value) {
    self->data[self->head] = new_value;
    if (++self->head == self->size)
        self->head = 0;
}


// Get latest FIR filter output (fast version)
static float dsbuffer_fir_get_fast (dsbuffer_t *self) {
    float fvalue = 0;
    size_t index = self->head, i;
    for (i = 0; i < self->num_fir_taps; ++i)
        fvalue += self->data[(--index) & (self->size - 1)] * self->fir_taps[i];
    return fvalue;
}


// Get latest FIR filter output (normal version)
static float dsbuffer_fir_get_normal (dsbuffer_t *self) {
    float fvalue = 0;
    size_t index = self->head, i;
    for (i = 0; i < self->num_fir_taps; ++i) {
        index = (index != 0) ? (index - 1) : (self->size - 1);
        fvalue += self->data[index] * self->fir_taps[i];
    }
    return fvalue;
}


// Print raw buffer
static void dsbuffer_print_raw (dsbuffer_t *self, bool fft_supported) {
    assert (self);
    printf ("\ndsbuffer: size: %zu, fft_supported: %s, head: %zu\n",
            self->size, fft_supported ? "true" : "false", self->head);
    printf("===============================================\n");
    for (size_t t = 0; t < self->size; t++) {
        printf ("%.3f", self->data[t]);
        if (t < self->size - 1) {
            printf(", ");
        }
    }

    if (fft_supported) {
        printf(" | ");
        for (size_t t = self->size; t < 2*self->size; t++) {
            printf ("%.3f", self->data[t]);
            if (t < 2*self->size - 1) {
                printf(", ");
            }
        }
    }
    printf("\n\n");
}


// ---------------------------------------------------------------------------


dsbuffer_t *dsbuffer_new (size_t size, bool fft_supported) {
    if (fft_supported && size % 2 == 1) {
        printf("ERROR: buffer size must be even for FFT.\n");
        return NULL;
    }

    dsbuffer_t *self = (dsbuffer_t *) malloc (sizeof (dsbuffer_t));
    assert (self);

    // Create signal buffer and initilize to zero
    size_t alloc_size = fft_supported ? (size * 2) : size;
    self->data = (float *) calloc (alloc_size, sizeof (float));
    assert (self->data);

    self->size = size;
    self->head = 0;

    // If filter length equals power of 2, use the fast version, otherwise the
    // normal version
    if (is_power_of_2 (size))
        self->pusher = fft_supported ?
                       dsbuffer_push_fast_with_fft :
                       dsbuffer_push_fast;
    else
        self->pusher = fft_supported ?
                       dsbuffer_push_normal_with_fft :
                       dsbuffer_push_normal;

    self->fft_supported = fft_supported;
    if (fft_supported) {
        self->fft_cfg = kiss_fftr_alloc ((int) size, 0, NULL, NULL);
        assert (self->fft_cfg);
    }
    else
        self->fft_cfg = NULL;

    self->fir_taps = NULL;
    self->num_fir_taps = 0;
    self->fir_getter = NULL;

    return self;
}


float dsbuffer_at (dsbuffer_t *self, size_t idx) {
    assert (self);
    assert (idx < self->size);

    if (self->fft_supported)
        return self->data[self->head + idx];
    else {
        return self->data[(self->head + idx) % self->size];
    }
}


void dsbuffer_push (dsbuffer_t *self, float new_value) {
    assert (self);
    return self->pusher (self, new_value);
}


void dsbuffer_dump (dsbuffer_t *self, float *output) {
    assert (self);
    assert (output);
    if (self->fft_supported)
        memcpy (output, self->data + self->head, sizeof (float) * self->size);
    else {
        memcpy (output,
                self->data + self->head,
                sizeof (float) * (self->size - self->head));
        memcpy (output + self->size - self->head,
                self->data,
                sizeof (float) * self->head);
    }
}


void dsbuffer_fftr (dsbuffer_t *self, dsbuffer_complex *output) {
    assert (self);
    assert (output);
    kiss_fftr (self->fft_cfg, &self->data[self->head], (kiss_fft_cpx *)output);
}


void dsbuffer_fft_freq (dsbuffer_t *self, float fs, float *output) {
    assert (self);
    assert (output);
    assert (fs > 0);
    float interval = fs/self->size;
    output[0] = 0;
    for (size_t idx = 1; idx < self->size/2+1; idx++) {
        output[idx] = output[idx-1] + interval;
    }
}


void dsbuffer_setup_fir (dsbuffer_t *self, const float *fir_taps, size_t num_taps) {
    assert (self);
    assert (self->size >= num_taps);
    if (self->size > num_taps)
        printf ("WARNING: dsbuffer size is larger than number of FIR taps.\n");
    self->fir_taps = fir_taps;
    self->num_fir_taps = num_taps;

    if (is_power_of_2 (self->size))
        self->fir_getter = dsbuffer_fir_get_fast;
    else
        self->fir_getter = dsbuffer_fir_get_normal;
}


float dsbuffer_latest_fir_output (dsbuffer_t *self) {
    assert (self);
    assert (self->fir_taps);
    return self->fir_getter (self);
}


void dsbuffer_fir_filter (dsbuffer_t *self, float *output) {
    assert (self);
    assert (self->fir_taps);
    assert (output);

    // Convolution
    for (size_t ind_fsig = 0; ind_fsig < self->size; ind_fsig++) {
        float s = 0.0;
        for (size_t ind_tap = 0; ind_tap < self->num_fir_taps; ind_tap++) {
            if (ind_fsig < ind_tap)
                break;
            // s += self->fir_taps[ind_tap] * input_signal[ind_fsig-ind_tap];
            s += self->fir_taps[ind_tap] *
                 self->data[(self->head + ind_fsig - ind_tap) % self->size];
        }
        output[ind_fsig] = s;
    }
}


float dsbuffer_mean (dsbuffer_t *self) {
    assert (self);
    float sum = 0.0;
    for (size_t i = 0; i < self->size; i++)
        sum += self->data[i];
    return sum / self->size;
}


float dsbuffer_sum (dsbuffer_t *self) {
    assert (self);
    float sum = 0.0;
    for (size_t i = 0; i < self->size; i++)
        sum += self->data[i];
    return sum;
}


float dsbuffer_length (dsbuffer_t *self) {
    assert (self);
    float ss = 0.0;
    for (size_t i = 0; i < self->size; i++)
        ss += self->data[i] * self->data[i];
    return sqrt (ss);
}


float dsbuffer_energy (dsbuffer_t *self) {
    assert (self);
    float ss = 0.0;
    for (size_t i = 0; i < self->size; i++)
        ss += self->data[i] * self->data[i];
    return ss;
}


float dsbuffer_max (dsbuffer_t *self) {
    assert (self);
    assert (self->size > 0);
    float maxv = self->data[0];
    for (size_t i = 1; i < self->size; i++)
        if (self->data[i] > maxv)
            maxv = self->data[i];
    return maxv;
}


float dsbuffer_min (dsbuffer_t *self) {
    assert (self);
    assert (self->size > 0);
    float minv = self->data[0];
    for (size_t i = 1; i < self->size; i++)
        if (self->data[i] < minv)
            minv = self->data[i];
    return minv;
}


float dsbuffer_variance (dsbuffer_t *self) {
    assert (self);
    assert (self->size > 1);
    float mean = dsbuffer_mean(self);
    float ss = 0.0;
    for (size_t i = 0; i < self->size; i++) {
        float c = self->data[i] - mean;
        ss += c * c;
    }
    return ss / (self->size - 1);
}


float dsbuffer_std (dsbuffer_t *self) {
    return sqrtf(dsbuffer_variance(self));
}


void dsbuffer_add (dsbuffer_t *self, float value, float *output) {
    assert (self);
    assert (output);

    if (self->fft_supported) {
        for (size_t i = 0; i < self->size; i++)
            output[i] = self->data[self->head+i] + value;
    }
    else {
        size_t idx = self->head;
        for (size_t i = 0; i < self->size; i++) {
            output[i] = self->data[idx] + value;
            if (++idx == self->size)
                idx = 0;
        }
    }
}


void dsbuffer_multiply (dsbuffer_t *self, float value, float *output) {
    assert (self);
    assert (output);

    if (self->fft_supported) {
        for (size_t i = 0; i < self->size; i++)
            output[i] = self->data[self->head+i] * value;
    }
    else {
        size_t idx = self->head;
        for (size_t i = 0; i < self->size; i++) {
            output[i] = self->data[idx] * value;
            if (++idx == self->size)
                idx = 0;
        }
    }
}


void dsbuffer_mod (dsbuffer_t *self, float value, float *output) {
    assert (self);
    assert (output);

    if (self->fft_supported) {
        for (size_t i = 0; i < self->size; i++)
            output[i] = fmodf(self->data[self->head+i], value);
    }
    else {
        size_t idx = self->head;
        for (size_t i = 0; i < self->size; i++) {
            output[i] = fmodf(self->data[idx], value);
            if (++idx == self->size)
                idx = 0;
        }
    }
}


void dsbuffer_sqrt (dsbuffer_t *self, float *output) {
    assert (self);
    assert (output);

    if (self->fft_supported) {
        for (size_t i = 0; i < self->size; i++)
            output[i] = sqrtf(self->data[self->head+i]);
    }
    else {
        size_t idx = self->head;
        for (size_t i = 0; i < self->size; i++) {
            output[i] = sqrtf(self->data[idx]);
            if (++idx == self->size)
                idx = 0;
        }
    }
}


void dsbuffer_remove_mean (dsbuffer_t *self, float *output) {
    assert (self);
    assert (output);

    float mean = dsbuffer_mean (self);

    if (self->fft_supported) {
        for (size_t i = 0; i < self->size; i++)
            output[i] = self->data[self->head + i] - mean;
    }
    else {
        size_t idx = self->head;
        for (size_t i = 0; i < self->size; i++) {
            output[i] = self->data[idx] - mean;
            if (++idx == self->size)
                idx = 0;
        }
    }
}


void dsbuffer_normalize_to_unit_length (dsbuffer_t *self,
                                        bool remove_mean,
                                        float *output) {
    assert (self);
    assert (output);

    if (remove_mean) {
        dsbuffer_remove_mean (self, output);

        float length = 0.0;
        for (size_t i = 0; i < self->size; i++) {
            length += output[i] * output[i];
        }
        length = sqrtf (length);

        if (length > 0) {
            for (size_t i = 0; i < self->size; i++)
                output[i] /= length;
        }
    }
    else {
        float length = dsbuffer_length (self);
        if (length > 0)
            dsbuffer_multiply (self, 1/length, output);
        else
            dsbuffer_dump (self, output);
    }
}


void dsbuffer_normalize_to_unit_variance (dsbuffer_t *self,
                                          bool remove_mean,
                                          float *output) {
    assert (self);
    assert (output);
    
    if (self->size == 0)
        return;
    
    if (self->size == 1) {
        output[0] = 1;
        return;
    }
    
    // Compute mean and std
    float mean = dsbuffer_mean(self);
    float ss = 0.0;
    for (size_t i = 0; i < self->size; i++) {
        float c = self->data[i] - mean;
        ss += c * c;
    }
    float std = ss / (self->size - 1);
    
    if (remove_mean) {
        // v -> (v-mean)/std
        dsbuffer_add(self, -mean, output);
        if (std > 0) {
            for (size_t i = 0; i < self->size; i++)
                output[i] /= std;
        }
    }
    else {
        // v -> v/std
        if (std > 0) {
            dsbuffer_multiply(self, 1/std, output);
        }
        else
            dsbuffer_dump(self, output);
    }
}


float dsbuffer_dot_product (dsbuffer_t *self, const float *vector) {
    assert (self);
    assert (vector);

    float result = 0.0;
    if (self->fft_supported) {
        for (size_t i = 0; i < self->size; i++)
            result += self->data[self->head + i] * vector[i];
    }
    else {
        size_t idx = self->head;
        for (size_t i = 0; i < self->size; i++) {
            result += self->data[idx] * vector[i];
            if (++idx == self->size)
                idx = 0;
        }
    }
    return result;
}


void dsbuffer_clear (dsbuffer_t *self) {
    assert (self);
    memset (self->data, 0, sizeof (float) *
                           (self->fft_supported ? (2*self->size) : self->size));
    self->head = 0;
}


void dsbuffer_print (dsbuffer_t *self) {
    assert (self);
    printf ("DSBuffer size: %zu\n", self->size);

    if (self->fft_supported) {
        for (size_t idx = 0; idx < self->size; idx++)
            printf ("%.2f ", self->data[self->head + idx]);
        printf ("\n");
    }
    else {
        for (size_t cnt = 0, idx = 0; cnt < self->size; cnt++) {
            printf ("%.2f ", self->data[self->head + idx]);
            if (++idx == self->size)
                idx = 0;
        }
        printf ("\n");
    }
}


void dsbuffer_free (dsbuffer_t **self_p) {
    assert (self_p);
    if (*self_p) {
        dsbuffer_t *self = *self_p;
        free (self->data);
        if (self->fft_cfg)
            free (self->fft_cfg);
        free (self);
        *self_p = NULL;
    }
}


void dsbuffer_free_unsafe (dsbuffer_t *self) {
    assert (self);
    free (self->data);
    if (self->fft_cfg)
        free (self->fft_cfg);
    free (self);
}


void dsbuffer_test () {

    #include "fir_taps.ini"

    dsbuffer_t *buf = NULL;
    float *dumped = NULL;
    size_t size;
    bool fft_supported;

    // 1
    buf = dsbuffer_new (num_fir_taps, false);
    assert (buf);
    for (size_t i = 0; i < num_fir_taps; i++)
        assert (fabs (dsbuffer_at (buf, i) - 0) < 1e-8);

    dsbuffer_setup_fir (buf, fir_taps, num_fir_taps);

    for (size_t t = 0; t < 10000000; t++) {
        float x = t * 1.0;
        dsbuffer_push (buf, x);
        dsbuffer_latest_fir_output (buf);
    }

    dsbuffer_free (&buf);

    // 2
    size = num_fir_taps;
    buf = dsbuffer_new (num_fir_taps, false);
    assert (buf);
    dsbuffer_setup_fir (buf, fir_taps, num_fir_taps);

    dumped = (float *) malloc (sizeof (float) * size);

    float signal1[] = {1, 4, 2, 5};
    for (size_t t = 0; t < 4; t++) {
        dsbuffer_push (buf, signal1[t]);
        dsbuffer_dump (buf, dumped);
        for (size_t i = 0; i < size; i++)
            printf ("dumped idx: %zu, value: %.3f\n", i, dumped[i]);
        printf ("FIR output: %.3f\n", dsbuffer_latest_fir_output (buf));
    }

    dsbuffer_print_raw (buf, false);

    free (dumped);

    float *output = (float *) malloc (sizeof (float) * size);
    assert (output);
    dsbuffer_fir_filter (buf, output);
    for (size_t i = 0; i < num_fir_taps; i++)
        printf ("%.3f ", output[i]);
    printf ("\n");
    free (output);

    dsbuffer_free (&buf);

    // 3. FFT

    float signal2[] = {1, 4, 2, 5, 6, 7, -1, -8};
    size = sizeof (signal2) / sizeof (float);

    buf = dsbuffer_new (size, true);
    assert (buf);
    dsbuffer_print_raw (buf, true);

    dumped = (float *) malloc (sizeof (float) * size);

    for (size_t t = 0; t < size; t++) {
        dsbuffer_push (buf, signal2[t]);
        dsbuffer_print_raw (buf, true);
        // if (t == 3)
        //     dsbuffer_clear (buf);
        dsbuffer_dump (buf, dumped);
        for (size_t i = 0; i < size; i++)
            printf ("dumped idx: %zu, value: %.3f\n", i, dumped[i]);
    }

    free (dumped);

    dsbuffer_complex *fft_data =
        (dsbuffer_complex *) malloc (sizeof (dsbuffer_complex) * (size/2+1));
    dsbuffer_fftr (buf, fft_data);

    float *fft_freq = (float *) malloc (sizeof (float) * (size/2+1));
    dsbuffer_fft_freq (buf, 9.0, fft_freq);

    for (size_t idx = 0; idx < size/2+1; idx++) {
        printf("idx: %zu, freq: %.3f, real: %.3f, imag: %.3f\n",
               idx, fft_freq[idx], fft_data[idx].real, fft_data[idx].imag);
    }

    dsbuffer_free (&buf);


    // 4.
    size = 64;
    fft_supported = false;
    buf = dsbuffer_new (size, fft_supported);
    assert (buf);
    dumped = (float *) malloc (sizeof (float) * size);
    assert (dumped);

    for (size_t t = 0; t < 100000; t++) {
        float a = (int)(rand()*10000.0/RAND_MAX)/100.0;
        dsbuffer_push (buf, a);
        // dsbuffer_print (buf, fft_supported);
        dsbuffer_dump (buf, dumped);
        // for (size_t i = 0; i < size; i++)
        //     printf("%.3f, ", dumped[i]);
        // printf("\n");
        // printf("push: %.3f, get: %.3f\n", a, dumped[size-1]);
        assert (dumped[size-1] == a);
    }

    free (dumped);
    dsbuffer_free (&buf);

    // 5.
    size = 64;
    fft_supported = true;
    buf = dsbuffer_new (size, fft_supported);
    assert (buf);
    dumped = (float *) malloc (sizeof (float) * size);
    assert (dumped);

    for (size_t t = 0; t < 100000; t++) {
        float a = (int)(rand()*10000.0/RAND_MAX)/100.0;
        dsbuffer_push (buf, a);
        // dsbuffer_print (buf, fft_supported);
        dsbuffer_dump (buf, dumped);
        // for (size_t i = 0; i < size; i++)
        //     printf("%.3f, ", dumped[i]);
        // printf("\n");
        // printf("push: %.3f, get: %.3f\n", a, dumped[size-1]);
        assert (dumped[size-1] == a);
    }

    free (dumped);
    dsbuffer_free (&buf);


    // 6.
    size = 100;
    fft_supported = true;
    buf = dsbuffer_new (size, fft_supported);
    assert (buf);
    dumped = (float *) malloc (sizeof (float) * size);
    assert (dumped);

    for (size_t t = 0; t < 100000; t++) {
        float a = (int)(rand()*10000.0/RAND_MAX)/100.0;
        dsbuffer_push (buf, a);
        // dsbuffer_print (buf, fft_supported);
        dsbuffer_dump (buf, dumped);
        // for (size_t i = 0; i < size; i++)
        //     printf("%.3f, ", dumped[i]);
        // printf("\n");
        // printf("push: %.3f, get: %.3f\n", a, dumped[size-1]);
        assert (dumped[size-1] == a);
    }

    free (dumped);
    dsbuffer_free (&buf);

    // 7.
    size = 100;
    fft_supported = false;
    buf = dsbuffer_new (size, fft_supported);
    assert (buf);
    dumped = (float *) malloc (sizeof (float) * size);
    assert (dumped);

    for (size_t t = 0; t < 100000; t++) {
        float a = (int)(rand()*10000.0/RAND_MAX)/100.0;
        dsbuffer_push (buf, a);
        // dsbuffer_print (buf, fft_supported);
        dsbuffer_dump (buf, dumped);
        // for (size_t i = 0; i < size; i++)
        //     printf("%.3f, ", dumped[i]);
        // printf("\n");
        // printf("push: %.3f, get: %.3f\n", a, dumped[size-1]);
        assert (dumped[size-1] == a);
    }

    free (dumped);
    dsbuffer_free (&buf);

    // 8. normalize
    size = 5;
    fft_supported = false;
    buf = dsbuffer_new (size, fft_supported);
    assert (buf);

    float signal3[] = {4.5, 6.7, 99.3, 45.3, 78.6};
    for (size_t t = 0; t < size; t++)
        dsbuffer_push (buf, signal3[t]);
    printf ("mean: %.2f, length: %.2f\n", dsbuffer_mean (buf), dsbuffer_length (buf));

    dumped = (float *) malloc (sizeof (float) * size);
    assert (dumped);

    dsbuffer_normalize_to_unit_length (buf, true, dumped);
    for (size_t i = 0; i < size; i++)
        printf ("normalized idx: %zu, value: %.2f\n", i, dumped[i]);

    free (dumped);
    dsbuffer_free (&buf);


    printf ("OK\n");
}
