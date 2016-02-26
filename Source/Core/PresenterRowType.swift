//
//  PresenterRowType.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

/**
 *  Protocol that every row that displays a new view controller must conform to.
 *  This includes presenting or pushing view controllers.
 */
public protocol PresenterRowType: TypedRowType {
    
    associatedtype ProviderType : UIViewController, TypedRowControllerType
    
    /// Defines how the view controller will be presented, pushed, etc.
    var presentationMode: PresentationMode<ProviderType>? { get set }
    
    /// Will be called before the presentation occurs.
    var onPresentCallback: ((FormViewController, ProviderType)->())? { get set }
}

extension PresenterRowType {
    
    /**
     Sets a block to be executed when the row presents a view controller
     
     - parameter callback: the block
     
     - returns: this row
     */
    public func onPresent(callback: (FormViewController, ProviderType)->()) -> Self {
        onPresentCallback = callback
        return self
    }
}