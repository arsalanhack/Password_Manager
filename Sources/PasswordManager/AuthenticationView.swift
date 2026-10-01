import SwiftUI

public struct AuthenticationView: View {
    @ObservedObject var viewModel: VaultViewModel

    public init(viewModel: VaultViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: viewModel.isSetupRequired ? "shield.badge.plus" : "lock.shield.fill")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundColor(.white)
                }

                Text(viewModel.isSetupRequired ? "Create Master Vault" : "Welcome Back")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Text(viewModel.isSetupRequired
                     ? "Set up your master credentials to secure your passwords."
                     : "Enter your master username and password to unlock your vault.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Master Username")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.secondary)
                        TextField("Username", text: $viewModel.inputUsername)
                            .textFieldStyle(.plain)
                    }
                    .padding(10)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Master Password")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.secondary)
                        SecureField("Master Password", text: $viewModel.inputPassword)
                            .textFieldStyle(.plain)
                    }
                    .padding(10)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                }

                if viewModel.isSetupRequired {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Master Password")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.secondary)
                            SecureField("Confirm Password", text: $viewModel.inputConfirmPassword)
                                .textFieldStyle(.plain)
                        }
                        .padding(10)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                }

                if let errorMessage = viewModel.authErrorMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .padding(.top, 4)
                    .transition(.opacity)
                }

                Button(action: {
                    if viewModel.isSetupRequired {
                        viewModel.handleMasterSetup()
                    } else {
                        viewModel.handleMasterLogin()
                    }
                }) {
                    HStack {
                        Text(viewModel.isSetupRequired ? "Create & Unlock Vault" : "Unlock Vault")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 8)
            }
            .padding(24)
            .background(.thinMaterial)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            .frame(width: 360)

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                Text("AES-256 Encrypted Local Protection")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.bottom, 16)
        }
        .frame(minWidth: 700, minHeight: 520)
    }
}
