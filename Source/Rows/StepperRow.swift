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

    @IBOutlet public weak var stepper: UIStepper!
    @IBOutlet public weak var valueLabel: UILabel?

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        let stepper = UIStepper()
        self.stepper = stepper
        self.stepper.translatesAutoresizingMaskIntoConstraints = false

        let valueLabel = UILabel()
        self.valueLabel = valueLabel
        self.valueLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.valueLabel?.numberOfLines = 1

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(stepper)
        addSubview(valueLabel)

        guard let textLabel = self.textLabel else { return }
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[t]-[v]-[s]-|", options: .alignAllCenterY, metrics: nil,
                                                      views: ["s": stepper, "v": valueLabel, "t": textLabel]))
        addConstraint(NSLayoutConstraint(item: stepper, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .centerY, relatedBy: .equal, toItem: stepper, attribute: .centerY,
                                         multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: textLabel, attribute: .centerY, relatedBy: .equal, toItem: stepper, attribute: .centerY,
                                         multiplier: 1.0, constant: 0))
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        selectionStyle = .none
        stepper.addTarget(self, action: #selector(StepperCell.valueChanged), for: .valueChanged)
    }

    deinit {
        stepper.removeTarget(self, action: nil, for: .allEvents)
    }

    open override func update() {
        super.update()
        stepper.isEnabled = !row.isDisabled
        stepper.value = row.value ?? 0
        stepper.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel?.textColor = tintColor
        valueLabel?.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel?.text = row.displayValueFor?(row.value)
        detailTextLabel?.text = nil
    }

    @objc func valueChanged() {
        row.value = stepper.value
        row.updateCell()
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
