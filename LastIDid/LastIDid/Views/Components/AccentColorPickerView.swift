import SwiftUI

struct AccentColorPickerView: View {
    @Binding var selectedColor: String

    private let columns = [
        GridItem(.adaptive(minimum: 60, maximum: 80), spacing: 16)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(AccentColorOption.allCases) { option in
                ColorCircle(
                    option: option,
                    isSelected: selectedColor == option.rawValue,
                    action: { selectedColor = option.rawValue }
                )
            }
        }
        .padding(.vertical, 8)
    }
}

private struct ColorCircle: View {
    let option: AccentColorOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(option.color)
                        .frame(width: 44, height: 44)

                    if isSelected {
                        Circle()
                            .strokeBorder(.white, lineWidth: 3)
                            .frame(width: 44, height: 44)

                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .shadow(color: option.color.opacity(0.4), radius: isSelected ? 6 : 0)

                Text(option.displayName)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .primary : .secondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selected = "coral"

        var body: some View {
            AccentColorPickerView(selectedColor: $selected)
                .padding()
                .preferredColorScheme(.dark)
        }
    }

    return PreviewWrapper()
}
