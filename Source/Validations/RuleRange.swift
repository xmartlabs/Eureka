//  RuleRange.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public struct RuleGreaterThan<T: Comparable>: RuleType {
    
    let min: T
    
    public var id: String?
    public var validationError: ValidationError
    
    public init(min: T){
        self.min = min
        self.validationError = ValidationError(msg: "Field value must be greater than \(min)")
    }
    
    public func isValid(value: T?) -> ValidationError? {
        guard let val = value else { return nil }
        guard val > min else { return validationError }
        return nil
    }
}

public struct RuleGreaterOrEqualThan<T: Comparable>: RuleType {
    
    let min: T
    
    public var id: String?
    public var validationError: ValidationError
    
    public init(min: T){
        self.min = min
        self.validationError = ValidationError(msg: "Field value must be greater or equals than \(min)")
    }
    
    public func isValid(value: T?) -> ValidationError? {
        guard let val = value else { return nil }
        guard val >= min else { return validationError }
        return nil
    }
}

public struct RuleSmallerThan<T: Comparable>: RuleType {
    
    let max: T
    
    public var id: String?
    public var validationError: ValidationError
    
    public init(max: T) {
        self.max = max
        self.validationError = ValidationError(msg: "Field value must be smaller than \(max)")
    }
    
    public func isValid(value: T?) -> ValidationError? {
        guard let val = value else { return nil }
        guard val < max else { return validationError }
        return nil
    }
}

public struct RuleSmallerOrEqualThan<T: Comparable>: RuleType {
    
    let max: T
    
    public var id: String?
    public var validationError: ValidationError
    
    public init(max: T) {
        self.max = max
        self.validationError = ValidationError(msg: "Field value must be smaller or equals than \(max)")
    }
    
    public func isValid(value: T?) -> ValidationError? {
        guard let val = value else { return nil }
        guard val <= max else { return validationError }
        return nil
    }
}
