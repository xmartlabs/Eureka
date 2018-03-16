//  GenericMultipleSelectorRow.swift
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

/// Generic options selector row that allows multiple selection.
open class GenericMultipleSelectorRow<T, Cell: CellType>: Row<Cell>, PresenterRowType, NoValueDisplayTextConformance, OptionsProviderRow
            where Cell: BaseCell, Cell.Value == Set<T> {
    
    public typealias PresentedController = MultipleSelectorViewController<GenericMultipleSelectorRow<T,Cell>>

    /// Defines how the view controller will be presented, pushed, etc.
    open var presentationMode: PresentationMode<PresentedController>?

    /// Will be called before the presentation occurs.
    open var onPresentCallback: ((FormViewController, PresentedController) -> Void)?

    /// Title to be displayed for the options
    open var selectorTitle: String?
    open var noValueDisplayText: String?

    /// Options from which the user will choose
    open var optionsProvider: OptionsProvider<T>?

    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { (rowValue: Set<T>?) in
            return rowValue?.map({ String(describing: $0) }).sorted().joined(separator: ", ")
        }
        presentationMode = .show(controllerProvider: ControllerProvider.callback {
                return MultipleSelectorViewController<GenericMultipleSelectorRow<T,Cell>>()
        }, onDismiss: { vc in
            let _ = vc.navigationController?.popViewController(animated: true)
        })
    }

    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        guard let presentationMode = presentationMode, !isDisabled else { return }
        if let controller = presentationMode.makeController() {
            controller.row = self
            controller.title = selectorTitle ?? controller.title
            onPresentCallback?(cell.formViewController()!, controller)
            presentationMode.present(controller, row: self, presentingController: self.cell.formViewController()!)
        } else {
            presentationMode.present(nil, row: self, presentingController: self.cell.formViewController()!)
        }
    }

    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let rowVC = segue.destination as? PresentedController else { return }
        rowVC.title = selectorTitle ?? rowVC.title
        rowVC.onDismissCallback = presentationMode?.onDismissCallback ?? rowVC.onDismissCallback
        onPresentCallback?(cell.formViewController()!, rowVC)
        rowVC.row = self
    }
}
