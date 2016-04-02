//
//  PostalAddressRow.swift
//  Eureka
//
//  Created by Martin Barreto on 2/23/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation


// MARK: Type

/**
 *  Protocol to be implemented by PostalAddress types.
 */
public protocol PostalAddressType: Equatable {
    var street: String? { get set }
    var state: String? { get set }
    var postalCode: String? { get set }
    var city: String? { get set }
    var country: String? { get set }
}

public func == <T: PostalAddressType>(lhs: T, rhs: T) -> Bool {
    return lhs.street == rhs.street && lhs.state == rhs.state && lhs.postalCode == rhs.postalCode && lhs.city == rhs.city && lhs.country == rhs.country
}

public struct PostalAddress: PostalAddressType {
    public var street: String?
    public var state: String?
    public var postalCode: String?
    public var city: String?
    public var country: String?
    
    public init(){}
    
    public init(street: String?, state: String?, postalCode: String?, city: String?, country: String?) {
        self.street = street
        self.state = state
        self.postalCode = postalCode
        self.city = city
        self.country = country
    }
}

// MARK: PostalAddressCell

/**
 *  Protocol for cells that contain a postal address
 */
public protocol PostalAddressCellConformance {
    var streetTextField: UITextField { get }
    var stateTextField: UITextField { get }
    var postalCodeTextField: UITextField { get }
    var cityTextField: UITextField { get }
    var countryTextField: UITextField { get }
}

public protocol PostalAddressFormatterConformance: class {
    var streetUseFormatterDuringInput: Bool { get set }
    var streetFormatter: NSFormatter? { get set }
    
    var stateUseFormatterDuringInput: Bool { get set }
    var stateFormatter: NSFormatter? { get set }
    
    var postalCodeUseFormatterDuringInput: Bool { get set }
    var postalCodeFormatter: NSFormatter? { get set }
    
    var cityUseFormatterDuringInput: Bool { get set }
    var cityFormatter: NSFormatter? { get set }
    
    var countryUseFormatterDuringInput: Bool { get set }
    var countryFormatter: NSFormatter? { get set }
}

public protocol PostalAddressRowConformance: PostalAddressFormatterConformance {
    var postalAddressPercentage : CGFloat? { get set }
    var placeholderColor : UIColor? { get set }
    var streetPlaceholder : String? { get set }
    var statePlaceholder : String? { get set }
    var postalCodePlaceholder : String? { get set }
    var cityPlaceholder : String? { get set }
    var countryPlaceholder : String? { get set }
}

public class PostalAddressCell<T: PostalAddressType>: Cell<T>, CellType, PostalAddressCellConformance, UITextFieldDelegate {
    
