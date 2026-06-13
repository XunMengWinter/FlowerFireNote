import Combine
import SwiftUI

struct HomeView: View {
    @ObservedObject var store: UnsplashFeedStore
    let favoriteIDs: Set<InspirationPost.ID>
    var onToggleFavorite: (InspirationPost) -> Void
    @State private var searchDraftText = ""
    @State private var submittedSearchText = ""
    @State private var searchSubmissionID = 0
    @State private var selectedChannel = "今日灵感"

    private let channels = ["今日灵感", "摄影", "插画", "胶片感", "配色"]

    var body: some View {
        ZStack {
            Color.clear.huahuoBackground()

            VStack(spacing: 0) {
                VStack(spacing: 14) {
                    BrandHeader()
                    SearchField(text: $searchDraftText, onSubmit: submitSearch)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ChannelStrip(channels: channels, selected: $selectedChannel)
                        feedContent
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                    .padding(.bottom, 22)
                }
//                .border(.green)
            }
        }
        .navigationBarHidden(true)
        .task(id: queryToken) {
            let shouldDebounce = store.hasLoadedContent
            if shouldDebounce {
                try? await Task.sleep(for: .milliseconds(350))
            }
            guard !Task.isCancelled else { return }
            await store.reloadIfNeeded(query: activeQuery, token: queryToken)
        }
        .onChange(of: selectedChannel) { _, _ in
            searchDraftText = ""
            submittedSearchText = ""
        }
    }

    @ViewBuilder
    private var feedContent: some View {
        if store.isLoadingInitial && store.posts.isEmpty {
            LoadingFeedView()
        } else if let errorMessage = store.errorMessage, store.posts.isEmpty {
            ErrorFeedView(message: errorMessage, isRateLimited: store.isRateLimited) {
                Task { await store.retry() }
            }
        } else if store.posts.isEmpty {
            EmptyFeedView()
        } else {
            FeedGrid(postColumns: store.postColumns, favoriteIDs: favoriteIDs, onToggleFavorite: onToggleFavorite)
            FeedFooter(
                isLoading: store.isLoadingPage,
                canLoadMore: store.canLoadMore,
                errorMessage: store.errorMessage,
                isRateLimited: store.isRateLimited,
                onLoadMore: { Task { await store.loadNextPage() } },
                onRetry: { Task { await store.retry() } }
            )
        }
    }

    private var queryToken: String {
        "\(selectedChannel)|\(submittedSearchText)|\(searchSubmissionID)"
    }

    private var activeQuery: String {
        Self.apiQuery(searchText: submittedSearchText, channel: selectedChannel)
    }

    private func submitSearch() {
        submittedSearchText = searchDraftText.trimmingCharacters(in: .whitespacesAndNewlines)
        searchSubmissionID += 1
    }

    private static func apiQuery(searchText: String, channel: String) -> String {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            return translatedQuery(for: trimmed)
        }

        switch channel {
        case "摄影":
            return "editorial photography soft light"
        case "插画":
            return "illustration artwork pastel"
        case "胶片感":
            return "film photography grain"
        case "配色":
            return "pastel color palette photography"
        default:
            return UnsplashConfig.defaultQuery
        }
    }

    private static func translatedQuery(for keyword: String) -> String {
        switch keyword {
        case let value where value.localizedCaseInsensitiveContains("胶片"):
            return "film photography grain"
        case let value where value.localizedCaseInsensitiveContains("插画"):
            return "illustration artwork pastel"
        case let value where value.localizedCaseInsensitiveContains("摄影"):
            return "editorial photography soft light"
        case let value where value.localizedCaseInsensitiveContains("配色"):
            return "pastel color palette"
        case let value where value.localizedCaseInsensitiveContains("窗边"):
            return "window light photography"
        case let value where value.localizedCaseInsensitiveContains("拼贴"):
            return "creative collage art"
        default:
            return keyword
        }
    }
}

