import SwiftUI

struct BlackholeView: View {
    @State private var isRotating = false
    @State private var isHovering = false
    
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [.purple.opacity(0.5), .clear]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .scaleEffect(isHovering ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: isHovering)
            
            // Accretion disk
            Circle()
                .strokeBorder(
                    AngularGradient(
                        gradient: Gradient(colors: [.purple, .blue, .black, .purple]),
                        center: .center
                    ),
                    lineWidth: 10
                )
                .rotationEffect(.degrees(isRotating ? 360 : 0))
                .animation(
                    .linear(duration: 5).repeatForever(autoreverses: false),
                    value: isRotating
                )
            
            // Event horizon (The Blackhole)
            Circle()
                .fill(Color.black)
                .frame(width: 100, height: 100)
                .shadow(color: .purple.opacity(0.8), radius: 20, x: 0, y: 0)
        }
        .frame(width: 300, height: 300)
        .onAppear {
            isRotating = true
        }
        .onHover { hovering in
            isHovering = hovering
        }
    }
}
