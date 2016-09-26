//  ExampleUITests.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2016 Xmartlabs ( http://xmartlabs.com )
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

class FieldRowUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDecimalRowWithFormatterDuringInput() {
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        // navigte to Rows view controller
        tablesQuery.cells.staticTexts["Rows"].tap()
        
        
        // get Decimal row text field
        let decimalRowTextFieldElement = tablesQuery.cells.containing(.staticText, identifier:"DecimalRow").children(matching: .textField).element
        
        // chack initial value
        XCTAssertEqual(decimalRowTextFieldElement.value as? String, decimalFormatter.editingString(for: Double(5)), "Initial Decimal Row value is wrong, should be 5,00 or 5.00")
        
        
        // check that delete keyboard worlks properly
        decimalRowTextFieldElement.tap()
        let deleteKey = app.keys["Delete"]
        deleteKey.tap()
        XCTAssertEqual(decimalRowTextFieldElement.value as? String, decimalFormatter.editingString(for: Double(0.5)), "Decimal Row value is wrong, should be 0,50 or 0.50")
        
        // check empty value
        for _ in 1...2 { deleteKey.tap() }
        //should be 0,00
        XCTAssertEqual(decimalRowTextFieldElement.value as? String, decimalFormatter.editingString(for: Double(0)), "Decimal Row value is wrong, should be 0,00 or 0.00")
        
        
        // check result when entering digits
        decimalRowTextFieldElement.typeText("5678")
        // Should be 56,78
        XCTAssertEqual(decimalRowTextFieldElement.value as? String, decimalFormatter.editingString(for: Double(56.78)), "Decimal Row value is wrong, should be 56,78 or 56.78")
        
        // one more check...
        decimalRowTextFieldElement.typeText("9")
        // SHOULD BE 567,89
        XCTAssertEqual(decimalRowTextFieldElement.value as? String, decimalFormatter.editingString(for: Double(567.89)), "Decimal Row value is wrong, should be 567,89 or 567.89")
    }
    
    
    func testIntRowWithFormatterButNotDUringInput() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.cells.staticTexts["Rows"].tap()
        
        let textField = tablesQuery.cells.containing(.staticText, identifier:"IntRow").children(matching: .textField).element
        
        // chack initial value
        XCTAssertEqual(textField.value as? String, intFormatter.string(for: Int(2015)), "Initial Int Row value is wrong, should be 2,015 or 2.015")
        
        textField.tap()
        // should be 2015
        XCTAssertEqual(textField.value as? String, "2015", "Editing Initial Int Row value is wrong, should be 2015")
    
        let deleteKey = app.keys["Delete"]
        
        deleteKey.tap()
        // sould be 201
        XCTAssertEqual(textField.value as? String, intFormatter.string(for: Int(201)), "Int Row value is wrong, should be 201")
        
        deleteKey.tap()
        deleteKey.tap()
        deleteKey.tap()
        // should be empty
        XCTAssertEqual(textField.value as? String, "", "Int Row value is wrong, should be \"\"")
        
        
        textField.typeText("1")
        // should be 1
        XCTAssertEqual(textField.value as? String, intFormatter.string(for: Int(1)), "Int Row value is wrong, should be 1")
        
        
        textField.typeText("2345")
        // regign firest responder
        app.toolbars.buttons["Done"].tap()
        
    
        // should be 12,345
        XCTAssertEqual(textField.value as? String, intFormatter.string(for: Int(12345)), "Int Row value is wrong, should be 12,345 or 12.345")
    }
    
    
    
    //MARK: Helpers

    lazy var decimalFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 2
        return numberFormatter
    }()
    
    lazy var intFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale.current
        numberFormatter.numberStyle = .decimal
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 0
        return numberFormatter
    }()

    
}
