/// DSBuffer
///
/// Created by Yang Liu (gloolar@gmail.com) on 16/6/20.
/// Copyright © 2016年 Yang Liu. All rights reserved.


import Foundation


/// Fixed length signal buffer (Float type) which is suitable for storing and processing a windowed time series.
public class DSBuffer {
    
    private var buffer: OpaquePointer
    private var size: Int
    
    private var fftIsSupported: Bool
    private var fftData: [dsbuffer_complex]?
    private var fftIsUpdated: Bool?
    
    
    /// Constructor
    ///
    /// - parameter size: Buffer length
    /// - parameter fftIsSupported: Whether FFT will be performed on the buffer
    /// - returns: DSBuffer object
    ///
    /// *Tips*: If you do not need to perform FFT on the buffer, set fftIsSupperted to false would accelerate more. If you need to perform FFT, set buffer size to power of 2 would accelerate more.
    init(_ size: Int, fftIsSupported: Bool = true) {
        if (fftIsSupported && size % 2 == 1) {
            print("WARNING: size must be even for FFT. Reset size to: %d.", size+1)
            self.size = size + 1
        }
        else {
            self.size = size
        }
        self.buffer = dsbuffer_new(size, fftIsSupported)
        
        self.fftIsSupported = fftIsSupported
        if (fftIsSupported) {
            self.fftData = [dsbuffer_complex](repeating: dsbuffer_complex(real: 0.0, imag: 0.0), count: self.size/2+1)
            self.fftIsUpdated = false
        }
    }
    
    
    /// Destructor
    deinit {
        dsbuffer_free_unsafe(self.buffer)
    }
    
    
    /// Push new value to buffer
    ///
    /// - parameter value: New value to be added
    func push(_ value: Float) {
        dsbuffer_push(self.buffer, value)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
    }
    
    
    /// Get Buffer size
    var bufferSize: Int {
        return self.size
    }
    
    
    /// Dump buffer as array
    var signals: [Float] {
        var dumpedSignal = [Float](repeating: 0.0, count: self.size)
        dsbuffer_dump(self.buffer, &dumpedSignal)
        return dumpedSignal
    }
    
    
    /// Reset buffer to be zero filled
    func clear() {
        dsbuffer_clear(self.buffer)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
    }
    
    
    // MARK: Vector operations
    
    /// Add value to each buffer data
    func add(value: Float) -> [Float] {
        var result = [Float](repeating: 0.0, count: self.size)
        dsbuffer_add(self.buffer, value, &result)
        return result
    }
    
    
    /// Multiply each buffer data with value
    func multiply(value: Float) -> [Float] {
        var result = [Float](repeating: 0.0, count: self.size)
        dsbuffer_multiply(self.buffer, value, &result)
        return result
    }
    
    
    /// Mean value
    var mean: Float {
        return dsbuffer_mean(self.buffer)
    }
    
    
    /// Vector length
    var length: Float {
        return dsbuffer_length(self.buffer)
    }
    
    
    /// Remove mean value (centralize)
    func centralized() -> [Float] {
        var result = [Float](repeating: 0.0, count: self.size)
        dsbuffer_remove_mean(self.buffer, &result)
        return result
    }
    
    
    /// Normalize vector to have unit length
    func normalizedToUnitLength(centralized: Bool) -> [Float] {
        var result = [Float](repeating: 0.0, count: self.size)
        dsbuffer_normalize_to_unit_length(self.buffer, centralized, &result)
        return result
    }
    
    
    /// Perform dot production with array
    func dotProduct(with: [Float]) -> Float {
        assert(self.size == with.count)
        return dsbuffer_dot_product(self.buffer, with)
    }
    
    
    // MARK: FFT
    
