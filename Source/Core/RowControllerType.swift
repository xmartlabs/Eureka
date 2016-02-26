//
//  RowControllerType.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


/**
 *  Base protocol for view controllers presented by Eureka rows.
 */
public protocol RowControllerType : NSObjectProtocol {
    
    /// A closure to be called when the controller disappears.
    var completionCallback : ((UIViewController) -> ())? { get set }
}