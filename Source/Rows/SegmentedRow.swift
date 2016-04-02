//
//  SegmentedRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

//MARK: SegmentedCell

public class SegmentedCell<T: Equatable> : Cell<T>, CellType {
    
    public var titleLabel : UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        return textLabel
    }
    lazy public var segmentedControl : UISegmentedControl = {
        let result = UISegmentedControl()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setContentHuggingPriority(500, forAxis: .Horizontal)
        return result
    }()
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    deinit {
        segmentedControl.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        contentView.addSubview(titleLabel!)
        contentView.addSubview(segmentedControl)
        titleLabel?.addObserver(self, forKeyPath: "text", options: [.Old, .New], context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: [.Old, .New], context: nil)
        segmentedControl.addTarget(self, action: #selector(SegmentedCell.valueChanged), forControlEvents: .ValueChanged)
        contentView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        
        updateSegmentedControl()
        segmentedControl.selectedSegmentIndex = selectedIndex() ?? UISegmentedControlNoSegment
        segmentedControl.enabled = !row.isDisabled
    }
    
    func valueChanged() {
        row.value =  (row as! SegmentedRow<T>).options[segmentedControl.selectedSegmentIndex]
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let changeType = change, let _ = keyPath where ((obj === titleLabel && keyPath == "text") || (obj === imageView && keyPath == "image")) && changeType[NSKeyValueChangeKindKey]?.unsignedLongValue == NSKeyValueChange.Setting.rawValue{
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    func updateSegmentedControl() {
        segmentedControl.removeAllSegments()
        for item in items().enumerate() {
            segmentedControl.insertSegmentWithTitle(item.element, atIndex: item.index, animated: false)
        }
    }
    
    public override func updateConstraints() {
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views : [String: AnyObject] =  ["segmentedControl": segmentedControl]
        
        var hasImageView = false
        var hasTitleLabel = false
        
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            hasImageView = true
        }
        
        if let titleLabel = titleLabel, text = titleLabel.text where !text.isEmpty {
            views["titleLabel"] = titleLabel
            hasTitleLabel = true
        }
        
        if hasImageView && hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[titleLabel]-[segmentedControl]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
            dynamicConstraints.append(NSLayoutConstraint(item: segmentedControl, attribute: .Width, relatedBy: (row as? FieldRowConformance)?.textFieldPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: (row as? FieldRowConformance)?.textFieldPercentage ?? 0.3, constant: 0.0))
            dynamicConstraints.append(NSLayoutConstraint(item: titleLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        else if hasImageView && !hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:[imageView]-[segmentedControl]-|", options: [], metrics: nil, views: views)
        }
        else if !hasImageView && hasTitleLabel {
            dynamicConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[titleLabel]-16-[segmentedControl]-|", options: .AlignAllCenterY, metrics: nil, views: views)
            
            dynamicConstraints.append(NSLayoutConstraint(item: titleLabel!, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        else {
            dynamicConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[segmentedControl]-|", options: .AlignAllCenterY, metrics: nil, views: views)
        }
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    func items() -> [String] {// or create protocol for options
        var result = [String]()
        for object in (row as! SegmentedRow<T>).options{
            result.append(row.displayValueFor?(object) ?? "")
        }
        return result
    }
    
    func selectedIndex() -> Int? {
        guard let value = row.value else { return nil }
        return (row as! SegmentedRow<T>).options.indexOf(value)
    }
}

//MARK: SegmentedRow

/// An options row where the user can select an option from an UISegmentedControl
public final class SegmentedRow<T: Equatable>: OptionsRow<T, SegmentedCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

