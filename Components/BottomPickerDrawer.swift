// MARK: - BottomPickerDrawer.swift

import SwiftUI

struct BottomPickerDrawer: View {
    let title: String
    @Binding var isPresented: Bool
    @Binding var value: Double
    let range: ClosedRange<Double>   // Represented in hundredths (e.g. 50...30000 for 0.5...300.0)
    let unit: String

    var body: some View {
        if isPresented {
            ZStack {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isPresented = false
                    }

                // Picker container
                VStack(spacing: 0) {
                    Text(title)
                        .font(.headline)
                        .padding(.top)
                        .padding(.bottom, 4)

                    Divider()

                    Picker(title, selection: Binding(
                        get: {
                            // Clamp to range in case value gets out of sync
                            min(max(value, range.lowerBound), range.upperBound)
                        },
                        set: {
                            value = $0
                        }
                    )) {
                        ForEach(Array(stride(from: range.lowerBound, through: range.upperBound, by: 0.1)), id: \.self) { level in
                            Text("\(level, specifier: "%.1f") \(unit)")
                                .tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 160)

                    Divider()

                    Button("Done") {
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut, value: isPresented)
            }
        }
    }
}
