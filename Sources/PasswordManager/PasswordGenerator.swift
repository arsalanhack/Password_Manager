import Foundation

public struct PasswordGenerator {
    public static func generate(
        length: Int = 16,
        includeUppercase: Bool = true,
        includeLowercase: Bool = true,
        includeNumbers: Bool = true,
        includeSymbols: Bool = true
    ) -> String {
        let uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lowercase = "abcdefghijklmnopqrstuvwxyz"
        let numbers = "0123456789"
        let symbols = "!@#$%^&*()_+-=[]{}|;:,.<>?"

        var characterPool = ""
        if includeUppercase { characterPool += uppercase }
        if includeLowercase { characterPool += lowercase }
        if includeNumbers { characterPool += numbers }
        if includeSymbols { characterPool += symbols }

        if characterPool.isEmpty {
            characterPool = lowercase + numbers
        }

        var password = ""
        for _ in 0..<length {
            if let randomChar = characterPool.randomElement() {
                password.append(randomChar)
            }
        }
        return password
    }

    public enum StrengthScore: String {
        case weak = "Weak"
        case fair = "Fair"
        case strong = "Strong"
        case excellent = "Very Strong"
    }

    public static func evaluateStrength(password: String) -> StrengthScore {
        if password.count < 8 { return .weak }
        var score = 0
        if password.count >= 12 { score += 2 }
        if password.count >= 16 { score += 1 }
        if password.rangeOfCharacter(from: .uppercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .lowercaseLetters) != nil { score += 1 }
        if password.rangeOfCharacter(from: .decimalDigits) != nil { score += 1 }
        if password.rangeOfCharacter(from: .punctuationCharacters) != nil || password.rangeOfCharacter(from: .symbols) != nil { score += 1 }

        switch score {
        case 0...2: return .weak
        case 3...4: return .fair
        case 5...6: return .strong
        default: return .excellent
        }
    }
}
