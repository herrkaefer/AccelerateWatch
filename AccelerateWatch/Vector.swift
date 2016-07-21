///  Vector
//
//  Created by Yang Liu (gloolar@gmail.com) on 16/7/9.
//  Copyright © 2016年 Yang Liu. All rights reserved.
//

import Foundation

/// Mean value. Float type version.
public func vMean(_ v: [Float]) -> Float {
    return vectorf_mean(v, v.count)
}


/// Mean value. Double type version.
public func vMean(_ v: [Double]) -> Double {
    return vectord_mean(v, v.count)
}


/// Vector Length. Float type version.
public func vLength(_ v: [Float]) -> Float {
    return vectorf_length(v, v.count)
}


/// Vector Length. Double type version.
public func vLength(_ v: [Double]) -> Double {
    return vectord_length(v, v.count)
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
