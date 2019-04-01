//
//  DoublePickerInputRow.swift
//  Eureka
//
//  Created by Mathias Claassen on 5/10/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Foundation
import UIKit

open class DoublePickerInputCell<A, B> : _PickerInputCell<Tuple<A, B>> where A: Equatable, B: Equatable {

    private var pickerRow: _DoublePickerInputRow<A, B>! { return row as? _DoublePickerInputRow<A, B> }

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func update() {
        super.update()
        if let selectedValue = pickerRow.value, let indexA = pickerRow.firstOptions().firstIndex(of: selectedValue.a),
            let indexB = pickerRow.secondOptions(selectedValue.a).firstIndex(of: selectedValue.b) {
            picker.selectRow(indexA, inComponent: 0, animated: true)
            picker.selectRow(indexB, inComponent: 1, animated: true)
        }
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    open override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return  component == 0 ? pickerRow.firstOptions().count : pickerRow.secondOptions(pickerRow.selectedFirst()).count
    }

    open override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerRow.displayValueForFirstRow(pickerRow.firstOptions()[row])
        } else {
            return pickerRow.displayValueForSecondRow(pickerRow.secondOptions(pickerRow.selectedFirst())[row])
        }
    }

    open override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let a = pickerRow.firstOptions()[row]
            if let value = pickerRow.value {
                guard value.a != a else {
                    return
                }
                if pickerRow.secondOptions(a).contains(value.b) {
                    pickerRow.value = Tuple(a: a, b: value.b)
                    pickerView.reloadComponent(1)
                    update()
                    return
                } else {
                    pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[0])
                }
            } else {
                pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[0])
            }
            pickerView.reloadComponent(1)
            pickerView.selectRow(0, inComponent: 1, animated: true)
        } else {
            let a = pickerRow.selectedFirst()
            pickerRow.value = Tuple(a: a, b: pickerRow.secondOptions(a)[row])
        }
        update()
    }
}

open class _DoublePickerInputRow<A: Equatable, B: Equatable> : Row<DoublePickerInputCell<A, B>>, NoValueDisplayTextConformance {

    open var noValueDisplayText: String? = nil
    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = {[]}
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = {_ in []}
    
    /// Modify the displayed values for the first picker row.
    public var displayValueForFirstRow: ((A) -> (String)) = { a in return String(describing: a) }
    /// Modify the displayed values for the second picker row.
    public var displayValueForSecondRow: ((B) -> (String)) = { b in return String(describing: b) }
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }

    func selectedFirst() -> A {
        return value?.a ?? firstOptions()[0]
    }

}

/// A generic row where the user can pick an option from a picker view displayed in the keyboard area
public final class DoublePickerInputRow<A, B>: _DoublePickerInputRow<A, B>, RowType where A: Equatable, B: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = { [weak self] tuple in
            guard let tuple = tuple else {
                return self?.noValueDisplayText
            }
            return String(describing: tuple.a) + ", " + String(describing: tuple.b)
        }
    }
}
