//
//  SectionInsertionTests.swift
//  Eureka
//
//  Created by Miguel Revetria on 5/8/17.
//  Copyright © 2017 Xmartlabs. All rights reserved.
//

import XCTest
@testable import Eureka

class SectionInsertionTests: XCTestCase {

    var formVC = FormViewController()
    var form: Form!

    func testAppendingSections() {
        let form = Form()
        form.append(Section("section_01"))
        form.append(Section("section_02"))
        form.append(Section("section_03"))

        hideAndShowSections(
            form: form,
            expectedTitles: ["section_01", "section_02", "section_03"]
        )
    }

    func testAppendingSectionsWithCustomOperator() {
        let form = Form()
        form +++ Section("section_01")
        form +++ Section("section_02")
        form +++ Section("section_03")

        hideAndShowSections(
            form: form,
            expectedTitles: ["section_01", "section_02", "section_03"]
        )
    }

    func testInsertingSectionsWithSubscript() {
        let form = Form()
        form[0] = Section("section_01")
        form[1] = Section("section_02")
        form[2] = Section("section_03")

        hideAndShowSections(
            form: form,
            expectedTitles: ["section_01", "section_02", "section_03"]
        )
    }

    func testMovingAppendedSections() {
        let formInit: () -> Form = {
            let form = Form()
            form.append(Section("section_01"))
            form.append(Section("section_02"))
            form.append(Section("section_03"))
            return form
        }

        let append: (Form, Section) -> Void = { form, section in
            form.append(section)
        }

        movingSections(formInit: formInit, formAppend: append)
    }

    func testMovingAppendedSectionsWithCustomOperator() {
        let formInit: () -> Form = {
            let form = Form()
            form +++ Section("section_01")
            form +++ Section("section_02")
            form +++ Section("section_03")
            return form
        }

        let append: (Form, Section) -> Void = { form, section in
            form +++ section
        }

        movingSections(formInit: formInit, formAppend: append)
    }

    func testMovingInsertedSectionsWithSubscript() {
        let formInit: () -> Form = {
            let form = Form()
            form[0] = Section("section_01")
            form[1] = Section("section_02")
            form[2] = Section("section_03")
            return form
        }

        let append: (Form, Section) -> Void = { form, section in
            form[form.count] = section
        }

        movingSections(formInit: formInit, formAppend: append)
    }

    func testReplacingAppendedSections() {
        let form = Form()
        form.append(Section("section_01"))
        form.append(Section("section_02"))
        form.append(Section("section_03"))

        replaceSections(form: form)
    }

    func testReplacingAppendedSectionsWithCustomOperator() {
        let form = Form()
        form +++ Section("section_01")
        form +++ Section("section_02")
        form +++ Section("section_03")

        replaceSections(form: form)
    }

    func testReplacingInsertedSectionsWithSubscript() {
        let form = Form()
        form[0] = Section("section_01")
        form[1] = Section("section_02")
        form[2] = Section("section_03")

        replaceSections(form: form)
    }

    func testReplacingSubrangeForAppendedSections() {
        let form = Form()
        form.append(Section("section_01"))
        form.append(Section("section_02"))
        form.append(Section("section_03"))

        replaceSectionSubranges(form: form)
    }

    func testReplacingSubrangeForAppendedSectionsWithCustomOperator() {
        let form = Form()
        form +++ Section("section_01")
        form +++ Section("section_02")
        form +++ Section("section_03")

        replaceSectionSubranges(form: form)
    }

    func testReplacingSubrangeForInsertedSectionsWithSubscript() {
        let form = Form()
        form[0] = Section("section_01")
        form[1] = Section("section_02")
        form[2] = Section("section_03")

        replaceSectionSubranges(form: form)
    }

    func testInsertingAfterRow() {
        let form = Form()
        form[0] = Section("section_01")
        form[0] <<< TextRow("a")
            <<< TextRow("b") { $0.hidden = true }
            <<< TextRow("d") { $0.hidden = true }
            <<< TextRow("e")

        let bRow = form.rowBy(tag: "b")
        XCTAssertNotNil(bRow)

        try? form[0].insert(row: TextRow("c"), after: bRow!)

        let cRow = form.rowBy(tag: "c")
        XCTAssertNotNil(cRow)

        XCTAssertEqual(form[0].count, 3) // a, c, e
        XCTAssertEqual(form.allRows.count, 5) // a, b, c, d, e
        XCTAssertEqual(form[0][1], cRow)
    }

