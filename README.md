# AccelerateWatch

![Language](https://img.shields.io/badge/language-C-lightgrey.svg?style=flat)
![Language](https://img.shields.io/badge/language-Swift-red.svg?style=flat)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)
[![Twitter](https://img.shields.io/badge/twitter-mrbeetle-blue.svg?style=flat)](http://twitter.com/mrbeetle)

Some digital signal processing implementions in C, and Swift wrapper.

# Where and why to use AccelerateWatch?

Unfortunately, for watchOS 3, [Accelerate framework](https://developer.apple.com/library/ios/documentation/Accelerate/Reference/AccelerateFWRef/) is still unavailable. This library will help those apps which need to process sensor datas in real time, just like what Accelerate does for iOS.

# How to use AccelerateWatch?

## Install

1. Copy AccelerateWatch folder to your project

2. Add a bridging header

[Instructions: ADDING A SWIFT BRIDGING HEADER](http://www.learnswiftonline.com/getting-started/adding-swift-bridging-header/)

add content:

```C
#include "acceleratelib.h"
```

## Sample usage

### DSBuffer

Create a DSBuffer object

```Swift
let buf = DSBuffer(size: Int, fftIsSupported: Bool)
```

Push new data

```Swift
buf.push(value: Float)
```

Dump buffer as array

```Swift
let dumpedSignal = buf.dump()
```

Perform FFT

```Swift
let fftData = buf.fft()
```

Get FFT sample frequencies

```Swift
let fftFreq = buf.fftFrequencies(fs: Float)
```

Get FFT magnitudes

```Swift
let fftMagnitudes = buf.fftMagnitudes()
```
Get power spectrum

```Swift
let psd = buf.powerSpectrum(fs: Float)
```

Setup a FIR filter

```Swift
buf.setupFIRFilter(FIRTaps: [Float])
```

Get latest FIR filter output

```Swift
let firOutput = buf.latestFIROutput()
```

Get FIR filtered signal series in buffer

```Swift
let firOutputs = buf.FIRFiltered()
```

Clear buffer (reset to zeros)

```Swift
buf.clear()
```

### Vector

- mean
- length
- add
- multiply
- remove_mean
- normalize
- dot_product

