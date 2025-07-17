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
        let tagColor = tag.color
        let textColor: Color = tagColor.isLight ? .primary : .white
        return Text(tag.label)
            .font(.system(size: 11, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(tagColor.opacity(0.15))
            .foregroundColor(textColor)
            .cornerRadius(8)
            .overlay(
                Group {
                    if isSelected {
                        Image(systemName: "xmark")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(textColor.opacity(0.8))
                            .offset(x: 8, y: -6)
                    }
                }, alignment: .topTrailing
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
