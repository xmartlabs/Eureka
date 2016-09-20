//  OperatorsTest.swift
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

class OperatorsTest: BaseEurekaTests {

    func testOperators() {
        // test the operators
        
        var form = Form()
        form +++ TextRow("textrow1_ctx")
            <<< TextRow("textrow2_ctx")
        form = form + (TextRow("textrow3_ctx")
            <<< TextRow("textrow4_ctx")
            +++ TextRow("textrow5_ctx")
            <<< TextRow("textrow6_ctx"))
            + (TextRow("textrow7_ctx")
                +++ TextRow("textrow8_ctx"))
        
        XCTAssertEqual(form.count, 5)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(form[2].count, 2)
        
        form +++ IntRow("introw1_ctx")
        form +++ IntRow("introw2_ctx")
            <<< IntRow("introw3_ctx")
            <<< IntRow("introw4_ctx")
        
        //      form:
        //          text1
        //          text2
        //          -----
        //          text3
        //          text4
        //          -----
        //          text5
        //          text6
        //          -----
        //          text7
        //          -----
        //          text8
        //          -----
        //          int1
        //          ----
        //          int2
        //          int3
        //          int4
        
        XCTAssertEqual(form.count, 7)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(form[2].count, 2)
        XCTAssertEqual(form[3].count, 1)
        XCTAssertEqual(form[4].count, 1)
        XCTAssertEqual(form[5].count, 1)
        XCTAssertEqual(form[6].count, 3)
    }
    
}
