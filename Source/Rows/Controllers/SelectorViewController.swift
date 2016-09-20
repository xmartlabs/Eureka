//  SelectorViewController.swift
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

open class _SelectorViewController<Row: SelectableRowType>: FormViewController, TypedRowControllerType where Row: BaseRow, Row: TypedRowType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Row.Cell.Value>!
    public var enableDeselection = true
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    public var selectableRowCellUpdate: ((_ cell: Row.Cell, _ row: Row) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        
        form +++ SelectableSection<Row>(row.title ?? "", selectionType: .singleSelection(enableDeselection: enableDeselection)) { [weak self] section in
            if let sec = section as? SelectableSection<Row> {
                sec.onSelectSelectableRow = { _, row in
                    self?.row.value = row.value
                    self?.onDismissCallback?(self!)
                }
            }
        }
        for option in options {
            form.first! <<< Row.init(String(describing: option)){ lrow in
                    lrow.title = self.row.displayValueFor?(option)
                    lrow.selectableValue = option
                    lrow.value = self.row.value == option ? option : nil
                }.cellUpdate { [weak self] cell, row in
                    self?.selectableRowCellUpdate?(cell, row)
                }
        }
    }
}

/// Selector Controller (used to select one option among a list)
open class SelectorViewController<T:Equatable> : _SelectorViewController<ListCheckRow<T>>  {
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
