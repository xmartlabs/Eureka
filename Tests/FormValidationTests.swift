import XCTest
@testable import Eureka

class FormValidationTests: BaseEurekaTests {
  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testRegexValidator() {
    let validator = RegexValidator(regex: "[0-9]")

    let validRow = TextRow() { $0.value = "123" }
    let invalidRow = TextRow() { $0.value = "abc" }

    XCTAssertTrue(validator.validate(validRow).valid)
    XCTAssertFalse(validator.validate(invalidRow).valid)
  }

  func testPresenceValidator() {
    let validator = PresenceValidator()

    let validRow = TextRow() { $0.value = "123" }
    let invalidRow = TextRow() { $0.value = nil }

    XCTAssertTrue(validator.validate(validRow).valid)
    XCTAssertFalse(validator.validate(invalidRow).valid)
  }

  func testFormValidation() {
    let form = Form()

    let validRow = TextRow("validRowTag") {
      $0.value = "123"
      $0.validations = [
        PresenceValidator(),
        RegexValidator(regex: "[0-9]"),
      ]
    }

    let invalidRow = TextRow("invalidRowTag") {
      $0.value = nil
      $0.validations = [
        PresenceValidator(),
        RegexValidator(regex: "[0-9]"),
      ]
    }

    form +++ Section() <<< validRow <<< invalidRow

    XCTAssertEqual(validRow.validations!.count, 2)
    XCTAssertEqual(invalidRow.validations!.count, 2)

    XCTAssertEqual(form.validationErrors().count, 2)
  }

  func testFormValidationWithOptionalFields() {
    let form = Form()

    let r1 = TextRow("r1") {
      $0.value = "123"
      $0.validations = [RegexValidator(regex: "[0-9]")]
      $0.optional = false
    }

    let r2 = TextRow("r2") {
      $0.value = nil
      $0.validations = [RegexValidator(regex: "[0-9]")]
      $0.optional = true
    }

    let r3 = TextRow("r3") {
      $0.value = "abc"
      $0.validations = [RegexValidator(regex: "[0-9]")]
      $0.optional = true
    }

    form +++ Section() <<< r1 <<< r2 <<< r3

    XCTAssertEqual(r1.validations!.count, 1)
    XCTAssertEqual(r2.validations!.count, 1)
    XCTAssertEqual(r3.validations!.count, 1)
    
    XCTAssertEqual(form.validationErrors().count, 1)
  }
}
