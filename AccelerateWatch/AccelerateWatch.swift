//
//  AccelerateWatch.swift
//  AccelerateWatchDemo
//
//  Created by HerrKaefer on 16/6/20.
//  Copyright © 2016年 Herrkaefer. All rights reserved.
//

import Foundation

// MARK: DSBuffer

public class DSBuffer {
    
    private var buffer: COpaquePointer
    private var size: Int
    
    private var fftIsSupported: Bool
    private var fftData: [dsbuffer_complex]?
    private var fftIsUpdated: Bool?
    
    
    // Initialization
    init(size: Int, fftIsSupported: Bool = true) {
        if (fftIsSupported && size % 2 == 1) {
            print("WARNING: size must be even for FFT. Reset size to: %d.", size+1)
            self.size = size + 1
        }
        else {
            self.size = size
        }
        self.buffer = dsbuffer_new (size, fftIsSupported)
        
        self.fftIsSupported = fftIsSupported
        if (fftIsSupported) {
            self.fftData = [dsbuffer_complex](count: self.size/2+1, repeatedValue: dsbuffer_complex(real: 0.0, imag: 0.0))
            self.fftIsUpdated = false
        }
    }
    
    
    deinit {
        dsbuffer_free(&self.buffer)
    }
    
    
    // Push new value to buffer
    func push(value: Float) {
        dsbuffer_push(self.buffer, value)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
    }
    
    
    // Dump as array
    var signals: [Float] {
        var dumpedSignal = [Float](count: self.size, repeatedValue: 0.0)
        dsbuffer_dump(self.buffer, &dumpedSignal)
        return dumpedSignal
    }
    
    
    // Reset buffer to be zero filled
    func clear() {
        dsbuffer_clear(self.buffer)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
    }
    
    
    // MARK: Vector operations
    
    // Add value to buffer data
    func add(value: Float) -> [Float] {
        var result = [Float](count: self.size, repeatedValue: 0.0)
        dsbuffer_add(self.buffer, value, &result)
        return result
    }
    
    
    // Multiply buffer data with value
    func multiply(value: Float) -> [Float] {
        var result = [Float](count: self.size, repeatedValue: 0.0)
        dsbuffer_multiply(self.buffer, value, &result)
        return result
    }
    
    
    // Mean value
    func mean() -> Float {
        return dsbuffer_mean(self.buffer)
    }
    
    
    // Vector length
    func length() -> Float {
        return dsbuffer_length(self.buffer)
    }
    
    
    // Remove mean value (centralize)
    func removeMean() -> [Float] {
        var result = [Float](count: self.size, repeatedValue: 0.0)
        dsbuffer_remove_mean(self.buffer, &result)
        return result
    }
    
    
    // normalize vector to have unit length
    func normalizeToUnitLength(centralized: Bool) -> [Float] {
        var result = [Float](count: self.size, repeatedValue: 0.0)
        dsbuffer_normalize_to_unit_length(self.buffer, centralized, &result)
        return result
    }
    
    
    func dotProduct(withVector: [Float]) -> Float {
        assert(self.size == withVector.count)
        return dsbuffer_dot_product(self.buffer, withVector)
    }
    
    
    // MARK: FFT
    
    // Perform FFT if it is not updated
    private func updateFFT() {
        assert (self.fftIsSupported)
        if (!self.fftIsUpdated!) {
            fft()
        }
    }
    
    
    // Perform FFT
    func fft() -> (real: [Float], imaginary: [Float]) {
        assert (self.fftIsSupported)
        dsbuffer_fftr(self.buffer, &self.fftData!)
        self.fftIsUpdated = true
        return (self.fftData!.map{$0.real}, self.fftData!.map{$0.imag})
    }
    
    
    // Get FFT sample frequencies
    func fftFrequencies(fs: Float) -> [Float] {
        assert (self.fftIsSupported)
        var fftFreq = [Float](count: self.size/2+1, repeatedValue: 0.0)
        dsbuffer_fft_freq(self.buffer, fs, &fftFreq)
        return fftFreq
    }
    
    
    // Get FFT magnitudes, i.e. abs(fft())
    func fftMagnitudes() -> [Float] {
        updateFFT()
        return self.fftData!.map{sqrt($0.real*$0.real + $0.imag*$0.imag)}
    }
    
    
    // Square of FFT magnitudes, i.e. (abs(fft()))^2
    func squaredPowerSpectrum() -> [Float] {
        updateFFT()
        var sps = self.fftData!.map{($0.real*$0.real + $0.imag*$0.imag) * 2}
        sps[0] /= 2.0 // DC
        return sps
    }
    
    
    // Mean-squared power spectrum, i.e. (abs(fft()))^2 / N
    func meanSquaredPowerSpectrum() -> [Float] {
        updateFFT()
        var pxx = self.fftData!.map{($0.real*$0.real + $0.imag*$0.imag) * 2 / Float(self.size)}
        pxx[0] /= 2.0 // DC
        return pxx
    }
    
    
    // Power spectral density (PSD), i.e. (abs(fft()))^2 / (fs*N)
    func powerSpectralDensity(fs: Float) -> [Float] {
        updateFFT()
        var psd = self.fftData!.map{($0.real*$0.real + $0.imag*$0.imag) * 2.0 / (fs * Float(self.size))}
        psd[0] /= 2.0 // DC
        return psd
    }
    
    
    // Average power on specified frequency band, i.e. mean(abs(fft(from...to))^2)
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
    
    
    // MARK: FIR
    
