//
//  PickerInputRow.swift
//  Eureka
//
//  Created by Miguel Developing on 31/3/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

//MARK: PickerInputCell

public class PickerInputCell<T where T: Equatable> : Cell<T>, CellType, UIPickerViewDataSource, UIPickerViewDelegate{
    
    lazy public var picker = UIPickerView()
    private var pickerRow : _PickerInputRow<T>? { return row as? _PickerInputRow<T> }
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public override func setup() {
        super.setup()
        accessoryType = .None
        editingAccessoryType = .None
        picker.delegate = self
        picker.dataSource = self
        
        // UITesting
        picker.accessibilityIdentifier = "picker_view"
    }
    
    deinit {
        picker.delegate = nil
        picker.dataSource = nil
    }
    
    public override func update(){
        super.update()
        selectionStyle = row.isDisabled ? .None : .Default
        detailTextLabel?.text = row.displayValueFor?(row.value)
        picker.reloadAllComponents()
        if let selectedValue = pickerRow?.value, let index = pickerRow?.options.indexOf(selectedValue){
            picker.selectRow(index, inComponent: 0, animated: true)
        }
    }
    
    
    public override func didSelect() {
        super.didSelect()
        row.deselect()
    }
    
    override public var inputView : UIView? {
        if let v = row.value{
            guard let index = pickerRow?.options.indexOf(v) else {
                return picker
            }
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        return picker
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return canBecomeFirstResponder()
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return !row.isDisabled;
    }
    
    // MARK - UIPickerView
    
    public func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerRow?.options.count ?? 0
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerRow?.displayValueFor?(pickerRow?.options[row])
    }
    
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerRow?.value = pickerRow?.options[row]
        detailTextLabel?.text = pickerRow!.displayValueFor?(pickerRow?.value)
    }
    
}

//MARK: PickerInputRow

public class _PickerInputRow<T where T: Equatable> : Row<T, PickerInputCell<T>>{
    
    public var options = [T]()
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A generic row where the user can pick an option from a picker view
public final class PickerInputRow<T where T: Equatable>: _PickerInputRow<T>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        onCellHighlight { cell, row in
            let color = cell.detailTextLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
}