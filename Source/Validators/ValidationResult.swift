public enum ValidationResult {
  case Valid(BaseRow)
  case Invalid(BaseRow, String)

  public var valid: Bool {
    switch self {
    case .Valid: return true
    case .Invalid: return false
    }
  }

  public var errors: [String] {
    switch self {
    case .Valid: return []
    case let .Invalid(_, msg): return [msg]
    }
  }
}
