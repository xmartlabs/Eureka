//  FormValuesTests.swift
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

class FormValuesTests: BaseEurekaTests {
    
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testFormValues() {
        let form = Form()
        
        let textRow = TextRow("RowTag")
        
        form +++ Section() <<< textRow
        
        // check that the row is included in the values dictionary
        XCTAssertEqual(form.values(includeHidden: true).count, 1)
        // check that the row value is nil
        XCTAssertTrue(form.values(includeHidden: true)["RowTag"]! == nil)
        
        // change the value and check that the new value appears
        textRow.value = "Hi!"
        XCTAssertTrue(form.values(includeHidden: true)["RowTag"] is String)
        XCTAssertEqual(form.values(includeHidden: true)["RowTag"] as? String, "Hi!")
        
        let textRowWithoutTag = TextRow()
        form +++ Section() <<< textRowWithoutTag
        
        XCTAssertEqual(form.values(includeHidden: true).count, 1)
        XCTAssertTrue(form.values(includeHidden: true)["RowTag"] is String)
        
        let textRowInvisible = TextRow("InvisibleRowTag")
        textRowInvisible.hidden = true
        form +++ Section() <<< textRowInvisible
        
        XCTAssertEqual(form.values(includeHidden: true).count, 2)
        XCTAssertTrue(form.values(includeHidden: true)["RowTag"] is String)
        
        XCTAssertEqual(form.allRows.count, 3)
        XCTAssertEqual(form.rows.count, 2)
        XCTAssertEqual(form.values().count, 1)
        XCTAssertEqual(form.values(includeHidden: true).count, 2)
    }
    
    func testIncludeHiddenFormValues() {
        let form = Form()
        
        let textRow = TextRow("RowTag")
        
        form +++ Section() <<< textRow
        
        // check that the row is included in the values dictionary
        XCTAssertEqual(form.values().count, 1)
        // check that the row value is nil
        XCTAssertTrue(form.values()["RowTag"]! == nil)
        
        // change the value and check that the new value appears
        textRow.value = "Hi!"
        XCTAssertTrue(form.values()["RowTag"] is String)
        XCTAssertEqual(form.values()["RowTag"] as? String, "Hi!")
        
        let textRowWithoutTag = TextRow()
        form +++ Section() <<< textRowWithoutTag
        
        XCTAssertEqual(form.values().count, 1)
        XCTAssertTrue(form.values()["RowTag"] is String)
        
        let textRowInvisible = TextRow("InvisibleRowTag")
        textRowInvisible.hidden = true
        textRowInvisible.value = "Bye!"
        form +++ Section() <<< textRowInvisible
        
        XCTAssertEqual(form.values(includeHidden: true).count, 2)
        XCTAssertTrue(form.values(includeHidden: true)["RowTag"] is String)
        XCTAssertTrue(form.values(includeHidden: true)["InvisibleRowTag"] is String)
        
        XCTAssertEqual(form.allRows.count, 3)
        XCTAssertEqual(form.rows.count, 2)
        XCTAssertEqual(form.values().count, 1)
        XCTAssertEqual(form.values(includeHidden: true).count, 2)
    }
    
    
}
