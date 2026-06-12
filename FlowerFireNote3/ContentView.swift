import SwiftUI

struct ContentView: View {
    @State private var posts = InspirationPost.samples

    var body: some View {
        NavigationStack {
            TabView {
                HomeView(posts: $posts)
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
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return nil }
        return $posts[index]
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
