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

public protocol BaseRuleType {
    var id: String? { get set }
    var validationError: ValidationError { get set }
}

public protocol RuleType: BaseRuleType {
    associatedtype RowValueType

    func isValid(value: RowValueType?) -> ValidationError?
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

public struct ValidationRuleHelper<T> where T: Equatable {
    let validateFn: ((T?) -> ValidationError?)
    public let rule: BaseRuleType
}

public struct RuleSet<T: Equatable> {

    internal var rules: [ValidationRuleHelper<T>] = []

    public init() {}

    /// Add a validation Rule to a Row
    /// - Parameter rule: RuleType object typed to the same type of the Row.value
    public mutating func add<Rule: RuleType>(rule: Rule) where T == Rule.RowValueType {
        let validFn: ((T?) -> ValidationError?) = { (val: T?) in
            return rule.isValid(value: val)
        }
        rules.append(ValidationRuleHelper(validateFn: validFn, rule: rule))
    }

    public mutating func remove(ruleWithIdentifier identifier: String) {
        if let index = rules.firstIndex(where: { (validationRuleHelper) -> Bool in
            return validationRuleHelper.rule.id == identifier
        }) {
            rules.remove(at: index)
        }
    }

    public mutating func removeAllRules() {
        rules.removeAll()
    }

}
