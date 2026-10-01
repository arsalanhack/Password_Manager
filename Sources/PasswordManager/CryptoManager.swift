import Foundation
import CryptoKit

public final class CryptoManager {
    public static let shared = CryptoManager()

    private let appSupportDirectory: URL

    private init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.appSupportDirectory = appSupport.appendingPathComponent("PasswordManager", isDirectory: true)

        try? fileManager.createDirectory(at: self.appSupportDirectory, withIntermediateDirectories: true)
    }

    private var vaultDataURL: URL {
        appSupportDirectory.appendingPathComponent("vault_data.enc")
    }

    private var masterConfigURL: URL {
        appSupportDirectory.appendingPathComponent("master_config.json")
    }

    public var isMasterSetupCompleted: Bool {
        FileManager.default.fileExists(atPath: masterConfigURL.path)
    }

    public func setupMasterAccount(username: String, password: String) throws {
        let salt = SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }.base64EncodedString()
        let hash = deriveHash(password: password, salt: salt)

        let config = MasterVaultConfig(masterUsername: username, passwordHash: hash, salt: salt)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(config)
        try data.write(to: masterConfigURL, options: .atomic)
    }

    public func verifyMasterLogin(username: String, password: String) -> (isSuccess: Bool, masterConfig: MasterVaultConfig?) {
        guard let configData = try? Data(contentsOf: masterConfigURL),
              let config = try? JSONDecoder().decode(MasterVaultConfig.self, from: configData) else {
            return (false, nil)
        }

        let computedHash = deriveHash(password: password, salt: config.salt)
        let usernameMatch = config.masterUsername.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let passwordMatch = computedHash == config.passwordHash

        if usernameMatch && passwordMatch {
            return (true, config)
        } else {
            return (false, nil)
        }
    }

    public func deriveSymmetricKey(masterPassword: String, salt: String) -> SymmetricKey {
        let combinedKeyData = (masterPassword + salt).data(using: .utf8)!
        let hash = SHA256.hash(data: combinedKeyData)
        return SymmetricKey(data: hash)
    }

    public func saveVaultItems(_ items: [VaultItem], masterPassword: String, salt: String) throws {
        let key = deriveSymmetricKey(masterPassword: masterPassword, salt: salt)
        let encoder = JSONEncoder()
        let plainData = try encoder.encode(items)

        let sealedBox = try AES.GCM.seal(plainData, using: key)
        guard let combinedData = sealedBox.combined else {
            throw NSError(domain: "CryptoManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to seal data"])
        }

        try combinedData.write(to: vaultDataURL, options: .atomic)
    }

    public func loadVaultItems(masterPassword: String, salt: String) throws -> [VaultItem] {
        guard FileManager.default.fileExists(atPath: vaultDataURL.path) else {
            return []
        }

        let key = deriveSymmetricKey(masterPassword: masterPassword, salt: salt)
        let combinedData = try Data(contentsOf: vaultDataURL)
        let sealedBox = try AES.GCM.SealedBox(combined: combinedData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)

        let decoder = JSONDecoder()
        return try decoder.decode([VaultItem].self, from: decryptedData)
    }

    private func deriveHash(password: String, salt: String) -> String {
        let input = (password + salt + "PasswordManagerSaltPrefix_v1").data(using: .utf8)!
        let hashed = SHA256.hash(data: input)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}
