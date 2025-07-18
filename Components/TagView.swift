import SwiftUI

enum TagSize {
    case normal
    case large
}

struct TagView: View {
    let tag: Tag
    var size: TagSize = .normal
    var onRemove: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 4) {
            Text(tag.label)
                .font(size == .large ? PluckrTheme.bodyFont(size: 14) : PluckrTheme.captionFont())
                .foregroundColor(.primary)
                .padding(.horizontal, size == .large ? 10 : 6)
                .padding(.vertical, size == .large ? 5 : 2)
                .background(Color(tag.colorNameOrHex))
                .cornerRadius(size == .large ? 12 : 8)
                .fixedSize() // Ensures tag expands to fit content and never truncates
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: size == .large ? 14 : 12))
                        .foregroundColor(.secondary)
                        .padding(.leading, 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
} 