    lazy public var streetTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var streetSeparatorView : UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGrayColor()
        return separatorView
    }()
    
    lazy public var stateTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var stateSeparatorView : UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGrayColor()
        return separatorView
    }()
    
    lazy public var postalCodeTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var postalCodeSeparatorView : UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGrayColor()
        return separatorView
    }()
    
    lazy public var cityTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy public var citySeparatorView : UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = .lightGrayColor()
        return separatorView
    }()
    
    lazy public var countryTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    public var titleLabel : UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, forAxis: .Horizontal)
        textLabel?.setContentCompressionResistancePriority(1000, forAxis: .Horizontal)
        return textLabel
    }
    
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    deinit {
        streetTextField.delegate = nil
        streetTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        stateTextField.delegate = nil
        stateTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        postalCodeTextField.delegate = nil
        postalCodeTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        cityTextField.delegate = nil
        cityTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        countryTextField.delegate = nil
        countryTextField.removeTarget(self, action: nil, forControlEvents: .AllEvents)
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
    }
    
    public override func setup() {
        super.setup()
        height = { 120 }
        selectionStyle = .None
        
        contentView.addSubview(titleLabel!)
        contentView.addSubview(streetTextField)
        contentView.addSubview(streetSeparatorView)
        contentView.addSubview(stateTextField)
        contentView.addSubview(stateSeparatorView)
        contentView.addSubview(postalCodeTextField)
        contentView.addSubview(postalCodeSeparatorView)
        contentView.addSubview(cityTextField)
        contentView.addSubview(citySeparatorView)
        contentView.addSubview(countryTextField)
        
        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.Old.union(.New), context: nil)
        
        streetTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        stateTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        postalCodeTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        cityTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        countryTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        if let title = row.title {
            streetTextField.textAlignment = .Left
            streetTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
            
            stateTextField.textAlignment = .Left
            stateTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
            
            postalCodeTextField.textAlignment = .Left
            postalCodeTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
            
            cityTextField.textAlignment = .Left
            cityTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
            
            countryTextField.textAlignment = .Left
            countryTextField.clearButtonMode = title.isEmpty ? .WhileEditing : .Never
        } else{
            streetTextField.textAlignment =  .Left
            streetTextField.clearButtonMode =  .WhileEditing
            
            stateTextField.textAlignment =  .Left
            stateTextField.clearButtonMode =  .WhileEditing
            
            postalCodeTextField.textAlignment =  .Left
            postalCodeTextField.clearButtonMode =  .WhileEditing
            
            cityTextField.textAlignment =  .Left
            cityTextField.clearButtonMode =  .WhileEditing
            
            countryTextField.textAlignment =  .Left
            countryTextField.clearButtonMode =  .WhileEditing
        }
        
        streetTextField.delegate = self
        streetTextField.text = row.value?.street
        streetTextField.enabled = !row.isDisabled
        streetTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        streetTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        streetTextField.autocorrectionType = .No
        streetTextField.autocapitalizationType = .Words
        streetTextField.keyboardType = .ASCIICapable
        
        stateTextField.delegate = self
        stateTextField.text = row.value?.state
        stateTextField.enabled = !row.isDisabled
        stateTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        stateTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        stateTextField.autocorrectionType = .No
        stateTextField.autocapitalizationType = .Words
        stateTextField.keyboardType = .ASCIICapable
        
        postalCodeTextField.delegate = self
        postalCodeTextField.text = row.value?.postalCode
        postalCodeTextField.enabled = !row.isDisabled
        postalCodeTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        postalCodeTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        postalCodeTextField.autocorrectionType = .No
        postalCodeTextField.autocapitalizationType = .AllCharacters
        postalCodeTextField.keyboardType = .NumbersAndPunctuation
        
        cityTextField.delegate = self
        cityTextField.text = row.value?.city
        cityTextField.enabled = !row.isDisabled
        cityTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        cityTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        cityTextField.autocorrectionType = .No
        cityTextField.autocapitalizationType = .Words
        cityTextField.keyboardType = .ASCIICapable
        
        countryTextField.delegate = self
        countryTextField.text = row.value?.country
        countryTextField.enabled = !row.isDisabled
        countryTextField.textColor = row.isDisabled ? .grayColor() : .blackColor()
        countryTextField.font = .preferredFontForTextStyle(UIFontTextStyleBody)
        countryTextField.autocorrectionType = .No
        countryTextField.autocapitalizationType = .Words
        countryTextField.keyboardType = .ASCIICapable
        
        if let rowConformance = row as? PostalAddressRowConformance{
            if let placeholder = rowConformance.streetPlaceholder{
                streetTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    streetTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.statePlaceholder{
                stateTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    stateTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.postalCodePlaceholder{
                postalCodeTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    postalCodeTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.cityPlaceholder{
                cityTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    cityTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.countryPlaceholder{
                countryTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    countryTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
        }
    }
    
    public override func cellCanBecomeFirstResponder() -> Bool {
        return !row.isDisabled && (
            streetTextField.canBecomeFirstResponder() ||
                stateTextField.canBecomeFirstResponder() ||
                postalCodeTextField.canBecomeFirstResponder() ||
                cityTextField.canBecomeFirstResponder() ||
                countryTextField.canBecomeFirstResponder()
        )
    }
    
    public override func cellBecomeFirstResponder(direction: Direction) -> Bool {
        return direction == .Down ? streetTextField.becomeFirstResponder() : countryTextField.becomeFirstResponder()
    }
    
    public override func cellResignFirstResponder() -> Bool {
        return streetTextField.resignFirstResponder()
            && stateTextField.resignFirstResponder()
            && postalCodeTextField.resignFirstResponder()
            && stateTextField.resignFirstResponder()
            && cityTextField.resignFirstResponder()
            && countryTextField.resignFirstResponder()
    }
    
    override public var inputAccessoryView: UIView? {
        
        if let v = formViewController()?.inputAccessoryViewForRow(row) as? NavigationAccessoryView {
            if streetTextField.isFirstResponder() {
                v.nextButton.enabled = true
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
            }
            else if stateTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.enabled = true
                v.nextButton.enabled = true
            }
            else if postalCodeTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.enabled = true
                v.nextButton.enabled = true
            } else if cityTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.enabled = true
                v.nextButton.enabled = true
            }
            else if countryTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.enabled = true
            }
            return v
        }
        return super.inputAccessoryView
    }
    
    func internalNavigationAction(sender: UIBarButtonItem) {
        guard let inputAccesoryView  = inputAccessoryView as? NavigationAccessoryView else { return }
        
        if streetTextField.isFirstResponder() {
            stateTextField.becomeFirstResponder()
        }
        else if stateTextField.isFirstResponder()  {
            sender == inputAccesoryView.previousButton ? streetTextField.becomeFirstResponder() : postalCodeTextField.becomeFirstResponder()
        }
        else if postalCodeTextField.isFirstResponder() {
            sender == inputAccesoryView.previousButton ? stateTextField.becomeFirstResponder() : cityTextField.becomeFirstResponder()
        }
        else if cityTextField.isFirstResponder() {
            sender == inputAccesoryView.previousButton ? postalCodeTextField.becomeFirstResponder() : countryTextField.becomeFirstResponder()
        }
        else if countryTextField.isFirstResponder() {
            cityTextField.becomeFirstResponder()
        }
    }
    
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKindKey] where ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) && changeType.unsignedLongValue == NSKeyValueChange.Setting.rawValue {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
        }
    }
    
    // Mark: Helpers
    public override func updateConstraints(){
        contentView.removeConstraints(dynamicConstraints)
        dynamicConstraints = []
        
        let cellHeight: CGFloat = self.height!()
        let cellPadding: CGFloat = 6.0
        let textFieldMargin: CGFloat = 2.0
        let textFieldHeight: CGFloat = (cellHeight - 2.0 * cellPadding - 3.0 * textFieldMargin * 2) / 4.0
        let postalCodeTextFieldWidth: CGFloat = 80.0
        let separatorViewHeight = 0.45
        
        var views : [String: AnyObject] =  [
            "streetTextField": streetTextField,
            "streetSeparatorView": streetSeparatorView,
            "stateTextField": stateTextField,
            "stateSeparatorView": stateSeparatorView,
            "postalCodeTextField": postalCodeTextField,
            "postalCodeSeparatorView": postalCodeSeparatorView,
            "cityTextField": cityTextField,
            "citySeparatorView": citySeparatorView,
            "countryTextField": countryTextField
        ]
        
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[streetTextField(\(textFieldHeight))]-\(textFieldMargin)-[streetSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[stateTextField(\(textFieldHeight))]-\(textFieldMargin)-[stateSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[postalCodeTextField(\(textFieldHeight))]-\(textFieldMargin)-[postalCodeSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[countryTextField]-\(cellPadding)-|", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[streetTextField(\(textFieldHeight))]-\(textFieldMargin)-[streetSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[stateTextField(\(textFieldHeight))]-\(textFieldMargin)-[stateSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[cityTextField(\(textFieldHeight))]-\(textFieldMargin)-[citySeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[countryTextField]-\(cellPadding)-|", options: [], metrics: nil, views: views)
        
        if let label = titleLabel, let text = label.text where !text.isEmpty {
            dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("V:|-\(cellPadding)-[titleLabel]-\(cellPadding)-|", options: [], metrics: nil, views: ["titleLabel": label])
            dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: self.contentView, attribute: .CenterY, multiplier: 1, constant: 0))
        }
        
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            if let titleLabel = titleLabel, text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[streetTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[stateTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[countryTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[streetSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[stateSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[label]-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[streetTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[stateTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[countryTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[streetSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[stateSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[imageView]-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
            }
        }
        else{
            
            if let titleLabel = titleLabel, let text = titleLabel.text where !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[streetTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[stateTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[countryTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[streetSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[stateSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
                
                let multiplier = (row as? PostalAddressRowConformance)?.postalAddressPercentage ?? 0.3
                dynamicConstraints.append(NSLayoutConstraint(item: streetTextField, attribute: .Width, relatedBy: (row as? PostalAddressRowConformance)?.postalAddressPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: multiplier, constant: 0.0))
                dynamicConstraints.append(NSLayoutConstraint(item: stateTextField, attribute: .Width, relatedBy: (row as? PostalAddressRowConformance)?.postalAddressPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: multiplier, constant: 0.0))
                dynamicConstraints.append(NSLayoutConstraint(item: countryTextField, attribute: .Width, relatedBy: (row as? PostalAddressRowConformance)?.postalAddressPercentage != nil ? .Equal : .GreaterThanOrEqual, toItem: contentView, attribute: .Width, multiplier: multiplier, constant: 0.0))
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[streetTextField]-|", options: .AlignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[stateTextField]-|", options: .AlignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[countryTextField]-|", options: .AlignAllLeft, metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[streetSeparatorView]-|", options: .AlignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[stateSeparatorView]-|", options: .AlignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
            }
        }
        
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    public func textFieldDidChange(textField : UITextField){
        guard let textValue = textField.text else {
            switch(textField){
            case streetTextField:
                row.value?.street = nil
                
            case stateTextField:
                row.value?.state = nil
                
            case postalCodeTextField:
                row.value?.postalCode = nil
            case cityTextField:
                row.value?.city = nil
                
            case countryTextField:
                row.value?.country = nil
                
            default:
                break
            }
            return
        }
        
        if let rowConformance = row as? PostalAddressRowConformance{
            var useFormatterDuringInput = false
            var valueFormatter: NSFormatter?
            
            switch(textField){
            case streetTextField:
                useFormatterDuringInput = rowConformance.streetUseFormatterDuringInput
                valueFormatter = rowConformance.streetFormatter
                
            case stateTextField:
                useFormatterDuringInput = rowConformance.stateUseFormatterDuringInput
                valueFormatter = rowConformance.stateFormatter
                
            case postalCodeTextField:
                useFormatterDuringInput = rowConformance.postalCodeUseFormatterDuringInput
                valueFormatter = rowConformance.postalCodeFormatter
                
            case cityTextField:
                useFormatterDuringInput = rowConformance.cityUseFormatterDuringInput
                valueFormatter = rowConformance.cityFormatter
                
            case countryTextField:
                useFormatterDuringInput = rowConformance.countryUseFormatterDuringInput
                valueFormatter = rowConformance.countryFormatter
                
            default:
                break
            }
            
            if let formatter = valueFormatter where useFormatterDuringInput{
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>.alloc(1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?> = nil
                if formatter.getObjectValue(value, forString: textValue, errorDescription: errorDesc) {
                    
                    switch(textField){
                    case streetTextField:
                        row.value?.street = value.memory as? String
                    case stateTextField:
                        row.value?.state = value.memory as? String
                    case postalCodeTextField:
                        row.value?.postalCode = value.memory as? String
                    case cityTextField:
                        row.value?.city = value.memory as? String
                    case countryTextField:
                        row.value?.country = value.memory as? String
                    default:
                        break
                    }
                    
                    if var selStartPos = textField.selectedTextRange?.start {
                        let oldVal = textField.text
                        textField.text = row.displayValueFor?(row.value)
                        if let f = formatter as? FormatterProtocol {
                            selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text)
                        }
                        textField.selectedTextRange = textField.textRangeFromPosition(selStartPos, toPosition: selStartPos)
                    }
                    return
                }
            }
        }
        
        guard !textValue.isEmpty else {
            switch(textField){
            case streetTextField:
                row.value?.street = nil
            case stateTextField:
                row.value?.state = nil
            case postalCodeTextField:
                row.value?.postalCode = nil
            case cityTextField:
                row.value?.city = nil
            case countryTextField:
                row.value?.country = nil
            default:
                break
            }
            return
        }
        
        switch(textField){
        case streetTextField:
            row.value?.street = textValue
        case stateTextField:
            row.value?.state = textValue
        case postalCodeTextField:
            row.value?.postalCode = textValue
        case cityTextField:
            row.value?.city = textValue
        case countryTextField:
            row.value?.country = textValue
        default:
            break
        }
    }
    
    //MARK: TextFieldDelegate
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
    }
    
    public func textFieldDidEndEditing(textField: UITextField) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
    }
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
}


//MARK: PostalAddressRow

public class _PostalAddressRow<T: Equatable, Cell: CellType where Cell: BaseCell, Cell: TypedCellType, Cell: PostalAddressCellConformance, Cell.Value == T>: Row<T, Cell>, PostalAddressRowConformance, KeyboardReturnHandler {
    
    /// Configuration for the keyboardReturnType of this row
    public var keyboardReturnType : KeyboardReturnTypeConfiguration?
    
    /// The percentage of the cell that should be occupied by the postal address
    public var postalAddressPercentage: CGFloat?
    
    /// The textColor for the textField's placeholder
    public var placeholderColor : UIColor?
    
    /// The placeholder for the street textField
    public var streetPlaceholder : String?
    
    /// The placeholder for the state textField
    public var statePlaceholder : String?
    
    /// The placeholder for the zip textField
    public var postalCodePlaceholder : String?
    
    /// The placeholder for the city textField
    public var cityPlaceholder : String?
    
    /// The placeholder for the country textField
    public var countryPlaceholder : String?
    
    /// A formatter to be used to format the user's input for street
    public var streetFormatter: NSFormatter?
    
    /// A formatter to be used to format the user's input for state
    public var stateFormatter: NSFormatter?
    
    /// A formatter to be used to format the user's input for zip
    public var postalCodeFormatter: NSFormatter?
    
    /// A formatter to be used to format the user's input for city
    public var cityFormatter: NSFormatter?
    
    /// A formatter to be used to format the user's input for country
    public var countryFormatter: NSFormatter?
    
    /// If the formatter should be used while the user is editing the street.
    public var streetUseFormatterDuringInput: Bool
    
    /// If the formatter should be used while the user is editing the state.
    public var stateUseFormatterDuringInput: Bool
    
    /// If the formatter should be used while the user is editing the zip.
    public var postalCodeUseFormatterDuringInput: Bool
    
    /// If the formatter should be used while the user is editing the city.
    public var cityUseFormatterDuringInput: Bool
    
    /// If the formatter should be used while the user is editing the country.
    public var countryUseFormatterDuringInput: Bool
    
    public required init(tag: String?) {
        streetUseFormatterDuringInput = false
        stateUseFormatterDuringInput = false
        postalCodeUseFormatterDuringInput = false
        cityUseFormatterDuringInput = false
        countryUseFormatterDuringInput = false
        
        super.init(tag: tag)
    }
}

/// A PostalAddress valued row where the user can enter a postal address.
public final class PostalAddressRow: _PostalAddressRow<PostalAddress, PostalAddressCell<PostalAddress>>, RowType {
    public required init(tag: String? = nil) {
        super.init(tag: tag)
        onCellHighlight { cell, row  in
            let color = cell.textLabel?.textColor
            row.onCellUnHighlight { cell, _ in
                cell.textLabel?.textColor = color
            }
            cell.textLabel?.textColor = cell.tintColor
        }
    }
}
