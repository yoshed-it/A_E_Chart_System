// MARK: - BottomPickerDrawer.swift

import SwiftUI

/**
 *Bottom sheet picker for machine settings*
 
 This component provides a native iOS-style bottom sheet picker for
 selecting RF and DC levels with proper styling and animations.
 
 ## Usage
 ```swift
 BottomPickerDrawer(
     title: "RF Level",
     isPresented: $showRfWheel,
     value: $viewModel.rfLevel,
     range: 0.1...300.0,
     unit: "MHz"
 )
 ```
 */
struct BottomPickerDrawer: View {
    let title: String
    @Binding var isPresented: Bool
    @Binding var value: Double
    let range: ClosedRange<Double>
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
                    // Header
                    HStack {
                        Button("Cancel") {
                            isPresented = false
                        }
                        .font(.journalBody)
                        .foregroundColor(PluckrTheme.accentColor)
                        
                        Spacer()
                        
                        Text(title)
                            .font(.journalSubtitle)
                            .fontWeight(.semibold)
                            .foregroundColor(PluckrTheme.primaryColor)
                        
                        Spacer()
                        
                        Button("Done") {
                            isPresented = false
                        }
                        .font(.journalBody)
                        .fontWeight(.semibold)
                        .foregroundColor(PluckrTheme.primaryColor)
                    }
                    .padding(.horizontal, PluckrTheme.padding)
                    .padding(.vertical, PluckrTheme.spacing)

                    Divider()
                        .background(PluckrTheme.borderColor)

                    // Picker
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
                                .font(.journalBody)
                                .tag(level)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 160)
                }
                .background(Color(.systemBackground))
                .cornerRadius(PluckrTheme.cornerRadius * 2)
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .padding(.horizontal, PluckrTheme.padding)
                .padding(.bottom, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: isPresented)
            }
        }
    }
}

#Preview {
    BottomPickerDrawer(
        title: "RF Level",
        isPresented: .constant(true),
        value: .constant(15.0),
        range: 0.1...300.0,
        unit: "MHz"
    )
}
