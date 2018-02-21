//  HelperMethodTests.swift
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

class HelperMethodTests: BaseEurekaTests {

    func testRowByTag() {
        // Tests rowBy(tag: ) method

        let urlRow: URLRow? = fieldForm.rowBy(tag: "UrlRow_f1")
        XCTAssertNotNil(urlRow)

        let phoneRow: PhoneRow? = fieldForm.rowBy(tag: "phone")
        XCTAssertNil(phoneRow)
    }

    func testRowSequenceMethods() {
        // Tests the nextRowForRow() and the previousRowForRow() methods

        let form = fieldForm + shortForm + dateForm
        let row6 = form.nextRow(for: form[0][5])

        XCTAssertEqual(row6, form[0][6])
        XCTAssertEqual(row6, form.rowBy(tag: "IntRow_f1") as? IntRow)

        let row_5_and_6: MutableSlice<Section> = form[0][Range(5...6)]
        XCTAssertEqual(row_5_and_6[5], form[0][5])
        XCTAssertEqual(row_5_and_6[6], form[0][6])

        let row10n = form.nextRow(for: form[0][8])
        let rownil = form.nextRow(for: form[2][7])

        XCTAssertEqual(row10n, form[0][9])
        XCTAssertNil(rownil)

        let row10p = form.previousRow(for: form[0][10])
        let rowNilP = form.previousRow(for: form[0][0])

        XCTAssertEqual(row10n, row10p)
        XCTAssertNil(rowNilP)

        XCTAssertNotNil(form.nextRow(for: form[1][1]))
        XCTAssertEqual(form[1][1], form.previousRow(for: form.nextRow(for: form[1][1])!))
    }

    func testAllRowsMethod() {
        // Tests the allRows() method

        let form = fieldForm + shortForm + dateForm
        XCTAssertEqual(form.rows.count, 21)
        XCTAssertEqual(form.rows[12], shortForm[0][1])
        XCTAssertEqual(form.rows[20], form.rowBy(tag: "IntervalDateRow_d1") as? DateRow)
    }

    func testAllRowsWrappedByTagMethod() {
        // Tests the allRows() method

        let form = fieldForm + shortForm + dateForm

        let rows = form.dictionaryValuesToEvaluatePredicate()

        XCTAssertEqual(rows.count, 21)
    }

    func testDisabledRows() {
        // Tests that a row set up as disabled can not become firstResponder

        let checkRow = CheckRow("check") { $0.disabled = true }
        let switchRow = SwitchRow("switch") { $0.disabled = true }
        let segmentedRow = SegmentedRow<String>("segments") { $0.disabled = true; $0.options = ["a", "b"] }
        let intRow = IntRow("int") { $0.disabled = true }

        formVC.form +++ checkRow <<< switchRow <<< segmentedRow <<< intRow

        checkRow.updateCell()
        XCTAssertTrue(checkRow.cell.selectionStyle == .none)

        switchRow.updateCell()
        XCTAssertNotNil(switchRow.cell.switchControl)
        XCTAssertFalse(switchRow.cell.switchControl!.isEnabled)

        segmentedRow.updateCell()
        XCTAssertFalse(segmentedRow.cell.segmentedControl.isEnabled)

        intRow.updateCell()
        XCTAssertFalse(intRow.cell.cellCanBecomeFirstResponder())

    }

    func testAllSectionsMethod() {
        let form = manySectionsForm

        let sections = form
        let allSections = form.allSections

        XCTAssertEqual(sections.count, 6)
        XCTAssertEqual(sections.count, allSections.count)

        let section1 = form[0]
        let section4 = form[3]
        form.hideSection(section1)
        form.hideSection(section4)

        XCTAssertEqual(sections.count, 4)
        XCTAssertEqual(allSections.count, 6)
    }

}
