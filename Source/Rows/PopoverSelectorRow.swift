//
//  PopoverSelectorRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

open class _PopoverSelectorRow<Cell: CellType> : SelectorRow<Cell, SelectorViewController<Cell.Value>> where Cell: BaseCell, Cell: TypedCellType {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        onPresentCallback = { [weak self] (_, viewController) -> Void in
            guard let porpoverController = viewController.popoverPresentationController, let tableView = self?.baseCell.formViewController()?.tableView, let cell = self?.cell else {
                fatalError()
            }
            porpoverController.sourceView = tableView
            porpoverController.sourceRect = tableView.convert(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, from: cell)
        }
        presentationMode = .popover(controllerProvider: ControllerProvider.callback { return SelectorViewController<Cell.Value>(){ _ in } }, completionCallback: { [weak self] in
            $0.dismiss(animated: true, completion: nil)
            self?.reload()
            })
    }
    
    open override func didSelect() {
        deselect()
        super.didSelect()
    }
}

public final class PopoverSelectorRow<T: Equatable> : _PopoverSelectorRow<PushSelectorCell<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
