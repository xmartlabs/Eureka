//
//  ValidationsTests.swift
//  Eureka
//
//  Created by Martin Barreto on 9/14/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

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
    
    
    func testAddRule() {
        let textRow = TextRow()
        textRow.addRule(rule: RuleRequired())
        textRow.addRule(rule: RuleEmail())
        XCTAssertEqual(textRow.rules.count, 2)
        
        textRow.removeAllRules()
        XCTAssertEqual(textRow.rules.count, 0)
    }
    
    
    func testRuleSet() {
        
        
        var ruleSet = RuleSet<String>()
        ruleSet.addRule(rule: RuleRequired())
        ruleSet.addRule(rule: RuleEmail())
        XCTAssertEqual(ruleSet.rules.count, 2)
        
        let textRow = TextRow()
        textRow.addRuleSet(set: ruleSet)
        
        XCTAssertEqual(textRow.rules.count, 2)
    }
    
    func testRemoveRules(){
        let textRow = TextRow()
        textRow.addRule(rule: RuleRequired())
        textRow.addRule(rule: RuleEmail())
        XCTAssertEqual(textRow.rules.count, 2)
        
        textRow.removeAllRules()
        XCTAssertEqual(textRow.rules.count, 0)
        
        var requiredRule = RuleRequired<String>()
        requiredRule.id = "required_rule_id"
        textRow.addRule(rule: requiredRule)
        textRow.addRule(rule: RuleEmail())
        XCTAssertEqual(textRow.rules.count, 2)
        
        textRow.removeRuleWith(identifier: "required_rule_id")
        XCTAssertEqual(textRow.rules.count, 1)
        
    }
    
    func testRequired() {
        
        let textRow = TextRow()
        textRow.addRule(rule: RuleRequired())
        
        textRow.value = nil
        XCTAssertTrue(textRow.validate().count == 1, "errors collection must contains Required rule error")
        
        textRow.value = "Hi1"
        XCTAssertTrue(textRow.validate().count == 0, "errors collection must not contains Required rule error")
    }
    
}
