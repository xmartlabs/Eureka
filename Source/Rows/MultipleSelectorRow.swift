//
//  MultipleSelectorRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class _MultipleSelectorRow<T: Hashable, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == Set<T>>: GenericMultipleSelectorRow<T, Cell, MultipleSelectorViewController<T>> {
    public required init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = {
            if let t = $0 {
                return t.map({ String($0) }).joinWithSeparator(", ")
            }
            return nil
        }
    }
}

/// A selector row where the user can pick several options from a pushed view controller
public final class MultipleSelectorRow<T: Hashable> : _MultipleSelectorRow<T, PushSelectorCell<Set<T>>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
