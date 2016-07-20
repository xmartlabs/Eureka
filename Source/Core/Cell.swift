//  Cell.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


import Foundation

protocol DetailLabelConformance {
    var detailLabelLeftConst: CGFloat? { get set }
    var detailLabelTextAlignment: NSTextAlignment? { get set }
}

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
    
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        guard let detailLabel = detailTextLabel, let view = detailTextLabel?.superview else {
            return
        }
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: detailLabel, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: detailLabel, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 110))
        detailLabel.textAlignment = .Left
    }
    
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
        height = { UITableViewAutomaticDimension }
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
        detailTextLabel?.text = row.displayValueFor?(row.value) ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText
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