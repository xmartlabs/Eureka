//
//  SelectorAlertController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

/// Selector UIAlertController
public class SelectorAlertController<T: Equatable> : UIAlertController, TypedRowControllerType {
    
    /// The row that pushed or presented this controller
    public var row: RowOf<T>!
    
    public var cancelTitle = NSLocalizedString("Cancel", comment: "")
    
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
        addAction(UIAlertAction(title: cancelTitle, style: .Cancel, handler: nil))
        for option in options {
            addAction(UIAlertAction(title: row.displayValueFor?(option), style: .Default, handler: { [weak self] _ in
                self?.row.value = option
                self?.completionCallback?(self!)
                }))
        }
    }
    
}
