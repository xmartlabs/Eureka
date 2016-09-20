//
//  DictionaryMessageRow.swift
//  Eureka
//
//  Created by Jingang Liu on 8/16/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//
import Foundation

// MARK: -- Message Row

public final class DictionaryMessageRow : Row<DictionaryMessageCell>, MessageRow, RowType {
    weak public var mainRow: BaseRow?
    open var cellBackgroundColor : UIColor? {
        didSet {
            cell.cellBackgroundColor = cellBackgroundColor
        }
    }
    open var cellTextColor : UIColor? {
        didSet {
            cell.cellTextColor = cellTextColor
        }
    }

    required public init(tag: String?) {
        super.init(tag: tag)
        cellStyle = .default
    }
    convenience public init() {
        self.init(nil)
    }
}

// MARK: -- Message Cell

open class DictionaryMessageCell : Cell<DictionaryMessage>, CellType {
    
    open static var labelInsets : UIEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
    open var cellBackgroundColor : UIColor? {
        didSet {
            style()
        }
    }
    open var cellTextColor : UIColor? {
        didSet {
            style()
        }
    }
    // MARK: - Initializer
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Properties
    var message : DictionaryMessage? {
        return messageRow?.value
    }
    
    open lazy var messageLabel : UILabel = { [unowned self] in
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(type(of: self).labelInsets.top)-[label]-\(type(of: self).labelInsets.bottom)-|", options: [], metrics: nil, views: ["label": label]))
        self.contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(type(of: self).labelInsets.left)-[label]-\(type(of: self).labelInsets.right)-|", options: [], metrics: nil, views: ["label": label]))
        return label
        }()
    
    // MARK: - Private Properties
    fileprivate lazy var hideCellConstraint : NSLayoutConstraint = { [unowned self] in
        let constraint = NSLayoutConstraint(item: self.contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        constraint.priority = UILayoutPriorityRequired
        return constraint
        }()
    fileprivate var messageRow : DictionaryMessageRow? {
        return row as? DictionaryMessageRow
    }
    
    // MARK: - Overriding methods
    open override func setup() {
        super.setup()
        contentView.clipsToBounds = true
        self.clipsToBounds = true
        selectionStyle = .none
        
        style() // using messageLabel will add it to `self`.
    }
    
    open override func update() {
        style()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        messageLabel.text = self.message?.concatenatedMessage()
        if self.message?.concatenatedMessage().characters.count ?? 0 == 0 {
            contentView.addConstraint(hideCellConstraint)
            self.isHidden = true
        }
        else {
            contentView.removeConstraint(hideCellConstraint)
            self.isHidden = false
        }
    }
    
    fileprivate func style() {
        messageLabel.textColor = cellTextColor ?? UIColor.white
        self.backgroundColor = cellBackgroundColor ?? UIColor.red
        // Hide seperator
        self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }
}

// MARK: -- Message Type

open class DictionaryMessage : Equatable {
    var messages:[String:String] = [:]
    func concatenatedMessage() -> String {
        var concatenatedString = ""
        var keys = Array(messages.keys)
        for i in 0 ..< keys.count {
            if i != 0 {
                concatenatedString += "\n"
            }
            concatenatedString += messages[keys[i]] ?? ""
        }
        return concatenatedString
    }
    public init(messages:[String:String]) {
        self.messages = messages
    }
    open subscript(key:String) -> String? {
        get {
            return messages[key]
        }
        set {
            messages[key] = newValue
        }
    }
}
public func == (lhs:DictionaryMessage, rhs:DictionaryMessage) -> Bool {
    return lhs.messages == rhs.messages
}
