//  ValidationsTests.swift
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

import XCTest
@testable import Eureka

class ValidationsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testadd() {
        let textRow = TextRow()
        textRow.add(Required(), "")
        textRow.add(RuleEmail(), "")
        XCTAssertEqual(textRow.rules.count, 2)

        textRow.removeAllRules()
        XCTAssertEqual(textRow.rules.count, 0)
    }

    func testRemoveRules() {
        let textRow = TextRow()
        textRow.add(Required(), "")
        textRow.add(RuleEmail(), "")
        XCTAssertEqual(textRow.rules.count, 2)

        textRow.removeAllRules()
        XCTAssertEqual(textRow.rules.count, 0)

        let requiredRule = Required<String>()
        textRow.add(requiredRule, "", id: "required_rule_id")
        textRow.add(RuleEmail(), "")
        XCTAssertEqual(textRow.rules.count, 2)

        textRow.removeRule(by: "required_rule_id")
        XCTAssertEqual(textRow.rules.count, 1)
    }

    func testBlurred() {
        let formVC = FormViewController(style: .grouped)
        let row = TextRow()
        row.add(Required(), "")
        XCTAssertFalse(row.wasBlurred)
        formVC.form +++ row
        formVC.endEditing(of: row.cell)
        XCTAssertTrue(row.wasBlurred)
    }

    func testUsed() {
        let formVC = FormViewController(style: .grouped)
        let row = TextRow()
        row.add(Required(), "The value is required")
        XCTAssertFalse(row.wasChanged)
        row.value = "Hi!"
        XCTAssertFalse(row.wasChanged) // because it's not added in the form yet
        formVC.form +++ row
        row.value = "Eureka!"
        XCTAssertTrue(row.wasChanged) // because it was added to the form
    }

    func testRequired() {
        let form = Form()
        let textRow = TextRow()
        form +++ Section() <<< textRow
        textRow.add(Required(), "The value is required")

        textRow.value = nil
        XCTAssertTrue(textRow.validate().count == 1, "errors collection must contains Required rule error")

        textRow.value = "Hi1"
        XCTAssertTrue(textRow.validate().count == 0, "errors collection must not contains Required rule error")
    }

    func testRuleEmail() {
        let form = Form()
        let emailRule = RuleEmail()

        XCTAssertTrue(emailRule.allows(nil, in: form))
        XCTAssertTrue(emailRule.allows("", in: form))
        XCTAssertTrue(emailRule.allows("a@b.com", in: form))

        XCTAssertFalse(emailRule.allows("abc", in: form))
        XCTAssertFalse(emailRule.allows("abc.com", in: form))
        XCTAssertFalse(emailRule.allows("abc@assa", in: form))
    }

    func testMaxLengthRule() {
        let form = Form()
        let maxLengthRule = Length(shorterThan: 11)
        XCTAssertTrue(maxLengthRule.allows(nil, in: form))
        XCTAssertTrue(maxLengthRule.allows("123456789", in: form))
        XCTAssertFalse(maxLengthRule.allows("12345678910", in: form))
    }

    func testMinLengthRule() {
        let form = Form()
        let minimumLengthRule = Length(longerThan: 4)
        XCTAssertTrue(minimumLengthRule.allows(nil, in: form))
        XCTAssertTrue(minimumLengthRule.allows("12345", in: form))
        XCTAssertFalse(minimumLengthRule.allows("1234", in: form))
    }
    
    func testExactLengthRule() {
        let form = Form()

        let exactLengthRule = Length(exactly: 3)
        XCTAssertTrue(exactLengthRule.allows(nil, in: form))
        XCTAssertTrue(exactLengthRule.allows("123", in: form))
        XCTAssertFalse(exactLengthRule.allows("1234", in: form))
    }
    
    func testRuleURL() {
        let form = Form()
        let urlRule = ValidURL()
        
        XCTAssertTrue(urlRule.allows(nil, in: form))
        XCTAssertTrue(urlRule.allows(URL(string: ""), in: form))
        XCTAssertTrue(urlRule.allows(URL(string: "http://example.com"), in: form))
        XCTAssertTrue(urlRule.allows(URL(string: "https://example.com/path/to/file.ext?key=value#location"), in: form))
        
        XCTAssertFalse(urlRule.allows(URL(string: "example.com"), in: form))
        XCTAssertFalse(urlRule.allows(URL(string: "http://"), in: form))
    }
}
