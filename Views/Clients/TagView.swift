import SwiftUI

struct TagView: View {
    let tag: Tag
    let isSelected: Bool
    let onTap: (() -> Void)?
    
    init(tag: Tag, isSelected: Bool = false, onTap: (() -> Void)? = nil) {
        self.tag = tag
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    // MARK: - Legacy Support
    init(text: String) {
        self.tag = Tag(label: text)
        self.isSelected = false
        self.onTap = nil
    }

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    tagContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                tagContent
            }
        }
    }
    
    private var tagContent: some View {
        HStack(spacing: 4) {
            Text(tag.label)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if isSelected {
                Image(systemName: "xmark")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(isSelected ? tag.color : Color(.systemGray6))
                .overlay(
                    Capsule()
                        .stroke(isSelected ? tag.color : tag.color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
                )
        )
        .foregroundColor(isSelected ? .white : tag.color)
        .shadow(color: isSelected ? tag.color.opacity(0.3) : .clear, radius: 2, x: 0, y: 1)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
