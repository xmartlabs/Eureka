//
//  SelectorInlineRow.swift
//  Eureka
//
//  Created by Anton Kovtun on 10/25/17.
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

import UIKit

open class SelectorInlineCell<T: Equatable> : Cell<T>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func setup() {
        super.setup()
        accessoryType = .none
        editingAccessoryType =  .none
    }
    
    override open func update() {
        super.update()
        selectionStyle = row.isDisabled ? .none : .default
    }
    
    override open func didSelect() {
        super.didSelect()
        row.deselect()
    }
}

open class _SelectorInlineRow<T> : Row<SelectorInlineCell<T>>, NoValueDisplayTextConformance where T: Equatable {
    
    public typealias InlineRow = SelectionListRow<T>
    open var options = [T]()
    
    public var noValueDisplayText: String?
    private var subcellConfigurator: (UITableViewCell, T, Int) -> Void = { _, _, _ in }
    
    public func setupInlineRow(_ inlineRow: SelectionListRow<T>) {
        inlineRow.options = options
        inlineRow.displayValueFor = displayValueFor
        inlineRow.configureCell(subcellConfigurator)
        inlineRow.value = value
    }
    
    /// The block used to configure cells of underlying `SelectionListRow`
    @discardableResult
    open func configureSubcell(_ configurator: @escaping (UITableViewCell, T, Int) -> Void) -> Self {
        subcellConfigurator = configurator
        return self
    }
}

final public class SelectorInlineRow<T> : _SelectorInlineRow<T>, RowType, InlineRowType where T: Equatable {
    
    /// Sets underlying `SelectionListRow` textLabel color
    public var subcellTextColor = UIColor.gray
    /// Sets underlying `SelectionListRow` horizontal insets in it's superview
    public var subcellHorizontalInset: CGFloat = 16
    
    required public init(tag: String?) {
        super.init(tag: tag)
        onExpandInlineRow { cell, row, _ in
            let color = cell.detailTextLabel?.textColor
            row.onCollapseInlineRow { cell, _, _ in
                cell.detailTextLabel?.textColor = color
            }
            cell.detailTextLabel?.textColor = cell.tintColor
        }
    }
    
    override public func customDidSelect() {
        super.customDidSelect()
        if !isDisabled {
            toggleInlineRow()
        }
    }
    
    override public func setupInlineRow(_ inlineRow: InlineRow) {
        super.setupInlineRow(inlineRow)
        inlineRow.onDidSelect { [weak self] _ in self?.toggleInlineRow() }
        inlineRow.textColor = subcellTextColor
        inlineRow.horizontalContentInset = subcellHorizontalInset
    }
    
    /// This block gets called immediately and on `expanded/collapsed` state changes, setting first parameter `true` if `expanded`
    @discardableResult
    public func onToggleInlineRow(_ callback: @escaping (Bool, SelectorInlineCell<T>, SelectorInlineRow<T>, InlineRow) -> Void) -> SelectorInlineRow {
        callback(isExpanded, cell, self, inlineRow ?? InlineRow())
        onExpandInlineRow { callback(true, $0, $1, $2) }
        onCollapseInlineRow { callback(false, $0, $1, $2) }
        return self
    }
}
