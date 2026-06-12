import SwiftUI

enum HuahuoTheme {
    static let background = Color(red: 0.99, green: 0.96, blue: 0.99)
    static let surface = Color.white
    static let foreground = Color(red: 0.20, green: 0.17, blue: 0.25)
    static let muted = Color(red: 0.50, green: 0.47, blue: 0.56)
    static let border = Color(red: 0.92, green: 0.88, blue: 0.95)
    static let accent = Color(red: 0.91, green: 0.35, blue: 0.43)
    static let mint = Color(red: 0.75, green: 0.93, blue: 0.84)
    static let sky = Color(red: 0.79, green: 0.90, blue: 1.00)
    static let lilac = Color(red: 0.89, green: 0.81, blue: 0.96)
    static let butter = Color(red: 0.97, green: 0.91, blue: 0.64)
    static let peach = Color(red: 0.96, green: 0.76, blue: 0.62)
    static let rose = Color(red: 0.97, green: 0.79, blue: 0.83)
    static let shadow = Color(red: 0.28, green: 0.23, blue: 0.36).opacity(0.13)
}

extension View {
    func glassCard(cornerRadius: CGFloat = 24, shadow: Bool = true) -> some View {
        background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(.white.opacity(0.72), lineWidth: 1)
            }
            .shadow(color: shadow ? HuahuoTheme.shadow : .clear, radius: shadow ? 18 : 0, y: shadow ? 10 : 0)
    }

    func huahuoBackground() -> some View {
        background {
            ZStack {
                LinearGradient(
                    colors: [HuahuoTheme.rose, HuahuoTheme.sky, HuahuoTheme.butter],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                RadialGradient(
                    colors: [HuahuoTheme.butter.opacity(0.85), .clear],
                    center: .topLeading,
                    startRadius: 20,
                    endRadius: 260
                )
                RadialGradient(
                    colors: [HuahuoTheme.lilac.opacity(0.82), .clear],
                    center: .topTrailing,
                    startRadius: 20,
                    endRadius: 250
                )
                RadialGradient(
                    colors: [HuahuoTheme.mint.opacity(0.80), .clear],
                    center: .bottomLeading,
                    startRadius: 20,
                    endRadius: 280
                )
            }
            .ignoresSafeArea()
        }
    }
}
