//  RowByTagTests.swift
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

class RowByTagTests: XCTestCase {

    var form: Form!
    
    override func setUp() {
        super.setUp()
        
        form = Form()
        let section = Section()
        
        form +++ section
        
        section <<< LabelRow("LabelRow")
        section <<< ButtonRow("ButtonRow")
        section <<< ActionSheetRow<String>("ActionSheetRow")
        section <<< AlertRow<Int>("AlertRow")
        section <<< PushRow<URL>("PushRow")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRowByTag() {
        
        let labelRow: LabelRow? = form.rowBy(tag: "LabelRow")
        XCTAssertNotNil(labelRow)
        
        let buttonRow: ButtonRow? = form.rowBy(tag: "ButtonRow")
        XCTAssertNotNil(buttonRow)
        
        let actionSheetRow: ActionSheetRow<String>? = form.rowBy(tag: "ActionSheetRow")
        XCTAssertNotNil(actionSheetRow)
        
        let alertRow: AlertRow<Int>? = form.rowBy(tag: "AlertRow")
        XCTAssertNotNil(alertRow)

        let pushRow: PushRow<URL>? = form.rowBy(tag: "PushRow")
        XCTAssertNotNil(pushRow)
    }
    
}
