//  CallbacksTests.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
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

class CallbacksTests: XCTestCase {
    
    var formVC = FormViewController()
    
    override func setUp() {
        super.setUp()
        // load the view to test the cells
        formVC.view.frame = CGRectMake(0, 0, 375, 3000)
        formVC.tableView?.frame = formVC.view.frame
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testOnChange() {
        onChangeTest(TextRow(), value: "text")
        onChangeTest(IntRow(), value: 33)
        onChangeTest(DecimalRow(), value: 35.7)
        onChangeTest(URLRow(), value: NSURL(string: "http://xmartlabs.com")!)
        onChangeTest(DateRow(), value: NSDate().dateByAddingTimeInterval(100))
        onChangeTest(DateInlineRow(), value: NSDate().dateByAddingTimeInterval(100))
    }
    
    
    func testDefaultInitializers() {
        defaultInitializerTest(TextRow())
        defaultInitializerTest(IntRow())
        defaultInitializerTest(DecimalRow())
        defaultInitializerTest(URLRow())
        defaultInitializerTest(DateRow())
        defaultInitializerTest(DateInlineRow())
    }
    
    private func onChangeTest<Row, Value where  Row: BaseRow, Row : RowType, Row.Value == Row.Cell.Value, Value == Row.Value>(row:Row, value:Value){
        var onChangeWasInvoked = false
        row.onChange { row in
            onChangeWasInvoked = true
        }
        formVC.form  +++ Section() <<< row
        row.value = value
        XCTAssertTrue(onChangeWasInvoked)
    }
    
    private func defaultInitializerTest<Row where Row: BaseRow, Row : RowType, Row.Value == Row.Cell.Value>(row:Row){
        var defaultInitWasInvoked = false
        Row.defaultRowInitializer = { row in
            defaultInitWasInvoked = true
        }
        formVC.form +++= Row.init() { _ in }
        XCTAssertTrue(defaultInitWasInvoked)
    }
}