    func setupFIRFilter(FIRTaps: [Float]) {
        dsbuffer_setup_fir(self.buffer, FIRTaps, FIRTaps.count)
    }
    
    
    func latestFIROutput() -> Float {
        return dsbuffer_latest_fir_output(self.buffer)
    }
    
    
    func FIRFiltered() -> [Float] {
        var output = [Float](count: self.size, repeatedValue: 0.0)
        dsbuffer_fir_filter(self.buffer, &output)
        return output
    }
    
    
    // Self test
    class func test() {
        print("DSBuffer test:\n\n")
        
        let size = 16
        let buf = DSBuffer(size: size, fftIsSupported: true)
        
        let signalData: [Float] = [1.0, 4, 2, 5, 6, 7, -1, -8]
        for value in signalData {
            buf.push(value)
//            print(buf.signals)
        }
        
//        let fft = buf.fft()
//        print(fft)
//        
//        let fftSM = buf.SquaredPowerSpectrum()
//        print(fftSM)
        
        
        buf.clear()
        for _ in 0 ..< 10000 {
            let a = Float(arc4random_uniform(100))
            buf.push(a)
            let signals = buf.signals
            print(a)
            print(signals)
            assert(signals[size-1] == a)
        }
        
        print("\nDSBuffer test OK:\n\n")
    }
    
}


// MARK: Vector

public func vMean(v: [Float]) -> Float {
    return vectorf_mean(v, v.count)
}


public func vMean(v: [Double]) -> Double {
    return vectord_mean(v, v.count)
}


public func vLength(v: [Float]) -> Float {
    return vectorf_length(v, v.count)
}


public func vLength(v: [Double]) -> Double {
    return vectord_length(v, v.count)
}


public func vAdd(v: [Float], valueToAdd: Float) -> [Float] {
    var result = [Float](count: v.count, repeatedValue: 0.0)
    vectorf_add(v, v.count, valueToAdd, &result)
    return result
}


public func vAdd(v: [Double], valueToAdd: Double) -> [Double] {
    var result = [Double](count: v.count, repeatedValue: 0.0)
    vectord_add(v, v.count, valueToAdd, &result)
    return result
}


public func vMultiply(v: [Float], valueToMultiply: Float) -> [Float] {
    var result = [Float](count: v.count, repeatedValue: 0.0)
    vectorf_multiply(v, v.count, valueToMultiply, &result)
    return result
}


public func vMultiply(v: [Double], valueToMultiply: Double) -> [Double] {
    var result = [Double](count: v.count, repeatedValue: 0.0)
    vectord_multiply(v, v.count, valueToMultiply, &result)
    return result
}


public func vRemoveMean(v: [Float]) -> [Float] {
    var result = [Float](count: v.count, repeatedValue: 0.0)
    vectorf_remove_mean(v, v.count, &result)
    return result
}


public func vRemoveMean(v: [Double]) -> [Double] {
    var result = [Double](count: v.count, repeatedValue: 0.0)
    vectord_remove_mean(v, v.count, &result)
    return result
}


public func vNormalizeToUnitLength(v: [Float], centralized: Bool) -> [Float] {
    var result = [Float](count: v.count, repeatedValue: 0.0)
    vectorf_normalize_to_unit_length(v, v.count, centralized, &result)
    return result
}


public func vNormalizeToUnitLength(v: [Double], centralized: Bool) -> [Double] {
    var result = [Double](count: v.count, repeatedValue: 0.0)
    vectord_normalize_to_unit_length(v, v.count, centralized, &result)
    return result
}


public func vDotProduct(v1: [Float], v2: [Float]) -> Float {
    assert (v1.count == v2.count)
    return vectorf_dot_product(v1, v2, v1.count)
}


public func vDotProduct(v1: [Double], v2: [Double]) -> Double {
    assert (v1.count == v2.count)
    return vectord_dot_product(v1, v2, v1.count)
}




