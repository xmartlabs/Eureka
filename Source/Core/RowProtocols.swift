//
//  Protocols.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

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
    func viewForSection(section: Section, type: HeaderFooterType, controller: FormViewController) -> UIView?
    
    /// If the header or footer of a section was created with a String then it will be stored in the title.
    var title: String? { get set }
    
    /// The height of the header or footer.
    var height: (()->CGFloat)? { get set }
}


