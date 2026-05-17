import Foundation

// MARK: - String Validation Extensions

extension String {

    /// Returns true if the string is not empty after trimming whitespace.
    var isNotEmpty: Bool {
        !self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Checks if the string is a valid Chinese A-share stock code (6 digits).
    var isValidStockCode: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count == 6 else { return false }
        return trimmed.allSatisfy { $0.isNumber }
    }

    /// Checks if the string is a valid username (non-empty after trimming).
    var isValidUsername: Bool {
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
    }
}
