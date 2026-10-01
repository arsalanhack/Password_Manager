import SwiftUI
import AppKit

@main
struct PasswordManagerApp: App {
    @StateObject private var viewModel = VaultViewModel()

    init() {
        // Force macOS to treat the binary as a active GUI app with keyboard focus when launched via `swift run`
        NSApplication.shared.setActivationPolicy(.regular)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if viewModel.isAuthenticated {
                    MainVaultView(viewModel: viewModel)
                } else {
                    AuthenticationView(viewModel: viewModel)
                }
            }
            .frame(minWidth: 800, minHeight: 520)
            .onAppear {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
}
