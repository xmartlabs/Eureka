//
//  PlainTextMessageRowCell.swift
//  Eureka
//
//  Created by Jingang Liu on 8/16/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import Foundation

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
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[label]-0-|", options: [], metrics: nil, views: ["label": label]))
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
}