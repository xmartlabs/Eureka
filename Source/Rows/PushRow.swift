//
//  PushRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class _PushRow<Cell: CellType where Cell: BaseCell> : SelectorRow<Cell, SelectorViewController<Cell.Value>> {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        presentationMode = .show(controllerProvider: ControllerProvider.callback { return SelectorViewController<Cell.Value>(){ _ in } }, completionCallback: { vc in
            let _ = vc.navigationController?.popViewController(animated: true) })
    }
}

/// A selector row where the user can pick an option from a pushed view controller
public final class PushRow<T: Equatable> : _PushRow<PushSelectorCell<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
