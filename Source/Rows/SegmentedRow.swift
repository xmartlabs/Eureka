//  SegmentedRow.swift
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

// MARK: SegmentedCell

open class SegmentedCell<T: Equatable> : Cell<T>, CellType {

    @IBOutlet public weak var segmentedControl: UISegmentedControl!
    @IBOutlet public weak var titleLabel: UILabel?

    private var dynamicConstraints = [NSLayoutConstraint]()
    fileprivate var observingTitleText = false
    private var awakeFromNibCalled = false

    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        let segmentedControl = UISegmentedControl()
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.setContentHuggingPriority(250, for: .horizontal)
        self.segmentedControl = segmentedControl

        self.titleLabel = self.textLabel
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.setContentHuggingPriority(500, for: .horizontal)

        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            guard me.observingTitleText else { return }
            me.titleLabel?.removeObserver(me, forKeyPath: "text")
            me.observingTitleText = false
        }
        NotificationCenter.default.addObserver(forName: Notification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            guard !me.observingTitleText else { return }
            me.titleLabel?.addObserver(me, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
            me.observingTitleText = true
        }

        NotificationCenter.default.addObserver(forName: Notification.Name.UIContentSizeCategoryDidChange, object: nil, queue: nil) { [weak self] _ in
            self?.titleLabel = self?.textLabel
            self?.setNeedsUpdateConstraints()
        }
        contentView.addSubview(titleLabel!)
        contentView.addSubview(segmentedControl)
        titleLabel?.addObserver(self, forKeyPath: "text", options: [.old, .new], context: nil)
        observingTitleText = true
        imageView?.addObserver(self, forKeyPath: "image", options: [.old, .new], context: nil)

        contentView.addConstraint(NSLayoutConstraint(item: segmentedControl, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func awakeFromNib() {
        super.awakeFromNib()
        awakeFromNibCalled = true
    }

    deinit {
        segmentedControl.removeTarget(self, action: nil, for: .allEvents)
        if !awakeFromNibCalled {
            if observingTitleText {
                titleLabel?.removeObserver(self, forKeyPath: "text")
            }
            imageView?.removeObserver(self, forKeyPath: "image")
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillResignActive, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
        }

    }

    open override func setup() {
        super.setup()
        height = { BaseRow.estimatedRowHeight }
        selectionStyle = .none
        segmentedControl.addTarget(self, action: #selector(SegmentedCell.valueChanged), for: .valueChanged)
    }

    open override func update() {
        super.update()
        detailTextLabel?.text = nil

        updateSegmentedControl()
        segmentedControl.selectedSegmentIndex = selectedIndex() ?? UISegmentedControlNoSegment
        segmentedControl.isEnabled = !row.isDisabled
    }

    func valueChanged() {
        row.value =  (row as! SegmentedRow<T>).options[segmentedControl.selectedSegmentIndex]
    }

    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let obj = object as AnyObject?

        if let changeType = change, let _ = keyPath, ((obj === titleLabel && keyPath == "text") || (obj === imageView && keyPath == "image")) &&
            (changeType[NSKeyValueChangeKey.kindKey] as? NSNumber)?.uintValue == NSKeyValueChange.setting.rawValue, !awakeFromNibCalled {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }

    func updateSegmentedControl() {
        segmentedControl.removeAllSegments()
        
        (row as! SegmentedRow<T>).options.reversed().forEach {
            if let image = $0 as? UIImage {
                segmentedControl.insertSegment(with: image, at: 0, animated: false)
            } else {
                segmentedControl.insertSegment(withTitle: row.displayValueFor?($0) ?? "", at: 0, animated: false)
            }
        }
    }

    open override func updateConstraints() {
        guard !awakeFromNibCalled else { return }
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        var views: [String: AnyObject] =  ["segmentedControl": segmentedControl]

        var hasImageView = false
        var hasTitleLabel = false

        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            hasImageView = true
        }

        if let titleLabel = titleLabel, let text = titleLabel.text, !text.isEmpty {
            views["titleLabel"] = titleLabel
            hasTitleLabel = true
            dynamicConstraints.append(NSLayoutConstraint(item: titleLabel, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0))
        }

        dynamicConstraints.append(NSLayoutConstraint(item: segmentedControl, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: 0.3, constant: 0.0))

        if hasImageView && hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-(15)-[titleLabel]-[segmentedControl]-|", options: [], metrics: nil, views: views)
        } else if hasImageView && !hasTitleLabel {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:[imageView]-[segmentedControl]-|", options: [], metrics: nil, views: views)
        } else if !hasImageView && hasTitleLabel {
            dynamicConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-[segmentedControl]-|", options: .alignAllCenterY, metrics: nil, views: views)
        } else {
            dynamicConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[segmentedControl]-|", options: .alignAllCenterY, metrics: nil, views: views)
        }
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }

    func selectedIndex() -> Int? {
        guard let value = row.value else { return nil }
        return (row as! SegmentedRow<T>).options.index(of: value)
    }
}

// MARK: SegmentedRow

/// An options row where the user can select an option from an UISegmentedControl
public final class SegmentedRow<T: Equatable>: OptionsRow<SegmentedCell<T>>, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
