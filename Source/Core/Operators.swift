//
//  Operators.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

// MARK: Operators

infix operator +++{ associativity left precedence 95 }

/**
 Appends a section to a form
 
 - parameter left:  the form
 - parameter right: the section to be appended
 
 - returns: the updated form
 */
public func +++(left: Form, right: Section) -> Form {
    left.append(right)
    return left
}

infix operator +++= { associativity left precedence 95 }

/**
 Appends a section to a form without return statement
 
 - parameter left:  the form
 - parameter right: the section to be appended
 */
public func +++=(inout left: Form, right: Section){
    left = left +++ right
}

/**
 Appends a row to the last section of a form
 
 - parameter left:  the form
 - parameter right: the row
 */
public func +++=(inout left: Form, right: BaseRow){
    left +++= Section() <<< right
}

/**
 Creates a form with two sections
 
 - parameter left:  the first section
 - parameter right: the second section
 
 - returns: the created form
 */
public func +++(left: Section, right: Section) -> Form {
    let form = Form()
    form +++ left +++ right
    return form
}

/**
 Creates a form with two sections, each containing one row.
 
 - parameter left:  The row for the first section
 - parameter right: The row for the second section
 
 - returns: the created form
 */
public func +++(left: BaseRow, right: BaseRow) -> Form {
    let form = Section() <<< left +++ Section() <<< right
    return form
}

infix operator <<<{ associativity left precedence 100 }

/**
 Appends a row to a section.
 
 - parameter left:  the section
 - parameter right: the row to be appended
 
 - returns: the section
 */
public func <<<(left: Section, right: BaseRow) -> Section {
    left.append(right)
    return left
}

/**
 Creates a section with two rows
 
 - parameter left:  The first row
 - parameter right: The second row
 
 - returns: the created section
 */
public func <<<(left: BaseRow, right: BaseRow) -> Section {
    let section = Section()
    section <<< left <<< right
    return section
}

/**
 Appends a collection of rows to a section
 
 - parameter lhs: the section
 - parameter rhs: the rows to be appended
 */
public func +=< C : CollectionType where C.Generator.Element == BaseRow>(inout lhs: Section, rhs: C){
    lhs.appendContentsOf(rhs)
}

/**
 Appends a collection of section to a form
 
 - parameter lhs: the form
 - parameter rhs: the sections to be appended
 */
public func +=< C : CollectionType where C.Generator.Element == Section>(inout lhs: Form, rhs: C){
    lhs.appendContentsOf(rhs)
}
