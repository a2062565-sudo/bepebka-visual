import SwiftUI

// MARK: - Ambient app background

struct AmbientBackground: View {
    @EnvironmentObject private var store: ClientStore
    @State private var drift = false

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let accent = store.accentColor

            ZStack {
                LinearGradient(
                    colors: store.theme.backgroundColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [accent.opacity(0.30), accent.opacity(0.08), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: max(size.width, size.height) * 0.44
                        )
                    )
                    .frame(width: max(size.width, size.height) * 0.9)
                    .blur(radius: 70)
                    .position(
                        x: drift ? size.width * 0.16 : size.width * 0.32,
                        y: drift ? size.height * 0.12 : size.height * 0.24
                    )
                    .opacity(0.65)

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "#2563EB").opacity(0.16), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: max(size.width, size.height) * 0.38
                        )
                    )
                    .frame(width: max(size.width, size.height) * 0.8)
                    .blur(radius: 80)
                    .position(
                        x: drift ? size.width * 0.86 : size.width * 0.72,
                        y: drift ? size.height * 0.82 : size.height * 0.66
                    )

                GridOverlay()
                    .opacity(0.055)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.35)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .frame(width: size.width, height: size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            guard store.settings.ui.animationsEnabled else { return }
            withAnimation(.easeInOut(duration: 18).repeatForever(autoreverses: true)) {
                drift = true
            }
        }
        .onChange(of: store.settings.ui.animationsEnabled) { _, enabled in
            if !enabled {
                withAnimation(.easeOut(duration: 0.5)) { drift = false }
            }
        }
    }
}

private struct GridOverlay: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 64
            var path = Path()

            var x: CGFloat = 0
            while x <= size.width {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: size.height))
                x += spacing
            }

            var y: CGFloat = 0
            while y <= size.height {
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                y += spacing
            }

            context.stroke(path, with: .color(.white), lineWidth: 0.5)
        }
        .ignoresSafeArea()
        .mask(
            LinearGradient(
                colors: [.clear, .white.opacity(0.6), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Logo

struct BVLogoMark: View {
    @EnvironmentObject private var store: ClientStore
    var size: CGFloat = 38
    var showSparkle: Bool = true

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#1B1C22"), Color(hex: "#050506")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: size * 0.3, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [store.accentColor.opacity(0.9), .white.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )

            Text("B")
                .font(.system(size: size * 0.54, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color.white.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .offset(y: -size * 0.015)

            if showSparkle {
                Image(systemName: "sparkle")
                    .font(.system(size: size * 0.19, weight: .bold))
                    .foregroundStyle(store.accentColor)
                    .offset(x: size * 0.27, y: -size * 0.27)
            }
        }
        .frame(width: size, height: size)
        .shadow(color: store.accentColor.opacity(0.28), radius: size * 0.4, y: 4)
    }
}

// MARK: - Preview surfaces

struct PreviewSurface<Content: View>: View {
    var height: CGFloat?
    var cornerRadius: CGFloat = 20
    var contentPadding: CGFloat = 0
    @ViewBuilder var content: Content

    init(
        height: CGFloat? = nil,
        cornerRadius: CGFloat = 20,
        contentPadding: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.height = height
        self.cornerRadius = cornerRadius
        self.contentPadding = contentPadding
        self.content = content()
    }

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "#101116"), Color(hex: "#050507")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.14), .white.opacity(0.035)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.8
                    )
            )
            .shadow(color: .black.opacity(0.35), radius: 24, y: 14)
    }
}

struct DisabledPreviewOverlay: View {
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.black.opacity(0.48))
                .background(.ultraThinMaterial)

            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                Text(title)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .tracking(1.3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
