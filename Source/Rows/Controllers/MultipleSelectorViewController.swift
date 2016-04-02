//
//  MultipleSelectorViewController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


/// Selector Controller that enables multiple selection
public class _MultipleSelectorViewController<T:Hashable, Row: SelectableRowType where Row: BaseRow, Row: TypedRowType, Row.Value == T, Row.Cell.Value == T> : FormViewController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Set<T>>!
    
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
        form +++= SelectableSection<Row, Row.Value>(row.title ?? "", selectionType: .MultipleSelection) { [weak self] section in
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
                }.cellUpdate { [weak self] cell, row in
                    self?.selectableRowCellUpdate?(cell: cell, row: row)
                }
        
        }
        form.first?.header = HeaderFooterView<UITableViewHeaderFooterView>(title: row.title)
    }
    
}


public class MultipleSelectorViewController<T:Hashable> : _MultipleSelectorViewController<T, ListCheckRow<T>> {
}


