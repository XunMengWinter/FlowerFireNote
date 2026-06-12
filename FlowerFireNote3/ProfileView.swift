import SwiftUI

struct ProfileView: View {
    let favorites: [InspirationPost]
    let favoriteIDs: Set<InspirationPost.ID>
    var onToggleFavorite: (InspirationPost) -> Void

    var body: some View {
        ZStack {
            Color.clear.huahuoBackground()

            VStack(spacing: 14) {
                FavoriteSectionHeader(count: favorites.count)

                if favorites.isEmpty {
                    Spacer(minLength: 0)
                    EmptyFavoritesView()
                    Spacer(minLength: 0)
                } else {
                    ScrollView(showsIndicators: false) {
                        FavoriteGrid(favorites: favorites, favoriteIDs: favoriteIDs, onToggleFavorite: onToggleFavorite)
                        .padding(.bottom, 22)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, favorites.isEmpty ? 24 : 0)
        }
        .navigationBarHidden(true)
    }
}

private struct FavoriteSectionHeader: View {
    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("我的收藏")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuoTheme.foreground)

                Text("摄影 / 插画灵感")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HuahuoTheme.muted)
            }

            Spacer()

            Text("\(count) 条")
                .font(.system(size: 12, weight: .heavy))
                .foregroundStyle(HuahuoTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.70), in: Capsule())
        }
        .padding(.top, 2)
    }
}

private struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "heart")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(HuahuoTheme.accent)
                .frame(width: 88, height: 88)
                .background(
                    LinearGradient(colors: [HuahuoTheme.butter, HuahuoTheme.rose], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: RoundedRectangle(cornerRadius: 31, style: .continuous)
                )

            Text("还没有收藏")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HuahuoTheme.muted)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 498)
        .padding(24)
        .glassCard(cornerRadius: 34)
    }
}

private struct FavoriteGrid: View {
    let favorites: [InspirationPost]
    let favoriteIDs: Set<InspirationPost.ID>
    var onToggleFavorite: (InspirationPost) -> Void

    var body: some View {
        let columns = balancedColumns(for: favorites)
        HStack(alignment: .top, spacing: 12) {
            ForEach(columns.indices, id: \.self) { columnIndex in
                LazyVStack(spacing: 12) {
                    ForEach(Array(columns[columnIndex].enumerated()), id: \.element.id) { itemIndex, post in
                        NavigationLink(value: post) {
                            FavoritePostCard(
                                post: post,
                                isFavorite: favoriteIDs.contains(post.id),
                                rotation: itemIndex.isMultiple(of: 2) ? -5 : 5,
                                onToggleFavorite: onToggleFavorite
                            )
                        }
                        .buttonStyle(.plain)
                    }
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
}

private struct FavoritePostCard: View {
    let post: InspirationPost
    let isFavorite: Bool
    var rotation: Double
    var onToggleFavorite: (InspirationPost) -> Void

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
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(isFavorite ? HuahuoTheme.accent : HuahuoTheme.muted)
                            .frame(width: 28, height: 28)
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isFavorite ? "取消收藏 \(post.title)" : "收藏 \(post.title)")
                }
            }
            .padding(10)
        }
        .glassCard(cornerRadius: 22)
    }
}
