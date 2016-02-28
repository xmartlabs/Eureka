import Foundation

public struct RegexValidator: RowValidator {
  private let regex: String
  private let msg: String

  public init(regex: String, msg: String = "Regex didn't match") {
    self.regex = regex
    self.msg = msg
  }

  public func validate(row: BaseRow) -> ValidationResult {
    if let value = row.baseValue as? String where match(value) {
      return .Valid(row)
    } else {
      return .Invalid(row, msg)
    }
  }

  private func match(value: String) -> Bool {
    return value.rangeOfString(regex, options: .RegularExpressionSearch) != nil
  }
}
