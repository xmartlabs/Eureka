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
open class _MultipleSelectorViewController<T: Hashable, Row: SelectableRowType> : FormViewController, TypedRowControllerType where Row: BaseRow, Row: TypedRowType, Row.Cell.Value == T {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Set<T>>!
    
    public var selectableRowCellSetup: ((_ cell: Row.Cell, _ row: Row) -> ())?
    public var selectableRowCellUpdate: ((_ cell: Row.Cell, _ row: Row) -> ())?

    /// A closure to be called when the controller disappears.
    public var onDismissCallback : ((UIViewController) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    convenience public init(_ callback: ((UIViewController) -> ())?){
        self.init(nibName: nil, bundle: nil)
        onDismissCallback = callback
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupForm()
    }
    
    open func setupForm() {
        guard let options = row.dataProvider?.arrayData else { return }
        form +++ section(with: options, header: row.title, footer: nil)
    }
    
    func section(with options: [Set<T>], header: String?, footer: String?) -> SelectableSection<Row> {
        let header = header ?? ""
        let footer = footer ?? ""
        let section = SelectableSection<Row>(header: header, footer: footer, selectionType: .multipleSelection) { [weak self] section in
            if let sec = section as? SelectableSection<Row> {
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
        for option in options {
            section <<< Row.init() { lrow in
                lrow.title = String(describing: option.first!)
                lrow.selectableValue = option.first!
                lrow.value = self.row.value?.contains(option.first!) ?? false ? option.first! : nil
                }.cellSetup { [weak self] cell, row in
                    self?.selectableRowCellSetup?(cell, row)
                }.cellUpdate { [weak self] cell, row in
                    self?.selectableRowCellUpdate?(cell, row)
            }
        }
        return section
    }
}

open class _SectionedMultipleSelectorViewController<K: Hashable & Comparable, T: Hashable, Row: SelectableRowType>: _MultipleSelectorViewController<T, Row> where Row: BaseRow, Row: TypedRowType, Row.Cell.Value == T {
    
    public var sectionKeyFor: ((Row.Cell.Value) -> (K))?
    public var sectionHeaderTitleFor: ((K) -> String?)? = { String(describing: $0) }
    public var sectionFooterTitleFor: ((K) -> String?)?
    
    open override func setupForm() {
        if let optionsBySections = self.optionsBySections() {
            for (sectionKey, options) in optionsBySections {
                form +++ section(with: options, header: sectionHeaderTitleFor?(sectionKey), footer: sectionFooterTitleFor?(sectionKey))
            }
        } else {
            super.setupForm()
        }
    }
    
    open func optionsBySections() -> [(K, [Set<Row.Cell.Value>])]? {
        guard let options = row.dataProvider?.arrayData, let sectionKeyFor = sectionKeyFor else { return nil }
        
        let sections = options.reduce([:]) { (reduced, option) -> [K: [Set<Row.Cell.Value>]] in
            var reduced = reduced
            let key = sectionKeyFor(option.first!)
            reduced[key] = (reduced[key] ?? []) + [option]
            return reduced
        }
        
        return sections.sorted(by: { (lhs, rhs) in lhs.0 < rhs.0 })
    }
    
}

open class MultipleSelectorViewController<T:Hashable> : _MultipleSelectorViewController<T, ListCheckRow<T>> {
}

open class SectionedMultipleSelectorViewController<K: Hashable & Comparable, T:Hashable> : _SectionedMultipleSelectorViewController<K, T, ListCheckRow<T>> {
}
