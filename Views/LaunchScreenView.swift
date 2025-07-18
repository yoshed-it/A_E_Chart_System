import SwiftUI

struct LaunchScreenView: View {
    var body: some View {
        ZStack {
            // Background
            Image("LaunchScreen")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Logo overlay
            VStack(spacing: 20) {
                
                VStack(spacing: 8) {
                    Text("Pluckr")
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    
                    Text("Clinical Journal")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
        }
    }
}

#Preview {
    LaunchScreenView()
} 