private struct FeedGrid: View {
    let postColumns: [[InspirationPost]]
    let favoriteIDs: Set<InspirationPost.ID>
    var onToggleFavorite: (InspirationPost) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ForEach(postColumns.indices, id: \.self) { columnIndex in
                LazyVStack(spacing: 12) {
                    ForEach(postColumns[columnIndex]) { post in
                        NavigationLink(value: post) {
                            PostCard(
                                post: post,
                                isFavorite: favoriteIDs.contains(post.id),
                                rotation: Self.cardRotation(for: post.id),
                                onToggleFavorite: onToggleFavorite
                            )
                            .equatable()
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }

    private static func cardRotation(for id: InspirationPost.ID) -> Double {
        let seed = id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return seed.isMultiple(of: 2) ? -5 : 5
    }
}

private struct PostCard: View, Equatable {
    let post: InspirationPost
    let isFavorite: Bool
    var rotation: Double
    var onToggleFavorite: (InspirationPost) -> Void

    static func == (lhs: PostCard, rhs: PostCard) -> Bool {
        lhs.post == rhs.post &&
            lhs.isFavorite == rhs.isFavorite &&
            lhs.rotation == rhs.rotation
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RemoteArtworkView(url: post.imageURL, style: post.style, rotation: rotation, cornerRadius: 22)
                .aspectRatio(post.imageAspectRatio, contentMode: .fit)

            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuoTheme.foreground)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 6) {
                    HStack(spacing: 5) {
                        AvatarView(imageURL: post.authorAvatarURL)
                        Text(post.author)
                            .lineLimit(1)
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(HuahuoTheme.muted)

                    Spacer(minLength: 4)

                    Button {
                        onToggleFavorite(post)
                    } label: {
                        HStack(spacing: 3) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 12, weight: .semibold))
                            Text("\(post.likes)")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundStyle(isFavorite ? HuahuoTheme.accent : HuahuoTheme.muted)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isFavorite ? "取消收藏 \(post.title)" : "收藏 \(post.title)")
                }
            }
            .padding(10)
        }
        .glassCard(cornerRadius: 22, shadow: false)
    }
}

private struct FeedFooter: View {
    let isLoading: Bool
    let canLoadMore: Bool
    let errorMessage: String?
    let isRateLimited: Bool
    var onLoadMore: () -> Void
    var onRetry: () -> Void

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .tint(HuahuoTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            } else if let errorMessage {
                VStack(spacing: 8) {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(HuahuoTheme.muted)
                        .multilineTextAlignment(.center)
                    if isRateLimited {
                        Text("额度恢复后再搜索")
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundStyle(HuahuoTheme.accent)
                    } else {
                        Button("重试", action: onRetry)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14)
                            .frame(height: 34)
                            .background(HuahuoTheme.accent, in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            } else if canLoadMore {
                Color.clear
                    .frame(height: 1)
                    .onAppear(perform: onLoadMore)
            }
        }
    }
}

private struct LoadingFeedView: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(HuahuoTheme.accent)
                .scaleEffect(1.12)

            Text("正在寻找花火灵感")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuoTheme.foreground)

            Text("从 Unsplash 拉取摄影和插画参考。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(HuahuoTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .padding(24)
        .glassCard(cornerRadius: 34)
    }
}

private struct ErrorFeedView: View {
    let message: String
    let isRateLimited: Bool
    var onRetry: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(HuahuoTheme.accent)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [HuahuoTheme.butter, HuahuoTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 31, style: .continuous)
                )

            Text(isRateLimited ? "Unsplash 额度已用完" : "图片加载失败")
                .font(.system(size: 24, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuoTheme.foreground)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HuahuoTheme.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            if !isRateLimited {
                Button("重试", action: onRetry)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(height: 42)
                    .padding(.horizontal, 22)
                    .background(HuahuoTheme.accent, in: Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .padding(24)
        .glassCard(cornerRadius: 34)
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
