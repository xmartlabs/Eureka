//
//  ActionSheetRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class AlertSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func update() {
        super.update()
        accessoryType = .none
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .none : .default
    }
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

public class _ActionSheetRow<Cell: CellType where Cell: BaseCell>: OptionsRow<Cell>, PresenterRowType {
    
    public var onPresentCallback : ((FormViewController, SelectorAlertController<Cell.Value>)->())?
    lazy public var presentationMode: PresentationMode<SelectorAlertController<Cell.Value>>? = {
        return .presentModally(controllerProvider: ControllerProvider.callback { [weak self] in
            let vc = SelectorAlertController<Cell.Value>(title: self?.selectorTitle, message: nil, preferredStyle: .actionSheet)
            if let popView = vc.popoverPresentationController {
                guard let cell = self?.cell, let tableView = cell.formViewController()?.tableView else { fatalError() }
                popView.sourceView = tableView
                popView.sourceRect = tableView.convert(cell.detailTextLabel?.frame ?? cell.textLabel?.frame ?? cell.contentView.frame, from: cell)
            }
            vc.row = self
            return vc
            },
                               completionCallback: { [weak self] in
                                $0.dismiss(animated: true, completion: nil)
                                self?.cell?.formViewController()?.tableView?.reloadData()
            })
    }()
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode, !isDisabled {
            if let controller = presentationMode.createController(){
                controller.row = self
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.presentViewController(controller, row: self, presentingViewController: cell.formViewController()!)
            }
            else{
                presentationMode.presentViewController(nil, row: self, presentingViewController: cell.formViewController()!)
            }
        }
    }
}

/// An options row where the user can select an option from an ActionSheet
public final class ActionSheetRow<T: Equatable>: _ActionSheetRow<AlertSelectorCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

