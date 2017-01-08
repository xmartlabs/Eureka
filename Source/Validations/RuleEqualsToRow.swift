//  RuleRequire.swift
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

public struct RuleEqualsToRow<T: Equatable>: RuleType {
    
    public init(form: Form, tag: String, msg: String = "Fields don't match!"){
        self.validationError = ValidationError(msg: msg)
        self.form = form
        self.tag = tag
        self.row = nil;
    }
    
    public init(row: RowOf<T>, msg: String = "Fields don't match!"){
        self.validationError = ValidationError(msg: msg)
        self.form = nil
        self.tag = nil
        self.row = row
    }
    
    public var id: String?
    public var validationError: ValidationError
    public var form: Form?
    public var tag: String?
    public var row: RowOf<T>?
    
    public func isValid(value: T?) -> ValidationError? {
        let rowAux: RowOf<T> = row ?? form!.rowBy(tag: tag!)!
        return rowAux.value == value ? nil : validationError
    }
}
