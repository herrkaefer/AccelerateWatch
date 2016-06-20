//
//  AccelerateWatch.swift
//  AccelerateWatchDemo
//
//  Created by HerrKaefer on 16/6/20.
//  Copyright © 2016年 Herrkaefer. All rights reserved.
//

import Foundation

class DSBuffer {
    var buffer: COpaquePointer
    
    init(size: Int, fft_supported: Bool) {
        self.buffer = dsbuffer_new (size, fft_supported)
    }
    
    func push(value: Float) {
        dsbuffer_push(self.buffer, value)
    }
    
    func fft() -> [Float] {
        return dsbuffer_fftr(self.buffer)
    }
    
    func fftFreq(fs: Float) -> [Float] {
        return dsbuffer_freq(self.buffer, fs)
    }
    
    func fftSquareOfMagnitudes() -> [Float] {
        return dsbuffer_fft_magnitudes_square(self.buffer)
    }
    
    func setupFIRFilter(FIRTaps: [Float]) {
        dsbuffer_setup_fir
    }
    
    func clear() {
        dsbuffer_clear(self.buffer)
    }
    
    class func test() {
        dsbuffer_test()
    }
    
    deinit {
        dsbuffer_free(&self.buffer)
    }
}

