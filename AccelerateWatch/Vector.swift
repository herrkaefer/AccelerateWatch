//
//  Vector.swift
//
//  Created by HerrKaefer (gloolar@gmail.com) on 16/7/9.
//  Copyright © 2016年 HerrKaefer. All rights reserved.
//

import Foundation


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
