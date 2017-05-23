//  Operators.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
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

// MARK: Operators

precedencegroup FormPrecedence {
    associativity: left
    higherThan: LogicalConjunctionPrecedence
}

precedencegroup SectionPrecedence {
    associativity: left
    higherThan: FormPrecedence
}

infix operator +++ : FormPrecedence

/**
 Appends a section to a form
 
 - parameter left:  the form
 - parameter right: the section to be appended
 
 - returns: the updated form
 */
@discardableResult
public func +++ (left: Form, right: Section) -> Form {
    left.append(right)
    return left
}

/**
 Appends a row to the last section of a form
 
 - parameter left:  the form
 - parameter right: the row
 */
@discardableResult
public func +++ (left: Form, right: BaseRow) -> Form {
    let section = Section()
    let _ =  left +++ section <<< right
    return left
}

/**
 Creates a form with two sections
 
 - parameter left:  the first section
 - parameter right: the second section
 
 - returns: the created form
 */
@discardableResult
public func +++ (left: Section, right: Section) -> Form {
    let form = Form()
    let _ =  form +++ left +++ right
    return form
}

/**
 Appends the row wrapped in a new section
 
 - parameter left: a section of the form
 - parameter right: a row to be appended
 
 - returns: the form
 */
@discardableResult
public func +++ (left: Section, right: BaseRow) -> Form {
    let section = Section()
    section <<< right
    return left +++ section
}

/**
 Creates a form with two sections, each containing one row.
 
 - parameter left:  The row for the first section
 - parameter right: The row for the second section
 
 - returns: the created form
 */
@discardableResult
public func +++ (left: BaseRow, right: BaseRow) -> Form {
    let form = Section() <<< left +++ Section() <<< right
    return form
}

infix operator <<< : SectionPrecedence

/**
 Appends a row to a section.
 
 - parameter left:  the section
 - parameter right: the row to be appended
 
 - returns: the section
 */
@discardableResult
public func <<< (left: Section, right: BaseRow) -> Section {
    left.append(right)
    return left
}

/**
 Creates a section with two rows
 
 - parameter left:  The first row
 - parameter right: The second row
 
 - returns: the created section
 */
@discardableResult
public func <<< (left: BaseRow, right: BaseRow) -> Section {
    let section = Section()
    section <<< left <<< right
    return section
}

/**
 Appends a collection of rows to a section
 
 - parameter lhs: the section
 - parameter rhs: the rows to be appended
 */
public func += <C: Collection>(lhs: inout Section, rhs: C) where C.Iterator.Element == BaseRow {
    lhs.append(contentsOf: rhs)
}

/**
 Appends a collection of section to a form
 
 - parameter lhs: the form
 - parameter rhs: the sections to be appended
 */
public func += <C: Collection>(lhs: inout Form, rhs: C) where C.Iterator.Element == Section {
    lhs.append(contentsOf: rhs)
}
