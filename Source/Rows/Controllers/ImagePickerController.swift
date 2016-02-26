//
//  ImagePickerController.swift
//  Eureka
//
//  Created by Martin Barreto on 2/24/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

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