    // Perform FFT if it is not updated
    private func updateFFT() {
        assert (self.fftIsSupported)
        if (!self.fftIsUpdated!) {
            _ = fft()
        }
    }
    
    
    /// Perform FFT
    ///
    /// **Note for FFT related methods**:
    ///
    /// - Set fftIsSupported to true when creating the buffer.
    /// - Buffer size should be even. If you pass odd size when creating the buffer, it is automatically increased by 1.
    /// - Only results in nfft/2+1 complex frequency bins from DC to Nyquist are returned.
    func fft() -> (real: [Float], imaginary: [Float]) {
        assert (self.fftIsSupported)
        dsbuffer_fftr(self.buffer, &self.fftData!)
        self.fftIsUpdated = true
        return (self.fftData!.map{$0.real}, self.fftData!.map{$0.imag})
    }
    
    
    /// FFT sample frequencies
    ///
    /// - returns: array of size nfft/2+1
    func fftFrequencies(fs: Float) -> [Float] {
        assert (self.fftIsSupported)
        var fftFreq = [Float](repeating: 0.0, count: self.size/2+1)
        dsbuffer_fft_freq(self.buffer, fs, &fftFreq)
        return fftFreq
    }
    
    
    /// FFT magnitudes, i.e. abs(fft())
    ///
    /// - returns: array of size nfft/2+1
    func fftMagnitudes() -> [Float] {
        updateFFT()
        return self.fftData!.map{sqrt($0.real*$0.real + $0.imag*$0.imag)}
    }
    
    
    /// Square of FFT magnitudes, i.e. (abs(fft()))^2
    ///
    /// - returns: array of size nfft/2+1
    func squaredPowerSpectrum() -> [Float] {
        updateFFT()
        var sps = self.fftData!.map{($0.real*$0.real + $0.imag*$0.imag) * 2}
        sps[0] /= 2.0 // DC
        return sps
    }
    
    
    /// Mean-squared power spectrum, i.e. (abs(fft()))^2 / N
    ///
    /// - returns: array of size nfft/2+1
    func meanSquaredPowerSpectrum() -> [Float] {
        updateFFT()
        var pxx = self.fftData!.map{($0.real*$0.real + $0.imag*$0.imag) * 2 / Float(self.size)}
        pxx[0] /= 2.0 // DC
        return pxx
    }
    
    
    /// Power spectral density (PSD), i.e. (abs(fft()))^2 / (fs*N)
    /// 
    /// - returns: array of size nfft/2+1
    func powerSpectralDensity(fs: Float) -> [Float] {
        updateFFT()
        var psd = self.fftData!.map{($0.real*$0.real + $0.imag*$0.imag) * 2.0 / (fs * Float(self.size))}
        psd[0] /= 2.0 // DC
        return psd
    }
    
    
    /// Average power over specific frequency band, i.e. mean(abs(fft(from...to))^2)
    func averageBandPower(fromFreq: Float = 0, toFreq: Float, fs: Float) -> Float {
        assert (fromFreq >= 0)
        assert (toFreq <= fs/2.0)
        assert (fromFreq <= toFreq)
        
        updateFFT()
        
        // Compute index range corresponding to given frequency band
        // f = idx*df = idx*fs/N ==> idx = N*f/fs
        let fromIdx = Int(floor(fromFreq * Float(self.size) / fs))
        let toIdx = Int(ceil(toFreq * Float(self.size) / fs))
        
//        let fftBand = Array(self.fftData![fromIdx...toIdx])
        let bandPower = self.fftData![fromIdx...toIdx].map{$0.real*$0.real+$0.imag*$0.imag}
        
        // Averaging
        return bandPower.reduce(0.0, combine: +) / Float(toIdx - fromIdx + 1)
    }
    
    
    // MARK: FIR filter
    
    // Setup FIR filter
    func setupFIRFilter(FIRTaps: [Float]) {
        assert (self.size >= FIRTaps.count)
        dsbuffer_setup_fir(self.buffer, FIRTaps, FIRTaps.count)
    }
    
    
    /// Get latest FIR output
    func latestFIROutput() -> Float {
        return dsbuffer_latest_fir_output(self.buffer)
    }
    
    
    /// FIR filtered buffer
    func FIRFiltered() -> [Float] {
        var output = [Float](repeating: 0.0, count: self.size)
        dsbuffer_fir_filter(self.buffer, &output)
        return output
    }
    
    
    // Self test
    class func test() {
        print("DSBuffer test:\n\n")
        
        let size = 16
        let buf = DSBuffer(size, fftIsSupported: true)
        
        let signalData: [Float] = [1.0, 4, 2, 5, 6, 7, -1, -8]
        for value in signalData {
            buf.push(value)
//            print(buf.signals)
        }
        
        let fft = buf.fft()
        print(fft)
        
        let fftSM = buf.squaredPowerSpectrum()
        print(fftSM)
        
        
        buf.clear()
        for _ in 0 ..< 10000 {
            let a = Float(arc4random_uniform(100))
            buf.push(a)
            let signals = buf.signals
//            print(a)
//            print(signals)
            assert(signals[size-1] == a)
        }
        
        
        let norm = buf.normalizedToUnitLength(centralized: true)
        let coeff = vDotProduct(norm, v2: norm)
        print("coeff: %.2f\n", coeff)
        
        print("\nDSBuffer test OK.\n\n")
    }
    
}
