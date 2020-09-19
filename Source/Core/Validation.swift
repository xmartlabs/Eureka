//  RowValidationType.swift
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

public struct ValidationError: Equatable {

    public let msg: String

    public init(msg: String) {
        self.msg = msg
    }
}

public func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
    return lhs.msg == rhs.msg
}

/// Type representing any rule that row can contain
public protocol RowRule {
    associatedtype RowValue

    /// Returns `true` if a value fits this row describes, otherwise the result is `false`
    /// - Parameter value: Value that needs to be validated
    /// - Parameter form: Form where rule's owner is placed
    func allows(_ value: RowValue?, in form: Form) -> Bool
}

public struct ValidationOptions: OptionSet {

    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let validatesOnDemand  = ValidationOptions(rawValue: 1 << 0)
    public static let validatesOnChange  = ValidationOptions(rawValue: 1 << 1)
    public static let validatesOnBlur = ValidationOptions(rawValue: 1 << 2)
    public static let validatesOnChangeAfterBlurred = ValidationOptions(rawValue: 1 << 3)

    public static let validatesAlways: ValidationOptions = [.validatesOnChange, .validatesOnBlur]
}

public struct RowRuleWrapping<T: Equatable> {
    let closure: (T?, Form) -> ValidationError?
    let linkedError: ValidationError
    let id: String?
    
    public init(closure: @escaping (T?, Form) -> ValidationError?, linkedError: ValidationError, id: String? = nil) {
        self.closure = closure
        self.linkedError = linkedError
        self.id = id
    }
}
