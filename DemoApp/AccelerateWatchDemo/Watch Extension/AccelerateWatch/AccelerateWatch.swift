//
//  AccelerateWatch.swift
//  AccelerateWatchDemo
//
//  Created by HerrKaefer on 16/6/20.
//  Copyright © 2016年 Herrkaefer. All rights reserved.
//

import Foundation


//struct ComplexNumber {
//    var real: Float
//    var imag: Float
//}


class DSBuffer {
    
    private var buffer: COpaquePointer
    private var size: Int
    
    private var fftIsSupported: Bool
    private var fftData: [dsbuffer_complex]?
    private var fftIsUpdated: Bool?
    
    init(size: Int, fftIsSupported: Bool) {
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
    
    func push(value: Float) {
        dsbuffer_push(self.buffer, value)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
    }
    
    func fft() -> (real: [Float], imaginary: [Float]) {
        assert (self.fftIsSupported)
        dsbuffer_fftr(self.buffer, &self.fftData!)
        self.fftIsUpdated = true
        return (self.fftData!.map{$0.real}, self.fftData!.map{$0.imag})
    }
    
    func fftFrequencies(fs: Float) -> [Float] {
        assert (self.fftIsSupported)
        var fftFreq = [Float](count: self.size/2+1, repeatedValue: 0.0)
        dsbuffer_fft_freq(self.buffer, fs, &fftFreq)
        return fftFreq
    }
    
    func fftMagnitudes() -> [Float] {
        assert (self.fftIsSupported)
        if (!self.fftIsUpdated!) {
            fft()
        }
        return self.fftData!.map{sqrt($0.real*$0.real + $0.imag*$0.imag)}
    }
    
    func squareOfFFTMagnitudes() -> [Float] {
        assert (self.fftIsSupported)
        if (!self.fftIsUpdated!) {
            fft()
        }
        return self.fftData!.map{$0.real*$0.real + $0.imag*$0.imag}
    }
    
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
    
    func clear() {
        dsbuffer_clear(self.buffer)
        if (self.fftIsSupported) {
            self.fftIsUpdated = false
        }
    }
    
    class func test() {
//        dsbuffer_test()
        let signalData: [Float] = [1.0, 4, 2, 5, 6, 7, -1, -8]
        let buf = DSBuffer(size: signalData.count, fftIsSupported: true)
        for value in signalData {
            buf.push(value)
        }
        
        let fft = buf.fft()
        print(fft)
        
        let fftSM = buf.squareOfFFTMagnitudes()
        print(fftSM)
    }
    
    deinit {
        dsbuffer_free(&self.buffer)
    }
}



