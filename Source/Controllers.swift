//  Controllers.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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

public class SelectorViewController<T:Equatable> : FormViewController, TypedRowControllerType {
    
    public var row: RowOf<T>!
    public var completionCallback : ((UIViewController) -> ())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init()
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        let rows = options.map { opt in
            ListCheckRow<T>(String(opt)){ lrow in
                lrow.title = row.displayValueFor?(opt)
                lrow.selectableValue = opt
                lrow.value = row.value == opt ? opt : nil
            }.onCellSelection { [weak self] cell, row in
                self?.row.value = row.value
                self?.completionCallback?(self!)
            }
        }
        form +++= SelectableList<ListCheckRow<T>, T>(rows: rows, initializer: {
            [weak self] sec in
                sec.header = HeaderFooterView<UITableViewHeaderFooterView>(title: self?.row.title)
            })
    }
}

public class MultipleSelectorViewController<T:Hashable> : FormViewController, TypedRowControllerType {

    public var row: RowOf<Set<T>>!
    public var completionCallback : ((UIViewController) -> ())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init()
        completionCallback = callback
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        form +++= Section()
        for o in options {
            form.first! <<< CheckRow() { [weak self] in
                                $0.title = String(o.first!)
                                $0.value = self?.row.value?.contains(o.first!) ?? false
                            }
                            .onCellSelection { [weak self] _, _ in
                                guard let set = self?.row.value else {
                                    self?.row.value = [o.first!]
                                    return
                                }
                                if set.contains(o.first!) {
                                    self?.row.value!.remove(o.first!)
                                }
                                else{
                                    self?.row.value!.insert(o.first!)
                                }
                            }
        }
        form.first?.header = HeaderFooterView<UITableViewHeaderFooterView>(title: row.title)
    }
    
}


public class SelectorAlertController<T: Equatable> : UIAlertController, TypedRowControllerType {
    
    public var row: RowOf<T>!
    public var completionCallback : ((UIViewController) -> ())?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init()
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
        addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        for option in options {
            addAction(UIAlertAction(title: row.displayValueFor?(option), style: .Default, handler: { [weak self] _ in
                self?.row.value = option
                self?.completionCallback?(self!)
            }))
        }
    }
    
}

public class ImagePickerController : UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public var row: RowOf<UIImage>!
    public var completionCallback : ((UIViewController) -> ())?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        row.value = info[UIImagePickerControllerOriginalImage] as? UIImage
        completionCallback?(self)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController){
        completionCallback?(self)
    }
}


