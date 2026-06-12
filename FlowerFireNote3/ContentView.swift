import SwiftUI

struct ContentView: View {
    @State private var posts = InspirationPost.samples

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(posts: $posts)
            }
            .tabItem {
                Label("首页", systemImage: "house")
            }

            NavigationStack {
                PublishView()
            }
            .tabItem {
                Label("发布", systemImage: "plus.square")
            }

            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("我的", systemImage: "person")
            }
        }
        .tint(HuahuoTheme.accent)
    }
}

#Preview {
    ContentView()
}
