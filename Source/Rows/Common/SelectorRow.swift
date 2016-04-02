//
//  SelectorRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class PushSelectorCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func update() {
        super.update()
        accessoryType = .DisclosureIndicator
        editingAccessoryType = accessoryType
        selectionStyle = row.isDisabled ? .None : .Default
    }
}

/// Generic row type where a user must select a value among several options.
public class SelectorRow<T: Equatable, Cell: CellType, VCType: TypedRowControllerType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == T, VCType: UIViewController,  VCType.RowValue == T>: OptionsRow<T, Cell>, PresenterRowType {
    
    /// Defines how the view controller will be presented, pushed, etc.
    public var presentationMode: PresentationMode<VCType>?
    
    /// Will be called before the presentation occurs.
    public var onPresentCallback : ((FormViewController, VCType)->())?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    /**
     Extends `didSelect` method
     */
    public override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.createController(){
                    controller.row = self
                    if let title = selectorTitle {
                        controller.title = title
                    }
                    onPresentCallback?(cell.formViewController()!, controller)
                    presentationMode.presentViewController(controller, row: self, presentingViewController: self.cell.formViewController()!)
                }
                else{
                    presentationMode.presentViewController(nil, row: self, presentingViewController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? VCType else {
            return
        }
        if let title = selectorTitle {
            rowVC.title = title
        }
        if let callback = self.presentationMode?.completionHandler {
            rowVC.completionCallback = callback
        }
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}
