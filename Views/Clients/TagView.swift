import SwiftUI

struct TagView: View {
    enum Size { case normal, large }
    let tag: Tag
    let isSelected: Bool
    let onTap: (() -> Void)?
    let size: Size
    
    init(tag: Tag, isSelected: Bool = false, onTap: (() -> Void)? = nil, size: Size = .normal) {
        self.tag = tag
        self.isSelected = isSelected
        self.onTap = onTap
        self.size = size
    }
    
    // MARK: - Legacy Support
    init(text: String) {
        self.tag = Tag(label: text)
        self.isSelected = false
        self.onTap = nil
        self.size = .normal
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
        let (fontSize, hPad, vPad, corner): (CGFloat, CGFloat, CGFloat, CGFloat) = {
            switch size {
            case .normal: return (11, 8, 3, 8)
            case .large: return (17, 16, 7, 16)
            }
        }()
        return Text(tag.label)
            .font(.system(size: fontSize, weight: .medium))
            .padding(.horizontal, hPad)
            .padding(.vertical, vPad)
            .background(tagColor.opacity(0.15))
            .foregroundColor(textColor)
            .cornerRadius(corner)
            .lineLimit(1)
            .truncationMode(.tail)
            .overlay(
                Group {
                    if isSelected {
                        Image(systemName: "xmark")
                            .font(.system(size: fontSize * 0.7, weight: .bold))
                            .foregroundColor(textColor.opacity(0.8))
                            .offset(x: hPad, y: -vPad)
                    }
                }, alignment: .topTrailing
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
