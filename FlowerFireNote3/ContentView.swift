import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var feedStore = UnsplashFeedStore()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FavoritePost.createdAt, order: .reverse) private var favoritePosts: [FavoritePost]

    var body: some View {
        NavigationStack {
            TabView {
                HomeView(store: feedStore, favoriteIDs: favoriteIDs, onToggleFavorite: toggleFavorite)
                    .tabItem {
                        Label("首页", systemImage: "house")
                    }

                PublishView()
                    .tabItem {
                        Label("发布", systemImage: "plus.square")
                    }

                ProfileView(favorites: favoritePosts.map(\.inspirationPost), favoriteIDs: favoriteIDs, onToggleFavorite: toggleFavorite)
                    .tabItem {
                        Label("我的", systemImage: "person")
                    }
            }
            .tint(HuahuoTheme.accent)
            .navigationDestination(for: InspirationPost.self) { post in
                PostDetailView(post: resolvedPost(post), isFavorite: favoriteIDs.contains(post.id), onToggleFavorite: toggleFavorite)
            }
        }
    }

    private var favoriteIDs: Set<InspirationPost.ID> {
        Set(favoritePosts.map(\.postID))
    }

    private func resolvedPost(_ post: InspirationPost) -> InspirationPost {
        if let feedPost = feedStore.post(id: post.id) {
            return feedPost
        }
        return favoritePosts.first { $0.postID == post.id }?.inspirationPost ?? post
    }

    private func toggleFavorite(_ post: InspirationPost) {
        if let favorite = favoritePosts.first(where: { $0.postID == post.id }) {
            modelContext.delete(favorite)
        } else {
            modelContext.insert(FavoritePost(post: post))
        }

        try? modelContext.save()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: FavoritePost.self, inMemory: true)
}
