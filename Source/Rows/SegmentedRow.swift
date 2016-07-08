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
        textLabel?.setContentHuggingPriority(500, for: .horizontal)
        return textLabel
    }
    lazy public var segmentedControl : UISegmentedControl = {
        let result = UISegmentedControl()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setContentHuggingPriority(250, for: .horizontal)
        return result
    }()
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        segmentedControl.removeTarget(self, action: nil, for: .allEvents)
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    public override func setup() {
        super.setup()
        height = { BaseRow.estimatedRowHeight }
        selectionStyle = .none
        contentView.addSubview(titleLabel!)
        contentView.addSubview(segmentedControl)
        titleLabel?.addObserver(self, forKeyPath: "text", options: [.old, .new], context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: [.old, .new], context: nil)
        segmentedControl.addTarget(self, action: #selector(SegmentedCell.valueChanged), for: .valueChanged)
        contentView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        
        updateSegmentedControl()
        segmentedControl.selectedSegmentIndex = selectedIndex() ?? UISegmentedControlNoSegment
        segmentedControl.isEnabled = !row.isDisabled
    }
    
    func valueChanged() {
        row.value =  (row as! SegmentedRow<T>).options[segmentedControl.selectedSegmentIndex]
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if let obj = object, let changeType = change, let _ = keyPath where ((obj === titleLabel && keyPath == "text") || (obj === imageView && keyPath == "image")) && changeType[NSKeyValueChangeKey.kindKey]?.uintValue == NSKeyValueChange.setting.rawValue{
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    func updateSegmentedControl() {
        segmentedControl.removeAllSegments()
        items().enumerated().forEach { segmentedControl.insertSegment(withTitle: $0.element, at: $0.offset, animated: false) }
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
            dynamicConstraints.append(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        dynamicConstraints.append(NSLayoutConstraint(item: segmentedControl, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: 0.3, constant: 0.0))
        
        
        if hasImageView && hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-[titleLabel]-[segmentedControl]-|", options: [], metrics: nil, views: views)
        }
        else if hasImageView && !hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-[segmentedControl]-|", options: [], metrics: nil, views: views)
        }
        else if !hasImageView && hasTitleLabel {
            dynamicConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-[segmentedControl]-|", options: .alignAllCenterY, metrics: nil, views: views)
        }
        else {
            dynamicConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[segmentedControl]-|", options: .alignAllCenterY, metrics: nil, views: views)
        }
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    func items() -> [String] {// or create protocol for options
        var result = [String]()
        for object in (row as! SegmentedRow<T>).options {
            result.append(row.displayValueFor?(object) ?? "")
        }
        return result
    }
    
    func selectedIndex() -> Int? {
        guard let value = row.value else { return nil }
        return (row as! SegmentedRow<T>).options.index(of: value)
    }
}

//MARK: SegmentedRow

/// An options row where the user can select an option from an UISegmentedControl
public final class SegmentedRow<T: Equatable>: OptionsRow<SegmentedCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

