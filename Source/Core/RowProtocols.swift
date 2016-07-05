//  RowProtocols.swift
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


/**
 *  Protocol that view controllers pushed or presented by a row should conform to.
 */
public protocol TypedRowControllerType : RowControllerType {
    associatedtype RowValue: Equatable
    
    /// The row that pushed or presented this controller
    var row : RowOf<Self.RowValue>! { get set }
}



//MARK: Header Footer Protocols

/**
 *  Protocol used to set headers and footers to sections.
 *  Can be set with a view or a String
 */
public protocol HeaderFooterViewRepresentable {
    
    /**
     This method can be called to get the view corresponding to the header or footer of a section in a specific controller.
     
     - parameter section:    The section from which to get the view.
     - parameter type:       Either header or footer.
     - parameter controller: The controller from which to get that view.
     
     - returns: The header or footer of the specified section.
     */
    func viewForSection(_ section: Section, type: HeaderFooterType) -> UIView?
    
    /// If the header or footer of a section was created with a String then it will be stored in the title.
    var title: String? { get set }
    
    /// The height of the header or footer.
    var height: (()->CGFloat)? { get set }
}


