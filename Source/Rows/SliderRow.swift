//  SliderRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
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

import UIKit

/// The cell of the SliderRow
open class SliderCell: Cell<Float>, CellType {
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(forName: Notification.Name.UIContentSizeCategoryDidChange, object: nil, queue: nil){ [weak self] notification in
            guard let me = self else { return }
            if me.shouldShowTitle() {
                me.contentView.addSubview(me.titleLabel)
                me.contentView.addSubview(me.valueLabel!)
                me.addConstraints()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var titleLabel: UILabel! {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, for: .horizontal)
        return textLabel
    }
    open var valueLabel: UILabel! {
        detailTextLabel?.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel?.setContentHuggingPriority(500, for: .horizontal)
        return detailTextLabel
    }
    lazy open var slider: UISlider = {
        let result = UISlider()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.setContentHuggingPriority(500, for: .horizontal)
        return result
    }()
    open var formatter: NumberFormatter?
    
    open override func setup() {
        super.setup()
        selectionStyle = .none
        slider.minimumValue = sliderRow.minimumValue
        slider.maximumValue = sliderRow.maximumValue
        slider.addTarget(self, action: #selector(SliderCell.valueChanged), for: .valueChanged)
        
        if shouldShowTitle() {
            contentView.addSubview(titleLabel)
            contentView.addSubview(valueLabel!)
        }
        contentView.addSubview(slider)
        addConstraints()
    }
    
    open override func update() {
        super.update()
        if !shouldShowTitle() {
            textLabel?.text = nil
            valueLabel.text = nil
        } else if valueLabel.text == nil {
            valueLabel.text = " "
        }
        slider.value = row.value ?? 0.0
    }
    
    func addConstraints() {
        let views: [String : Any] = ["titleLabel" : titleLabel, "valueLabel" : valueLabel, "slider" : slider]
        //TODO: in Iphone 6 Plus hPadding should be 20
        let metrics = ["hPadding" : 15.0, "vPadding" : 12.0, "spacing" : 12.0]
        if shouldShowTitle() {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hPadding-[titleLabel]-[valueLabel]-hPadding-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vPadding-[titleLabel]-spacing-[slider]-vPadding-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: metrics, views: views))
            
        } else {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vPadding-[slider]-vPadding-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: metrics, views: views))
        }
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hPadding-[slider]-hPadding-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: metrics, views: views))

    }
    
    func valueChanged() {
        let roundedValue: Float
        let steps = Float(sliderRow.steps)
        if steps > 0 {
            let stepValue = round((slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * steps)
            let stepAmount = (slider.maximumValue - slider.minimumValue) / steps
            roundedValue = stepValue * stepAmount + self.slider.minimumValue
        }
        else {
            roundedValue = slider.value
        }
        row.value = roundedValue
        row.updateCell()
    }
    
    private func shouldShowTitle() -> Bool {
        return row.title?.isEmpty == false
    }
    
    private var sliderRow: SliderRow {
        return row as! SliderRow
    }
}

/// A row that displays a UISlider. If there is a title set then the title and value will appear above the UISlider.
public final class SliderRow: Row<SliderCell>, RowType {
    
    public var minimumValue: Float = 0.0
    public var maximumValue: Float = 10.0
    public var steps: UInt = 20
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

