//  RuleLength.swift
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

public struct RuleMinLength: RuleType {

    let min: UInt

    public var id: String?
    public var validationError: ValidationError

    public init(minLength: UInt, msg: String? = nil) {
        let ruleMsg = msg ?? "Field value must have at least \(minLength) characters"
        min = minLength
        validationError = ValidationError(msg: ruleMsg)
    }

    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value.count < Int(min) ? validationError : nil
    }
}

public struct RuleMaxLength: RuleType {

    let max: UInt

    public var id: String?
    public var validationError: ValidationError

    public init(maxLength: UInt, msg: String? = nil) {
        let ruleMsg = msg ?? "Field value must have less than \(maxLength) characters"
        max = maxLength
        validationError = ValidationError(msg: ruleMsg)
    }

    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value.count > Int(max) ? validationError : nil
    }
}

public struct RuleExactLength: RuleType {
    let length: UInt
    
    public var id: String?
    public var validationError: ValidationError
    
    public init(exactLength: UInt, msg: String? = nil) {
        let ruleMsg = msg ?? "Field value must have exactly \(exactLength) characters"
        length = exactLength
        validationError = ValidationError(msg: ruleMsg)
    }
    
    public func isValid(value: String?) -> ValidationError? {
        guard let value = value else { return nil }
        return value.count != Int(length) ? validationError : nil
    }
}
