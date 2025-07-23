import SwiftUI

/**
 *A styled save button component for chart entries*
 
 This component provides a consistent save button design for chart
 entries using the Pluckr theme.
 
 ## Usage
 ```swift
 SaveButtonView(
     isSaving: false,
     treatmentArea: "Face",
     chartId: nil
 ) {
     // Save action
 }
 ```
 */
struct SaveButtonView: View {
    let isSaving: Bool
    let treatmentArea: String
    let chartId: String?
    let onSaveTapped: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Button(action: onSaveTapped) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(chartId == nil ? "Save Chart Entry" : "Update Chart")
                        .font(PluckrTheme.bodyFont(size: 17))
                        .foregroundColor(.white)
                }
            }
            .pluckrButton(small: true)
            .disabled(isSaving || treatmentArea.isEmpty)
            .opacity((isSaving || treatmentArea.isEmpty) ? 0.6 : 1.0)
            
            if treatmentArea.isEmpty {
                Text("Please select a treatment area")
                    .font(PluckrTheme.captionFont())
                    .foregroundColor(PluckrTheme.textSecondary)
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack(spacing: 16) {
        SaveButtonView(
            isSaving: false,
            treatmentArea: "Face",
            chartId: nil
        ) {
            print("Save tapped")
        }
        
        SaveButtonView(
            isSaving: true,
            treatmentArea: "Face",
            chartId: "chart123"
        ) {
            print("Update tapped")
        }
        
        SaveButtonView(
            isSaving: false,
            treatmentArea: "",
            chartId: nil
        ) {
            print("Save tapped")
        }
    }
    .padding()
    .background(PluckrTheme.background)
}
