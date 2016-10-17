# AccelerateWatch

![Language](https://img.shields.io/badge/language-C-lightgrey.svg?style=flat)
![Language](https://img.shields.io/badge/language-Swift-red.svg?style=flat)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](http://mit-license.org)
![Build](https://img.shields.io/wercker/ci/wercker/docs.svg?style=flat)

```AccelerateWatch```: High performance digital signal processing and vector operations implemented in C, and wrapped in Swift, designed especially to be targeted at watchOS.

# Working version: 1.0.1

Currently all codes are built and tested on

- Xcode 8.0 beta 3
- iOS 10.0 beta 3
- watchOS 3.0 beta 3
- Swift 3

# Where and why to use AccelerateWatch?

Apple watchOS 3 opens opptunities to developers to access more motion sensor data both in real time and possible background tasks. Unfortunately meanwhile, the [Accelerate framework](https://developer.apple.com/library/ios/documentation/Accelerate/Reference/AccelerateFWRef/), a powerful tool for high-performance computations, is still unavailable on watchOS. This library is extracted from my other projects, and help those watchOS⌚️ apps which need to process sensor data in real time, just like what Accelerate does for iOS platform.

- Swift APIs. C data structures and methods are wrapped in Swift, so that you can call them using Swift conveniently.
- Friendly syntax. This is a reason that you even want to use this instead of Accelerate framework on iOS, though other similar libraries like [Surge](https://github.com/mattt/Surge) exists.

Currently the functionality set is relatively smaller compared with Accelerate framework because only those I used in my projects are added (mostly focused on time series operations and analysis). So **contributions are welcome!** 😃

# Install

Manual install is recommended for now. [Swift Package Manager](https://github.com/apple/swift-package-manager) will be supported when it is ready.

1. Clone the latest version of this repo to your local machine.
2. Copy AccelerateWatch folder to your project (usually the Watch Extension folder). Remove `acceleratelib/build` folder which is for C code testing.
3. Check that every .swift and .c files has *Watch Extension* as target if your want it to be used on watch target.
4. Add a bridging header (here is a [Instruction](http://www.learnswiftonline.com/getting-started/adding-swift-bridging-header/)), and add the following line to it:

```c
#include "acceleratelib.h"
```

# Usage

Full documentation [HERE](http://herrkaefer.online/AccelerateWatch/).

The library currently has two modules:

- `DSBuffer` is a class for windowed time series processing. You can simply push data into the buffer, and extract time-domain features, or perform Fourier transform and freqency analysis on it.
- `Vector` is a set of functons for accelerating vector manipulations.

Below is a summary of the APIs.

## DSBuffer

DSBuffer represents a fixed length signal queue (Float type) which is suitable for storing and processing a windowed time series.

#### Normal operations

```swift
// Create a DSBuffer object
// *Tips*: 
// - If you do not need to perform FFT on the buffer, set fftIsSupperted to be false could save 50% memory.
// - If you need to perform FFT, set buffer size to power of 2 could accelerate more.
init(size: Int, fftIsSupported: Bool = true)

// Push new data to the end of the buffer (and the foremost will be dropped)
func push(value: Float)

// Get data by index
func dataAt(index: Int)

// Get buffer size
var bufferSize: Int

// Dump buffer as array
var data: [Float]

// Reset all buffer values to zero
func clear()
```

#### Vector-like operations

```swift
func add(value: Float) -> [Float]
func multiply(value: Float) -> [Float]
var centralized: [Float]
func normalizedToUnitLength(centralized: Bool) -> [Float]
func normalizedToUnitVariance(centralized: Bool) -> [Float]
func dotProduct(with: [Float]) -> Float
```

#### Time-domain features

```swift
var mean: Float
var sum: Float
var length: Float
var energy: Float
var max: Float
var min: Float
var variance: Float
var std: Float
```

#### Fast Fourier Transform and frequency-domain features

**Note for FFT related methods**:

- Set `fftIsSupported` to true when creating the buffer.
- Buffer `size` should be even. If you pass odd size when creating the buffer, it is automatically increased by 1.
- Only results in **size/2+1** complex frequency bins from DC to Nyquist are returned.

```swift
// Perform FFT on buffer
func fft() -> (real: [Float], imaginary: [Float])

// Get FFT sample frequencies
func fftFrequencies(fs: Float) -> [Float]

// Get FFT magnitudes
func fftMagnitudes() -> [Float]

// Square of FFT Magnitude, i.e. (abs(fft()))^2
func squaredPowerSpectrum() -> [Float]

// Mean-squared power spectrum, i.e. (abs(fft()))^2 / N
func meanSquaredPowerSpectrum() -> [Float]

// Power spectral density (PSD), i.e. (abs(fft()))^2 / (fs*N)
func powerSpectralDensity(fs: Float) -> [Float]

// Average power over specified frequency band, i.e. mean(abs(fft(from...to))^2)
func averageBandPower(fromFreq: Float = 0, toFreq: Float, fs: Float) -> Float
```

#### FIR filter

```swift
// Setup a FIR filter
func setupFIRFilter(FIRTaps: [Float])

// Get latest FIR filter output
func latestFIROutput() -> Float

// Get FIR filtered signal series in buffer
func FIRFiltered() -> [Float]
```


## Vector

Vector module includes operations on regular arrays. All functions have two versions, for float and double type respectively.

- `vMean`
- `vSum`
- `vLength`
- `vPower`
- `vAdd`
- `vMultiply`
- `vRemoveMean`
- `vNormalizeToUnitLength`
- `vSqrt`
- `vDotProduct`
- `vCorrelationCoefficient`


# Demo App

```AccelerateWatchDemoApp``` is a demo app showing how to integrate AccelerateWatch for watch target. For details, please see `DSBuffer.test()` in DSBuffer.swift and `vTest()` in Vector.swift.

# Known issues

- Setting any LLVM (v8) optimization level rather than `None [-O0]` would probably cause unexpected behavior of DSBuffer.

# How to contribute

...

# Acknowledgement

- [kissfft](https://github.com/itdaniher/kissfft)

kissfft is employed for FFT implementation. It is a lightweight and fast FFT library. Only the real-value FFT related part is included here.

- [jazzy](https://github.com/realm/jazzy)

For documentation generation.

# License

MIT
