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

/// Selector Controller (used to select one option among a list)
public class SelectorViewController<T:Equatable> : FormViewController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<T>!
    
    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
        completionCallback = callback
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        guard let options = row.dataProvider?.arrayData else { return }
            
        form +++= SelectableSection<ListCheckRow<T>, T>(row.title ?? "", selectionType: .SingleSelection(enableDeselection: true)) { [weak self] section in
            if let sec = section as? SelectableSection<ListCheckRow<T>, T> {
                sec.onSelectSelectableRow = { _, row in
                    self?.row.value = row.value
                    self?.completionCallback?(self!)
                }
            }
        }
        for option in options {
            form.first! <<< ListCheckRow<T>(String(option)){ lrow in
                    lrow.title = row.displayValueFor?(option)
                    lrow.selectableValue = option
                    lrow.value = row.value == option ? option : nil
                }
        }
    }
}

/// Selector Controller that enables multiple selection
public class MultipleSelectorViewController<T:Hashable> : FormViewController, TypedRowControllerType {

    /// The row that pushed or presented this controller
    public var row: RowOf<Set<T>>!
    
    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience public init(_ callback: (UIViewController) -> ()){
        self.init(nibName: nil, bundle: nil)
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

/// Selector UIAlertController
public class SelectorAlertController<T: Equatable> : UIAlertController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<T>!
    
    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
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

/// Selector Controller used to pick an image
public class ImagePickerController : UIImagePickerController, TypedRowControllerType, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<UIImage>!
    
    /// A closure to be called when the controller disappears.
    public var completionCallback : ((UIViewController) -> ())?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]){
        row.value = info[UIImagePickerControllerOriginalImage] as? UIImage
        (row as? ImageRow)?.imageURL = info[UIImagePickerControllerReferenceURL] as? NSURL
        completionCallback?(self)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController){
        completionCallback?(self)
    }
}


