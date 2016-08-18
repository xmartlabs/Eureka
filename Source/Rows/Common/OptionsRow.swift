//
//  OptionsRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

open class OptionsRow<Cell: CellType> : Row<Cell>, NoValueDisplayTextConformance where Cell: BaseCell {
    
    public var options: [Cell.Value] {
        get { return dataProvider?.arrayData ?? [] }
        set { dataProvider = DataProvider(arrayData: newValue) }
    }
    public var selectorTitle: String?
    public var noValueDisplayText: String?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
