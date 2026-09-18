import SwiftUI

enum ProjectColor: String, Codable, CaseIterable, Identifiable, Hashable {
    case ocean
    case indigo
    case violet
    case rose
    case coral
    case amber
    case mint
    case teal
    case sky
    case graphite

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }

    var accent: Color {
        switch self {
        case .ocean: Color(hue: 0.56, saturation: 0.72, brightness: 0.82)
        case .indigo: Color(hue: 0.67, saturation: 0.65, brightness: 0.84)
        case .violet: Color(hue: 0.76, saturation: 0.64, brightness: 0.86)
        case .rose: Color(hue: 0.94, saturation: 0.62, brightness: 0.86)
        case .coral: Color(hue: 0.02, saturation: 0.68, brightness: 0.88)
        case .amber: Color(hue: 0.11, saturation: 0.75, brightness: 0.88)
        case .mint: Color(hue: 0.42, saturation: 0.58, brightness: 0.78)
        case .teal: Color(hue: 0.49, saturation: 0.66, brightness: 0.76)
        case .sky: Color(hue: 0.58, saturation: 0.50, brightness: 0.92)
        case .graphite: Color(hue: 0.60, saturation: 0.12, brightness: 0.58)
        }
    }

    var softFill: Color { accent.opacity(0.13) }
}
