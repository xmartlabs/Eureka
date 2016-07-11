//
//  SelectorViewController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public class _SelectorViewController<Row: SelectableRowType where Row: BaseRow, Row: TypedRowType>: FormViewController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Row.Cell.Value>!
    public var enableDeselection = true
    
    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    public var selectableRowCellUpdate: ((cell: Row.Cell, row: Row) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        
        form +++ SelectableSection<Row>(row.title ?? "", selectionType: .singleSelection(enableDeselection: enableDeselection)) { [weak self] section in
            if let sec = section as? SelectableSection<Row> {
                sec.onSelectSelectableRow = { _, row in
                    self?.row.value = row.value
                    self?.completionCallback?(self!)
                }
            }
        }
        for option in options {
            form.first! <<< Row.init(String(option)){ lrow in
                    lrow.title = self.row.displayValueFor?(option)
                    lrow.selectableValue = option
                    lrow.value = self.row.value == option ? option : nil
                }.cellUpdate { [weak self] cell, row in
                    self?.selectableRowCellUpdate?(cell: cell, row: row)
                }
        }
    }
}

/// Selector Controller (used to select one option among a list)
public class SelectorViewController<T:Equatable> : _SelectorViewController<ListCheckRow<T>>  {
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
