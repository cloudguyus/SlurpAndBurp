import SwiftUI

@main
struct SlurpAndBurpApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                #if os(iOS)
                .statusBarHidden(true)
                .persistentSystemOverlays(.hidden)
                #endif
        }
        #if os(macOS)
        .defaultSize(width: 1100, height: 760)
        .windowResizability(.contentMinSize)
        #endif
        .commands {
            CommandGroup(replacing: .newItem) { }
        }
    }
}
