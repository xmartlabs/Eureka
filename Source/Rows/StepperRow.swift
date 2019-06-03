//
//  StepperRow.swift
//  Eureka
//
//  Created by Andrew Holt on 3/4/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import UIKit

/// The cell of the StepperRow
open class StepperCell: Cell<Double>, CellType {
  
  private var awakeFromNibCalled = false
  
  @IBOutlet open weak var titleLabel: UILabel!
  @IBOutlet open weak var valueLabel: UILabel!
  @IBOutlet open weak var stepper: UIStepper!
  
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
      let font = self.valueLabel.font!
      self.valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: font.pointSize, weight: font.weight)
      
      let stepper = UIStepper()
      stepper.translatesAutoresizingMaskIntoConstraints = false
      stepper.setContentHuggingPriority(UILayoutPriority(rawValue: 500), for: .horizontal)
      self.stepper = stepper
      
      if shouldShowTitle {
        contentView.addSubview(titleLabel)
      }
      contentView.addSubview(valueLabel)
      contentView.addSubview(stepper)
      setNeedsUpdateConstraints()
    }
    selectionStyle = .none
    stepper.minimumValue = 0
    stepper.maximumValue = 10
    stepper.addTarget(self, action: #selector(StepperCell.valueChanged), for: .valueChanged)
  }
  
  open override func update() {
    super.update()
    titleLabel.text = row.title
    titleLabel.isHidden = !shouldShowTitle
    valueLabel.text = row.displayValueFor?(row.value)
    stepper.value = row.value ?? stepper.minimumValue
    stepper.isEnabled = !row.isDisabled
    
  }
  
  @objc func valueChanged() {
    row.value = stepper.value
    row.updateCell()
  }
  
  var shouldShowTitle: Bool {
    return row?.title?.isEmpty == false
  }
  
  private var stepperRow: StepperRow {
    return row as! StepperRow
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
    
    let title = shouldShowTitle ? "[titleLabel]-(>=15)-" : ""
    
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


/// A row that displays a UIStepper. If there is a title set then the title and value will appear above the UIStepper.
public final class StepperRow: Row<StepperCell>, RowType {
  
  required public init(tag: String?) {
    super.init(tag: tag)
  }
}

extension UIFont {
  var weight: UIFont.Weight {
    guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
    let weightRawValue = CGFloat(weightNumber.doubleValue)
    let weight = UIFont.Weight(rawValue: weightRawValue)
    return weight
  }
  
  private var traits: [UIFontDescriptor.TraitKey: Any] {
    return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
      ?? [:]
  }
}
