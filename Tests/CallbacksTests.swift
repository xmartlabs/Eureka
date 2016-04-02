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
        onChangeTest(PopoverSelectorRow<String>(), value: "text")
        onChangeTest(PostalAddressRow(), value: PostalAddress(street: "a", state: "b", postalCode: "c", city: "d", country: "e"))
        onChangeTest(SliderRow(), value: 5.0)
        onChangeTest(StepperRow(), value: 2.5)
    }
    
    func testCellSetup() {
        cellSetupTest(TextRow())
        cellSetupTest(IntRow())
        cellSetupTest(DecimalRow())
        cellSetupTest(URLRow())
        cellSetupTest(DateRow())
        cellSetupTest(DateInlineRow())
        cellSetupTest(PopoverSelectorRow<String>())
        cellSetupTest(PostalAddressRow())
        cellSetupTest(SliderRow())
        cellSetupTest(StepperRow())
    }
    
    func testCellUpdate() {
        cellUpdateTest(TextRow())
        cellUpdateTest(IntRow())
        cellUpdateTest(DecimalRow())
        cellUpdateTest(URLRow())
        cellUpdateTest(DateRow())
        cellUpdateTest(DateInlineRow())
        cellUpdateTest(PopoverSelectorRow<String>())
        cellUpdateTest(PostalAddressRow())
        cellUpdateTest(SliderRow())
        cellUpdateTest(StepperRow())
    }
    
    func testDefaultCellSetup() {
        defaultCellSetupTest(TextRow())
        defaultCellSetupTest(IntRow())
        defaultCellSetupTest(DecimalRow())
        defaultCellSetupTest(URLRow())
        defaultCellSetupTest(DateRow())
        defaultCellSetupTest(DateInlineRow())
        defaultCellSetupTest(PopoverSelectorRow<String>())
        defaultCellSetupTest(PostalAddressRow())
        defaultCellSetupTest(SliderRow())
        defaultCellSetupTest(StepperRow())
    }
    
    func testDefaultCellUpdate() {
        defaultCellUpdateTest(TextRow())
        defaultCellUpdateTest(IntRow())
        defaultCellUpdateTest(DecimalRow())
        defaultCellUpdateTest(URLRow())
        defaultCellUpdateTest(DateRow())
        defaultCellUpdateTest(DateInlineRow())
        defaultCellUpdateTest(PopoverSelectorRow<String>())
        defaultCellUpdateTest(PostalAddressRow())
        defaultCellUpdateTest(SliderRow())
        defaultCellUpdateTest(StepperRow())
    }
    
    func testDefaultInitializers() {
        defaultInitializerTest(TextRow())
        defaultInitializerTest(IntRow())
        defaultInitializerTest(DecimalRow())
        defaultInitializerTest(URLRow())
        defaultInitializerTest(DateRow())
        defaultInitializerTest(DateInlineRow())
        defaultInitializerTest(PopoverSelectorRow<String>())
        defaultInitializerTest(PostalAddressRow())
        defaultInitializerTest(SliderRow())
        defaultInitializerTest(StepperRow())
    }
    
    private func onChangeTest<Row, Value where Row: BaseRow, Row: RowType, Row: TypedRowType, Row.Value == Row.Cell.Value, Value == Row.Value>(row:Row, value:Value){
        var invoked = false
        row.onChange { row in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        row.value = value
        XCTAssertTrue(invoked)
    }
    
    private func cellSetupTest<Row, Value where  Row: BaseRow, Row : RowType, Row: TypedRowType, Row.Value == Row.Cell.Value, Value == Row.Value>(row:Row){
        var invoked = false
        row.cellSetup { cell, row in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        row.cell // laod cell
        XCTAssertTrue(invoked)
    }
    
    private func cellUpdateTest<Row, Value where  Row: BaseRow, Row : RowType, Row: TypedRowType, Row.Value == Row.Cell.Value, Value == Row.Value>(row:Row){
        var invoked = false
        row.cellUpdate { cell, row in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        formVC.tableView(formVC.tableView!, willDisplayCell: row.cell, forRowAtIndexPath: row.indexPath()!) // should invoke cell update
        XCTAssertTrue(invoked)
    }
    
    private func defaultInitializerTest<Row where Row: BaseRow, Row : RowType,  Row: TypedRowType, Row.Value == Row.Cell.Value>(row:Row){
        var invoked = false
        Row.defaultRowInitializer = { row in
            invoked = true
        }
        formVC.form +++= Row.init() { _ in }
        XCTAssertTrue(invoked)
    }
    
    private func defaultCellSetupTest<Row where Row: BaseRow, Row: RowType,  Row: TypedRowType, Row.Value == Row.Cell.Value>(row:Row){
        var invoked = false
        Row.defaultCellSetup = { cell, row in
            invoked = true
        }
        formVC.form +++= row
        row.cell // laod cell
        XCTAssertTrue(invoked)
    }

    private func defaultCellUpdateTest<Row where Row: BaseRow, Row : RowType, Row: TypedRowType, Row.Value == Row.Cell.Value>(row:Row){
        var invoked = false
        Row.defaultCellUpdate = { cell, row in
            invoked = true
        }
        formVC.form +++= row
        formVC.tableView(formVC.tableView!, willDisplayCell: row.cell, forRowAtIndexPath: row.indexPath()!) // should invoke cell update
        XCTAssertTrue(invoked)
    }
}
