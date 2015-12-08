//  SelectableSectionTests.swift
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


class SelectableSectionTests: XCTestCase {
    
    var formVC = FormViewController()
    
    override func setUp() {
        super.setUp()
        var form = Form()
        //create a form with two sections. The second one is of multiple selection
        
        let continents = [("Africa", "Africa", "Africa"),
            ("Antarctica", "Antarctica", "Antarctica"),
            ("Asia", "Asia", "Asia"),
            ("Australia", "Australia", "Australia"),
            ("Europe", "Europe", "Europe"),
            ("North America", "North America", "North America"),
            ("South America", "South America", "South America")]
        form +++= SelectableSection<ListCheckRow<String>, String>(data: continents, initializer: nil)
        
        let oceans = ["Arctic", "Atlantic", "Indian", "Pacific", "Southern"]
        let rows1 = oceans.map { o in
            ListCheckRow<String>(o){ lrow in
                lrow.title = o
                lrow.selectableValue = o
                }
        }
        let rows2 = oceans.map { o in
            ListCheckRow<String>(o.stringByAppendingString("2")){ lrow in
                lrow.title = o
                lrow.selectableValue = o
            }
        }
        let rows3 = oceans.map { o in
            ListCheckRow<String>(o.stringByAppendingString("3")){ lrow in
                lrow.title = o
                lrow.selectableValue = o
            }
        }

        form +++ SelectableSection<ListCheckRow<String>, String>(rows: rows1, initializer: nil, isMultipleSelection: true, enableDeselection: true)
        
        form +++ SelectableSection<ListCheckRow<String>, String>(rows: rows2, initializer: nil, isMultipleSelection: false, enableDeselection: false)
        
        form +++ SelectableSection<ListCheckRow<String>, String>(rows: rows3, initializer: nil, isMultipleSelection: true, enableDeselection: false)
        formVC.form = form
        
        // load the view to test the cells
        formVC.view.frame = CGRectMake(0, 0, 375, 3000)
        formVC.tableView?.frame = formVC.view.frame
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSections() {
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 3, inSection: 1))
        
        let value1 = (formVC.form[0] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        let value2 = (formVC.form[1] as! SelectableSection<ListCheckRow<String>, String>).selectedRows().map({$0.baseValue})
        
        XCTAssertEqual(value1 as? String, "Antarctica")
        XCTAssertTrue(value2.count == 2)
        XCTAssertEqual((value2[0] as? String), "Atlantic")
        XCTAssertEqual((value2[1] as? String), "Pacific")
        
        //Now deselect One of the multiple selection section and change the value of the first section
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 6, inSection: 0))
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 1))
        
        let value3 = (formVC.form[0] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        let value4 = (formVC.form[1] as! SelectableSection<ListCheckRow<String>, String>).selectedRows().map({$0.baseValue})
        
        XCTAssertEqual(value3 as? String, "South America")
        XCTAssertTrue(value4.count == 1)
        XCTAssertEqual((value4[0] as? String), "Pacific")
    }
    
    func testDeselectionDisabled() {
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 3))
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 4, inSection: 3))
        
        var value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        var value2 = (formVC.form[3] as! SelectableSection<ListCheckRow<String>, String>).selectedRows().map({$0.baseValue})
        
        XCTAssertEqual(value1 as? String, "Arctic")
        XCTAssertTrue(value2.count == 2)
        XCTAssertEqual((value2[0] as? String), "Indian")
        XCTAssertEqual((value2[1] as? String), "Southern")
        
        // now try deselecting one of each and see that nothing changes.
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 3))
        
        value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        value2 = (formVC.form[3] as! SelectableSection<ListCheckRow<String>, String>).selectedRows().map({$0.baseValue})
        
        XCTAssertEqual(value1 as? String, "Arctic")
        XCTAssertTrue(value2.count == 2)
        XCTAssertEqual((value2[0] as? String), "Indian")
        XCTAssertEqual((value2[1] as? String), "Southern")
        
        // But we can change the value in the first section
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 2))
        
        value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        
        XCTAssertEqual(value1 as? String, "Indian")
        
    }
}

