//
//  LabelRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

// MARK: LabelCell

public class LabelCellOf<T: Equatable>: Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
    }
    
    public override func update() {
        super.update()
    }
}

public typealias LabelCell = LabelCellOf<String>

// MARK: LabelRow

public class _LabelRow: Row<String, LabelCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// Simple row that can show title and value but is not editable by user.
public final class LabelRow: _LabelRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}