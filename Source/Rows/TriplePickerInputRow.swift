//
//  TriplePickerInputRow.swift
//  Eureka
//
//  Created by Mathias Claassen on 5/10/18.
//  Copyright © 2018 Xmartlabs. All rights reserved.
//

import Foundation

open class TriplePickerInputCell<A, B, C> : PickerInputCell<Tuple3<A, B, C>> where A: Equatable, B: Equatable, C: Equatable {

    private var pickerRow: _TriplePickerInputRow<A, B, C>! { return row as? _TriplePickerInputRow<A, B, C> }

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func selectValue() {
        if let selectedValue = pickerRow.value, let indexA = pickerRow.firstOptions().index(of: selectedValue.a),
            let indexB = pickerRow.secondOptions(selectedValue.a).index(of: selectedValue.b),
            let indexC = pickerRow.thirdOptions(selectedValue.a, selectedValue.b).index(of: selectedValue.c){
            picker.selectRow(indexA, inComponent: 0, animated: true)
            picker.selectRow(indexB, inComponent: 1, animated: true)
            picker.selectRow(indexC, inComponent: 2, animated: true)
        }
    }

    open override func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    open override func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerRow.firstOptions().count
        } else if component == 1 {
            return pickerRow.secondOptions(pickerRow.selectedFirst()).count
        } else {
            return pickerRow.thirdOptions(pickerRow.selectedFirst(), pickerRow.selectedSecond()).count
        }
    }

    open override func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return String(describing: pickerRow.firstOptions()[row])
        } else if component == 1 {
            return String(describing: pickerRow.secondOptions(pickerRow.selectedFirst())[row])
        } else {
            return String(describing: pickerRow.thirdOptions(pickerRow.selectedFirst(), pickerRow.selectedSecond())[row])
        }
    }

    open override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            let a = pickerRow.firstOptions()[row]
            if let value = pickerRow.value {
                if value.a == a {
                    return
                }

                let b: B = pickerRow.secondOptions(a).contains(value.b) ? value.b : pickerRow.secondOptions(a)[0]
                let c: C = pickerRow.thirdOptions(a, b).contains(value.c) ? value.c : pickerRow.thirdOptions(a, b)[0]
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
                pickerRow.value = Tuple3(a: a, b: b, c: c)
                if b != value.b {
                    pickerView.selectRow(0, inComponent: 1, animated: true)
                }
                if c != value.c {
                    pickerView.selectRow(0, inComponent: 2, animated: true)
                }
            } else {
                let b = pickerRow.secondOptions(a)[0]
                pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[0])
                pickerView.reloadComponent(1)
                pickerView.reloadComponent(2)
                pickerView.selectRow(0, inComponent: 1, animated: true)
                pickerView.selectRow(0, inComponent: 2, animated: true)
            }
        } else if component == 1 {
            let a = pickerRow.selectedFirst()
            let b = pickerRow.secondOptions(a)[row]
            if let value = pickerRow.value {
                if value.b == b {
                    return
                }
                if pickerRow.thirdOptions(a, b).contains(value.c) {
                    pickerRow.value = Tuple3(a: a, b: b, c: value.c)
                    pickerView.reloadComponent(2)
                    update()
                    return
                } else {
                    pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[0])
                }
            } else {
                pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[0])
            }
            pickerView.reloadComponent(2)
            pickerView.selectRow(0, inComponent: 2, animated: true)
        } else {
            let a = pickerRow.selectedFirst()
            let b = pickerRow.selectedSecond()
            pickerRow.value = Tuple3(a: a, b: b, c: pickerRow.thirdOptions(a, b)[row])
        }
        update()
    }
}

open class _TriplePickerInputRow<A: Equatable, B: Equatable, C: Equatable> : Row<TriplePickerInputCell<A, B, C>>, NoValueDisplayTextConformance {

    open var noValueDisplayText: String? = nil
    /// Options for first component. Will be called often so should be O(1)
    public var firstOptions: (() -> [A]) = {[]}
    /// Options for second component given the selected value from the first component. Will be called often so should be O(1)
    public var secondOptions: ((A) -> [B]) = {_ in []}
    /// Options for third component given the selected value from the first and second components. Will be called often so should be O(1)
    public var thirdOptions: ((A, B) -> [C]) = {_, _ in []}

    required public init(tag: String?) {
        super.init(tag: tag)
    }

    func selectedFirst() -> A {
        return value?.a ?? firstOptions()[0]
    }

    func selectedSecond() -> B {
        return value?.b ?? secondOptions(selectedFirst())[0]
    }

}

/// A generic row where the user can pick an option from a picker view displayed in the keyboard area
public final class TriplePickerInputRow<A, B, C>: _TriplePickerInputRow<A, B, C>, RowType where A: Equatable, B: Equatable, C: Equatable {

    required public init(tag: String?) {
        super.init(tag: tag)
        self.displayValueFor = { [weak self] tuple in
            if let tuple = tuple {
                return String(describing: tuple.a) + ", " + String(describing: tuple.b) + ", " + String(describing: tuple.c)
            }
            return self?.noValueDisplayText
        }
    }
}
