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

/// Selector UIAlertController
open class SelectorAlertController<T> : UIAlertController, TypedRowControllerType where T: Equatable {

    /// The row that pushed or presented this controller
    public var row: RowOf<T>!

    public var cancelTitle = NSLocalizedString("Cancel", comment: "")

    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> Void)?

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
        guard let options = row.dataProvider?.arrayData else { return }
        addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: nil))
        for option in options {
            addAction(UIAlertAction(title: row.displayValueFor?(option), style: .default, handler: { [weak self] _ in
                self?.row.value = option
                self?.onDismissCallback?(self!)
                }))
        }
    }

}
