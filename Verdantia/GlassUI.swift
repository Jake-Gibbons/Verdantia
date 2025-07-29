import SwiftUI

// MARK: - Glass UI Modifier
struct GlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(radius: 4)
    }
}

extension View {
    func glassCard() -> some View {
        self.modifier(GlassCard())
    }
}

