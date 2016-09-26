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
        textRow.add(rule: RuleRequired())
        textRow.add(rule: RuleEmail())
        XCTAssertEqual(textRow.rules.count, 2)
        
        textRow.removeAllRules()
        XCTAssertEqual(textRow.rules.count, 0)
    }
    
    
    func testRuleSet() {
        
        
        var ruleSet = RuleSet<String>()
        ruleSet.add(rule: RuleRequired())
        ruleSet.add(rule: RuleEmail())
        XCTAssertEqual(ruleSet.rules.count, 2)
        
        let textRow = TextRow()
        textRow.add(ruleSet: ruleSet)
        
        XCTAssertEqual(textRow.rules.count, 2)
    }
    
    func testRemoveRules(){
        let textRow = TextRow()
        textRow.add(rule: RuleRequired())
        textRow.add(rule: RuleEmail())
        XCTAssertEqual(textRow.rules.count, 2)
        
        textRow.removeAllRules()
        XCTAssertEqual(textRow.rules.count, 0)
        
        var requiredRule = RuleRequired<String>()
        requiredRule.id = "required_rule_id"
        textRow.add(rule: requiredRule)
        textRow.add(rule: RuleEmail())
        XCTAssertEqual(textRow.rules.count, 2)
        
        textRow.remove(ruleWithIdentifier: "required_rule_id")
        XCTAssertEqual(textRow.rules.count, 1)
    }

    
    func testBlurred() {
        let formVC = FormViewController(style: .grouped)
        let row = TextRow()
        row.add(rule: RuleRequired())
        XCTAssertFalse(row.wasBlurred)
        formVC.form +++ row
        formVC.endEditing(of: row.cell)
        XCTAssertTrue(row.wasBlurred)
    }
    
    func testUsed(){
        let formVC = FormViewController(style: .grouped)
        let row = TextRow()
        row.add(rule: RuleRequired())
        XCTAssertFalse(row.wasChanged)
        row.value = "Hi!"
        XCTAssertFalse(row.wasChanged) // because it's not added in the form yet
        formVC.form +++ row
        row.value = "Eureka!"
        XCTAssertTrue(row.wasChanged) // because it was added to the form
    }

    
    func testRequired() {
        
        let textRow = TextRow()
        textRow.add(rule: RuleRequired())
        
        textRow.value = nil
        XCTAssertTrue(textRow.validate().count == 1, "errors collection must contains Required rule error")
        
        textRow.value = "Hi1"
        XCTAssertTrue(textRow.validate().count == 0, "errors collection must not contains Required rule error")
    }
    
    
    func testRuleEmail() {
        let emailRule = RuleEmail()
        
        XCTAssertNil(emailRule.isValid(value: nil))
        XCTAssertNil(emailRule.isValid(value: ""))
        XCTAssertNil(emailRule.isValid(value: "a@b.com"))
        
        XCTAssertNotNil(emailRule.isValid(value: "abc"))
        XCTAssertNotNil(emailRule.isValid(value: "abc.com"))
        XCTAssertNotNil(emailRule.isValid(value: "abc@assa"))
        
    }
    

    
}
