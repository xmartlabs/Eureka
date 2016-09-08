public protocol RowValidator {
  func validate(row: BaseRow) -> ValidationResult
}
