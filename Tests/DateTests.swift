//  DateTests.swift
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

class DateTests: BaseEurekaTests {

    override func setUp() {
        super.setUp()
        formVC.form = dateForm
    }
    
    func testMinMax(){
        
        let minRow : DateRow? = formVC.form.rowByTag("MinDateRow_d1")
        let maxRow : DateRow?  = formVC.form.rowByTag("MaxDateRow_d1")
        let minMaxRow : DateRow? = formVC.form.rowByTag("MinMaxDateRow_d1")
        
        XCTAssertNotNil(minRow?.indexPath())
        XCTAssertNotNil(maxRow?.indexPath())
        XCTAssertNotNil(minMaxRow?.indexPath())
        
        // make sure cellSetup is called for each cell
        formVC.tableView(formVC.tableView!, cellForRowAtIndexPath: minRow!.indexPath()!)
        formVC.tableView(formVC.tableView!, cellForRowAtIndexPath: maxRow!.indexPath()!)
        formVC.tableView(formVC.tableView!, cellForRowAtIndexPath: minMaxRow!.indexPath()!)
        
        //make sure cell update is called for each cell
        formVC.tableView(formVC.tableView!, willDisplayCell: minRow!.cell, forRowAtIndexPath: minRow!.indexPath()!)
        formVC.tableView(formVC.tableView!, willDisplayCell: maxRow!.cell, forRowAtIndexPath: maxRow!.indexPath()!)
        formVC.tableView(formVC.tableView!, willDisplayCell: minMaxRow!.cell, forRowAtIndexPath: minMaxRow!.indexPath()!)
        
        
        XCTAssertNil(minRow?.cell.datePicker.maximumDate)
        XCTAssertEqual(minRow?.cell.datePicker.minimumDate, minRow?.value?.dateByAddingTimeInterval(-60*60*24))
        XCTAssertNil(maxRow?.cell.datePicker.minimumDate)
        XCTAssertEqual(maxRow?.cell.datePicker.maximumDate, maxRow?.value?.dateByAddingTimeInterval(60*60*24))
        
        XCTAssertNotNil(minMaxRow?.cell.datePicker.minimumDate)
        XCTAssertEqual(minMaxRow?.cell.datePicker.maximumDate, minMaxRow?.cell.datePicker.minimumDate!.dateByAddingTimeInterval(2*60*60*24))
        
        
    }
    
    func testInterval(){
        let row : DateRow? = formVC.form.rowByTag("IntervalDateRow_d1")
        
        XCTAssertNotNil(row?.indexPath())
        
        // make sure cellSetup is called for each cell
        formVC.tableView(formVC.tableView!, cellForRowAtIndexPath: row!.indexPath()!)
        
        //make sure cell update is called for each cell
        formVC.tableView(formVC.tableView!, willDisplayCell: row!.cell, forRowAtIndexPath: row!.indexPath()!)
        
        XCTAssertEqual(row?.cell.datePicker.minuteInterval, 15)

    }

}
