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

    private var awakeFromNibCalled = false

    @IBOutlet open weak var titleLabel: UILabel!
    @IBOutlet open weak var valueLabel: UILabel!
    @IBOutlet open weak var slider: UISlider!

    open var formatter: NumberFormatter?

    public required init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            if me.shouldShowTitle {
                me.titleLabel = me.textLabel
                me.valueLabel = me.detailTextLabel
                me.setNeedsUpdateConstraints()
            }
        }
    }

    deinit {
        guard !awakeFromNibCalled else { return }
        NotificationCenter.default.removeObserver(self, name: UIContentSizeCategory.didChangeNotification, object: nil)
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

            let value = detailTextLabel
            value?.translatesAutoresizingMaskIntoConstraints = false
            value?.setContentHuggingPriority(UILayoutPriority(500), for: .horizontal)
            value?.adjustsFontSizeToFitWidth = true
            value?.minimumScaleFactor = 0.5
            self.valueLabel = value

            let slider = UISlider()
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            self.slider = slider

            if shouldShowTitle {
                contentView.addSubview(titleLabel)
            }

            if !sliderRow.shouldHideValue {
              contentView.addSubview(valueLabel)
            }
            contentView.addSubview(slider)
            setNeedsUpdateConstraints()
        }
        selectionStyle = .none
        slider.minimumValue = 0
        slider.maximumValue = 10
        slider.addTarget(self, action: #selector(SliderCell.valueChanged), for: .valueChanged)
    }

    open override func update() {
        super.update()
        titleLabel.text = row.title
        titleLabel.isHidden = !shouldShowTitle
        valueLabel.text = row.displayValueFor?(row.value ?? slider.minimumValue)
        valueLabel.isHidden = sliderRow.shouldHideValue
        slider.value = row.value ?? slider.minimumValue
        slider.isEnabled = !row.isDisabled
    }

    @objc (sliderValueDidChange) func valueChanged() {
        let roundedValue: Float
        let steps = Float(sliderRow.steps)
        if steps > 0 {
            let stepValue = round((slider.value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue) * steps)
            let stepAmount = (slider.maximumValue - slider.minimumValue) / steps
            roundedValue = stepValue * stepAmount + self.slider.minimumValue
        } else {
            roundedValue = slider.value
        }
        row.value = roundedValue
        row.updateCell()
    }

    var shouldShowTitle: Bool {
        return row?.title?.isEmpty == false
    }

    private var sliderRow: SliderRow {
        return row as! SliderRow
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
        
        var views: [String : Any] = ["titleLabel": titleLabel!, "slider": slider!, "valueLabel": valueLabel!]
        let metrics = ["spacing": 15.0]
        valueLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        let title = shouldShowTitle ? "[titleLabel]-spacing-" : ""
        let value = !sliderRow.shouldHideValue ? "-[valueLabel]" : ""
        
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            let hContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-(15)-\(title)[slider]\(value)-|", options: .alignAllCenterY, metrics: metrics, views: views)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            dynamicConstraints.append(contentsOf: hContraints)
        } else {
            let hContraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(title)[slider]\(value)-|", options: .alignAllCenterY, metrics: metrics, views: views)
            dynamicConstraints.append(contentsOf: hContraints)
        }
        let vContraint = NSLayoutConstraint(item: slider!, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        dynamicConstraints.append(vContraint)
        contentView.addConstraints(dynamicConstraints)
    }

}
        

/// A row that displays a UISlider. If there is a title set then the title and value will appear above the UISlider.
public final class SliderRow: Row<SliderCell>, RowType {

    public var steps: UInt = 20
    public var shouldHideValue = false

    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
