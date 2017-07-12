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

    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        NotificationCenter.default.addObserver(forName: Notification.Name.UIContentSizeCategoryDidChange, object: nil, queue: nil) { [weak self] _ in
            guard let me = self else { return }
            if me.shouldShowTitle {
                me.titleLabel = me.textLabel
                me.valueLabel = me.detailTextLabel
                me.addConstraints()
            }
        }
    }

    deinit {
        guard !awakeFromNibCalled else { return }
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIContentSizeCategoryDidChange, object: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        awakeFromNibCalled = true
    }

    open override func setup() {
        super.setup()
        if !awakeFromNibCalled {
            // title
            let title = textLabel
            textLabel?.translatesAutoresizingMaskIntoConstraints = false
            textLabel?.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            self.titleLabel = title

            let value = detailTextLabel
            value?.translatesAutoresizingMaskIntoConstraints = false
            value?.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            self.valueLabel = value

            let slider = UISlider()
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
            self.slider = slider

            if shouldShowTitle {
                contentView.addSubview(titleLabel)
                contentView.addSubview(valueLabel!)
            }
            contentView.addSubview(slider)
            addConstraints()
        }
        selectionStyle = .none
        slider.minimumValue = sliderRow.minimumValue
        slider.maximumValue = sliderRow.maximumValue
        slider.addTarget(self, action: #selector(SliderCell.valueChanged), for: .valueChanged)
    }

    open override func update() {
        super.update()
        titleLabel.text = row.title
        valueLabel.text = row.displayValueFor?(row.value)
        valueLabel.isHidden = !shouldShowTitle && !awakeFromNibCalled
        titleLabel.isHidden = valueLabel.isHidden
        slider.value = row.value ?? 0.0
        slider.isEnabled = !row.isDisabled
    }

    func addConstraints() {
        guard !awakeFromNibCalled else { return }
        let views: [String : Any] = ["titleLabel": titleLabel, "valueLabel": valueLabel, "slider": slider]
        //TODO: in Iphone 6 Plus hPadding should be 20
        let metrics = ["hPadding": 15.0, "vPadding": 12.0, "spacing": 12.0]
        if shouldShowTitle {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hPadding-[titleLabel]-[valueLabel]-hPadding-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: metrics, views: views))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vPadding-[titleLabel]-spacing-[slider]-vPadding-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: metrics, views: views))

        } else {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-vPadding-[slider]-vPadding-|", options: NSLayoutFormatOptions.alignAllLeft, metrics: metrics, views: views))
        }
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-hPadding-[slider]-hPadding-|", options: NSLayoutFormatOptions.alignAllLastBaseline, metrics: metrics, views: views))

    }

    @objc func valueChanged() {
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
