//
//  StepperRow.swift
//  Eureka
//
//  Created by Andrew Holt on 3/4/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import UIKit

// MARK: StepperCell

public class StepperCell : Cell<Double>, CellType {
    
    public typealias Value = Double
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        height = { BaseRow.estimatedRowHeight }
    }
    
    public lazy var stepper: UIStepper = {
        let s = UIStepper()
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()
    
    public lazy var valueLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.numberOfLines = 1
        return l
    }()
    
    public override func setup() {
        super.setup()
        selectionStyle = .None
        
        addSubview(stepper)
        addSubview(valueLabel)
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[v]-[s]-|", options: .AlignAllCenterY, metrics: nil, views: ["s": stepper, "v": valueLabel]))
        addConstraint(NSLayoutConstraint(item: stepper, attribute: .CenterY, relatedBy: .Equal, toItem: contentView, attribute: .CenterY, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: valueLabel, attribute: .CenterY, relatedBy: .Equal, toItem: stepper, attribute: .CenterY, multiplier: 1.0, constant: 0))
        
        stepper.addTarget(self, action: #selector(StepperCell.valueChanged), forControlEvents: .ValueChanged)
        stepper.value = row.value ?? 0
        
        valueLabel.textColor = stepper.tintColor
        valueLabel.text = "\(row.value ?? 0)"
    }
    
    deinit {
        stepper.removeTarget(self, action: nil, forControlEvents: .AllEvents)
    }
    
    public override func update() {
        super.update()
        stepper.enabled = !row.isDisabled
        stepper.alpha = row.isDisabled ? 0.3 : 1.0
        valueLabel.alpha = row.isDisabled ? 0.3 : 1.0
    }
    
    func valueChanged() {
        valueLabel.text = "\(stepper.value)"
        row.value = stepper.value
    }
}

// MARK: StepperRow

public class _StepperRow: Row<Double, StepperCell> {
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
