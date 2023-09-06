//  ResultBuildersTests.swift
//  Eureka ( https://github.com/xmartlabs/Eureka )
//
//  Copyright (c) 2022 Xmartlabs ( http://xmartlabs.com )
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

class ResultBuildersTests: BaseEurekaTests {
    #if swift(>=5.4)
    @SectionBuilder
    var section1: Section {
        NameRow("NameRow_f1") { $0.title = "Name" }
        if true {
            IntRow("IntRow_f1") { $0.title = "Int" }
        }
        DecimalRow("DecimalRow_f1") { $0.title = "Decimal" }
    }

    @FormBuilder
    var form: Form {
        Section("Section A") { section in
            section.tag = "Section_A"
        }
        if true {
            Section("Section B") { section in
                section.tag = "Section_B"
            }
        }
        NameRow("NameRow_f1") { $0.title = "Name" }
    }
    #endif

    private var checkBuildEither = false
    private var checkBuildExpressionBaseRowOptional = false

    func testSectionBuilder() {
        #if swift(>=5.4)
        setupManySectionsForm()
        addMoreItemsToManySectionsForm()

        XCTAssertNotNil(manySectionsForm.rowBy(tag: "NameRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "IntRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "DecimalRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "UrlRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "TwitterRow_f1"))
        XCTAssertNil(manySectionsForm.rowBy(tag: "TwitterRow_f2"))
        XCTAssertNil(manySectionsForm.rowBy(tag: "EmailRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "AccountRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "PhoneRow_f1"))
        XCTAssertNil(manySectionsForm.rowBy(tag: "PhoneRow_f2"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "ZipCodeRow_f1"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "PasswordRow_f1"))
        #endif
    }

    private func setupManySectionsForm() {
        checkBuildEither = false
        checkBuildExpressionBaseRowOptional = true
        manySectionsForm = (section1 +++ {
            URLRow("UrlRow_f1") { $0.title = "Url" }
            if checkBuildEither {
                TwitterRow("TwitterRow_f2") { $0.title = "Twitter" }
            } else {
                TwitterRow("TwitterRow_f1") { $0.title = "Twitter" }
            }
            if checkBuildExpressionBaseRowOptional {
                nil
            } else {
                EmailRow("EmailRow_f1") { $0.title = "Email" }
            }
            AccountRow("AccountRow_f1") { $0.title = "Account" }
        })
    }

    private func addMoreItemsToManySectionsForm() {
        checkBuildEither.toggle()
        checkBuildExpressionBaseRowOptional.toggle()
        manySectionsForm +++ {
            if checkBuildEither {
                PhoneRow("PhoneRow_f1") { $0.title = "Phone" }
            } else {
                PhoneRow("PhoneRow_f2") { $0.title = "Phone" }
            }
            if checkBuildExpressionBaseRowOptional {
                nil
            } else {
                ZipCodeRow("ZipCodeRow_f1") { $0.title = "Zip Code" }
            }
            PasswordRow("PasswordRow_f1") { $0.title = "Password" }
        }
    }

    func testFormBuilder() {
        #if swift(>=5.4)
        manySectionsForm = form
        XCTAssertNotNil(manySectionsForm.sectionBy(tag: "Section_A"))
        XCTAssertNotNil(manySectionsForm.sectionBy(tag: "Section_B"))
        XCTAssertNotNil(manySectionsForm.rowBy(tag: "NameRow_f1"))
        #endif
    }
}
