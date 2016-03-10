//
//  MultipleSelectorViewController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


/// Selector Controller that enables multiple selection
public class MultipleSelectorViewController<T:Hashable> : FormViewController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<Set<T>>!
    
    public var displayValueFor : (T? -> String?)?

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
                    $0.title = self?.displayValueFor?(o.first!) ?? String(o.first!)
                    $0.value = self?.row.value?.contains(o.first!) ?? false
                }.onCellSelection { [weak self] _, _ in
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
