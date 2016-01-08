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
        
        let continents = ["Africa", "Antarctica", "Asia", "Australia", "Europe", "North America", "South America"]
        let oceans = ["Arctic", "Atlantic", "Indian", "Pacific", "Southern"]
        
        form +++= SelectableSection<ListCheckRow<String>, String>() { _ in }
        for option in continents {
            form.last! <<< ListCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                lrow.value = nil
            }
        }

        form +++ SelectableSection<ListCheckRow<String>, String>("And which of the following oceans have you taken a bath in?", selectionType: .MultipleSelection)
        for option in oceans {
            form.last! <<< ListCheckRow<String>(option){ lrow in
                lrow.title = option
                lrow.selectableValue = option
            }
        }
        
        form +++ SelectableSection<ListCheckRow<String>, String>("", selectionType: .SingleSelection(enableDeselection: false))
        for option in oceans {
            form.last! <<< ListCheckRow<String>("\(option)2"){ lrow in
                lrow.title = option
                lrow.selectableValue = option
            }
        }
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
        
        var value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        
        XCTAssertEqual(value1 as? String, "Arctic")
        
        // now try deselecting one of each and see that nothing changes.
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 2))
        
        value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        
        XCTAssertEqual(value1 as? String, "Arctic")
        
        // But we can change the value in the first section
        formVC.tableView(formVC.tableView!, didSelectRowAtIndexPath: NSIndexPath(forRow: 2, inSection: 2))
        
        value1 = (formVC.form[2] as! SelectableSection<ListCheckRow<String>, String>).selectedRow()?.baseValue
        
        XCTAssertEqual(value1 as? String, "Indian")
        
    }
}

