import NukeUI
import SwiftUI

struct BrandHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            SparkMark()

            VStack(alignment: .leading, spacing: 3) {
                Text("花火记")
                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuoTheme.foreground)
                Text("摄影 / 插画灵感")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HuahuoTheme.muted)
            }

            Spacer()

            Button {
            } label: {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .semibold))
                    .frame(width: 42, height: 42)
                    .foregroundStyle(HuahuoTheme.foreground)
            }
            .glassCard(cornerRadius: 21)
            .accessibilityLabel("通知")
        }
    }
}

struct SparkMark: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [HuahuoTheme.accent, HuahuoTheme.peach],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(alignment: .topLeading) {
                Circle()
                    .fill(.white.opacity(0.86))
                    .frame(width: 9, height: 9)
                    .padding(11)
            }
            .frame(width: 38, height: 38)
            .shadow(color: HuahuoTheme.accent.opacity(0.24), radius: 12, y: 7)
    }
}

struct SearchField: View {
    @Binding var text: String
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: 9) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(HuahuoTheme.muted)

            TextField("搜索胶片、窗边光、拼贴...", text: $text)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit(onSubmit)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HuahuoTheme.foreground)

            Text("推荐")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(HuahuoTheme.muted)
                .padding(.horizontal, 9)
                .padding(.vertical, 5)
                .background(.white.opacity(0.58), in: Capsule())
        }
        .frame(height: 42)
        .padding(.horizontal, 12)
        .glassCard(cornerRadius: 21)
    }
}

struct ChannelStrip: View {
    let channels: [String]
    @Binding var selected: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(channels, id: \.self) { channel in
                    Button {
                        selected = channel
                    } label: {
                        Text(channel)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(selected == channel ? HuahuoTheme.foreground : HuahuoTheme.muted)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(selected == channel ? .white.opacity(0.82) : .white.opacity(0.48), in: Capsule())
                            .overlay {
                                Capsule()
                                    .stroke(.white.opacity(0.60), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 2)
        }
    }
}

struct AvatarView: View {
    var imageURL: URL?
    var size: CGFloat = 18

    var body: some View {
        ZStack {
            avatarPlaceholder

            if let imageURL {
                LazyImage(url: imageURL) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                    }
                }
                .frame(width: size, height: size)
            }
        }
        .clipShape(Circle())
        .overlay {
            Circle()
                .stroke(.white.opacity(0.76), lineWidth: max(1, size / 18))
        }
        .frame(width: size, height: size)
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [HuahuoTheme.sky, HuahuoTheme.rose],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }
}

struct RemoteArtworkView: View {
    let url: URL?
    let style: InspirationPost.VisualStyle
    var rotation: Double = -5
    var cornerRadius: CGFloat = 22

    var body: some View {
        Group {
            if let url {
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        ArtworkPlaceholderView(style: style, showsError: state.error != nil)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transaction { transaction in
                    transaction.animation = nil
                }
            } else {
                ArtworkPlaceholderView(style: style, showsError: false)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct ArtworkPlaceholderView: View {
    let style: InspirationPost.VisualStyle
    var showsError: Bool

    var body: some View {
        LinearGradient(
            colors: style.gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            Image(systemName: showsError ? "photo" : "sparkles")
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white.opacity(showsError ? 0.78 : 0.52))
        }
    }
}

struct ArtworkView: View {
    let style: InspirationPost.VisualStyle
    var rotation: Double = -5
    var cornerRadius: CGFloat = 22

    var body: some View {
        ZStack {
            LinearGradient(
                colors: style.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(.white.opacity(0.44))
                .frame(width: 88, height: 88)
                .offset(x: 55, y: -58)

            Circle()
                .fill(.white.opacity(0.40))
                .frame(width: 54, height: 54)
                .offset(x: -52, y: 54)

            MiniScene(rotation: rotation)
                .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

struct MiniScene: View {
    var rotation: Double

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width * 0.76
            let height = proxy.size.height * 0.66

            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.white.opacity(0.24))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.70), lineWidth: 2)
                }
                .overlay(alignment: .bottom) {
                    Capsule()
                        .fill(HuahuoTheme.peach.opacity(0.72))
                        .frame(width: width * 0.58, height: height * 0.25)
                        .offset(y: -height * 0.12)
                }
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(HuahuoTheme.butter.opacity(0.82))
                        .frame(width: 22, height: 22)
                        .padding(.top, height * 0.14)
                        .padding(.trailing, width * 0.15)
                }
                .frame(width: width, height: height)
                .rotationEffect(.degrees(rotation))
                .shadow(color: HuahuoTheme.shadow, radius: 12, y: 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct TagFlow: View {
    let tags: [String]

    var body: some View {
        FlowLayout(spacing: 7, lineSpacing: 7) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(HuahuoTheme.foreground.opacity(0.88))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(.white.opacity(0.58), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.white.opacity(0.72), lineWidth: 1)
                    }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = arrangeRows(proposal: proposal, subviews: subviews)
        let width = proposal.width ?? rows.map(\.width).max() ?? 0
        let height = rows.last.map { $0.y + $0.height } ?? 0
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = arrangeRows(proposal: ProposedViewSize(width: bounds.width, height: proposal.height), subviews: subviews)
        for row in rows {
            for item in row.items {
                subviews[item.index].place(
                    at: CGPoint(x: bounds.minX + item.x, y: bounds.minY + row.y),
                    proposal: ProposedViewSize(item.size)
                )
            }
        }
    }

    private func arrangeRows(proposal: ProposedViewSize, subviews: Subviews) -> [FlowRow] {
        let maxWidth = proposal.width ?? 320
        var rows: [FlowRow] = []
        var currentItems: [FlowItem] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let nextX = currentItems.isEmpty ? 0 : x + spacing

            if nextX + size.width > maxWidth, !currentItems.isEmpty {
                rows.append(FlowRow(items: currentItems, y: y, height: rowHeight, width: x))
                y += rowHeight + lineSpacing
                currentItems = []
                x = 0
                rowHeight = 0
            }

            let itemX = currentItems.isEmpty ? 0 : x + spacing
            currentItems.append(FlowItem(index: index, x: itemX, size: size))
            x = itemX + size.width
            rowHeight = max(rowHeight, size.height)
        }

        if !currentItems.isEmpty {
            rows.append(FlowRow(items: currentItems, y: y, height: rowHeight, width: x))
        }

        return rows
    }

    private struct FlowRow {
        var items: [FlowItem]
        var y: CGFloat
        var height: CGFloat
        var width: CGFloat
    }

    private struct FlowItem {
        var index: Int
        var x: CGFloat
        var size: CGSize
    }
}
