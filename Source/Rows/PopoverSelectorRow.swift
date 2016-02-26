//
//  PopoverSelectorRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class _PopoverSelectorRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == T> : SelectorRow<T, Cell, SelectorViewController<T>> {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        onPresentCallback = { [weak self] (_, viewController) -> Void in
            guard let porpoverController = viewController.popoverPresentationController, tableView = self?.baseCell.formViewController()?.tableView, cell = self?.cell else {
                fatalError()
            }
            porpoverController.sourceView = tableView
            porpoverController.sourceRect = tableView.convertRect(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, fromView: cell)
        }
        presentationMode = .Popover(controllerProvider: ControllerProvider.Callback { return SelectorViewController<T>(){ _ in } }, completionCallback: { [weak self] in
            $0.dismissViewControllerAnimated(true, completion: nil)
            self?.reload()
            })
    }
    
    public override func didSelect() {
        deselect()
        super.didSelect()
    }
}

public final class PopoverSelectorRow<T: Equatable> : _PopoverSelectorRow<T, PushSelectorCell<T>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}
