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

/// Base class for the Eureka cells
open class BaseCell : UITableViewCell, BaseCellType {

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
    public func formViewController() -> FormViewController? {
        var responder : AnyObject? = self
        while responder != nil {
            if let formVC = responder as? FormViewController {
              return formVC
            }
            responder = responder?.next
        }
        return nil
    }

    open func setup(){}
    open func update() {}

    open func didSelect() {}

    /**
     If the cell can become first responder. By default returns false
     */
    open func cellCanBecomeFirstResponder() -> Bool {
        return false
    }

    /**
     Called when the cell becomes first responder
     */
    @discardableResult
    open func cellBecomeFirstResponder(withDirection: Direction = .down) -> Bool {
        return becomeFirstResponder()
    }

    /**
     Called when the cell resigns first responder
     */
    @discardableResult
    open func cellResignFirstResponder() -> Bool {
        return resignFirstResponder()
    }
}

/// Generic class that represents the Eureka cells.
open class Cell<T: Equatable> : BaseCell, TypedCellType {

    public typealias Value = T

    /// The row associated to this cell
    public weak var row : RowOf<T>!

    /// Returns the navigationAccessoryView if it is defined or calls super if not.
    override open var inputAccessoryView: UIView? {
        if let v = formViewController()?.inputAccessoryView(for: row){
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
    open override func setup(){
        super.setup()
    }

    /**
     Function responsible for updating the cell each time it is reloaded.
     */
    open override func update(){
        super.update()
        textLabel?.text = row.title
        textLabel?.textColor = row.isDisabled ? .gray : .black
        detailTextLabel?.text = row.displayValueFor?(row.value) ?? (row as? NoValueDisplayTextConformance)?.noValueDisplayText
    }

    /**
     Called when the cell was selected.
     */
    open override func didSelect() {}

    override open var canBecomeFirstResponder: Bool {
        get { return false }
    }

    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            formViewController()?.beginEditing(of: self)
        }
        return result
    }

    open override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        if result {
            formViewController()?.endEditing(of: self)
        }
        return result
    }

    /// The untyped row associated to this cell.
    public override var baseRow : BaseRow! { return row }
}
