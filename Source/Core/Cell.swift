//
//  Cell.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

/// Base class for the Eureka cells
public class BaseCell : UITableViewCell, BaseCellType {
    
    /// Untyped row associated to this cell.
    public var baseRow: BaseRow! { return nil }
    
    /// Block that returns the height for this cell.
    public var height: (()->CGFloat)?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /**
     Function that returns the FormViewController this cell belongs to.
     */
    public func formViewController () -> FormViewController? {
        var responder : AnyObject? = self
        while responder != nil {
            if responder! is FormViewController {
                return responder as? FormViewController
            }
            responder = responder?.nextResponder()
        }
        return nil
    }
    
    public func setup(){}
    public func update() {}
    
    public func didSelect() {}
    
    public func highlight() {}
    public func unhighlight() {}
    
    
    /**
     If the cell can become first responder. By default returns false
     */
    public func cellCanBecomeFirstResponder() -> Bool {
        return false
    }
    
    /**
     Called when the cell becomes first responder
     */
    public func cellBecomeFirstResponder(direction: Direction = .Down) -> Bool {
        return becomeFirstResponder()
    }
    
    /**
     Called when the cell resigns first responder
     */
    public func cellResignFirstResponder() -> Bool {
        return resignFirstResponder()
    }
}

/// Generic class that represents the Eureka cells.
public class Cell<T: Equatable> : BaseCell, TypedCellType {
    
    public typealias Value = T
    
    /// The row associated to this cell
    public weak var row : RowOf<T>!
    
    /// Returns the navigationAccessoryView if it is defined or calls super if not.
    override public var inputAccessoryView: UIView? {
        if let v = formViewController()?.inputAccessoryViewForRow(row){
            return v
        }
        return super.inputAccessoryView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /**
     Function responsible for setting up the cell at creation time.
     */
    public override func setup(){
        super.setup()
    }
    
    /**
     Function responsible for updating the cell each time it is reloaded.
     */
    public override func update(){
        super.update()
        textLabel?.text = row.title
        textLabel?.textColor = row.isDisabled ? .grayColor() : .blackColor()
        detailTextLabel?.text = row.displayValueFor?(row.value)
    }
    
    /**
     Called when the cell was selected.
     */
    public override func didSelect() {}
    
    public override func canBecomeFirstResponder() -> Bool {
        return false
    }
    
    public override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            formViewController()?.beginEditing(self)
        }
        return result
    }
    
    public override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            formViewController()?.endEditing(self)
        }
        return result
    }
    
    /// The untyped row associated to this cell.
    public override var baseRow : BaseRow! { return row }
}