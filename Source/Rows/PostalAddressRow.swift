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
    var streetFormatter: Formatter? { get set }
    
    var stateUseFormatterDuringInput: Bool { get set }
    var stateFormatter: Formatter? { get set }
    
    var postalCodeUseFormatterDuringInput: Bool { get set }
    var postalCodeFormatter: Formatter? { get set }
    
    var cityUseFormatterDuringInput: Bool { get set }
    var cityFormatter: Formatter? { get set }
    
    var countryUseFormatterDuringInput: Bool { get set }
    var countryFormatter: Formatter? { get set }
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
        separatorView.backgroundColor = .lightGray()
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
        separatorView.backgroundColor = .lightGray()
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
        separatorView.backgroundColor = .lightGray()
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
        separatorView.backgroundColor = .lightGray()
        return separatorView
    }()
    
    lazy public var countryTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    public var titleLabel : UILabel? {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.setContentHuggingPriority(500, for: .horizontal)
        textLabel?.setContentCompressionResistancePriority(1000, for: .horizontal)
        return textLabel
    }
    
    private var dynamicConstraints = [NSLayoutConstraint]()
    
    public required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil){ [weak self] notification in
            guard let me = self else { return }
            me.titleLabel?.removeObserver(me, forKeyPath: "text")
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil){ [weak self] notification in
            self?.titleLabel?.addObserver(self!, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil, queue: nil){ [weak self] notification in
            self?.setNeedsUpdateConstraints()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        streetTextField.delegate = nil
        streetTextField.removeTarget(self, action: nil, for: .allEvents)
        stateTextField.delegate = nil
        stateTextField.removeTarget(self, action: nil, for: .allEvents)
        postalCodeTextField.delegate = nil
        postalCodeTextField.removeTarget(self, action: nil, for: .allEvents)
        cityTextField.delegate = nil
        cityTextField.removeTarget(self, action: nil, for: .allEvents)
        countryTextField.delegate = nil
        countryTextField.removeTarget(self, action: nil, for: .allEvents)
        titleLabel?.removeObserver(self, forKeyPath: "text")
        imageView?.removeObserver(self, forKeyPath: "image")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    public override func setup() {
        super.setup()
        height = { 120 }
        selectionStyle = .none
        
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
        
        titleLabel?.addObserver(self, forKeyPath: "text", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
        imageView?.addObserver(self, forKeyPath: "image", options: NSKeyValueObservingOptions.old.union(.new), context: nil)
        
        streetTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), for: .editingChanged)
        stateTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), for: .editingChanged)
        postalCodeTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), for: .editingChanged)
        cityTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), for: .editingChanged)
        countryTextField.addTarget(self, action: #selector(PostalAddressCell.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    public override func update() {
        super.update()
        detailTextLabel?.text = nil
        if let title = row.title {
            streetTextField.textAlignment = .left
            streetTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
            
            stateTextField.textAlignment = .left
            stateTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
            
            postalCodeTextField.textAlignment = .left
            postalCodeTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
            
            cityTextField.textAlignment = .left
            cityTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
            
            countryTextField.textAlignment = .left
            countryTextField.clearButtonMode = title.isEmpty ? .whileEditing : .never
        } else{
            streetTextField.textAlignment =  .left
            streetTextField.clearButtonMode =  .whileEditing
            
            stateTextField.textAlignment =  .left
            stateTextField.clearButtonMode =  .whileEditing
            
            postalCodeTextField.textAlignment =  .left
            postalCodeTextField.clearButtonMode =  .whileEditing
            
            cityTextField.textAlignment =  .left
            cityTextField.clearButtonMode =  .whileEditing
            
            countryTextField.textAlignment =  .left
            countryTextField.clearButtonMode =  .whileEditing
        }
        
        streetTextField.delegate = self
        streetTextField.text = row.value?.street
        streetTextField.isEnabled = !row.isDisabled
        streetTextField.textColor = row.isDisabled ? .gray() : .black()
        streetTextField.font = .preferredFont(forTextStyle: UIFontTextStyleBody)
        streetTextField.autocorrectionType = .no
        streetTextField.autocapitalizationType = .words
        streetTextField.keyboardType = .asciiCapable
        
        stateTextField.delegate = self
        stateTextField.text = row.value?.state
        stateTextField.isEnabled = !row.isDisabled
        stateTextField.textColor = row.isDisabled ? .gray() : .black()
        stateTextField.font = .preferredFont(forTextStyle: UIFontTextStyleBody)
        stateTextField.autocorrectionType = .no
        stateTextField.autocapitalizationType = .words
        stateTextField.keyboardType = .asciiCapable
        
        postalCodeTextField.delegate = self
        postalCodeTextField.text = row.value?.postalCode
        postalCodeTextField.isEnabled = !row.isDisabled
        postalCodeTextField.textColor = row.isDisabled ? .gray() : .black()
        postalCodeTextField.font = .preferredFont(forTextStyle: UIFontTextStyleBody)
        postalCodeTextField.autocorrectionType = .no
        postalCodeTextField.autocapitalizationType = .allCharacters
        postalCodeTextField.keyboardType = .numbersAndPunctuation
        
        cityTextField.delegate = self
        cityTextField.text = row.value?.city
        cityTextField.isEnabled = !row.isDisabled
        cityTextField.textColor = row.isDisabled ? .gray() : .black()
        cityTextField.font = .preferredFont(forTextStyle: UIFontTextStyleBody)
        cityTextField.autocorrectionType = .no
        cityTextField.autocapitalizationType = .words
        cityTextField.keyboardType = .asciiCapable
        
        countryTextField.delegate = self
        countryTextField.text = row.value?.country
        countryTextField.isEnabled = !row.isDisabled
        countryTextField.textColor = row.isDisabled ? .gray() : .black()
        countryTextField.font = .preferredFont(forTextStyle: UIFontTextStyleBody)
        countryTextField.autocorrectionType = .no
        countryTextField.autocapitalizationType = .words
        countryTextField.keyboardType = .asciiCapable
        
        if let rowConformance = row as? PostalAddressRowConformance{
            if let placeholder = rowConformance.streetPlaceholder{
                streetTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    streetTextField.attributedPlaceholder = AttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.statePlaceholder{
                stateTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    stateTextField.attributedPlaceholder = AttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.postalCodePlaceholder{
                postalCodeTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    postalCodeTextField.attributedPlaceholder = AttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.cityPlaceholder{
                cityTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    cityTextField.attributedPlaceholder = AttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
                }
            }
            
            if let placeholder = rowConformance.countryPlaceholder{
                countryTextField.placeholder = placeholder
                
                if let color = rowConformance.placeholderColor {
                    countryTextField.attributedPlaceholder = AttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
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
    
    public override func cellBecomeFirstResponder(_ direction: Direction) -> Bool {
        return direction == .down ? streetTextField.becomeFirstResponder() : countryTextField.becomeFirstResponder()
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
                v.nextButton.isEnabled = true
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
            }
            else if stateTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.isEnabled = true
                v.nextButton.isEnabled = true
            }
            else if postalCodeTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.isEnabled = true
                v.nextButton.isEnabled = true
            } else if cityTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.nextButton.target = self
                v.nextButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.isEnabled = true
                v.nextButton.isEnabled = true
            }
            else if countryTextField.isFirstResponder() {
                v.previousButton.target = self
                v.previousButton.action = #selector(PostalAddressCell.internalNavigationAction(_:))
                v.previousButton.isEnabled = true
            }
            return v
        }
        return super.inputAccessoryView
    }
    
    func internalNavigationAction(_ sender: UIBarButtonItem) {
        guard let inputAccesoryView  = inputAccessoryView as? NavigationAccessoryView else { return }
        
        if streetTextField.isFirstResponder() {
            stateTextField.becomeFirstResponder()
        }
        else if stateTextField.isFirstResponder()  {
            let _ = sender == inputAccesoryView.previousButton ? streetTextField.becomeFirstResponder() : postalCodeTextField.becomeFirstResponder()
        }
        else if postalCodeTextField.isFirstResponder() {
            let _ = sender == inputAccesoryView.previousButton ? stateTextField.becomeFirstResponder() : cityTextField.becomeFirstResponder()
        }
        else if cityTextField.isFirstResponder() {
            let _ = sender == inputAccesoryView.previousButton ? postalCodeTextField.becomeFirstResponder() : countryTextField.becomeFirstResponder()
        }
        else if countryTextField.isFirstResponder() {
            cityTextField.becomeFirstResponder()
        }
    }
    
    
    public override func observeValue(forKeyPath keyPath: String?, of object: AnyObject?, change: [NSKeyValueChangeKey : AnyObject]?, context: UnsafeMutablePointer<Void>?) {
        if let obj = object, let keyPathValue = keyPath, let changeType = change?[NSKeyValueChangeKey.kindKey], ((obj === titleLabel && keyPathValue == "text") || (obj === imageView && keyPathValue == "image")) && changeType.uintValue == NSKeyValueChange.setting.rawValue {
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
        
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[streetTextField(\(textFieldHeight))]-\(textFieldMargin)-[streetSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[stateTextField(\(textFieldHeight))]-\(textFieldMargin)-[stateSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[postalCodeTextField(\(textFieldHeight))]-\(textFieldMargin)-[postalCodeSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[countryTextField]", options: [], metrics: nil, views: views)
        dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[streetTextField(\(textFieldHeight))]-\(textFieldMargin)-[streetSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[stateTextField(\(textFieldHeight))]-\(textFieldMargin)-[stateSeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[cityTextField(\(textFieldHeight))]-\(textFieldMargin)-[citySeparatorView(\(separatorViewHeight))]-\(textFieldMargin)-[countryTextField]", options: [], metrics: nil, views: views)
        
        if let label = titleLabel, let text = label.text, !text.isEmpty {
            dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(cellPadding)-[titleLabel]-\(cellPadding)-|", options: [], metrics: nil, views: ["titleLabel": label])
            dynamicConstraints.append(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
        }
        
        if let imageView = imageView, let _ = imageView.image {
            views["imageView"] = imageView
            if let titleLabel = titleLabel, let text = titleLabel.text, !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[streetTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[stateTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[countryTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[streetSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[stateSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[label]-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[streetTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[stateTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[countryTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[streetSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[stateSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
            }
        }
        else{
            
            if let titleLabel = titleLabel, let text = titleLabel.text, !text.isEmpty {
                views["label"] = titleLabel
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[streetTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[stateTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[countryTextField]-|", options: [], metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[streetSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[stateSeparatorView]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
                
                let multiplier = (row as? PostalAddressRowConformance)?.postalAddressPercentage ?? 0.3
                dynamicConstraints.append(NSLayoutConstraint(item: streetTextField, attribute: .width, relatedBy: (row as? PostalAddressRowConformance)?.postalAddressPercentage != nil ? .equal : .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: multiplier, constant: 0.0))
                dynamicConstraints.append(NSLayoutConstraint(item: stateTextField, attribute: .width, relatedBy: (row as? PostalAddressRowConformance)?.postalAddressPercentage != nil ? .equal : .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: multiplier, constant: 0.0))
                dynamicConstraints.append(NSLayoutConstraint(item: countryTextField, attribute: .width, relatedBy: (row as? PostalAddressRowConformance)?.postalAddressPercentage != nil ? .equal : .greaterThanOrEqual, toItem: contentView, attribute: .width, multiplier: multiplier, constant: 0.0))
            }
            else{
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[streetTextField]-|", options: .alignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stateTextField]-|", options: .alignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[postalCodeTextField(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[cityTextField]-|", options: [], metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[countryTextField]-|", options: .alignAllLeft, metrics: nil, views: views)
                
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[streetSeparatorView]-|", options: .alignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[stateSeparatorView]-|", options: .alignAllLeft, metrics: nil, views: views)
                dynamicConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-[postalCodeSeparatorView(\(postalCodeTextFieldWidth))]-\(textFieldMargin * 2.0)-[citySeparatorView]-|", options: [], metrics: nil, views: views)
            }
        }
        
        contentView.addConstraints(dynamicConstraints)
        super.updateConstraints()
    }
    
    public func textFieldDidChange(_ textField : UITextField){
		if row.baseValue == nil{
			row.baseValue = PostalAddress()
		}
		
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
            var valueFormatter: Formatter?
			
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
            
            if let formatter = valueFormatter, useFormatterDuringInput{
                let value: AutoreleasingUnsafeMutablePointer<AnyObject?> = AutoreleasingUnsafeMutablePointer<AnyObject?>.init(UnsafeMutablePointer<T>(allocatingCapacity: 1))
                let errorDesc: AutoreleasingUnsafeMutablePointer<NSString?>? = nil
                if formatter.getObjectValue(value, for: textValue, errorDescription: errorDesc) {
                    
                    switch(textField){
                    case streetTextField:
                        row.value?.street = value.pointee as? String
                    case stateTextField:
                        row.value?.state = value.pointee as? String
                    case postalCodeTextField:
                        row.value?.postalCode = value.pointee as? String
                    case cityTextField:
                        row.value?.city = value.pointee as? String
                    case countryTextField:
                        row.value?.country = value.pointee as? String
                    default:
                        break
                    }
                    
                    if var selStartPos = textField.selectedTextRange?.start {
                        let oldVal = textField.text
                        textField.text = row.displayValueFor?(row.value)
                        if let f = formatter as? FormatterProtocol {
                            selStartPos = f.getNewPosition(forPosition: selStartPos, inTextInput: textField, oldValue: oldVal, newValue: textField.text)
                        }
                        textField.selectedTextRange = textField.textRange(from: selStartPos, to: selStartPos)
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
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        formViewController()?.beginEditing(self)
        formViewController()?.textInputDidBeginEditing(textField, cell: self)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        formViewController()?.endEditing(self)
        formViewController()?.textInputDidEndEditing(textField, cell: self)
        textFieldDidChange(textField)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldReturn(textField, cell: self) ?? true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldBeginEditing(textField, cell: self) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldClear(textField, cell: self) ?? true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return formViewController()?.textInputShouldEndEditing(textField, cell: self) ?? true
    }
}


//MARK: PostalAddressRow

public class _PostalAddressRow<Cell: CellType where Cell: BaseCell, Cell: PostalAddressCellConformance>: Row<Cell>, PostalAddressRowConformance, KeyboardReturnHandler {
    
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
    public var streetFormatter: Formatter?
    
    /// A formatter to be used to format the user's input for state
    public var stateFormatter: Formatter?
    
    /// A formatter to be used to format the user's input for zip
    public var postalCodeFormatter: Formatter?
    
    /// A formatter to be used to format the user's input for city
    public var cityFormatter: Formatter?
    
    /// A formatter to be used to format the user's input for country
    public var countryFormatter: Formatter?
    
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
public final class PostalAddressRow: _PostalAddressRow<PostalAddressCell<PostalAddress>>, RowType {
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
