//  RowCallbackTests.swift
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

class RowCallbackTests: BaseEurekaTests {

    override func setUp() {
        super.setUp()
        formVC.form = Form()
            +++ Section("something")
            <<< CheckRow("row1").cellSetup { cell, row in
                cell.textLabel?.text = "checkrow + Setup"
                cell.backgroundColor = .red
            }
            <<< IntRow("row2").cellUpdate({ cell, row in
                cell.textLabel?.text = "introw"
                cell.textLabel?.font = UIFont(name: "Baskerville-Italic", size: 20)
            })
            <<< TextRow("row3").cellSetup({ cell, row in
                cell.textLabel?.text = "aftersetup"
            }).cellUpdate({ cell, row in
                cell.textLabel?.text = "afterupdate"
                cell.textLabel?.font = UIFont(name: "Baskerville-Italic", size: 20)
            })
    }
    
    func testTableViewNotNil() {
        XCTAssertNotNil(formVC.tableView)
    }
    
    func testOnChange() {
        // Test onChange callback
        let chk = CheckRow("row1"){ $0.title = "check"; $0.value = false }
        
        formVC.form = Form()
                        +++ Section("something")
                            <<< chk
                            <<< IntRow("row2"){ $0.title = "int"; $0.value = 1 }
                                .onChange { [weak chk] row in
                                    chk?.value = ((row.value! % 2) == 0)
                                }
        let intRow = formVC.form[0][1]
        intRow.baseValue = 2
        XCTAssertEqual(chk.value, true)
        formVC.form[0][1].baseValue = 3
        XCTAssertEqual(chk.value, false)
    }

    func testCellSetupAndUpdate() {

        let chkRow : CheckRow! = formVC.form.rowBy(tag: "row1")
        let intRow : IntRow! = formVC.form.rowBy(tag: "row2")
        let textRow : TextRow! = formVC.form.rowBy(tag: "row3")
        
        // check that they all have indexPath
        XCTAssertNotNil(chkRow.indexPath)
        XCTAssertNotNil(intRow.indexPath)
        XCTAssertNotNil(textRow.indexPath)
        
        // make sure cellSetup is called for each cell
        
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: intRow.indexPath!)
        
        
        XCTAssertEqual(chkRow.cell.textLabel?.text, "checkrow + Setup")
        XCTAssertEqual(textRow.cell.textLabel?.text, "aftersetup")
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: textRow.indexPath!)
        XCTAssertEqual(textRow.cell.textLabel?.text, "afterupdate")
        
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: chkRow.indexPath!)
        
        //make sure cell update is called for each cell
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: chkRow.indexPath!)
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: intRow.indexPath!)
        let _ = formVC.tableView(formVC.tableView!, cellForRowAt: textRow.indexPath!)
        
        XCTAssertEqual(chkRow?.cell.textLabel?.text, chkRow?.title)
        XCTAssertEqual(intRow?.cell.textLabel?.text, "introw")
        XCTAssertEqual(textRow?.cell.textLabel?.text, "afterupdate")
        
        XCTAssertEqual(chkRow?.cell.backgroundColor, .red)
        XCTAssertEqual(intRow?.cell.textLabel?.font, UIFont(name: "Baskerville-Italic", size: 20))
        XCTAssertEqual(textRow?.cell.textLabel?.font, UIFont(name: "Baskerville-Italic", size: 20))
        
    }
}
