//
//  SelectableRowType.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

/**
 *  Every row that shall be used in a SelectableSection must conform to this protocol.
 */
public protocol SelectableRowType : TypedRowType, RowType {
    var selectableValue : Value? { get set }
}