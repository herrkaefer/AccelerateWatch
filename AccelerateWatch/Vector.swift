/// Vector
//
//  Created by Yang Liu (gloolar [at] gmail [dot] com) on 16/7/9.
//  Copyright © 2016年 Yang Liu. All rights reserved.
//

import Foundation


private func scalarEqual(_ scalar1: Float, scalar2: Float) -> Bool {
    return fabs(scalar1 - scalar2) < 1e-6
}


private func scalarEqual(_ scalar1: Double, scalar2: Double) -> Bool {
    return fabs(scalar1 - scalar2) < 1e-6
}


/// Mean value. Float type version.
public func vMean(_ v: [Float]) -> Float {
    return vectorf_mean(v, v.count)
}


/// Mean value. Double type version.
public func vMean(_ v: [Double]) -> Double {
    return vectord_mean(v, v.count)
}


/// Summation. Float type version.
public func vSum(_ v: [Float]) -> Float {
    return vectorf_sum(v, v.count)
}


/// Summation. Double type version.
public func vSum(_ v: [Double]) -> Double {
    return vectord_sum(v, v.count)
}


/// Vector length. Float type version.
public func vLength(_ v: [Float]) -> Float {
    return vectorf_length(v, v.count)
}


/// Vector length. Double type version.
public func vLength(_ v: [Double]) -> Double {
    return vectord_length(v, v.count)
}


/// Square of length. Float type version.
public func vPower(_ v: [Float]) -> Float {
    return vectorf_power(v, v.count)
}


/// Square of length. Double type version.
public func vPower(_ v: [Double]) -> Double {
    return vectord_power(v, v.count)
}


/// Add scalar to vector. Float type version.
public func vAdd(_ v: [Float], valueToAdd: Float) -> [Float] {
    var result = [Float](repeating: 0.0, count: v.count)
    vectorf_add(v, v.count, valueToAdd, &result)
    return result
}


/// Add scalar to vector. Double type version.
public func vAdd(_ v: [Double], valueToAdd: Double) -> [Double] {
    var result = [Double](repeating: 0.0, count: v.count)
    vectord_add(v, v.count, valueToAdd, &result)
    return result
}


/// Multiply vector with scalar. Float type version.
public func vMultiply(_ v: [Float], valueToMultiply: Float) -> [Float] {
    var result = [Float](repeating: 0.0, count: v.count)
    vectorf_multiply(v, v.count, valueToMultiply, &result)
    return result
}


/// Multiply vector with scalar. Double type version.
public func vMultiply(_ v: [Double], valueToMultiply: Double) -> [Double] {
    var result = [Double](repeating: 0.0, count: v.count)
    vectord_multiply(v, v.count, valueToMultiply, &result)
    return result
}


/// Remove mean value. Float type version.
public func vRemoveMean(_ v: [Float]) -> [Float] {
    var result = [Float](repeating: 0.0, count: v.count)
    vectorf_remove_mean(v, v.count, &result)
    return result
}


/// Remove mean value. Double type version.
public func vRemoveMean(_ v: [Double]) -> [Double] {
    var result = [Double](repeating: 0.0, count: v.count)
    vectord_remove_mean(v, v.count, &result)
    return result
}


/// Normalize vector to have unit length. Float type version.
public func vNormalizeToUnitLength(_ v: [Float], centralized: Bool) -> [Float] {
    var result = [Float](repeating: 0.0, count: v.count)
    vectorf_normalize_to_unit_length(v, v.count, centralized, &result)
    return result
}


/// Normalize vector to have unit length. Double type version.
public func vNormalizeToUnitLength(_ v: [Double], centralized: Bool) -> [Double] {
    var result = [Double](repeating: 0.0, count: v.count)
    vectord_normalize_to_unit_length(v, v.count, centralized, &result)
    return result
}


/// Sqrt. Float type version.
public func vSqrt(_ v: [Float]) -> [Float] {
    var result = [Float](repeating: 0.0, count: v.count)
    vectorf_sqrt(v, v.count, &result)
    return result
}


/// Sqrt. Double type version.
public func vSqrt(_ v: [Double]) -> [Double] {
    var result = [Double](repeating: 0.0, count: v.count)
    vectord_sqrt(v, v.count, &result)
    return result
}


/// Dot production between two vectors. Float type version.
public func vDotProduct(_ v1: [Float], v2: [Float]) -> Float {
    assert (v1.count == v2.count)
    return vectorf_dot_product(v1, v2, v1.count)
}


/// Dot production between two vectors. Double type version.
public func vDotProduct(_ v1: [Double], v2: [Double]) -> Double {
    assert (v1.count == v2.count)
    return vectord_dot_product(v1, v2, v1.count)
}


/// Correlation Coefficient between two vectors. Float type version.
public func vCorrelationCoefficient(_ v1: [Float], v2: [Float]) -> Float {
    assert (v1.count == v2.count)
    return vDotProduct(vNormalizeToUnitLength(v1, centralized: true), v2: vNormalizeToUnitLength(v2, centralized: true))
}


/// Correlation Coefficient between two vectors. Double type version.
public func vCorrelationCoefficient(_ v1: [Double], v2: [Double]) -> Double {
    assert (v1.count == v2.count)
    return vDotProduct(vNormalizeToUnitLength(v1, centralized: true), v2: vNormalizeToUnitLength(v2, centralized: true))
}


/// :nodoc: 
/// Self test of Vector functions
public func vTest() {
    print("Vector test: \n")
    
    let v1 = Array(0..<10).map{Float($0)}
    var v2 = Array(0..<10).map{Float($0)}
    print(v1)
    print(v2)
    var cc = vCorrelationCoefficient(v1, v2: v2)
    print("cc: \(cc)")
    assert(scalarEqual(cc, scalar2: 1.0))
    
    v2 = vAdd(v2, valueToAdd: 3.0)
    cc = vCorrelationCoefficient(v1, v2: v2)
    print("cc: \(cc)")
    assert(scalarEqual(cc, scalar2: 1.0))
    
    // time it
    
    let iterations = 10000
    
    let v3 = Array(1...100).map{Double($0)}
    
    // Naïve Swift Implementation
    var startTime = CFAbsoluteTimeGetCurrent()
    for _ in 0..<iterations {
        let avg = v3.reduce(0.0, +) / Double(v3.count)
        let centralized = v3.map{$0-avg}
        let length = centralized.reduce(0.0, {$0+$1*$1})
        _ = centralized.map{$0/length}
    }
    let deltaTime1 = CFAbsoluteTimeGetCurrent() - startTime
    print(String(format: "deltaTime 1: %f\n", deltaTime1))
    
    startTime = CFAbsoluteTimeGetCurrent()
    for _ in 0..<iterations {
        _ = vNormalizeToUnitLength(v3, centralized: true)
    }
    let deltaTime2 = CFAbsoluteTimeGetCurrent() - startTime
    print(String(format: "deltaTime 2: %f\n", deltaTime2))
    print(String(format: "improve: %f\n", deltaTime1/deltaTime2))
    
    print("Vector test: OK.\n")
}
