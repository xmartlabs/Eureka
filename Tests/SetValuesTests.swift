//  SetValuesTests.swift
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
@testable import Eureka

class SetValuesTests: XCTestCase {

    var form: Form!

    override func setUp() {
        super.setUp()

        form = Form()
        let section = Section()

        form +++ section

        section <<< IntRow("IntRow")
        section <<< TextRow("TextRow")
        section <<< ActionSheetRow<String>("ActionSheetRow")
        section <<< AlertRow<Int>("AlertRow")
        section <<< PushRow<Float>("PushRow")

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSetValues() {
        let intRowValue: Int = 4
        let intRowNilValue: Int? = nil
        let textRowValue = "textRow value!!!"
        let actionSheetRowValue = "ActionSheetRow value!!!"
        let alertRowValue: Int = 33
        let pushRowValue: Float = 0.7

        form.setValues(["IntRow": intRowValue, "TextRow": textRowValue, "ActionSheetRow": actionSheetRowValue, "AlertRow": alertRowValue, "PushRow": pushRowValue, "No existing tag": 2.0])

        let intRow: IntRow? = form.rowBy(tag: "IntRow")
        XCTAssertEqual(intRow?.value, intRowValue)

        let textRow: TextRow? = form.rowBy(tag: "TextRow")
        XCTAssertEqual(textRow?.value, textRowValue)

        let actionSheetRow: ActionSheetRow<String>? = form.rowBy(tag: "ActionSheetRow")
        XCTAssertEqual(actionSheetRow?.value, actionSheetRowValue)

        let alertRow: AlertRow<Int>? = form.rowBy(tag: "AlertRow")
        XCTAssertNotNil(alertRow)
        XCTAssertEqual(alertRow!.value, alertRowValue)

        var pushRow: PushRow<Float>? = form.rowBy(tag: "PushRow")
        XCTAssertNotNil(pushRow)
        XCTAssertEqual(pushRow!.value, pushRowValue)

        form.setValues(["PushRow": Float(1.0), "No existing tag": 2.0])
        pushRow = form.rowBy(tag: "PushRow")
        XCTAssertNotNil(pushRow)
        XCTAssertEqual(pushRow!.value, Float(1.0))

        form.setValues(["IntRow": intRowNilValue])
        XCTAssertNil(intRow?.value)
    }
    
    // The reset value stores the default value of the row. The reset value should not change along with the value property, and when you reset the row value, it should set the value property to the reset value.
    func testSetAndResetValues() {
        let intValue: Int = 4
        let intDefaultvalue: Int = 0
        let stringValue = "String Value!"
        let stringDefaultValue = "String Default Value!"
        let floatValue: Float = 0.7
        let floatDefaultValue: Float = 1.4
        
        let intRow: IntRow? = form.rowBy(tag: "IntRow")
        XCTAssertNotNil(intRow)
        intRow?.resetValue = intDefaultvalue
        XCTAssertEqual(intRow?.resetValue, intDefaultvalue)
        intRow?.value = intValue
        intRow?.resetRowValue()
        XCTAssertEqual(intRow?.value, intDefaultvalue)
        
        let textRow: TextRow? = form.rowBy(tag: "TextRow")
        XCTAssertNotNil(textRow)
        textRow?.resetValue = stringDefaultValue
        XCTAssertEqual(textRow?.resetValue, stringDefaultValue)
        textRow?.value = stringValue
        textRow?.resetRowValue()
        XCTAssertEqual(textRow?.value, stringDefaultValue)
        
        let actionSheetRow: ActionSheetRow<String>? = form.rowBy(tag: "ActionSheetRow")
        XCTAssertNotNil(actionSheetRow)
        actionSheetRow?.resetValue = stringDefaultValue
        XCTAssertEqual(actionSheetRow?.resetValue, stringDefaultValue)
        actionSheetRow?.value = stringValue
        actionSheetRow?.resetRowValue()
        XCTAssertEqual(actionSheetRow?.value, stringDefaultValue)
        
        let alertRow: AlertRow<Int>? = form.rowBy(tag: "AlertRow")
        XCTAssertNotNil(alertRow)
        alertRow?.resetValue = intDefaultvalue
        XCTAssertEqual(alertRow?.resetValue, intDefaultvalue)
        alertRow?.value = intValue
        alertRow?.resetRowValue()
        XCTAssertEqual(alertRow?.value, intDefaultvalue)
        
        let pushRow: PushRow<Float>? = form.rowBy(tag: "PushRow")
        XCTAssertNotNil(pushRow)
        pushRow?.resetValue = floatDefaultValue
        XCTAssertEqual(pushRow?.resetValue, floatDefaultValue)
        pushRow?.value = floatValue
        pushRow?.resetRowValue()
        XCTAssertEqual(pushRow?.value, floatDefaultValue)
        
    }
}
