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

/// Provider of selectable options.
public enum OptionsProvider<T: Equatable> {
    /// Synchronous provider that provides array of options it was initialized with
    case array([T]?)
    /// Provider that uses closure it was initialized with to provide options. Can be synchronous or asynchronous.
    case lazy((FormViewController, @escaping ([T]?) -> Void) -> Void)
    
    func getOptions(for selectorViewController: FormViewController, completion: @escaping ([T]?) -> Void) {
        switch self {
        case let .array(array):
            completion(array)
        case let .lazy(fetch):
            fetch(selectorViewController, completion)
        }
    }
}

open class _SelectorViewController<Row: SelectableRowType>: FormViewController, TypedRowControllerType where Row: BaseRow, Row: TypedRowType {

    /// The row that pushed or presented this controller
    public var row: RowOf<Row.Cell.Value>!
    public var enableDeselection = true
    public var dismissOnSelection = true
    public var dismissOnChange = true

    public var selectableRowCellUpdate: ((_ cell: Row.Cell, _ row: Row) -> Void)?
    public var selectableRowCellSetup: ((_ cell: Row.Cell, _ row: Row) -> Void)?

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
    
    /// Options provider to use to get available options. 
    /// If not set will use synchronous data provider built with `row.dataProvider.arrayData`.
    public var optionsProvider: OptionsProvider<Row.Cell.Value>?

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
        let optionsProvider: OptionsProvider<Row.Cell.Value>?
        if let options = row.dataProvider?.arrayData {
            optionsProvider = .array(options)
        } else {
            optionsProvider = self.optionsProvider
        }
        
        optionsProvider?.getOptions(for: self) { [weak self] (options: [Row.Cell.Value]?) in
            guard let strongSelf = self, let options = options else { return }
            strongSelf.row.dataProvider = DataProvider(arrayData: options)
            strongSelf.setupForm(with: options)
        }
    }
    
    open func setupForm(with options: [Row.Cell.Value]) {
        if let optionsBySections = optionsBySections() {
            for (sectionKey, options) in optionsBySections {
                form +++ section(with: options,
                                 header: sectionHeaderTitleForKey?(sectionKey),
                                 footer: sectionFooterTitleForKey?(sectionKey))
            }
        } else {
            form +++ section(with: options, header: row.title, footer: nil)
        }
    }
    
    func optionsBySections() -> [(String, [Row.Cell.Value])]? {
        guard let options = row.dataProvider?.arrayData, let sectionKeyForValue = sectionKeyForValue else { return nil }

        let sections = options.reduce([:]) { (reduced, option) -> [String: [Row.Cell.Value]] in
            var reduced = reduced
            let key = sectionKeyForValue(option)
            reduced[key] = (reduced[key] ?? []) + [option]
            return reduced
        }

        return sections.sorted(by: { (lhs, rhs) in lhs.0 < rhs.0 })
    }

    func section(with options: [Row.Cell.Value], header: String?, footer: String?) -> SelectableSection<Row> {
        let header = header ?? ""
        let footer = footer ?? ""
        let section = SelectableSection<Row>(header: header, footer: footer, selectionType: .singleSelection(enableDeselection: enableDeselection)) { [weak self] section in
            section.onSelectSelectableRow = { _, row in
                let changed = self?.row.value != row.value
                self?.row.value = row.value
                
                if let form = row.section?.form {
                    for section in form where section !== row.section {
                        let section = section as! SelectableSection<Row>
                        if let selectedRow = section.selectedRow(), selectedRow !== row {
                            selectedRow.value = nil
                            selectedRow.updateCell()
                        }
                    }
                }
                
                if self?.dismissOnSelection == true || (changed && self?.dismissOnChange == true) {
                    self?.onDismissCallback?(self!)
                }
            }
        }
        for option in options {
            section <<< Row.init(String(describing: option)) { lrow in
                lrow.title = self.row.displayValueFor?(option)
                lrow.selectableValue = option
                lrow.value = self.row.value == option ? option : nil
            }.cellSetup { [weak self] cell, row in
                self?.selectableRowCellSetup?(cell, row)
            }.cellUpdate { [weak self] cell, row in
                self?.selectableRowCellUpdate?(cell, row)
            }
        }
        return section
    }

}

/// Selector Controller (used to select one option among a list)
open class SelectorViewController<T: Equatable> : _SelectorViewController<ListCheckRow<T>> {
}
