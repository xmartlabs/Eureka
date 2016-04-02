//
//  ImageRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

public struct ImageRowSourceTypes : OptionSetType {
    
    public let rawValue: Int
    public var imagePickerControllerSourceTypeRawValue: Int { return self.rawValue >> 1 }
    
    public init(rawValue: Int) { self.rawValue = rawValue }
    private init(_ sourceType: UIImagePickerControllerSourceType) { self.init(rawValue: 1 << sourceType.rawValue) }
    
    public static let PhotoLibrary  = ImageRowSourceTypes(.PhotoLibrary)
    public static let Camera  = ImageRowSourceTypes(.Camera)
    public static let SavedPhotosAlbum = ImageRowSourceTypes(.SavedPhotosAlbum)
    public static let All: ImageRowSourceTypes = [Camera, PhotoLibrary, SavedPhotosAlbum]
}

public enum ImageClearAction {
    case No
    case Yes(style: UIAlertActionStyle)
}

//MARK: Row

public class _ImageRow<Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell.Value == UIImage>: SelectorRow<UIImage, Cell, ImagePickerController> {
    

    public var sourceTypes: ImageRowSourceTypes
    public internal(set) var imageURL: NSURL?
    public var clearAction = ImageClearAction.Yes(style: .Destructive)
    
    private var _sourceType: UIImagePickerControllerSourceType = .Camera
    
    public required init(tag: String?) {
        sourceTypes = .All
        super.init(tag: tag)
        presentationMode = .PresentModally(controllerProvider: ControllerProvider.Callback { return ImagePickerController() }, completionCallback: { [weak self] vc in
            self?.select()
            vc.dismissViewControllerAnimated(true, completion: nil)
            })
        self.displayValueFor = nil
        
    }
    
    // copy over the existing logic from the SelectorRow
    private func displayImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        if let presentationMode = presentationMode where !isDisabled {
            if let controller = presentationMode.createController(){
                controller.row = self
                controller.sourceType = sourceType
                onPresentCallback?(cell.formViewController()!, controller)
                presentationMode.presentViewController(controller, row: self, presentingViewController: cell.formViewController()!)
            }
            else{
                _sourceType = sourceType
                presentationMode.presentViewController(nil, row: self, presentingViewController: cell.formViewController()!)
            }
        }
    }
    
    public override func customDidSelect() {
        guard !isDisabled else {
            super.customDidSelect()
            return
        }
        deselect()
        var availableSources: ImageRowSourceTypes = []
            
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            availableSources.insert(.PhotoLibrary)
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            availableSources.insert(.Camera)
        }
        if UIImagePickerController.isSourceTypeAvailable(.SavedPhotosAlbum) {
            availableSources.insert(.SavedPhotosAlbum)
        }

        sourceTypes.intersectInPlace(availableSources)
        
        if sourceTypes.isEmpty {
            super.customDidSelect()
            return
        }
        
        // now that we know the number of actions aren't empty
        let sourceActionSheet = UIAlertController(title: nil, message: selectorTitle, preferredStyle: .ActionSheet)
        guard let tableView = cell.formViewController()?.tableView  else { fatalError() }
        if let popView = sourceActionSheet.popoverPresentationController {
            popView.sourceView = tableView
            popView.sourceRect = tableView.convertRect(cell.accessoryView?.frame ?? cell.contentView.frame, fromView: cell)
        }
        
        if sourceTypes.contains(.Camera) {
            let cameraOption = UIAlertAction(title: NSLocalizedString("Take Photo", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.displayImagePickerController(.Camera)
                })
            sourceActionSheet.addAction(cameraOption)
        }
        if sourceTypes.contains(.PhotoLibrary) {
            let photoLibraryOption = UIAlertAction(title: NSLocalizedString("Photo Library", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.displayImagePickerController(.PhotoLibrary)
                })
            sourceActionSheet.addAction(photoLibraryOption)
        }
        if sourceTypes.contains(.SavedPhotosAlbum) {
            let savedPhotosOption = UIAlertAction(title: NSLocalizedString("Saved Photos", comment: ""), style: .Default, handler: { [weak self] _ in
                self?.displayImagePickerController(.SavedPhotosAlbum)
                })
            sourceActionSheet.addAction(savedPhotosOption)
        }
        
        switch clearAction {
        case .Yes(let style):
            if let _ = value {
                let clearPhotoOption = UIAlertAction(title: NSLocalizedString("Clear Photo", comment: ""), style: style, handler: { [weak self] _ in
                    self?.value = nil
                    self?.updateCell()
                    })
                sourceActionSheet.addAction(clearPhotoOption)
            }
        case .No:
            break
        }
        
        // check if we have only one source type given
        if sourceActionSheet.actions.count == 1 {
            if let imagePickerSourceType = UIImagePickerControllerSourceType(rawValue: sourceTypes.imagePickerControllerSourceTypeRawValue) {
                displayImagePickerController(imagePickerSourceType)
            }
        } else {
            let cancelOption = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler:nil)
            sourceActionSheet.addAction(cancelOption)
            
            if let presentingViewController = cell.formViewController() {
                presentingViewController.presentViewController(sourceActionSheet, animated: true, completion:nil)
            }
        }
    }
    
    public override func prepareForSegue(segue: UIStoryboardSegue) {
        super.prepareForSegue(segue)
        guard let rowVC = segue.destinationViewController as? ImagePickerController else {
            return
        }
        rowVC.sourceType = _sourceType
    }
    
    public override func customUpdateCell() {
        super.customUpdateCell()
        cell.accessoryType = .None
        if let image = self.value {
            let imageView = UIImageView(frame: CGRectMake(0, 0, 44, 44))
            imageView.contentMode = .ScaleAspectFill
            imageView.image = image
            imageView.clipsToBounds = true
            cell.accessoryView = imageView
        }
        else{
            cell.accessoryView = nil
        }
    }
}

/// A selector row where the user can pick an image
public final class ImageRow : _ImageRow<PushSelectorCell<UIImage>>, RowType {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

