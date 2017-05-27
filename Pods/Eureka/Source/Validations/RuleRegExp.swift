//  RegexRule.swift
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

public enum RegExprPattern: String {
    case EmailAddress = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
    case URL = "((https|http)://)((\\w|-)+)(([.]|[/])((\\w|-)+))+"
    case ContainsNumber = ".*\\d.*"
    case ContainsCapital = "^.*?[A-Z].*?$"
    case ContainsLowercase = "^.*?[a-z].*?$"
}

open class RuleRegExp: RuleType {

    public var regExpr: String = ""
    public var id: String?
    public var validationError: ValidationError
    public var allowsEmpty = true

    public init(regExpr: String, allowsEmpty: Bool = true, msg: String = "Invalid field value!") {
        self.validationError = ValidationError(msg: msg)
        self.regExpr = regExpr
        self.allowsEmpty = allowsEmpty
    }

    public func isValid(value: String?) -> ValidationError? {
        if let value = value, !value.isEmpty {
            let predicate = NSPredicate(format: "SELF MATCHES %@", regExpr)
            guard predicate.evaluate(with: value) else {
                return validationError
            }
            return nil
        } else if !allowsEmpty {
            return validationError
        }
        return nil
    }
}
