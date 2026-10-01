import SwiftUI

public struct MainVaultView: View {
    @ObservedObject var viewModel: VaultViewModel

    public init(viewModel: VaultViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationSplitView {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "shield.border.square.fill")
                        .font(.title2)
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Password Vault")
                            .font(.headline)
                        Text(viewModel.inputUsername.isEmpty ? "Secured" : viewModel.inputUsername)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Button(action: {
                        viewModel.lockVault()
                    }) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .help("Lock Vault")
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                Divider()

                List(selection: $viewModel.selectedCategory) {
                    Section("Categories") {
                        NavigationLink(value: Optional<CredentialCategory>.none) {
                            Label("All Items (\(viewModel.vaultItems.count))", systemImage: "tray.2.fill")
                        }

                        ForEach(CredentialCategory.allCases) { cat in
                            let count = viewModel.vaultItems.filter { $0.category == cat }.count
                            NavigationLink(value: Optional(cat)) {
                                Label("\(cat.rawValue) (\(count))", systemImage: cat.iconName)
                            }
                        }
                    }
                }
                .listStyle(.sidebar)

                Spacer()

                Button(action: {
                    viewModel.isShowingAddSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Credential")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.borderedProminent)
                .padding(12)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)

        } content: {
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search credentials...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)

                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .padding(10)

                Divider()

                if viewModel.filteredItems.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "key.viewfinder")
                            .font(.system(size: 44))
                            .foregroundColor(.secondary)
                        Text(viewModel.vaultItems.isEmpty ? "No Credentials Saved" : "No Matching Results")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(viewModel.vaultItems.isEmpty ? "Click 'Add Credential' to save your first password." : "Try adjusting your search query.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 200)
                        Spacer()
                    }
                } else {
                    List(viewModel.filteredItems, selection: $viewModel.selectedItem) { item in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 34, height: 34)
                                Text(item.title.prefix(1).uppercased())
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(item.title)
                                        .font(.body)
                                        .bold()
                                    if item.isFavorite {
                                        Image(systemName: "star.fill")
                                            .font(.caption2)
                                            .foregroundColor(.yellow)
                                    }
                                }

                                Text(item.username.isEmpty ? "No Username" : item.username)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .tag(item)
                    }
                    .listStyle(.inset)
                }
            }
            .navigationSplitViewColumnWidth(min: 240, ideal: 280, max: 350)

        } detail: {
            if let selectedItem = viewModel.selectedItem {
                ItemDetailView(viewModel: viewModel, item: selectedItem)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "lock.laptopcomputer")
                        .font(.system(size: 56))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("Select a Credential")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.secondary)
                    Text("Choose an item from the list to view username and password details.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .sheet(isPresented: $viewModel.isShowingAddSheet) {
            AddCredentialSheet(viewModel: viewModel)
        }
        .overlay(alignment: .bottom) {
            if let toast = viewModel.toastMessage {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(toast)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(Color.black.opacity(0.85)))
                .shadow(radius: 6)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: viewModel.toastMessage)
            }
        }
    }
}
