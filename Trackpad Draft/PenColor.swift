import SwiftUI

enum PenColor: String, CaseIterable, Identifiable {
    case black, red, orange, green, blue, purple

    var id: String { rawValue }

    // Fixed ink colors stay legible on the white canvas in either system appearance.
    var color: Color {
        switch self {
        case .black: return .black
        case .red: return Color(.sRGB, red: 0.78, green: 0.12, blue: 0.16)
        case .orange: return Color(.sRGB, red: 0.78, green: 0.35, blue: 0.06)
        case .green: return Color(.sRGB, red: 0.10, green: 0.47, blue: 0.24)
        case .blue: return Color(.sRGB, red: 0.12, green: 0.33, blue: 0.78)
        case .purple: return Color(.sRGB, red: 0.50, green: 0.22, blue: 0.70)
        }
    }

    var localizedName: String {
        switch self {
        case .black: return L10n.current == .zh ? "黑色" : "Black"
        case .red: return L10n.current == .zh ? "红色" : "Red"
        case .orange: return L10n.current == .zh ? "橙色" : "Orange"
        case .green: return L10n.current == .zh ? "绿色" : "Green"
        case .blue: return L10n.current == .zh ? "蓝色" : "Blue"
        case .purple: return L10n.current == .zh ? "紫色" : "Purple"
        }
    }
}
