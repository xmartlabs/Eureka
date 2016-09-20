//
//  StepperRow.swift
//  Eureka
//
//  Created by Andrew Holt on 3/4/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import UIKit

// MARK: StepperCell

open class StepperCell : Cell<Double>, CellType {
    
    public typealias Value = Double
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open lazy var stepper: UIStepper = {
        let s = UIStepper()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    open lazy var valueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        return l
    }()
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        
        addSubview(stepper)
        addSubview(valueLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[v]-[s]-|", options: .alignAllCenterY, metrics: nil, views: ["s": stepper, "v": valueLabel]))
        addConstraint(NSLayoutConstraint(item: stepper, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .centerY, relatedBy: .equal, toItem: stepper, attribute: .centerY, multiplier: 1.0, constant: 0))
        
        stepper.addTarget(self, action: #selector(StepperCell.valueChanged), for: .valueChanged)
        
        valueLabel.textColor = stepper.tintColor
    }
    
    deinit {
        stepper.removeTarget(self, action: nil, for: .allEvents)
    }
    
    open override func update() {
        super.update()
        stepper.isEnabled = !row.isDisabled
        stepper.value = row.value ?? 0
        valueLabel.text = "\(row.value ?? 0)"
        stepper.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel.alpha = row.isDisabled ? 0.3 : 1.0
    }
    
    func valueChanged() {
        valueLabel.text = "\(stepper.value)"
        row.value = stepper.value
    }
}

// MARK: StepperRow

open class _StepperRow: Row<StepperCell> {
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
    }
}


/// Double row that has a UIStepper as accessoryType
public final class StepperRow: _StepperRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
