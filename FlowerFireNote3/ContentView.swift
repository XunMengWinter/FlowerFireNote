import SwiftUI

struct ContentView: View {
    @StateObject private var feedStore = UnsplashFeedStore()

    var body: some View {
        NavigationStack {
            TabView {
                HomeView(store: feedStore)
                    .tabItem {
                        Label("首页", systemImage: "house")
                    }

                PublishView()
                    .tabItem {
                        Label("发布", systemImage: "plus.square")
                    }

                ProfileView()
                    .tabItem {
                        Label("我的", systemImage: "person")
                    }
            }
            .tint(HuahuoTheme.accent)
            .navigationDestination(for: InspirationPost.ID.self) { id in
                if let post = postBinding(id) {
                    PostDetailView(post: post)
                } else {
                    MissingPostView()
                }
            }
        }
    }

    private func postBinding(_ id: InspirationPost.ID) -> Binding<InspirationPost>? {
        guard feedStore.post(id: id) != nil else { return nil }
        return Binding {
            feedStore.post(id: id) ?? InspirationPost.samples[0]
        } set: { updatedPost in
            feedStore.update(updatedPost)
        }
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

#Preview {
    ContentView()
}
