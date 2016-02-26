//
//  SelectorViewController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

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
