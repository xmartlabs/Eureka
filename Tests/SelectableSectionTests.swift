//  SelectableSectionTests.swift
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

class SelectableSectionTests: XCTestCase {

    var formVC = FormViewController()

    override func setUp() {
        super.setUp()
        let form = Form()
        //create a form with two sections. The second one is of multiple selection

        let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        let oceans = ["Arctic", "Atlantic", "Indian", "Pacific", "Southern"]

        form +++ SelectableSection<ListCheckRow<String>> { _ in }
        for option in continents {
            form.last! <<< ListCheckRow<String>(option) { lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }
        }

        form +++ SelectableSection<ListCheckRow<String>>("And which of the following oceans have you taken a bath in?", selectionType: .multipleSelection)
        for option in oceans {
            form.last! <<< ListCheckRow<String>(option) { lrow in
                lrow.title = option
                lrow.selectableValue = option
            }
        }

        form +++ SelectableSection<ListCheckRow<String>>("", selectionType: .singleSelection(enableDeselection: false))
        for option in oceans {
            form.last! <<< ListCheckRow<String>("\(option)2") { lrow in
                lrow.title = option
                lrow.selectableValue = option
            }
        }
        formVC.form = form

        // load the view to test the cells
        formVC.view.frame = CGRect(x: 0, y: 0, width: 375, height: 3000)
        formVC.tableView?.frame = formVC.view.frame
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSections() {

        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 1, section: 0))
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 1, section: 1))
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 3, section: 1))

        let value1 = (formVC.form[0] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue
        let value2 = (formVC.form[1] as! SelectableSection<ListCheckRow<String>>).selectedRows().map {$0.baseValue}

        XCTAssertEqual(value1 as! String, "Antarctica")
        XCTAssertTrue(value2.count == 2)
        XCTAssertEqual((value2[0] as! String), "Atlantic")
        XCTAssertEqual((value2[1] as! String), "Pacific")

        //Now deselect One of the multiple selection section and change the value of the first section
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 6, section: 0))
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 1, section: 1))


        let value3 = (formVC.form[0] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue
        
        let selectedRows = (formVC.form[1] as! SelectableSection<ListCheckRow<String>>).selectedRows()
        let value4 = selectedRows.map { $0.baseValue }

        XCTAssertEqual(value3 as! String, "South America")
        XCTAssertTrue(value4.count == 1)
        XCTAssertEqual((value4[0] as! String), "Pacific")
    }

    func testDeselectionDisabled() {
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 0, section: 2))

        var value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue

        XCTAssertEqual(value1 as? String, "Arctic")

        // now try deselecting one of each and see that nothing changes.
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 0, section: 2))

        value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue

        XCTAssertEqual(value1 as? String, "Arctic")

        // But we can change the value in the first section
        formVC.tableView(formVC.tableView!, didSelectRowAt: IndexPath(row: 2, section: 2))

        value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>>).selectedRow()?.baseValue

        XCTAssertEqual(value1 as? String, "Indian")

    }

    func testSectionedSections() {
        let selectorViewController = SelectorViewController<PushRow<String>>(nibName: nil, bundle: nil)
        selectorViewController.row = PushRow<String> { row in
            row.options = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        }
        enum Hemisphere: Int {
            case west, east, none
        }

        selectorViewController.sectionKeyForValue = { option in
            switch option {
            case "Africa", "Asia", "Australia", "Europe":
                return String(Hemisphere.west.rawValue)
            case "North America", "South America":
                return String(Hemisphere.east.rawValue)
            default:
                return String(Hemisphere.none.rawValue)
            }
        }
        selectorViewController.sectionHeaderTitleForKey = { key in
            switch Hemisphere(rawValue: Int(key)!)! {
            case .west: return "West hemisphere"
            case .east: return "East hemisphere"
            case .none: return ""
            }
        }
        selectorViewController.sectionFooterTitleForKey = { key in
            switch Hemisphere(rawValue: Int(key)!)! {
            case .west: return "West hemisphere"
            case .east: return "East hemisphere"
            case .none: return ""
            }
        }

        selectorViewController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 3000)
        selectorViewController.tableView?.frame = selectorViewController.view.frame

        let form = selectorViewController.form

        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 4)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(form[2].count, 1)

        XCTAssertEqual(form[0].header?.title, "West hemisphere")
        XCTAssertEqual(form[1].header?.title, "East hemisphere")
        XCTAssertEqual(form[2].header?.title, "")

        XCTAssertEqual(form[0].footer?.title, "West hemisphere")
        XCTAssertEqual(form[1].footer?.title, "East hemisphere")
        XCTAssertEqual(form[2].footer?.title, "")

        XCTAssertEqual(form[0].compactMap({ ($0 as! ListCheckRow<String>).selectableValue }), ["Africa", "Asia", "Australia", "Europe"])
        XCTAssertEqual(form[1].compactMap({ ($0 as! ListCheckRow<String>).selectableValue }), ["North America", "South America"])
        XCTAssertEqual(form[2].compactMap({ ($0 as! ListCheckRow<String>).selectableValue }), ["Antarctica"])
    }

    func testLazyOptionsProvider() {
        let selectorViewController = SelectorViewController<PushRow<String>>(nibName: nil, bundle: nil)
        let row = PushRow<String>()
        selectorViewController.row = row
        let options = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        
        let optionsFetched = expectation(description: "Fetched options")
        row.optionsProvider = .lazy({ form, completion in
            DispatchQueue.main.async {
                completion(options)
                optionsFetched.fulfill()
            }
        })

        let form = selectorViewController.form
        
        XCTAssertEqual(form.count, 0)

        selectorViewController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 3000)
        selectorViewController.tableView?.frame = selectorViewController.view.frame
        
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(row.options ?? [], options)
        XCTAssertEqual(form.count, 1)
        XCTAssertEqual(form[0].count, options.count)
        XCTAssertEqual(form[0].compactMap({ ($0 as! ListCheckRow<String>).selectableValue }), options)
    }
    
}
