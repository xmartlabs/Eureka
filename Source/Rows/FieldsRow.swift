//  FieldsRow.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
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

import Foundation

open class TextCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .sentences
        textField.keyboardType = .default
    }
}

open class IntCell: _FieldCell<Int>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .default
        textField.autocapitalizationType = .none
        textField.keyboardType = .numberPad
    }
}

open class PhoneCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.keyboardType = .phonePad
    }
}

open class NameCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .words
        textField.keyboardType = .asciiCapable
    }
}

open class EmailCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
    }
}

open class PasswordCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
        textField.isSecureTextEntry = true
    }
}

open class DecimalCell: _FieldCell<Double>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.keyboardType = .decimalPad
    }
}

open class URLCell: _FieldCell<URL>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .URL
    }
}

open class TwitterCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .twitter
    }
}

open class AccountCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func setup() {
        super.setup()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.keyboardType = .asciiCapable
    }
}

open class ZipCodeCell: _FieldCell<String>, CellType {

    required public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func update() {
        super.update()
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .allCharacters
        textField.keyboardType = .numbersAndPunctuation
    }
}

open class _TextRow: FieldRow<TextCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _IntRow: FieldRow<IntCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        formatter = numberFormatter
    }
}

open class _PhoneRow: FieldRow<PhoneCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _NameRow: FieldRow<NameCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _EmailRow: FieldRow<EmailCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _PasswordRow: FieldRow<PasswordCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _DecimalRow: FieldRow<DecimalCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        formatter = numberFormatter
    }
}

open class _URLRow: FieldRow<URLCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _TwitterRow: FieldRow<TwitterCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _AccountRow: FieldRow<AccountCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

open class _ZipCodeRow: FieldRow<ZipCodeCell> {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter arbitrary text.
public final class TextRow: _TextRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter names. Biggest difference to TextRow is that it autocapitalization is set to Words.
public final class NameRow: _NameRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter secure text.
public final class PasswordRow: _PasswordRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter an email address.
public final class EmailRow: _EmailRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter a twitter username.
public final class TwitterRow: _TwitterRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter a simple account username.
public final class AccountRow: _AccountRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter a zip code.
public final class ZipCodeRow: _ZipCodeRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row where the user can enter an integer number.
public final class IntRow: _IntRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row where the user can enter a decimal number.
public final class DecimalRow: _DecimalRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A row where the user can enter an URL. The value of this row will be a URL.
public final class URLRow: _URLRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}

/// A String valued row where the user can enter a phone number.
public final class PhoneRow: _PhoneRow, RowType {
    required public init(tag: String?) {
        super.init(tag: tag)
    }
}
