import Foundation

public struct VaultItem: Identifiable, Codable, Equatable, Hashable {
    public let id: UUID
    public var title: String
    public var username: String
    public var password: String
    public var urlString: String
    public var notes: String
    public var category: CredentialCategory
    public var isFavorite: Bool
    public var createdAt: Date
    public var updatedAt: Date

    public init(
        id: UUID = UUID(),
        title: String,
        username: String,
        password: String,
        urlString: String = "",
        notes: String = "",
        category: CredentialCategory = .logins,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.username = username
        self.password = password
        self.urlString = urlString
        self.notes = notes
        self.category = category
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public enum CredentialCategory: String, Codable, CaseIterable, Identifiable {
    case logins = "Logins"
    case creditCards = "Cards"
    case secureNotes = "Secure Notes"
    case identity = "Identity"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .logins: return "key.fill"
        case .creditCards: return "creditcard.fill"
        case .secureNotes: return "note.text"
        case .identity: return "person.badge.shield.checkmark.fill"
        }
    }
}

public struct MasterVaultConfig: Codable {
    public let masterUsername: String
    public let passwordHash: String
    public let salt: String
    public let createdAt: Date

    public init(masterUsername: String, passwordHash: String, salt: String, createdAt: Date = Date()) {
        self.masterUsername = masterUsername
        self.passwordHash = passwordHash
        self.salt = salt
        self.createdAt = createdAt
    }
}
