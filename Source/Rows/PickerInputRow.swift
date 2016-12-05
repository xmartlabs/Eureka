//  PickerInputRow.swift
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

//MARK: PickerInputCell

open class PickerInputCell<T: Equatable> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate where T: Equatable, T: InputTypeInitiable {
    
    public var picker: UIPickerView
    
    private var pickerInputRow : _PickerInputRow<T>? { return row as? _PickerInputRow<T> }
    
    private var textFieldStartColor: UIColor?
    
    private var targetLabel: UILabel?
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        self.picker = UIPickerView()
        self.picker.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType = .none
        picker.delegate = self
        picker.dataSource = self
    }
    
    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }
    
    open override func update(){
        if row.title != nil && row.title != "" {
            // Due to the super function's operations on the labels, we should only call it if there is a title
            super.update()
            targetLabel = detailTextLabel!
        } else {
            targetLabel = textLabel!
        }
        
        selectionStyle = .none
        
        targetLabel?.text = row.value != nil ? "\(row.value!)" : ""
        if row.isHighlighted {
            textFieldStartColor = targetLabel?.textColor
            targetLabel?.textColor = tintColor
        } else if textFieldStartColor != nil {
            targetLabel?.textColor = textFieldStartColor
            if targetLabel == textLabel {
                detailTextLabel?.text = nil
            }
        }
        
        picker.reloadAllComponents()
        if let selectedValue = pickerInputRow?.value, let index = pickerInputRow?.options.index(of: selectedValue){
            picker.selectRow(index, inComponent: 0, animated: true)
        }
        
    }
    
    open override var inputView: UIView? {
        return picker
    }
    
    open override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder
    }
    
    override open var canBecomeFirstResponder: Bool {
        get {
            return !row.isDisabled
        }
    }
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerInputRow?.options.count ?? 0
    }
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerInputRow?.displayValueFor?(pickerInputRow?.options[row])
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow rowNumber: Int, inComponent component: Int) {
        if let picker = pickerInputRow, !picker.options.isEmpty {
            picker.value = picker.options[rowNumber]
            if picker.value != nil {
                row.value = picker.value
                targetLabel?.text = "\(picker.value!)"
            }
        }
    }
    
}

//MARK: PickerInputRow

open class _PickerInputRow<T> : Row<PickerInputCell<T>>, NoValueDisplayTextConformance where T: Equatable, T: InputTypeInitiable {
    open var noValueDisplayText: String? = nil
    
    open var options = [T]()
    
    required public init(tag: String?) {
        super.init(tag: tag)
        
    }
}

/// A generic row where the user can pick an option from a picker view displayed in the keyboard area
public final class PickerInputRow<T>: _PickerInputRow<T>, RowType where T: Equatable, T: InputTypeInitiable {
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
