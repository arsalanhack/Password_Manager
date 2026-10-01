import SwiftUI

public struct ItemDetailView: View {
    @ObservedObject var viewModel: VaultViewModel
    let item: VaultItem

    @State private var isPasswordVisible: Bool = false
    @State private var isEditing: Bool = false

    @State private var editTitle: String = ""
    @State private var editUsername: String = ""
    @State private var editPassword: String = ""
    @State private var editUrlString: String = ""
    @State private var editNotes: String = ""

    public init(viewModel: VaultViewModel, item: VaultItem) {
        self.viewModel = viewModel
        self.item = item
    }

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(LinearGradient(colors: [.blue.opacity(0.8), .indigo.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 52, height: 52)

                    Text(item.title.prefix(1).uppercased())
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.title)
                            .font(.title2)
                            .bold()

                        Button(action: {
                            viewModel.toggleFavorite(item: item)
                        }) {
                            Image(systemName: item.isFavorite ? "star.fill" : "star")
                                .foregroundColor(item.isFavorite ? .yellow : .gray)
                        }
                        .buttonStyle(.plain)
                    }

                    if !item.urlString.isEmpty {
                        Link(destination: URL(string: formatUrl(item.urlString)) ?? URL(string: "https://google.com")!) {
                            HStack(spacing: 4) {
                                Text(item.urlString)
                                    .font(.subheadline)
                                Image(systemName: "arrow.up.right.square")
                                    .font(.caption)
                            }
                        }
                    } else {
                        Text(item.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveEdits()
                    } else {
                        startEditing()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(.ultraThinMaterial)

            Divider()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    if isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Title").font(.caption).bold().foregroundColor(.secondary)
                            TextField("Title", text: $editTitle).textFieldStyle(.roundedBorder)

                            Text("Website URL").font(.caption).bold().foregroundColor(.secondary)
                            TextField("URL", text: $editUrlString).textFieldStyle(.roundedBorder)

                            Text("Username").font(.caption).bold().foregroundColor(.secondary)
                            TextField("Username", text: $editUsername).textFieldStyle(.roundedBorder)

                            Text("Password").font(.caption).bold().foregroundColor(.secondary)
                            TextField("Password", text: $editPassword).textFieldStyle(.roundedBorder)

                            Text("Notes").font(.caption).bold().foregroundColor(.secondary)
                            TextEditor(text: $editNotes)
                                .frame(height: 80)
                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray.opacity(0.3)))
                        }
                        .padding()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("USERNAME / EMAIL")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.secondary)

                            HStack {
                                Text(item.username.isEmpty ? "—" : item.username)
                                    .font(.system(.body, design: .monospaced))

                                Spacer()

                                if !item.username.isEmpty {
                                    Button(action: {
                                        viewModel.copyToClipboard(text: item.username, label: "Username")
                                    }) {
                                        Label("Copy", systemImage: "doc.on.doc")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(10)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("PASSWORD")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.secondary)

                            HStack {
                                if isPasswordVisible {
                                    Text(item.password.isEmpty ? "—" : item.password)
                                        .font(.system(.body, design: .monospaced))
                                } else {
                                    Text(item.password.isEmpty ? "—" : String(repeating: "•", count: max(8, item.password.count)))
                                        .font(.system(.body, design: .monospaced))
                                }

                                Spacer()

                                if !item.password.isEmpty {
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal, 4)

                                    Button(action: {
                                        viewModel.copyToClipboard(text: item.password, label: "Password")
                                    }) {
                                        Label("Copy Password", systemImage: "key.fill")
                                            .font(.caption)
                                    }
                                    .buttonStyle(.borderedProminent)
                                }
                            }
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(10)

                        if !item.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("SECURE NOTES")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.secondary)

                                Text(item.notes)
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(10)
                        }

                        HStack {
                            Text("Created \(item.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            Spacer()
                            Text("Updated \(item.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                        }
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
        }
        .onChange(of: item) { newItem in
            isEditing = false
            isPasswordVisible = false
        }
    }

    private func startEditing() {
        editTitle = item.title
        editUsername = item.username
        editPassword = item.password
        editUrlString = item.urlString
        editNotes = item.notes
        isEditing = true
    }

    private func saveEdits() {
        var updated = item
        updated.title = editTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.username = editUsername
        updated.password = editPassword
        updated.urlString = editUrlString
        updated.notes = editNotes
        updated.updatedAt = Date()

        viewModel.updateVaultItem(updated)
        isEditing = false
    }

    private func formatUrl(_ url: String) -> String {
        if url.lowercased().hasPrefix("http://") || url.lowercased().hasPrefix("https://") {
            return url
        }
        return "https://" + url
    }
}
