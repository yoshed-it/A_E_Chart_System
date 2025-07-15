import SwiftUI

struct TagPickerModal: View {
    @Binding var selectedTags: [ChartTag]
    let availableTags: [ChartTag]
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .frame(width: 40, height: 6)
                .foregroundColor(Color(.systemGray4))
                .padding(.top, 8)
            Text("Select Tags")
                .font(.headline)
                .padding(.top, 16)
            ScrollView(.vertical) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 12) {
                    ForEach(availableTags, id: \.self) { tag in
                        Button(action: {
                            if selectedTags.contains(tag) {
                                selectedTags.removeAll { $0 == tag }
                            } else {
                                selectedTags.append(tag)
                            }
                        }) {
                            HStack {
                                Text(tag.label)
                                    .foregroundColor(selectedTags.contains(tag) ? .white : .primary)
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedTags.contains(tag) ? Color.accentColor : Color.gray.opacity(0.2))
                            .cornerRadius(20)
                            .shadow(color: selectedTags.contains(tag) ? Color.accentColor.opacity(0.2) : .clear, radius: 6, x: 0, y: 2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            Button("Done") { dismiss() }
                .font(.headline)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding([.horizontal, .bottom])
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(radius: 16)
        )
    }
} 