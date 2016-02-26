//
//  AlertRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


public class _AlertRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == T>: OptionsRow<T, Cell>, PresenterRowType {
    
    public var onPresentCallback : ((FormViewController, SelectorAlertController<T>)->())?
    lazy public var presentationMode: PresentationMode<SelectorAlertController<T>>? = {
        return .PresentModally(controllerProvider: ControllerProvider.Callback { [weak self] in
            let vc = SelectorAlertController<T>(title: self?.selectorTitle, message: nil, preferredStyle: .Alert)
            vc.row = self
            return vc
            }, completionCallback: { [weak self] in
                $0.dismissViewControllerAnimated(true, completion: nil)
                self?.cell?.formViewController()?.tableView?.reloadData()
            }
        )
    }()
    
    public required init(tag: String?) {
        super.init(tag: tag)
    }
    
    public override func customDidSelect() {
        super.customDidSelect()
        if let presentationMode = presentationMode where !isDisabled  {
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

/// An options row where the user can select an option from a modal Alert
public final class AlertRow<T: Equatable>: _AlertRow<T, AlertSelectorCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

