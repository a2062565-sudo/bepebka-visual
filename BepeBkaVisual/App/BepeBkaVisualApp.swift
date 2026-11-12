import SwiftUI

@main
struct BepeBkaVisualApp: App {
    @StateObject private var store = ClientStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .statusBarHidden(false)
        }
    }
}