    func testInsertingAfterRowAtEnd() {
        let form = Form()
        form[0] = Section("section_01")
        form[0] <<< TextRow("a") { $0.hidden = true }

        let aRow = form.rowBy(tag: "a")
        XCTAssertNotNil(aRow)

        try? form[0].insert(row: TextRow("b") { $0.hidden = true }, after: aRow!)

        let bRow = form.rowBy(tag: "b")
        XCTAssertNotNil(bRow)

        XCTAssertEqual(form[0].count, 0)
        XCTAssertEqual(form.allRows.count, 2) // a, b

        try? form[0].insert(row: TextRow("c"), after: aRow!)

        let cRow = form.rowBy(tag: "c")
        XCTAssertNotNil(cRow)

        XCTAssertEqual(form[0].count, 1) // c
        XCTAssertEqual(form.allRows.count, 3) // a, c, b
        XCTAssertEqual(form.allRows[0], aRow)
        XCTAssertEqual(form.allRows[1], cRow)
        XCTAssertEqual(form.allRows[2], bRow)
    }

    private func hideAndShowSections(form: Form, expectedTitles titles: [String]) {
        // Doesn't matter how rows were added to the form (using append, +++ or subscript index)
        // next must work

        XCTAssertEqual(form.count, 3)

        var title1 = form[0].header!.title!
        var title2 = form[1].header!.title!
        var title3 = form[2].header!.title!

        XCTAssertEqual(title1, titles[0])
        XCTAssertEqual(title2, titles[1])
        XCTAssertEqual(title3, titles[2])

        var sect = form[1]
        sect.hidden = true
        sect.evaluateHidden()
        XCTAssertNotNil(sect.form)

        XCTAssertEqual(form.count, 2)
        XCTAssertEqual(form.allSections.count, 3)

        title1 = form[0].header!.title!
        title3 = form[1].header!.title!
        XCTAssertEqual(title1, titles[0])
        XCTAssertEqual(title3, titles[2])

        sect = form[0]
        sect.hidden = true
        sect.evaluateHidden()
        XCTAssertNotNil(sect.form)

        XCTAssertEqual(form.count, 1)
        XCTAssertEqual(form.allSections.count, 3)

        title3 = form[0].header!.title!
        XCTAssertEqual(title3, titles[2])

        sect = form[0]
        sect.hidden = true
        sect.evaluateHidden()
        XCTAssertNotNil(sect.form)

        XCTAssertEqual(form.count, 0)
        XCTAssertEqual(form.allSections.count, 3)

        form.allSections
            .map { $0.header!.title! }
            .enumerated()
            .forEach { ind, title in
                XCTAssertEqual(title, titles[ind])
            }

        form.allSections[1].hidden = false
        form.allSections[1].evaluateHidden()

        XCTAssertEqual(form.count, 1)
        XCTAssertEqual(form.allSections.count, 3)

        title2 = form[0].header!.title!
        XCTAssertEqual(title2, titles[1])
    }

    private func movingSections(formInit: () -> Form, formAppend: (Form, Section) -> Void) {
        var form = formInit()
        var tmp = form.remove(at: 0)
        XCTAssertNil(tmp.form)
        formAppend(form, tmp)
        XCTAssertNotNil(tmp.form)

        hideAndShowSections(form: form, expectedTitles: ["section_02", "section_03", "section_01"])

        form = formInit()
        tmp = form.remove(at: 1)
        XCTAssertNil(tmp.form)
        formAppend(form, tmp)
        XCTAssertNotNil(tmp.form)

        hideAndShowSections(form: form, expectedTitles: ["section_01", "section_03", "section_02"])

        form = formInit()
        tmp = form.remove(at: 2)
        XCTAssertNil(tmp.form)
        formAppend(form, tmp)
        XCTAssertNotNil(tmp.form)

        hideAndShowSections(form: form, expectedTitles: ["section_01", "section_02", "section_03"])
    }

    private func replaceSections(form: Form) {
        for ind in 0..<form.count {
            let testTitle = "section_test_\(ind)"
            let testSection = Section(testTitle)
            let section = form[ind]

            XCTAssertNotNil(section.form)
            form[ind] = testSection

            XCTAssertNotNil(testSection.form)
            XCTAssertNil(section.form)
            XCTAssertEqual(form[ind].header!.title!, testTitle)
        }
    }

    private func replaceSectionSubranges(form: Form) {
        let section = form.first!
        let testSection = Section("section_test_01")
        let testSection2 = Section("section_test_02")

        XCTAssertNotNil(section.form)
        form.replaceSubrange(0..<1, with: [testSection])
        XCTAssertNotNil(testSection.form)
        XCTAssertNil(section.form)
        XCTAssertEqual(form.count, 3)

        form.replaceSubrange(0..<1, with: [])
        XCTAssertNil(testSection.form)
        XCTAssertEqual(form.count, 2)

        form.replaceSubrange(0..<1, with: [testSection, testSection2])
        XCTAssertNotNil(testSection.form)
        XCTAssertNotNil(testSection2.form)
        XCTAssertEqual(form.count, 3)

        form.replaceSubrange(0..<form.count, with: [])
        XCTAssertNil(testSection.form)
        XCTAssertNil(testSection2.form)
        XCTAssertTrue(form.isEmpty)
    }

}
