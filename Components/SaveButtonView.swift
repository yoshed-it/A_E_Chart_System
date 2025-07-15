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
        VStack(spacing: PluckrTheme.spacing) {
            Button(action: onSaveTapped) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(chartId == nil ? "Save Chart Entry" : "Update Chart")
                        .font(.journalSubtitle)
                        .fontWeight(.semibold)
                }
            }
            .buttonStyle(PluckrButtonStyle())
            .disabled(isSaving || treatmentArea.isEmpty)
            .opacity((isSaving || treatmentArea.isEmpty) ? 0.6 : 1.0)
            
            if treatmentArea.isEmpty {
                Text("Please select a treatment area")
                    .font(.journalCaption)
                    .foregroundColor(PluckrTheme.secondaryColor)
            }
        }
        .padding(.horizontal, PluckrTheme.padding)
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
    .background(PluckrTheme.backgroundColor)
}
