# AccelerateWatch

![Language](https://img.shields.io/badge/language-C-lightgrey.svg?style=flat)
![Language](https://img.shields.io/badge/language-Swift-red.svg?style=flat)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)
[![Twitter](https://img.shields.io/badge/twitter-mrbeetle-blue.svg?style=flat)](http://twitter.com/mrbeetle)

Some basic digital signal processing algorithms implemented in C, and wrapped in Swift.

# Where and why to use AccelerateWatch?

Apple watchOS 3 opens opptunity to developers to obtain and process motion sensor data both in real time and longer running time. Unfortunately, at the same time, [Accelerate framework](https://developer.apple.com/library/ios/documentation/Accelerate/Reference/AccelerateFWRef/) is still unavailable on watchOS. This library will help those watchOS⌚️ apps which need to process sensor data in real time, just like what Accelerate does for iOS platform.

Current functionality is still much much less compared with Accelerate because only those I used in my projects are added. So **contributions are welcome!** 😃

# Install

## Install manually

1. Copy AccelerateWatch folder to your project

2. Add a bridging header (here is a [Instructions: ADDING A SWIFT BRIDGING HEADER](http://www.learnswiftonline.com/getting-started/adding-swift-bridging-header/)), and add the following contents to it:

```C
#include "acceleratelib.h"
```

# Usage

## DSBuffer

DSBuffer represents a fixed length signal buffer (Float type) which is suitable for storing and processing a windowed time series.

Create a DSBuffer object. If you do not need to perform FFT on the buffer, set fftIsSupperted to false would accelerate more.

```Swift
DSBuffer(size: Int, fftIsSupported: Bool): DSBuffer
```

Push new data to the end of the buffer

```Swift
func push(value: Float)
```

Get buffer size

```swift
var bufferSize: Int
```

Dump signal array

```Swift
var signals: [Float]
```

Reset all buffer values to zero

```swift
func clear()
```

Vector operations

```swift
func add(value: Float) -> [Float]
func multiply(value: Float) -> [Float]
var mean: Float
var length: Float
func centralized() -> [Float]
func normalizedToUnitLength(centralized: Bool) -> [Float]
func dotProduct(with: [Float]) -> Float
```

Perform FFT

```Swift
func fft() -> (real: [Float], imaginary: [Float])
```

Get FFT sample frequencies

```Swift
func fftFrequencies(fs: Float) -> [Float]
```

Get FFT magnitudes

```Swift
func fftMagnitudes() -> [Float]
```
Square of FFT Magnitude, i.e. (abs(fft()))^2

```swift
func squaredPowerSpectrum() -> [Float]
```

Mean-squared power spectrum, i.e. (abs(fft()))^2 / N

```swift
func meanSquaredPowerSpectrum() -> [Float]
```

Power spectral density (PSD), i.e. (abs(fft()))^2 / (fs*N)

```Swift
func powerSpectralDensity(fs: Float) -> [Float]
```

Average power on specified frequency band, i.e. mean(abs(fft(from...to))^2)

```swift
func averageBandPower(fromFreq: Float = 0, toFreq: Float, fs: Float) -> Float
```

Setup a FIR filter

```Swift
buf.setupFIRFilter(FIRTaps: [Float])
```

Get latest FIR filter output

```Swift
func latestFIROutput() -> Float
```

Get FIR filtered signal series in buffer

```Swift
func FIRFiltered() -> [Float]
```


## Vector

Vector module includes operations on regular arrays.

- vMean
- vLength
- vAdd
- vMultiply
- vRemoveMean
- vNormalizeToUnitLength
- vDotProduct

