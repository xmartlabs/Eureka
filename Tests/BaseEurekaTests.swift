//  BaseEurekaTests.swift
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

class BaseEurekaTests: XCTestCase {
    var dateForm = Form()
    var fieldForm = Form()
    var shortForm = Form()
    var manySectionsForm = Form()
    var formVC = FormViewController()

    override func setUp() {
        super.setUp()

        // load the view to test the cells
        formVC.view.frame = CGRect(x: 0, y: 0, width: 375, height: 3000)
        formVC.tableView?.frame = formVC.view.frame

        // Create a Date section containing one date row of each type and some extra rows that use minimumDate, maximumDate and minuteInterval restrictions
        dateForm +++ Section("Date Section")
            <<< DateRow("DateRow_d1") { $0.title = "Date"; $0.value = Date() }
            <<< DateTimeRow("DateTimeRow_d1") { $0.title = "DateTime"; $0.value = Date() }
            <<< TimeRow("TimeRow_d1") { $0.title = "Time"; $0.value = Date() }
            <<< CountDownRow("CountDownRow_d1") { $0.title = "CountDown"; $0.value = Date() }
            <<< DateRow("MinDateRow_d1") { $0.title = "Date(min)"; $0.value = Date(); $0.minimumDate = $0.value?.addingTimeInterval(-60*60*24) }
            <<< DateRow("MaxDateRow_d1") { $0.title = "Date(max)"; $0.value = Date(); $0.maximumDate = $0.value?.addingTimeInterval(60*60*24) }
            <<< DateRow("MinMaxDateRow_d1") { $0.title = "Date(min/max)"; $0.value = Date(); $0.minimumDate = $0.value?.addingTimeInterval(-60*60*24); $0.maximumDate = $0.value?.addingTimeInterval(60*60*24)  }
            <<< DateRow("IntervalDateRow_d1") { $0.title = "Date(interval)"; $0.value = Date(); $0.minuteInterval = 15 }

        shortForm +++ Section("short")
            <<< NameRow("NameRow_s1") { $0.title = "Name" }
            <<< IntRow("IntRow_s1") { $0.title = "Age" }

        fieldForm +++ Section("Field Section")
            <<< TextRow("TextRow_f1") { $0.title = "Text" }
            <<< NameRow("NameRow_f1") { $0.title = "Name" }
            <<< EmailRow("EmailRow_f1") { $0.title = "Email" }
            <<< PhoneRow("PhoneRow_f1") { $0.title = "Phone" }
            <<< PasswordRow("PasswordRow_f1") { $0.title = "Password" }
            <<< URLRow("UrlRow_f1") { $0.title = "Url" }
            <<< IntRow("IntRow_f1") { $0.title = "Int" }
            <<< DecimalRow("DecimalRow_f1") { $0.title = "Decimal" }
            <<< TwitterRow("TwitterRow_f1") { $0.title = "Twitter" }
            <<< AccountRow("AccountRow_f1") { $0.title = "Account" }
            <<< ZipCodeRow("ZipCodeRow_f1") { $0.title = "Zip Code" }

        manySectionsForm =  Section("Section A")
                        +++ Section("Section B")
                        +++ Section("Section C")
                        +++ Section("Section D")
                        +++ Section("Section E")
                        +++ Section("Section F")
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        dateForm = Form()
        shortForm = Form()
        fieldForm = Form()
        manySectionsForm = Form()
        formVC = FormViewController()
    }

    func testTearUp() {
        XCTAssertEqual(dateForm.count, 1)
        XCTAssertEqual(dateForm[0].count, 8)
        XCTAssertEqual(shortForm[0].count, 2)
        XCTAssertEqual(fieldForm.count, 1)
        XCTAssertEqual(fieldForm[0].count, 11)
        XCTAssertEqual(manySectionsForm.count, 6)
        XCTAssertEqual(manySectionsForm[0].count, 0)
    }
}

public class MyFormDelegate: FormDelegate {
    public var valuesChanged = 0
    public var rowsAdded = 0
    public var sectionsAdded = 0
    public var rowsRemoved = 0
    public var sectionsRemoved = 0
    public var rowsReplacedIn = 0
    public var sectionsReplacedIn = 0
    public var rowsReplacedOut = 0
    public var sectionsReplacedOut = 0

    public func valueHasBeenChanged(for: BaseRow, oldValue: Any?, newValue: Any?) {
        valuesChanged += 1
    }

    public func sectionsHaveBeenAdded(_ sections: [Section], at: IndexSet) {
        sectionsAdded += sections.count
    }

    public func sectionsHaveBeenRemoved(_ sections: [Section], at: IndexSet) {
        sectionsRemoved += sections.count
    }

    public func sectionsHaveBeenReplaced(oldSections: [Section], newSections: [Section], at: IndexSet) {
        sectionsReplacedIn += newSections.count
        sectionsReplacedOut += oldSections.count
    }

    public func rowsHaveBeenAdded(_ rows: [BaseRow], at: [IndexPath]) {
        rowsAdded += rows.count
    }

    public func rowsHaveBeenRemoved(_ rows: [BaseRow], at: [IndexPath]) {
        rowsRemoved += rows.count
    }

    public func rowsHaveBeenReplaced(oldRows: [BaseRow], newRows: [BaseRow], at: [IndexPath]) {
        rowsReplacedIn += newRows.count
        rowsReplacedOut += oldRows.count
    }

}
