//
//  Category.swift
//  LastIDid
//
//  Created by Andrew Collins on 1/20/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var systemIcon: String      // SF Symbol name
    var colorHex: String
    var sortOrder: Int
    var isSystemCategory: Bool
    var activities: [Activity] = []

    init(name: String, systemIcon: String, colorHex: String, sortOrder: Int, isSystemCategory: Bool = false) {
        self.id = UUID()
        self.name = name
        self.systemIcon = systemIcon
        self.colorHex = colorHex
        self.sortOrder = sortOrder
        self.isSystemCategory = isSystemCategory
    }

    var color: Color {
        Color(hex: colorHex) ?? .gray
    }

    // System categories for seeding on first launch
    static let systemCategories: [(name: String, icon: String, colorHex: String)] = [
        ("Home", "house.fill", "F97316"),           // Orange
        ("Health", "heart.fill", "EF4444"),         // Red
        ("Car", "car.fill", "3B82F6"),              // Blue
        ("Digital", "laptopcomputer", "8B5CF6"),    // Purple
        ("Finance", "dollarsign.circle.fill", "22C55E"), // Green
        ("Personal", "person.fill", "EC4899")       // Pink
    ]
}

// MARK: - Color Extension for Hex Support
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }

    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else { return "808080" }
        let r = Int(components[0] * 255)
        let g = Int(components.count > 1 ? components[1] * 255 : components[0] * 255)
        let b = Int(components.count > 2 ? components[2] * 255 : components[0] * 255)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}
