//  RuleURL.swift
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
import UIKit

public struct RuleURL: RuleType {
    
    public init(allowsEmpty: Bool = true, requiresProtocol: Bool = false, msg: String = "Field value must be an URL!") {
        validationError = ValidationError(msg: msg)
    }
    
    public var id: String?
    public var allowsEmpty = true
    public var requiresProtocol = false
    public var validationError: ValidationError
    
    public func isValid(value: URL?) -> ValidationError? {
        if let value = value, value.absoluteString.isEmpty == false {
            let predicate = NSPredicate(format:"SELF MATCHES %@", RegExprPattern.URL.rawValue)
            guard predicate.evaluate(with: value.absoluteString) else {
                return validationError
            }
            return nil
        }
        else if !allowsEmpty {
            return validationError
        }
        return nil
    }
}
