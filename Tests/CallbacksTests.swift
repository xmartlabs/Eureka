//  CallbacksTests.swift
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

class CallbacksTests: XCTestCase {

    var formVC = FormViewController()

    override func setUp() {
        super.setUp()
        // load the view to test the cells
        formVC.view.frame = CGRect(x: 0, y: 0, width: 375, height: 3000)
        formVC.tableView?.frame = formVC.view.frame
    }

    override func tearDown() {
        super.tearDown()
    }

    func testOnChange() {
        onChangeTest(row:TextRow(), value: "text")
        onChangeTest(row:IntRow(), value: 33)
        onChangeTest(row:DecimalRow(), value: 35.7)
        onChangeTest(row:URLRow(), value: URL(string: "http://xmartlabs.com")!)
        onChangeTest(row:DateRow(), value: Date().addingTimeInterval(100))
        onChangeTest(row:DateInlineRow(), value: Date().addingTimeInterval(100))
        onChangeTest(row:PopoverSelectorRow<String>(), value: "text")
        onChangeTest(row:SliderRow(), value: 5.0)
        onChangeTest(row:StepperRow(), value: 2.5)
        onChangeTest(row:PickerInputRow(), value: "Option 2")
    }

    func testCellSetup() {
        cellSetupTest(row:TextRow())
        cellSetupTest(row:IntRow())
        cellSetupTest(row:DecimalRow())
        cellSetupTest(row:URLRow())
        cellSetupTest(row:DateRow())
        cellSetupTest(row:DateInlineRow())
        cellSetupTest(row:PopoverSelectorRow<String>())
        cellSetupTest(row:SliderRow())
        cellSetupTest(row:StepperRow())
        cellSetupTest(row:PickerInputRow<String>())
    }

    func testCellUpdate() {
        cellUpdateTest(row:TextRow())
        cellUpdateTest(row:IntRow())
        cellUpdateTest(row:DecimalRow())
        cellUpdateTest(row:URLRow())
        cellUpdateTest(row:DateRow())
        cellUpdateTest(row:DateInlineRow())
        cellUpdateTest(row:PopoverSelectorRow<String>())
        cellUpdateTest(row:SliderRow())
        cellUpdateTest(row:StepperRow())
        cellUpdateTest(row:PickerInputRow<String>())
    }

    func testDefaultCellSetup() {
        defaultCellSetupTest(row:TextRow())
        defaultCellSetupTest(row:IntRow())
        defaultCellSetupTest(row:DecimalRow())
        defaultCellSetupTest(row:URLRow())
        defaultCellSetupTest(row:DateRow())
        defaultCellSetupTest(row:DateInlineRow())
        defaultCellSetupTest(row:PopoverSelectorRow<String>())
        defaultCellSetupTest(row:SliderRow())
        defaultCellSetupTest(row:StepperRow())
        defaultCellSetupTest(row:PickerInputRow<String>())
    }

    func testDefaultCellUpdate() {
       defaultCellUpdateTest(row: TextRow())
       defaultCellUpdateTest(row: IntRow())
       defaultCellUpdateTest(row: DecimalRow())
       defaultCellUpdateTest(row: URLRow())
       defaultCellUpdateTest(row: DateRow())
       defaultCellUpdateTest(row: DateInlineRow())
       defaultCellUpdateTest(row: PopoverSelectorRow<String>())
       defaultCellUpdateTest(row: SliderRow())
       defaultCellUpdateTest(row: StepperRow())
       defaultCellUpdateTest(row: PickerInputRow<String>())
    }

    func testDefaultInitializers() {
       defaultInitializerTest(row: TextRow())
       defaultInitializerTest(row: IntRow())
       defaultInitializerTest(row: DecimalRow())
       defaultInitializerTest(row: URLRow())
       defaultInitializerTest(row: DateRow())
       defaultInitializerTest(row: DateInlineRow())
       defaultInitializerTest(row: PopoverSelectorRow<String>())
       defaultInitializerTest(row: SliderRow())
       defaultInitializerTest(row: StepperRow())
       defaultInitializerTest(row: PickerInputRow<String>())
    }

    func testOnRowValidationChenged() {
        onRowValidationTests(row: TextRow(), value: "Eureka!")
        onRowValidationTests(row: IntRow(), value: 33)
        onRowValidationTests(row: DecimalRow(), value: 35.7)
        onRowValidationTests(row: URLRow(), value: URL(string: "http://xmartlabs.com")!)
        onRowValidationTests(row: DateRow(), value: Date().addingTimeInterval(100))
        onRowValidationTests(row: DateInlineRow(), value: Date().addingTimeInterval(100))
        onRowValidationTests(row: PopoverSelectorRow<String>(), value: "text")
        onRowValidationTests(row: SliderRow(), value: 5.0)
        onRowValidationTests(row: StepperRow(), value: 2.5)
        onRowValidationTests(row: TimeInlineRow(), value: Date())
        onRowValidationTests(row: PickerInputRow<String>(), value: "Hi!!")
    }

    private func onChangeTest<Row, Value>(row:Row, value:Value) where Row: BaseRow, Row: RowType, Value == Row.Cell.Value {
        var invoked = false
        row.onChange { _ in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        row.value = value
        XCTAssertTrue(invoked)
    }

    private func cellSetupTest<Row, Value>(row:Row) where  Row: BaseRow, Row : RowType, Value == Row.Cell.Value {
        var invoked = false
        row.cellSetup { _, _ in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        let _ = row.cell // laod cell
        XCTAssertTrue(invoked)
    }

    private func cellUpdateTest<Row, Value>(row:Row) where  Row: BaseRow, Row : RowType, Value == Row.Cell.Value {
        var invoked = false
        row.cellUpdate { _, _ in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: row.indexPath!) // should invoke cell update
        XCTAssertTrue(invoked)
    }

    func onRowValidationTests<Row, Value>(row:Row, value:Value) where Row: BaseRow, Row: RowType, Value == Row.Cell.Value {
        var invoked = false
        row.validationOptions = ValidationOptions.validatesOnChange
        row.add(rule: RuleClosure { _ in return ValidationError(msg: "Validation Error") })
        row.onRowValidationChanged { _, _ in
            invoked = true
        }
        formVC.form +++ Section() <<< row
        row.value = value

        XCTAssertTrue(invoked)
    }

    private func defaultInitializerTest<Row>(row:Row) where Row: BaseRow, Row : RowType {
        var invoked = false
        Row.defaultRowInitializer = { row in
            invoked = true
        }
        formVC.form +++ Row.init { _ in }
        XCTAssertTrue(invoked)
    }

    private func defaultCellSetupTest<Row>(row:Row) where Row: BaseRow, Row: RowType {
        var invoked = false
        Row.defaultCellSetup = { cell, row in
            invoked = true
        }
        formVC.form +++ row
        let _ = row.cell // laod cell
        XCTAssertTrue(invoked)
    }

    private func defaultCellUpdateTest<Row>(row:Row) where Row: BaseRow, Row : RowType {
        var invoked = false
        Row.defaultCellUpdate = { cell, row in
            invoked = true
        }
        formVC.form +++ row
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: row.indexPath!) // should invoke cell update
        XCTAssertTrue(invoked)
    }
}
