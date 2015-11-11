//
//  SliderRow.swift
//  Eureka
//
//  Created by Bruno Scheele on 27/10/15.
//  Copyright © 2015 Noodlewerk Apps. All rights reserved.
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

import UIKit

public class SliderCell: Cell<Float>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }
    
    public var titleLabel: UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        return textLabel
    }
    public var valueLabel: UILabel? {
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        return detailTextLabel
    }
    lazy public var slider: UISlider = {
        let result = UISlider()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setContentHuggingPriority(500, forAxis: .Horizontal)
        return result
    }()
    public var formatter: NSNumberFormatter?
    
    public override func setup() {
        height = { 88 }
        row.title = "Testing"
        
        super.setup()
        selectionStyle = .None
        
        slider.minimumValue = (row as! SliderRow).minimumValue
        slider.maximumValue = (row as! SliderRow).maximumValue
        slider.addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
        
        contentView.addSubview(titleLabel!)
        contentView.addSubview(valueLabel!)
        contentView.addSubview(slider)
        
        let views = [
            "titleLabel" : titleLabel!,
            "valueLabel" : valueLabel!,
            "slider" : slider
        ]
        let metrics = [
            "hPadding" : 16.0,
            "vPadding" : 12.0,
            "spacing" : 12.0,
        ]
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-hPadding-[titleLabel]-[valueLabel]-hPadding-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-vPadding-[titleLabel]-spacing-[slider]-vPadding-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: metrics, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-hPadding-[slider]-hPadding-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
    }
    
    func valueChanged() {
        let roundedValue: Float
        let steps = Float((row as! SliderRow).steps)
        if steps > 0 {
            let stepValue = round((slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * steps)
            let stepAmount = (slider.maximumValue - slider.minimumValue) / steps
            roundedValue = stepValue * stepAmount + self.slider.minimumValue;
        }
        else {
            roundedValue = slider.value
        }
        row.value = roundedValue
        valueLabel?.text = "\(row.value!)"
    }
}

public final class SliderRow: Row<Float, SliderCell>, RowType {
    
    public var minimumValue: Float = 0.0
    public var maximumValue: Float = 10.0
    public var steps: UInt = 20
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

