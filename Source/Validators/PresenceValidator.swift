public struct PresenceValidator: RowValidator {
  private let msg: String

  public init(msg: String = "Value needs to be present") {
    self.msg = msg
  }

  public func validate(row: BaseRow) -> ValidationResult {
    switch row.baseValue {
    case .Some: return .Valid(row)
    case .None: return .Invalid(row, msg)
    }
  }
}
