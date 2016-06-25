//
//  AccelerateWatch.swift
//  AccelerateWatchDemo
//
//  Created by HerrKaefer on 16/6/20.
//  Copyright © 2016年 Herrkaefer. All rights reserved.
//

import Foundation


class DSBuffer {
    
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
    func SquaredPowerSpectrum() -> [Float] {
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
    
    
    // Reset buffer to be zero filled
    func clear() {
        dsbuffer_clear(self.buffer)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
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
    
    
    deinit {
        dsbuffer_free(&self.buffer)
    }
}



