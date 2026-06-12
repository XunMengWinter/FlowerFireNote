import SwiftUI

struct PostDetailView: View {
    @Binding var post: InspirationPost
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.clear.huahuoBackground()

            VStack(spacing: 0) {
                DetailTopBar(post: post, onBack: { dismiss() })

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ArtworkView(style: post.style, rotation: -5, cornerRadius: 30)
                            .frame(maxWidth: .infinity)
                            .frame(height: 420)
                            .overlay(alignment: .bottom) {
                                PageDots()
                                    .padding(.bottom, 14)
                            }
                            .padding(.horizontal, 14)
                            .shadow(color: HuahuoTheme.shadow, radius: 22, y: 12)

                        NoteContentCard(post: post)
                        CommentCard(comments: post.comments)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 112)
                }
            }

            DetailActionBar(post: $post)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct DetailTopBar: View {
    let post: InspirationPost
    var onBack: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 42, height: 42)
                    .foregroundStyle(HuahuoTheme.foreground)
            }
            .glassCard(cornerRadius: 21)
            .accessibilityLabel("返回首页")

            HStack(spacing: 9) {
                AvatarView(size: 30)
                Text(post.author)
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(HuahuoTheme.foreground)
                    .lineLimit(1)
            }

            Spacer()

            Button("关注") {
            }
            .font(.system(size: 13, weight: .heavy))
            .foregroundStyle(.white)
            .frame(height: 34)
            .padding(.horizontal, 13)
            .background(HuahuoTheme.accent, in: Capsule())
            .shadow(color: HuahuoTheme.accent.opacity(0.22), radius: 10, y: 6)

            Button {
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .bold))
                    .frame(width: 42, height: 42)
                    .foregroundStyle(HuahuoTheme.foreground)
            }
            .glassCard(cornerRadius: 21)
            .accessibilityLabel("更多")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
    }
}

private struct NoteContentCard: View {
    let post: InspirationPost

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    AvatarView(size: 40)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(post.author)
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(HuahuoTheme.foreground)

                        Text("\(post.tags[0].replacingOccurrences(of: "#", with: "")) · 摄影 / 插画创作者")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(HuahuoTheme.muted)
                            .lineLimit(1)
                    }
                }

                Spacer()

                Text("关注")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 13)
                    .frame(height: 34)
                    .background(HuahuoTheme.accent, in: Capsule())
            }

            Text(post.title)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuoTheme.foreground)
                .lineSpacing(3)

            Text(post.copy)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(HuahuoTheme.foreground)
                .lineSpacing(7)

            TagFlow(tags: post.tags)

            Text("\(sampleHour(for: post)) 小时前 · 花火记")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(HuahuoTheme.muted)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 26)
        .padding(.horizontal, 12)
    }

    private func sampleHour(for post: InspirationPost) -> Int {
        (InspirationPost.samples.firstIndex(where: { $0.title == post.title }) ?? 0) + 1
    }
}

private struct CommentCard: View {
    let comments: [PostComment]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("评论")
                    .font(.system(size: 16, weight: .heavy, design: .rounded))
                    .foregroundStyle(HuahuoTheme.foreground)
                Spacer()
                Text("\(comments.count) 条")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(HuahuoTheme.muted)
            }

            ForEach(comments) { comment in
                HStack(alignment: .top, spacing: 9) {
                    AvatarView(size: 30)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(comment.name)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundStyle(HuahuoTheme.foreground)
                        Text(comment.text)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(HuahuoTheme.foreground)
                            .lineSpacing(3)
                        Text(comment.time)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(HuahuoTheme.muted)
                    }
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard(cornerRadius: 24)
        .padding(.horizontal, 12)
    }
}

private struct DetailActionBar: View {
    @Binding var post: InspirationPost

    var body: some View {
        HStack(spacing: 10) {
            Button {
            } label: {
                Text("说点什么...")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(HuahuoTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 42, alignment: .leading)
                    .padding(.horizontal, 14)
                    .background(.white.opacity(0.62), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.white.opacity(0.74), lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)

            HStack(spacing: 4) {
                ActionButton(systemImage: post.liked ? "heart.fill" : "heart", text: "\(post.likes)", highlighted: post.liked) {
                    post.liked.toggle()
                    post.likes += post.liked ? 1 : -1
                }

                ActionButton(systemImage: "bubble.right", text: "\(post.comments.count)") {
                }

                ActionButton(systemImage: "square.and.arrow.up", text: "") {
                }
            }
        }
        .padding(9)
        .glassCard(cornerRadius: 26)
        .padding(.horizontal, 12)
        .padding(.bottom, 10)
    }
}

private struct ActionButton: View {
    let systemImage: String
    let text: String
    var highlighted = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: systemImage)
                    .font(.system(size: 19, weight: .semibold))
                if !text.isEmpty {
                    Text(text)
                        .font(.system(size: 10, weight: .heavy))
                        .monospacedDigit()
                }
            }
            .foregroundStyle(highlighted ? HuahuoTheme.accent : HuahuoTheme.foreground)
            .frame(width: 42, height: 42)
            .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct PageDots: View {
    var body: some View {
        HStack(spacing: 5) {
            Capsule()
                .fill(.white.opacity(0.92))
                .frame(width: 16, height: 6)
            Circle()
                .fill(.white.opacity(0.58))
                .frame(width: 6, height: 6)
            Circle()
                .fill(.white.opacity(0.58))
                .frame(width: 6, height: 6)
        }
    }
}
