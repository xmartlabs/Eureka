//  SelectorAlertController.swift
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

/// Specific type, Responsible for the options passed to a selector alert view controller
public protocol AlertOptionsProviderRow: OptionsProviderRow {

    var cancelTitle: String? { get set }

}

/// Selector UIAlertController
open class SelectorAlertController<AlertOptionsRow: AlertOptionsProviderRow>: UIAlertController, TypedRowControllerType where AlertOptionsRow.OptionsProviderType.Option == AlertOptionsRow.Cell.Value, AlertOptionsRow: BaseRow {

    /// The row that pushed or presented this controller
    public var row: RowOf<AlertOptionsRow.Cell.Value>!

    @available(*, deprecated, message: "Use AlertOptionsRow.cancelTitle instead.")
    public var cancelTitle = NSLocalizedString("Cancel", comment: "")

    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> Void)?
    
    /// Options provider to use to get available options.
    /// If not set will use synchronous data provider built with `row.dataProvider.arrayData`.
    //    public var optionsProvider: OptionsProvider<T>?
    public var optionsProviderRow: AlertOptionsRow {
        return row as Any as! AlertOptionsRow
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience public init(_ callback: ((UIViewController) -> Void)?) {
        self.init()
        onDismissCallback = callback
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = optionsProviderRow.options else { return }
        let cancelTitle = optionsProviderRow.cancelTitle ?? NSLocalizedString("Cancel", comment: "")
        addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        for option in options {
            addAction(UIAlertAction(title: row.displayValueFor?(option), style: .default, handler: { [weak self] _ in
                self?.row.value = option
                self?.onDismissCallback?(self!)
            }))
        }
    }

}
