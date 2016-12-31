//  ButtonRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
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

// MARK: ButtonCell

open class ButtonCellOf<T: Equatable>: Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
        accessoryType = .none
        editingAccessoryType = accessoryType
        textLabel?.textAlignment = .center
        textLabel?.textColor = tintColor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        textLabel?.textColor  = UIColor(red: red, green: green, blue: blue, alpha: row.isDisabled ? 0.3 : 1.0)
    }
    
    open override func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

public typealias ButtonCell = ButtonCellOf<String>


//MARK: ButtonRow

open class _ButtonRowOf<T: Equatable> : Row<ButtonCellOf<T>> {
    open var presentationMode: PresentationMode<UIViewController>?
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellStyle = .default
    }
    
    open override func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            if let presentationMode = presentationMode {
                if let controller = presentationMode.makeController(){
                    presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
                }
                else{
                    presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
                }
            }
        }
    }
    
    open override func customUpdateCell() {
        super.customUpdateCell()
        let leftAligmnment = presentationMode != nil
        cell.textLabel?.textAlignment = leftAligmnment ? .left : .center
        cell.accessoryType = !leftAligmnment || isDisabled ? .none : .disclosureIndicator
        cell.editingAccessoryType = cell.accessoryType
        if (!leftAligmnment){
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            cell.tintColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            cell.textLabel?.textColor  = UIColor(red: red, green: green, blue: blue, alpha:isDisabled ? 0.3 : 1.0)
        }
        else{
            cell.textLabel?.textColor = nil
        }
    }
    
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        let rowVC = segue.destination as? RowControllerType
        rowVC?.onDismissCallback = presentationMode?.onDismissCallback
    }
}

/// A generic row with a button. The action of this button can be anything but normally will push a new view controller
public final class ButtonRowOf<T: Equatable> : _ButtonRowOf<T>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row with a button and String value. The action of this button can be anything but normally will push a new view controller
public typealias ButtonRow = ButtonRowOf<String>
