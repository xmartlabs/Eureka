//  HiddenRowsTests.swift
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

class HiddenRowsTests: BaseEurekaTests {
    var form : Form!
    let row10 = IntRow("int1_hrt"){
        $0.hidden = "$IntRow_s1 > 23" // .Predicate(NSPredicate(format: "$IntRow_s1 > 23"))
    }
    let row11 = TextRow("txt1_hrt"){
        $0.hidden = .Function(["NameRow_s1"], { form in
                        if let r1 : NameRow = form.rowByTag("NameRow_s1") {
                            return r1.value?.containsString(" is ") ?? false
                        }
                        return false
                    })
                }
    let sec2 = Section("Whatsoever"){
                    $0.tag = "s3_hrt"
                    $0.hidden = "$NameRow_s1 contains 'God'" //.Predicate(NSPredicate(format: "$NameRow_s1 contains 'God'"))
                }
    let row20 = TextRow("txt2_hrt"){
        $0.hidden = .Function(["IntRow_s1", "NameRow_s1"], { form in
                        if let r1 : IntRow = form.rowByTag("IntRow_s1"), let r2 : NameRow = form.rowByTag("NameRow_s1")  {
                            return r1.value == 88 || r2.value?.hasSuffix("real") ?? false
                        }
                        return false
                    })
                }
    
    override func setUp() {
        super.setUp()
        form = shortForm
            +++ row10
            <<< row11
            +++ sec2
            <<< row20
    }

    func testAddRowToObserver(){
        
        let intDep = form.rowObservers["IntRow_s1"]?[.Hidden]
        let nameDep = form.rowObservers["NameRow_s1"]?[.Hidden]
        
        // make sure we can unwrap
        XCTAssertNotNil(intDep)
        XCTAssertNotNil(nameDep)
        
        // test rowObservers
        XCTAssertEqual(intDep!.count, 2)
        XCTAssertEqual(nameDep!.count, 3)
        
        XCTAssertTrue(intDep!.contains({ $0.tag == "txt2_hrt" }))
        XCTAssertTrue(intDep!.contains({ $0.tag == "int1_hrt" }))
        XCTAssertFalse(intDep!.contains({ $0.tag == "s3_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag ==  "txt2_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "s3_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "txt1_hrt" }))
        XCTAssertFalse(nameDep!.contains({ $0.tag == "int1_hrt" }))
        
        //This should not change when some rows hide ...
        form[0][0].baseValue = "God is real"
        form[0][1].baseValue = 88
        
        
        //check everything is still the same
        XCTAssertEqual(intDep!.count, 2)
        XCTAssertEqual(nameDep!.count, 3)
        
        XCTAssertTrue(intDep!.contains({ $0.tag == "txt2_hrt" }))
        XCTAssertTrue(intDep!.contains({ $0.tag == "int1_hrt" }))
        XCTAssertFalse(intDep!.contains({ $0.tag == "s3_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "txt2_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "s3_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "txt1_hrt" }))
        XCTAssertFalse(nameDep!.contains({ $0.tag == "int1_hrt" }))
        
        // ...nor if they reappear
        form[0][0].baseValue = "blah blah blah"
        form[0][1].baseValue = 1
        
        //check everything is still the same
        XCTAssertEqual(intDep!.count, 2)
        XCTAssertEqual(nameDep!.count, 3)
        XCTAssertTrue(intDep!.contains({ $0.tag == "txt2_hrt" }))
        XCTAssertTrue(intDep!.contains({ $0.tag == "int1_hrt" }))
        XCTAssertFalse(intDep!.contains({ $0.tag == "s3_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "txt2_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "s3_hrt" }))
        XCTAssertTrue(nameDep!.contains({ $0.tag == "txt1_hrt" }))
        XCTAssertFalse(nameDep!.contains({ $0.tag == "int1_hrt" }))
    }
    
    func testItemsByTag(){
        // test that all rows and sections with tag are there
        XCTAssertEqual(form.rowByTag("NameRow_s1"), form[0][0])
        XCTAssertEqual(form.rowByTag("IntRow_s1"), form[0][1])
        
        XCTAssertEqual(form.rowByTag("int1_hrt"), row10)
        XCTAssertEqual(form.rowByTag("txt1_hrt"), row11)
        
        XCTAssertEqual(form.sectionByTag("s3_hrt"), sec2)
        XCTAssertEqual(form.rowByTag("txt2_hrt"), row20)
        
        // check that these are all in there
        XCTAssertEqual(form.rowsByTag.count, 5)
        
        
        // what happens after hiding the rows? Let's cause havoc
        form[0][0].baseValue = "God is real"
        form[0][1].baseValue = 88
        
        
        // we still want the same results here
        XCTAssertEqual(form.rowByTag("NameRow_s1"), form[0][0])
        XCTAssertEqual(form.rowByTag("IntRow_s1"), form[0][1])
        XCTAssertEqual(form.rowByTag("int1_hrt"), row10)
        XCTAssertEqual(form.rowByTag("txt1_hrt"), row11)
        XCTAssertEqual(form.sectionByTag("s3_hrt"), sec2)
        XCTAssertEqual(form.rowByTag("txt2_hrt"), row20)
        XCTAssertEqual(form.rowsByTag.count, 5)
        
        // and let them come up again
        form[0][0].baseValue = "blah blah"
        form[0][1].baseValue = 1
        
        // we still want the same results here
        XCTAssertEqual(form.rowsByTag["NameRow_s1"], form[0][0])
        XCTAssertEqual(form.rowsByTag["IntRow_s1"], form[0][1])
        XCTAssertEqual(form.rowsByTag["int1_hrt"], row10)
        XCTAssertEqual(form.rowsByTag["txt1_hrt"], row11)
        XCTAssertEqual(form.sectionByTag("s3_hrt"), sec2)
        XCTAssertEqual(form.rowsByTag["txt2_hrt"], row20)
        XCTAssertEqual(form.rowsByTag.count, 5)
    }
    
    func testCorrectValues(){
        
        //initial empty values (none is hidden)
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(sec2.count, 1)
        
        // false values
        form[0][0].baseValue = "Hi there"
        form[0][1].baseValue = 15
        
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(sec2.count, 1)
        
        // hide 'int1_hrt' row
        form[0][1].baseValue = 24
        
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 1)
        XCTAssertEqual(sec2.count, 1)
        XCTAssertEqual(form[1][0].tag, "txt1_hrt")
        
        // hide 'txt1_hrt' and 'txt2_hrt'
        form[0][0].baseValue = " is real"
        
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 0)
        XCTAssertEqual(sec2.count, 0)
        
        // let the last section disappear
        form[0][0].baseValue = "God is real"
        
        XCTAssertEqual(form.count, 2)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 0)
        
        // and see if they come back to live
        form[0][0].baseValue = "blah"
        form[0][1].baseValue = 2
        
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(sec2.count, 1)
    }
}
