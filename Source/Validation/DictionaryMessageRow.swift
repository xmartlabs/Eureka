//
//  DictionaryMessageRow.swift
//  Eureka
//
//  Created by Jingang Liu on 8/16/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class DictionaryMessageRow : Row<DictionaryMessage,DictionaryMessageCell>, MessageRow, RowType {
    weak var mainRow: BaseRow?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellStyle = .Default
    }
}