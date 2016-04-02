//
//  SelectorViewController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class _SelectorViewController<T: Equatable, Row: SelectableRowType where Row: BaseRow, Row: TypedRowType, Row.Value == T, Row.Cell.Value == T>: FormViewController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Row.Value>!
    
    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    public var selectableRowCellUpdate: ((cell: Row.Cell, row: Row) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        
        form +++= SelectableSection<Row, Row.Value>(row.title ?? "", selectionType: .SingleSelection(enableDeselection: true)) { [weak self] section in
            if let sec = section as? SelectableSection<Row, Row.Value> {
                sec.onSelectSelectableRow = { _, row in
                    self?.row.value = row.value
                    self?.completionCallback?(self!)
                }
            }
        }
        for option in options {
            form.first! <<< Row.init(String(option)){ lrow in
                    lrow.title = row.displayValueFor?(option)
                    lrow.selectableValue = option
                    lrow.value = row.value == option ? option : nil
                }.cellUpdate { [weak self] cell, row in
                    self?.selectableRowCellUpdate?(cell: cell, row: row)
                }
        }
    }
}

/// Selector Controller (used to select one option among a list)
public class SelectorViewController<T:Equatable> : _SelectorViewController<T, ListCheckRow<T>>  {
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    

}
