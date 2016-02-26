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

/// The cell of the SliderRow
public class SliderCell: Cell<Float>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Value1, reuseIdentifier: reuseIdentifier)
    }
    
    public var titleLabel: UILabel! {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        return textLabel
    }
    public var valueLabel: UILabel! {
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
        super.setup()
        height = shouldShowTitle() ? { 88 } : { UITableViewAutomaticDimension }
        
        selectionStyle = .None
        
        slider.minimumValue = (row as! SliderRow).minimumValue
        slider.maximumValue = (row as! SliderRow).maximumValue
        slider.addTarget(self, action: "valueChanged", forControlEvents: .ValueChanged)
        
        if shouldShowTitle() {
            contentView.addSubview(titleLabel)
            contentView.addSubview(valueLabel!)
        }
        contentView.addSubview(slider)
        
        let views = [
            "titleLabel" : titleLabel,
            "valueLabel" : valueLabel,
            "slider" : slider
        ]
        let metrics = [
            "hPadding" : 16.0,
            "vPadding" : 12.0,
            "spacing" : 12.0,
        ]
        
        if shouldShowTitle() {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-hPadding-[titleLabel]-[valueLabel]-hPadding-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-vPadding-[titleLabel]-spacing-[slider]-vPadding-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: metrics, views: views))
            
        } else {
            contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-vPadding-[slider]-vPadding-|", options: NSLayoutFormatOptions.AlignAllLeft, metrics: metrics, views: views))
        }
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-hPadding-[slider]-hPadding-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: metrics, views: views))
    }
    
    public override func update() {
        super.update()
        if !shouldShowTitle() {
            textLabel?.text = nil
            detailTextLabel?.text = nil
        }
        slider.value = row.value ?? 0.0
    }
    
    func valueChanged() {
        let roundedValue: Float
        let steps = Float((row as! SliderRow).steps)
        if steps > 0 {
            let stepValue = round((slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * steps)
            let stepAmount = (slider.maximumValue - slider.minimumValue) / steps
            roundedValue = stepValue * stepAmount + self.slider.minimumValue
        }
        else {
            roundedValue = slider.value
        }
        row.value = roundedValue
        if shouldShowTitle() {
            valueLabel.text = "\(row.value!)"
        }
    }
    
    func shouldShowTitle() -> Bool {
        return row.title?.isEmpty == false
    }
}

/// A row that displays a UISlider. If there is a title set then the title and value will appear above the UISlider.
public final class SliderRow: Row<Float, SliderCell>, RowType {
    
    public var minimumValue: Float = 0.0
    public var maximumValue: Float = 10.0
    public var steps: UInt = 20
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

