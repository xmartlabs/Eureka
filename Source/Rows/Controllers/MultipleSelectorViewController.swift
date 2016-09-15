//  MultipleSelectorViewController.swift
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


/// Selector Controller that enables multiple selection
public class _MultipleSelectorViewController<T:Hashable, Row: SelectableRowType where Row: BaseRow, Row: TypedRowType, Row.Value == T, Row.Cell.Value == T> : FormViewController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Set<T>>!
    
    public var selectableRowCellSetup: ((cell: Row.Cell, row: Row) -> ())?
    public var selectableRowCellUpdate: ((cell: Row.Cell, row: Row) -> ())?

    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        form +++ SelectableSection<Row, Row.Value>(row.title ?? "", selectionType: .MultipleSelection) { [weak self] section in
            if let sec = section as? SelectableSection<Row, Row.Value> {
                sec.onSelectSelectableRow = { _, selectableRow in
                    var newValue: Set<T> = self?.row.value ?? []
                    if let selectableValue = selectableRow.value {
                        newValue.insert(selectableValue)
                    }
                    else {
                        newValue.remove(selectableRow.selectableValue!)
                    }
                    self?.row.value = newValue
                }
            }
        }
        for o in options {
            form.first! <<< Row.init() { [weak self] in
                    $0.title = String(o.first!)
                    $0.selectableValue = o.first!
                    $0.value = self?.row.value?.contains(o.first!) ?? false ? o.first! : nil
                }.cellSetup { [weak self] cell, row in
                    self?.selectableRowCellSetup?(cell: cell, row: row)
                }.cellUpdate { [weak self] cell, row in
                    self?.selectableRowCellUpdate?(cell: cell, row: row)
                }
        
        }
        form.first?.header = HeaderFooterView<UITableViewHeaderFooterView>(title: row.title)
    }
    
}


public class MultipleSelectorViewController<T:Hashable> : _MultipleSelectorViewController<T, ListCheckRow<T>> {
}


