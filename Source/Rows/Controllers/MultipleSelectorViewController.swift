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
import UIKit

/// Selector Controller that enables multiple selection
open class _MultipleSelectorViewController<Row: SelectableRowType, OptionsRow: OptionsProviderRow> : FormViewController, TypedRowControllerType where Row: BaseRow, Row.Cell.Value == OptionsRow.OptionsProviderType.Option, OptionsRow.OptionsProviderType.Option: Hashable {

    /// The row that pushed or presented this controller
    public var row: RowOf<Set<OptionsRow.OptionsProviderType.Option>>!

    public var selectableRowSetup: ((_ row: Row) -> Void)?
    public var selectableRowCellSetup: ((_ cell: Row.Cell, _ row: Row) -> Void)?
    public var selectableRowCellUpdate: ((_ cell: Row.Cell, _ row: Row) -> Void)?
    
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> Void)?

    /// A closure that should return key for particular row value.
    /// This key is later used to break options by sections.
    public var sectionKeyForValue: ((Row.Cell.Value) -> (String))?

    /// A closure that returns header title for a section for particular key.
    /// By default returns the key itself.
    public var sectionHeaderTitleForKey: ((String) -> String?)? = { $0 }

    /// A closure that returns footer title for a section for particular key.
    public var sectionFooterTitleForKey: ((String) -> String?)?


    public var optionsProviderRow: OptionsRow {
        return row as! OptionsRow
    }
    

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience public init(_ callback: ((UIViewController) -> Void)?) {
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
        optionsProviderRow.optionsProvider?.options(for: self) { [weak self] (options: [OptionsRow.OptionsProviderType.Option]?) in
            guard let strongSelf = self, let options = options else { return }
            strongSelf.optionsProviderRow.cachedOptionsData = options
            strongSelf.setupForm(with: options)
        }
    }
    
    open func setupForm(with options: [OptionsRow.OptionsProviderType.Option]) {
        if let optionsBySections = optionsBySections(with: options) {
            for (sectionKey, options) in optionsBySections {
                form +++ section(with: options,
                                 header: sectionHeaderTitleForKey?(sectionKey),
                                 footer: sectionFooterTitleForKey?(sectionKey))
            }
        } else {
            form +++ section(with: options, header: row.title, footer: nil)
        }
    }
    
    open func optionsBySections(with options: [OptionsRow.OptionsProviderType.Option]) -> [(String, [Row.Cell.Value])]? {
        guard let sectionKeyForValue = sectionKeyForValue else { return nil }

        let sections = options.reduce([:]) { (reduced, option) -> [String: [Row.Cell.Value]] in
            var reduced = reduced
            let key = sectionKeyForValue(option)
            var items = reduced[key] ?? []
            items.append(option)
            reduced[key] = items
            return reduced
        }

        return sections.sorted(by: { (lhs, rhs) in lhs.0 < rhs.0 })
    }

    func section(with options: [OptionsRow.OptionsProviderType.Option], header: String?, footer: String?) -> SelectableSection<Row> {
        let section = SelectableSection<Row>(header: header ?? "", footer: footer ?? "", selectionType: .multipleSelection) { section in
            section.onSelectSelectableRow = {  [weak self] _, selectableRow in
                var newValue: Set<OptionsRow.OptionsProviderType.Option> = self?.row.value ?? []
                if let selectableValue = selectableRow.value {
                    newValue.insert(selectableValue)
                } else {
                    newValue.remove(selectableRow.selectableValue!)
                }
                self?.row.value = newValue
            }
        }
        for option in options {
            section <<< Row.init { lrow in
                lrow.title = String(describing: option)
                lrow.selectableValue = option
                lrow.value = self.row.value?.contains(option) ?? false ? option : nil
                self.selectableRowSetup?(lrow)
            }.cellSetup { [weak self] cell, row in
                self?.selectableRowCellSetup?(cell, row)
            }.cellUpdate { [weak self] cell, row in
                self?.selectableRowCellUpdate?(cell, row)
            }
        }
        return section
    }
}

open class MultipleSelectorViewController<OptionsRow: OptionsProviderRow>: _MultipleSelectorViewController<ListCheckRow<OptionsRow.OptionsProviderType.Option>, OptionsRow> where OptionsRow.OptionsProviderType.Option: Hashable{
    
    override public init(nibName nibNameOrNil: String? = nil, bundle nibBundleOrNil: Bundle? = nil) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
