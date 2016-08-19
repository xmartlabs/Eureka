//
//  DictionaryMessageRow.swift
//  Eureka
//
//  Created by Jingang Liu on 8/16/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//
import Foundation

// MARK: -- Message Row

public class DictionaryMessageRow : Row<DictionaryMessage,DictionaryMessageCell>, MessageRow, RowType {
    weak var mainRow: BaseRow?
    public var cellBackgroundColor : UIColor? {
        didSet {
            cell.cellBackgroundColor = cellBackgroundColor
        }
    }
    public var cellTextColor : UIColor? {
        didSet {
            cell.cellTextColor = cellTextColor
        }
    }
    
    required public init(tag: String?) {
        super.init(tag: tag)
        cellStyle = .Default
    }
    convenience public init() {
        self.init(nil)
    }
}

// MARK: -- Message Cell

public class DictionaryMessageCell : Cell<DictionaryMessage>, CellType {
    public var cellBackgroundColor : UIColor? {
        didSet {
            style()
        }
    }
    public var cellTextColor : UIColor? {
        didSet {
            style()
        }
    }
    // MARK: - Initializer
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    // MARK: - Public Properties
    var message : DictionaryMessage? {
        return messageRow?.value
    }
    
    public lazy var messageLabel : UILabel = { [unowned self] in
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(label)
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[label]-0-|", options: [], metrics: nil, views: ["label": label]))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-20-[label]-20-|", options: [], metrics: nil, views: ["label": label]))
        return label
        }()
    
    // MARK: - Private Properties
    private lazy var hideCellConstraint : NSLayoutConstraint = { [unowned self] in
        let constraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        constraint.priority = UILayoutPriorityRequired
        return constraint
        }()
    private var messageRow : DictionaryMessageRow? {
        return row as? DictionaryMessageRow
    }
    
    // MARK: - Overriding methods
    public override func setup() {
        super.setup()
        contentView.clipsToBounds = true
        self.clipsToBounds = true
        selectionStyle = .None
        
        style() // using messageLabel will add it to `self`.
    }
    
    public override func update() {
        style()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        messageLabel.text = self.message?.concatenatedMessage()
        if self.message?.concatenatedMessage().characters.count ?? 0 == 0 {
            self.addConstraint(hideCellConstraint)
            self.hidden = true
        }
        else {
            self.removeConstraint(hideCellConstraint)
            self.hidden = false
        }
    }
    
    private func style() {
        messageLabel.textColor = cellTextColor ?? UIColor.whiteColor()
        self.backgroundColor = cellBackgroundColor ?? UIColor.redColor()
        // Hide seperator
        self.separatorInset = UIEdgeInsetsMake(0, self.bounds.size.width, 0, 0);
    }
}

// MARK: -- Message Type

public class DictionaryMessage : Equatable {
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
    public subscript(key:String) -> String? {
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