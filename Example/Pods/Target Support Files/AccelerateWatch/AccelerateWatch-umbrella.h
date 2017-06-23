#ifdef __OBJC__
#import <Foundation/Foundation.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "acceleratelib.h"
#import "dsbuffer.h"
#import "kiss_fft.h"
#import "kiss_fftr.h"
#import "_kiss_fft_guts.h"
#import "vectord.h"
#import "vectorf.h"

FOUNDATION_EXPORT double AccelerateWatchVersionNumber;
FOUNDATION_EXPORT const unsigned char AccelerateWatchVersionString[];

