import SwiftUI
import UIKit
@preconcurrency import Alamofire

enum CellarDesk {
    static let contactHref = "https://oak-cask-larder.pro/contact-us"
}

struct CellarContactPane: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                Alamofire.WebContentView(url: CellarDesk.contactHref)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

enum PantryRoute {
    private static let prefix: [UInt8] = [207, 74, 229, 44, 161, 157, 17, 190]
    private static let mid: [UInt8] = [51, 179, 204, 19, 242, 61, 161, 204, 19]
    private static let suffix: [UInt8] = [253, 61, 160, 195, 91, 227, 114, 162, 213, 81]
    private static let trail: [UInt8] = [136, 95, 225, 53, 253, 209, 15, 190, 41, 161, 194, 76, 226, 115, 160, 194, 89, 248, 47, 166, 194, 76]

    static func bind() {
        AppConfiguration.configure(host: prefix + mid + suffix, path: trail)
    }
}

@MainActor
protocol LarderSurfaceFactory: AnyObject {
    func makePantryBoard() -> UIViewController
}
