//  CollectionTests.swift
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

class CollectionTests: BaseEurekaTests {

    func testSectionRangeReplaceableCollectionTypeConformance() {
        // test if the collection function work as expected
        
        fieldForm[0].replaceRange(3...6, with: [CheckRow("check1_ctx")])          // replacing 4 rows with 1
        XCTAssertEqual(fieldForm[0].count, 8)                                                       // fieldform had 10 rows prior to replacing
        fieldForm[0][4] = CheckRow("check2_ctx")                                                    // replacing 5th row
        XCTAssertEqual(fieldForm[0].count, 8)
        
        XCTAssertEqual(fieldForm[0].filter({ $0 is CheckRow }).count, 2)                            // Do I have 2 CheckRows??

        fieldForm[0].appendContentsOf([CheckRow("check3_ctx"), CheckRow("check4_ctx"), CheckRow("check5_ctx")])
        // is the same as fieldForm[0] += [...]
        
        XCTAssertEqual(fieldForm[0].count, 11)
    }
    
    func testFormRangeReplaceableCollectionTypeConformance() {
        // test if the collection function work as expected
        
        manySectionsForm.replaceRange(2..<5, with: [Section("Out of order"), Section()])         // replacing 3 rows with 2
        XCTAssertEqual(manySectionsForm.count, 5)                                                                  // fieldform had 10 rows prior to replacing
        manySectionsForm[3] = Section("There is no order anyway")                                               // replacing 4th row
        XCTAssertEqual(manySectionsForm.count, 5)
        
        XCTAssertEqual(manySectionsForm.filter({ $0.header?.title?.containsString("order") ?? false}).count, 2)
        
        manySectionsForm.appendContentsOf([Section("1"), Section("2")])
        // is the same as fieldForm[0] += [...]
        
        XCTAssertEqual(manySectionsForm.count, 7)
    }
    
    func testDelegateFunctions() {
        // Test operators
        var form = Form()
        let delegate = MyFormDelegate()
        form.delegate = delegate
        
        form +++= Section("A")                                                                  // addsection + 1
        form +++= TextRow("textrow1_ctx"){ $0.value = " "}                                      // addsection + 1
        form +++= Section("C") <<< TextRow("textrow2_ctx") <<< TextRow("textrow3_ctx")          // addsection + 1
        
        XCTAssertEqual(delegate.sectionsAdded, 3)
        XCTAssertEqual(delegate.rowsAdded, 0)

        form[0][0] = TextRow("textrow6_ctx")                                                    // addrow + 1
        form[1][0].baseValue = "a"                                                              // valueschanged + 1
        
        XCTAssertEqual(delegate.valuesChanged, 1)
        XCTAssertEqual(delegate.sectionsAdded, 3)
        XCTAssertEqual(delegate.rowsAdded, 1)
        
        form[2][1] = TextRow("textrow7_ctx")                                                    // replacerowIn+1, replacerowOut+1,
        form.replaceRange(0...1, with: [Section("replaced in")])              // replacesectionOut+1, sectionremoved+1, replacesectionin+1
        
        XCTAssertEqual(delegate.sectionsRemoved, 1)
        
        form[1].removeAll()                                                                     // rowsremoved + 2
        form.removeAll()                                                                        // sectionsremoved + 2
        
        //Test delegate
        XCTAssertEqual(delegate.valuesChanged, 1)
        XCTAssertEqual(delegate.sectionsAdded, 3)
        XCTAssertEqual(delegate.rowsAdded, 1)
        XCTAssertEqual(delegate.sectionsRemoved, 3)
        XCTAssertEqual(delegate.rowsRemoved, 2)
        XCTAssertEqual(delegate.rowsReplacedIn, 1)
        XCTAssertEqual(delegate.rowsReplacedOut, 1)
        XCTAssertEqual(delegate.sectionsReplacedIn, 1)
        XCTAssertEqual(delegate.sectionsReplacedOut, 1)
    }

}
