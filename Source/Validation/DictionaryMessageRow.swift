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
    private lazy var hideLabelConstraint : NSLayoutConstraint = { [unowned self] in
        let label = self.messageLabel
        return NSLayoutConstraint(item: label, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        }()
    private var messageRow : DictionaryMessageRow? {
        return row as? DictionaryMessageRow
    }
    
    // MARK: - Overriding methods
    public override func setup() {
        super.setup()
        selectionStyle = .None
        update() // using messageLabel will add it to `self`.
    }
    
    public override func update() {
        style()
        textLabel?.text = nil
        detailTextLabel?.text = nil
        messageLabel.text = self.message?.concatenatedMessage()
        if self.message == nil {
            messageLabel.addConstraint(hideLabelConstraint)
        }
        else {
            messageLabel.removeConstraint(hideLabelConstraint)
        }
    }
    
    private func style() {
        messageLabel.textColor = UIColor.whiteColor()
        self.backgroundColor = UIColor.redColor()
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