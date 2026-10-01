import Foundation
import SwiftUI
import AppKit

@MainActor
public final class VaultViewModel: ObservableObject {
    @Published public var isAuthenticated: Bool = false
    @Published public var isSetupRequired: Bool = false

    @Published public var inputUsername: String = ""
    @Published public var inputPassword: String = ""
    @Published public var inputConfirmPassword: String = ""
    @Published public var authErrorMessage: String? = nil

    @Published public var vaultItems: [VaultItem] = []
    @Published public var selectedItem: VaultItem? = nil
    @Published public var selectedCategory: CredentialCategory? = nil
    @Published public var searchQuery: String = ""
    @Published public var isShowingAddSheet: Bool = false

    @Published public var toastMessage: String? = nil

    private var activeMasterPassword: String = ""
    private var activeSalt: String = ""

    public init() {
        checkInitialSetup()
    }

    public func checkInitialSetup() {
        isSetupRequired = !CryptoManager.shared.isMasterSetupCompleted
    }

    public func handleMasterSetup() {
        let trimmedUsername = inputUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty else {
            authErrorMessage = "Please enter a valid Master Username."
            return
        }

        guard !inputPassword.isEmpty else {
            authErrorMessage = "Please enter a Master Password."
            return
        }

        guard inputPassword.count >= 6 else {
            authErrorMessage = "Master Password must be at least 6 characters long."
            return
        }

        guard inputPassword == inputConfirmPassword else {
            authErrorMessage = "Passwords do not match."
            return
        }

        do {
            try CryptoManager.shared.setupMasterAccount(username: trimmedUsername, password: inputPassword)
            activeMasterPassword = inputPassword
            let loginResult = CryptoManager.shared.verifyMasterLogin(username: trimmedUsername, password: inputPassword)
            if let config = loginResult.masterConfig {
                activeSalt = config.salt
                isAuthenticated = true
                authErrorMessage = nil
                loadVault()
            }
        } catch {
            authErrorMessage = "Failed to save master account: \(error.localizedDescription)"
        }
    }

    public func handleMasterLogin() {
        let trimmedUsername = inputUsername.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedUsername.isEmpty, !inputPassword.isEmpty else {
            authErrorMessage = "Please enter both username and master password."
            return
        }

        let result = CryptoManager.shared.verifyMasterLogin(username: trimmedUsername, password: inputPassword)
        if result.isSuccess, let config = result.masterConfig {
            activeMasterPassword = inputPassword
            activeSalt = config.salt
            isAuthenticated = true
            authErrorMessage = nil
            loadVault()
        } else {
            authErrorMessage = "Invalid master username or password. Please try again."
        }
    }

    public func lockVault() {
        isAuthenticated = false
        activeMasterPassword = ""
        activeSalt = ""
        vaultItems = []
        selectedItem = nil
        inputPassword = ""
        inputConfirmPassword = ""
        authErrorMessage = nil
    }

    public func loadVault() {
        do {
            vaultItems = try CryptoManager.shared.loadVaultItems(masterPassword: activeMasterPassword, salt: activeSalt)
            if selectedItem == nil, let first = vaultItems.first {
                selectedItem = first
            }
        } catch {
            showToast("Failed to load vault items: \(error.localizedDescription)")
        }
    }

    public func saveVault() {
        do {
            try CryptoManager.shared.saveVaultItems(vaultItems, masterPassword: activeMasterPassword, salt: activeSalt)
        } catch {
            showToast("Error saving vault: \(error.localizedDescription)")
        }
    }

    public func addVaultItem(_ item: VaultItem) {
        vaultItems.insert(item, at: 0)
        selectedItem = item
        saveVault()
        showToast("Credential '\(item.title)' saved successfully!")
    }

    public func updateVaultItem(_ item: VaultItem) {
        if let index = vaultItems.firstIndex(where: { $0.id == item.id }) {
            vaultItems[index] = item
            selectedItem = item
            saveVault()
            showToast("Updated '\(item.title)'")
        }
    }

    public func toggleFavorite(item: VaultItem) {
        if let index = vaultItems.firstIndex(where: { $0.id == item.id }) {
            vaultItems[index].isFavorite.toggle()
            saveVault()
        }
    }

    public var filteredItems: [VaultItem] {
        vaultItems.filter { item in
            let matchesCategory: Bool
            if let selectedCategory = selectedCategory {
                matchesCategory = (item.category == selectedCategory)
            } else {
                matchesCategory = true
            }

            let matchesSearch: Bool
            if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                matchesSearch = true
            } else {
                let q = searchQuery.lowercased()
                matchesSearch = item.title.lowercased().contains(q) ||
                                item.username.lowercased().contains(q) ||
                                item.urlString.lowercased().contains(q)
            }

            return matchesCategory && matchesSearch
        }
    }

    public func copyToClipboard(text: String, label: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        showToast("\(label) copied to clipboard!")
    }

    public func showToast(_ message: String) {
        toastMessage = message
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if toastMessage == message {
                toastMessage = nil
            }
        }
    }
}
