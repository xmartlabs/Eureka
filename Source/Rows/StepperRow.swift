//
//  StepperRow.swift
//  Eureka
//
//  Created by Andrew Holt on 3/4/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import UIKit

// MARK: StepperCell

open class StepperCell: Cell<Double>, CellType {
  
  
    @IBOutlet open weak var stepper: UIStepper!
    @IBOutlet open weak var valueLabel: UILabel!
    @IBOutlet open weak var titleLabel: UILabel!

    private var awakeFromNibCalled = false

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
      
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            if me.shouldShowTitle {
                me.titleLabel = me.textLabel
                me.setNeedsUpdateConstraints()
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNibCalled = true
    }

    open override func setup() {
        super.setup()
        if !awakeFromNibCalled {
            let title = textLabel
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            self.titleLabel = title
         
            let stepper = UIStepper()
            stepper.translatesAutoresizingMaskIntoConstraints = false
            stepper.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            self.stepper = stepper
          
            if shouldShowTitle {
                contentView.addSubview(titleLabel)
            }

            setupValueLabel()
            contentView.addSubview(stepper)
            setNeedsUpdateConstraints()
        }
        selectionStyle = .none
        stepper.addTarget(self, action: #selector(StepperCell.valueChanged), for: .valueChanged)
    }

    open func setupValueLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(UILayoutPriority(500), for: .horizontal)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        self.valueLabel = label
        contentView.addSubview(valueLabel)
    }
  
    open override func update() {
        super.update()
        detailTextLabel?.text = nil
        stepper.isEnabled = !row.isDisabled
        
        titleLabel.isHidden = !shouldShowTitle
        stepper.value = row.value ?? 0
        stepper.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel?.textColor = tintColor
        valueLabel?.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel?.text = row.displayValueFor?(row.value)
    }

    @objc(stepperValueDidChange) func valueChanged() {
        row.value = stepper.value
        row.updateCell()
    }
  
    var shouldShowTitle: Bool {
        return row?.title?.isEmpty == false
    }
  
    private var stepperRow: StepperRow {
        return row as! StepperRow
    }
    
    deinit {
        stepper.removeTarget(self, action: nil, for: .allEvents)
        guard !awakeFromNibCalled else { return }
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
    }

    open override func updateConstraints() {
        customConstraints()
        super.updateConstraints()
    }
  
    open var dynamicConstraints = [NSLayoutConstraint]()
  
    open func customConstraints() {
        guard !awakeFromNibCalled else { return }
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
      
        var views: [String : Any] = ["titleLabel": titleLabel!, "stepper": stepper!, "valueLabel": valueLabel!]
        let metrics = ["spacing": 15.0]
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
      
        let title = shouldShowTitle ? "[titleLabel]-(>=15@250)-" : ""
      
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            let hContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-(15)-\(title)[valueLabel]-[stepper]-|", options: .alignAllCenterY, metrics: metrics, views: views)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            dynamicConstraints.append(contentsOf: hContraints)
        } else {
            let hContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(title)[valueLabel]-[stepper]-|", options: .alignAllCenterY, metrics: metrics, views: views)
            dynamicConstraints.append(contentsOf: hContraints)
        }
        let vContraint = NSLayoutConstraint(item: stepper!, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        dynamicConstraints.append(vContraint)
        contentView.addConstraints(dynamicConstraints)
    }
  
}

// MARK: StepperRow

open class _StepperRow: Row<StepperCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = { value in
                                guard let value = value else { return nil }
                                return DecimalFormatter().string(from: NSNumber(value: value)) }
    }
}

/// Double row that has a UIStepper as accessoryType
public final class StepperRow: _StepperRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
