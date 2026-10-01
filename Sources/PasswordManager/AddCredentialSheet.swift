import SwiftUI

public struct AddCredentialSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: VaultViewModel

    @State private var title: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var urlString: String = ""
    @State private var notes: String = ""
    @State private var category: CredentialCategory = .logins

    @State private var errorMessage: String? = nil

    public init(viewModel: VaultViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Add New Credential")
                    .font(.headline)
                Spacer()
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Service / Title").font(.caption).bold().foregroundColor(.secondary)
                        TextField("e.g. GitHub, Google, Netflix", text: $title)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Website URL (Optional)").font(.caption).bold().foregroundColor(.secondary)
                        TextField("https://example.com", text: $urlString)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Category").font(.caption).bold().foregroundColor(.secondary)
                        Picker("Category", selection: $category) {
                            ForEach(CredentialCategory.allCases) { cat in
                                Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    Divider().padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Username / Email").font(.caption).bold().foregroundColor(.secondary)
                        TextField("username@domain.com", text: $username)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text("Password").font(.caption).bold().foregroundColor(.secondary)
                            Spacer()
                            Button(action: {
                                password = PasswordGenerator.generate(length: 16)
                            }) {
                                Label("Generate Password", systemImage: "sparkles")
                                    .font(.caption2)
                            }
                            .buttonStyle(.link)
                        }

                        HStack {
                            TextField("Password", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }

                        let strength = PasswordGenerator.evaluateStrength(password: password)
                        if !password.isEmpty {
                            HStack(spacing: 6) {
                                Text("Strength:")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(strength.rawValue)
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(colorForStrength(strength))
                            }
                        }
                    }

                    Divider().padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Secure Notes (Optional)").font(.caption).bold().foregroundColor(.secondary)
                        TextEditor(text: $notes)
                            .font(.body)
                            .frame(height: 70)
                            .padding(4)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
                    }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
            }

            Divider()

            HStack {
                Spacer()
                Button("Save Credential") {
                    saveAction()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding()
            .background(Color(NSColor.windowBackgroundColor))
        }
        .frame(width: 440, height: 540)
    }

    private func saveAction() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please specify a service or title."
            return
        }

        guard !username.isEmpty || !password.isEmpty else {
            errorMessage = "Please specify at least a username or password."
            return
        }

        let newItem = VaultItem(
            title: trimmedTitle,
            username: username,
            password: password,
            urlString: urlString,
            notes: notes,
            category: category
        )

        viewModel.addVaultItem(newItem)
        dismiss()
    }

    private func colorForStrength(_ strength: PasswordGenerator.StrengthScore) -> Color {
        switch strength {
        case .weak: return .red
        case .fair: return .orange
        case .strong: return .yellow
        case .excellent: return .green
        }
    }
}
