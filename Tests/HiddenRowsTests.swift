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
        $0.hidden = "$IntRow_s1 > 23"
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
        $0.hidden = "$NameRow_s1 contains 'God'"
    }
    let row20 = TextRow("txt2_hrt"){
        $0.hidden = .Function(["IntRow_s1", "NameRow_s1"], { form in
                        if let r1 : IntRow = form.rowByTag("IntRow_s1"), let r2 : NameRow = form.rowByTag("NameRow_s1")  {
                            return r1.value == 88 || r2.value?.hasSuffix("real") ?? false
                        }
                        return false
                    })
    }
    let inlineDateRow21 = DateInlineRow() {
        $0.hidden = "$IntRow_s1 > 23"
    }
    
    override func setUp() {
        super.setUp()
        form = shortForm
            +++ row10
            <<< row11
            +++ sec2
            <<< row20
            <<< inlineDateRow21
    }

    func testAddRowToObserver(){
        
        let intDep = form.rowObservers["IntRow_s1"]?[.Hidden]
        let nameDep = form.rowObservers["NameRow_s1"]?[.Hidden]
        
        // make sure we can unwrap
        XCTAssertNotNil(intDep)
        XCTAssertNotNil(nameDep)
        
        // test rowObservers
        XCTAssertEqual(intDep!.count, 3)
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
        XCTAssertEqual(intDep!.count, 3)
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
        XCTAssertEqual(intDep!.count, 3)
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
        XCTAssertEqual(sec2.count, 2)
        
        // false values
        form[0][0].baseValue = "Hi there"
        form[0][1].baseValue = 15
        
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(sec2.count, 2)
        
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
        XCTAssertEqual(sec2.count, 2)
    }
    
    func testInlineRows(){
        //initial empty values (none is hidden)
        XCTAssertEqual(sec2.count, 2)
        
        // change dependency value
        form[0][1].baseValue = 25
        
        XCTAssertEqual(sec2.count, 1)
        
        // change dependency value
        form[0][1].baseValue = 10
        XCTAssertEqual(sec2.count, 2)
        
        
        //hide inline row when expanded
        inlineDateRow21.expandInlineRow()
        
        // check that the row is expanded
        XCTAssertEqual(sec2.count, 3)
        
        
        // hide expanded inline row
        form[0][1].baseValue = 25
        XCTAssertEqual(sec2.count, 1)
        
        // make inline row visible again
        form[0][1].baseValue = 10
        XCTAssertEqual(sec2.count, 2)
    }
    
    func testHiddenSections(){
        let s1 = Section(){
                    $0.hidden = "$NameRow_s1 contains 'hello'"
                    $0.tag = "s1_ths"
                }
        let s2 = Section(){
                    $0.hidden = "$NameRow_s1 contains 'morning'"
                    $0.tag = "s2_ths"
                }
        form.insert(s1, atIndex: 1)
        form.insert(s2, atIndex: 3)
        
        /* what we should have here
        
        shortForm (1 section)
        s1
        { row10, row11 }
        s2
        sec2 (2 rows)
        */
        
        XCTAssertEqual(form.count, 5)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 0)
        XCTAssertEqual(form[2].count, 2)
        XCTAssertEqual(form[3].count, 0)
        XCTAssertEqual(form[4].count, 2)
        
        form[0][0].baseValue = "hello, good morning!"
        
        XCTAssertEqual(form.count, 3)
        XCTAssertEqual(form[0].count, 2)
        XCTAssertEqual(form[1].count, 2)
        XCTAssertEqual(form[2].count, 2)
        
        form[0][0].baseValue = "whatever"
        
        XCTAssertEqual(form.count, 5)
        XCTAssertEqual(form[1].tag, "s1_ths")
        XCTAssertEqual(form[3].tag, "s2_ths")
        XCTAssertEqual(form[4].tag, "s3_hrt")
    }
    
    func testInsertionIndex(){
        let r1 = CheckRow("check1_tii_hrt"){ $0.hidden = "$NameRow_s1 contains 'morning'" }
        let r2 = CheckRow("check2_tii_hrt"){ $0.hidden = "$NameRow_s1 contains 'morning'" }
        let r3 = CheckRow("check3_tii_hrt"){ $0.hidden = "$NameRow_s1 contains 'good'" }
        let r4 = CheckRow("check4_tii_hrt"){ $0.hidden = "$NameRow_s1 contains 'good'" }
        
        form[0].insert(r1, atIndex: 1)
        form[1].insertContentsOf([r2,r3], at: 0)
        
        //test correct insert
        
        XCTAssertEqual(form[0].count, 3)
        XCTAssertEqual(form[0][1].tag, "check1_tii_hrt")
        
        XCTAssertEqual(form[1].count, 4)
        XCTAssertEqual(form[1][0].tag, "check2_tii_hrt")
        XCTAssertEqual(form[1][1].tag, "check3_tii_hrt")
        
        // hide these rows
        form[0][0].baseValue = "hello, good morning!"
        
        // insert another row
        form[1].insert(r4, atIndex: 1)
        
        XCTAssertEqual(form[1].count, 2) // all inserted rows should be hidden
        XCTAssertEqual(form[1][0].tag, "int1_hrt")
        XCTAssertEqual(form[1][1].tag, "txt1_hrt")
        
        form[0][0].baseValue = "whatever"
        
        // we inserted r4 at index 1 but there were two rows hidden before it as well so it shall be at index 3
        XCTAssertEqual(form[1].count, 5)
        XCTAssertEqual(form[1][0].tag, "check2_tii_hrt")
        XCTAssertEqual(form[1][1].tag, "check3_tii_hrt")
        XCTAssertEqual(form[1][2].tag, "int1_hrt")
        XCTAssertEqual(form[1][3].tag, "check4_tii_hrt")
        XCTAssertEqual(form[1][4].tag, "txt1_hrt")
        
        form[0][0].baseValue = "hello, good morning!"
        
        //check that hidden rows get removed as well
        form[1].removeAll()
        
        //inserting 2 rows at the end, deleting 1
        form[2].replaceRange(1..<2, with: [r2, r4])
        
        XCTAssertEqual(form[1].count, 0)
        XCTAssertEqual(form[2].count, 1)
        XCTAssertEqual(form[2][0].tag, "txt2_hrt")
        
        form[0][0].baseValue = "whatever"
        
        XCTAssertEqual(form[2].count, 3)
        XCTAssertEqual(form[2][0].tag, "txt2_hrt")
        XCTAssertEqual(form[2][1].tag, "check2_tii_hrt")
        XCTAssertEqual(form[2][2].tag, "check4_tii_hrt")
        
    }
}
