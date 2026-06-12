import SwiftUI

struct HomeView: View {
    @Binding var posts: [InspirationPost]
    @State private var searchText = ""
    @State private var selectedChannel = "今日灵感"

    private let channels = ["今日灵感", "摄影", "插画", "胶片感", "配色"]

    var body: some View {
        ZStack {
            Color.clear.huahuoBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    BrandHeader()
                    SearchField(text: $searchText)
                    ChannelStrip(channels: channels, selected: $selectedChannel)
                    FeedGrid(visiblePosts: filteredPosts, allPosts: $posts, onToggleLike: toggleLike)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 22)
            }
        }
        .navigationBarHidden(true)
        .onChange(of: selectedChannel) { _, newValue in
            searchText = newValue == "今日灵感" ? "" : newValue
        }
    }

    private var filteredPosts: [InspirationPost] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return posts }

        return posts.filter { post in
            let text = "\(post.title) \(post.author) \(post.copy) \(post.tags.joined(separator: " "))"
            return text.localizedCaseInsensitiveContains(keyword)
        }
    }

    private func toggleLike(_ id: InspirationPost.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].liked.toggle()
        posts[index].likes += posts[index].liked ? 1 : -1
    }
}

private struct FeedGrid: View {
    let visiblePosts: [InspirationPost]
    @Binding var allPosts: [InspirationPost]
    var onToggleLike: (InspirationPost.ID) -> Void

    var body: some View {
        if visiblePosts.isEmpty {
            EmptyFeedView()
        } else {
            let columns = balancedColumns(for: visiblePosts)
            HStack(alignment: .top, spacing: 12) {
                ForEach(columns.indices, id: \.self) { columnIndex in
                    LazyVStack(spacing: 12) {
                        ForEach(Array(columns[columnIndex].enumerated()), id: \.element.id) { itemIndex, post in
                            NavigationLink(value: post.id) {
                                PostCard(post: post, rotation: itemIndex.isMultiple(of: 2) ? -5 : 5, onToggleLike: onToggleLike)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationDestination(for: InspirationPost.ID.self) { id in
                if let post = postBinding(id) {
                    PostDetailView(post: post)
                } else {
                    MissingPostView()
                }
            }
        }
    }

    private func balancedColumns(for posts: [InspirationPost]) -> [[InspirationPost]] {
        var columns = Array(repeating: [InspirationPost](), count: 2)
        var heights = Array(repeating: 0.0, count: 2)

        for post in posts {
            let target = heights[0] <= heights[1] ? 0 : 1
            columns[target].append(post)
            heights[target] += post.heightWeight
        }

        return columns
    }

    private func postBinding(_ id: InspirationPost.ID) -> Binding<InspirationPost>? {
        guard let index = allPosts.firstIndex(where: { $0.id == id }) else { return nil }
        return $allPosts[index]
    }
}

private struct PostCard: View {
    let post: InspirationPost
    var rotation: Double
    var onToggleLike: (InspirationPost.ID) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ArtworkView(style: post.style, rotation: rotation, cornerRadius: 22)
                .aspectRatio(post.size.aspectRatio, contentMode: .fit)

            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuoTheme.foreground)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    HStack(spacing: 5) {
                        AvatarView()
                        Text(post.author)
                            .lineLimit(1)
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(HuahuoTheme.muted)

                    Spacer(minLength: 4)

                    Button {
                        onToggleLike(post.id)
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: post.liked ? "heart.fill" : "heart")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(post.likes)")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(post.liked ? HuahuoTheme.accent : HuahuoTheme.muted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(post.liked ? "取消喜欢 \(post.title)" : "喜欢 \(post.title)")
                }
            }
            .padding(10)
        }
        .glassCard(cornerRadius: 22)
    }
}

private struct EmptyFeedView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "sparkles")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(HuahuoTheme.accent)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [HuahuoTheme.butter, HuahuoTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 31, style: .continuous)
                )

            Text("没有找到相关灵感")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuoTheme.foreground)

            Text("换一个关键词试试，比如胶片、窗边光或拼贴。")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HuahuoTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .padding(24)
        .glassCard(cornerRadius: 34)
    }
}

private struct MissingPostView: View {
    var body: some View {
        Text("这条灵感暂时不可用")
            .foregroundStyle(HuahuoTheme.muted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .huahuoBackground()
    }
}
