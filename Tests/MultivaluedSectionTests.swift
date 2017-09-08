//  MultivaluedSectionTests.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2017 Xmartlabs SRL ( http://xmartlabs.com )
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

class MultivaluedSectionTests: XCTestCase {

    var formVC = FormViewController()

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        formVC = FormViewController()
        formVC.view.frame = CGRect(x: 0, y: 0, width: 375, height: 3000)
        formVC.tableView?.frame = formVC.view.frame

    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddButton() {
        let section = MultivaluedSection(multivaluedOptions: .Insert, header: "", footer: "") { _ in
            // just an empty closure
        }
        XCTAssertEqual(section.count, 1)

        let section2 = MultivaluedSection(multivaluedOptions: .Reorder, header: "", footer: "") { _ in
            // just an empty closure
        }
        XCTAssertEqual(section2.count, 0)
    }

    func testDelegateMethods() {
        let form = Form()
        let section = MultivaluedSection(multivaluedOptions: .Insert, header: "", footer: "") { section in
            section.tag = "textrows"
            section <<< TextRow() {
                $0.value = "text"
            }
        }

        form +++ section
        formVC.form = form

        // values
        XCTAssertEqual(form.values().keys.count, 1)
        XCTAssertEqual(form.values()["textrows"] as! [String], ["text"])

        // canEditRowAt
        XCTAssertTrue(formVC.tableView(formVC.tableView, canEditRowAt: IndexPath(item: 0, section: 0)))
        form +++ Section() <<< TextRow()
        XCTAssertFalse(formVC.tableView(formVC.tableView, canEditRowAt: IndexPath(item: 0, section: 1)))

        // editingStyleForRowAt
        XCTAssertEqual(formVC.tableView(formVC.tableView, editingStyleForRowAt: IndexPath(item: 1, section: 0)), UITableViewCellEditingStyle.insert)
        XCTAssertEqual(formVC.tableView(formVC.tableView, editingStyleForRowAt: IndexPath(item: 0, section: 0)), UITableViewCellEditingStyle.none)
        XCTAssertEqual(formVC.tableView(formVC.tableView, editingStyleForRowAt: IndexPath(item: 0, section: 1)), UITableViewCellEditingStyle.none)

        form +++ MultivaluedSection(multivaluedOptions: .Delete, header: "", footer: "") { _ in } <<< TextRow()

        XCTAssertEqual(formVC.tableView(formVC.tableView, editingStyleForRowAt: IndexPath(item: 0, section: 2)), UITableViewCellEditingStyle.delete)

        // shouldIndentWhileEditingRowAt
        XCTAssertFalse(formVC.tableView(formVC.tableView, shouldIndentWhileEditingRowAt: IndexPath(item: 0, section: 0)))
        XCTAssertTrue(formVC.tableView(formVC.tableView, shouldIndentWhileEditingRowAt: IndexPath(item: 1, section: 0)))

        XCTAssertFalse(formVC.tableView(formVC.tableView, shouldIndentWhileEditingRowAt: IndexPath(item: 0, section: 1)))
        XCTAssertTrue(formVC.tableView(formVC.tableView, shouldIndentWhileEditingRowAt: IndexPath(item: 0, section: 2)))

        // canMoveRowAt
        XCTAssertFalse(formVC.tableView(formVC.tableView, canMoveRowAt:  IndexPath(item: 0, section: 0)))
        XCTAssertFalse(formVC.tableView(formVC.tableView, canMoveRowAt:  IndexPath(item: 1, section: 0)))

        form +++ MultivaluedSection(multivaluedOptions: .Reorder, header: "", footer: "") { _ in } <<< TextRow()
        XCTAssertFalse(formVC.tableView(formVC.tableView, canMoveRowAt:  IndexPath(item: 0, section: 3)))

        form.last! <<< TextRow()

        XCTAssertTrue(formVC.tableView(formVC.tableView, canMoveRowAt:  IndexPath(item: 0, section: 3)))
        XCTAssertTrue(formVC.tableView(formVC.tableView, canMoveRowAt:  IndexPath(item: 1, section: 3)))

    }
}
