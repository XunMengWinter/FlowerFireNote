import SwiftUI

struct PublishView: View {
    @State private var title = ""
    @State private var detail = ""
    @State private var draftState = "草稿"
    @State private var photoTiles: [Int] = []
    @State private var nextPhotoID = 1
    @FocusState private var focusedField: PublishField?

    private var titleByteCount: Int {
        title.reduce(0) { partialResult, character in
            partialResult + (character.unicodeScalars.allSatisfy { $0.value < 256 } ? 1 : 2)
        }
    }

    private var canPublish: Bool {
        !photoTiles.isEmpty && titleByteCount > 0 && titleByteCount <= 40 && !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            Color.clear.huahuoBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    PublishTopBar(draftState: draftState) {
                        clearDraft()
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("添加图文")
                                .font(.system(size: 24, weight: .heavy, design: .rounded))
                                .foregroundStyle(HuahuoTheme.foreground)
                            Text("上传多张图片，写下摄影 / 插画灵感的标题和详情。")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(HuahuoTheme.muted)
                                .lineSpacing(4)
                        }

                        PhotoGrid(photoTiles: photoTiles, onAdd: addPhotoTile, onRemove: removePhotoTile)

                        FieldBlock(label: "标题", counter: "\(titleByteCount)/40B", isOverLimit: titleByteCount > 40) {
                            TextField("例如：窗边蓝调光的一组速写", text: $title)
                                .focused($focusedField, equals: .title)
                                .submitLabel(.done)
                                .onSubmit {
                                    focusedField = nil
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(HuahuoTheme.foreground)
                                .padding(.horizontal, 14)
                                .frame(height: 48)
                                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(.white.opacity(0.72), lineWidth: 1)
                                }
                        }

                        FieldBlock(label: "详情", counter: "\(detail.count)", isOverLimit: false) {
                            TextEditor(text: $detail)
                                .focused($focusedField, equals: .detail)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(HuahuoTheme.foreground)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(minHeight: 156)
                                .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .overlay(alignment: .topLeading) {
                                    if detail.isEmpty {
                                        Text("写下拍摄时间、灵感来源、配色或创作过程...")
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundStyle(HuahuoTheme.muted.opacity(0.72))
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 17)
                                            .allowsHitTesting(false)
                                    }
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                                        .stroke(.white.opacity(0.72), lineWidth: 1)
                                }
                        }

                        HStack(spacing: 10) {
                            Button("保存草稿") {
                                draftState = "已存草稿"
                            }
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(HuahuoTheme.foreground)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(.white.opacity(0.60), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(.white.opacity(0.70), lineWidth: 1)
                            }

                            Button(canPublish ? "发布" : "发布") {
                                draftState = "已发布"
                            }
                            .font(.system(size: 15, weight: .heavy))
                            .foregroundStyle(canPublish ? .white : HuahuoTheme.muted)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(canPublish ? HuahuoTheme.accent : .white.opacity(0.50), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .shadow(color: canPublish ? HuahuoTheme.accent.opacity(0.24) : .clear, radius: 12, y: 7)
                            .disabled(!canPublish)
                        }
                    }
                    .padding(16)
                    .glassCard(cornerRadius: 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .safeAreaInset(edge: .bottom, alignment: .trailing, spacing: 0) {
            if focusedField != nil {
                PublishKeyboardDoneButton {
                    focusedField = nil
                }
                .padding(.trailing, 16)
                .padding(.bottom, 10)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.24, dampingFraction: 0.86), value: focusedField != nil)
        .onChange(of: title) { _, newValue in
            trimTitleIfNeeded(newValue)
            draftState = "编辑中"
        }
        .onChange(of: detail) { _, _ in
            draftState = "编辑中"
        }
    }

    private func trimTitleIfNeeded(_ value: String) {
        var output = ""
        var count = 0

        for character in value {
            let size = character.unicodeScalars.allSatisfy { $0.value < 256 } ? 1 : 2
            if count + size > 40 { break }
            output.append(character)
            count += size
        }

        if output != value {
            title = output
        }
    }

    private func addPhotoTile() {
        photoTiles.append(nextPhotoID)
        nextPhotoID += 1
        draftState = "已存草稿"
    }

    private func removePhotoTile(_ id: Int) {
        photoTiles.removeAll { $0 == id }
        draftState = "已存草稿"
    }

    private func clearDraft() {
        title = ""
        detail = ""
        photoTiles = []
        draftState = "草稿"
    }
}

private enum PublishField: Hashable {
    case title
    case detail
}

private struct PublishTopBar: View {
    let draftState: String
    var onCancel: () -> Void

    var body: some View {
        HStack {
            Button("取消", action: onCancel)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(HuahuoTheme.foreground)
                .frame(width: 68, height: 36)
                .background(.white.opacity(0.58), in: Capsule())

            Spacer()

            Text("发布灵感")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundStyle(HuahuoTheme.foreground)

            Spacer()

            Text(draftState)
                .font(.system(size: 14, weight: .heavy))
                .foregroundStyle(HuahuoTheme.muted)
                .frame(width: 68, height: 36)
                .background(.white.opacity(0.58), in: Capsule())
        }
    }
}

private struct PublishKeyboardDoneButton: View {
    var onDone: () -> Void

    var body: some View {
        Button(action: onDone) {
            Text("完成")
                .font(.system(size: 15, weight: .heavy))
                .foregroundStyle(.white)
                .frame(width: 82, height: 38)
                .background(HuahuoTheme.accent, in: Capsule())
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.70), lineWidth: 1)
                }
                .shadow(color: HuahuoTheme.accent.opacity(0.22), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("完成编辑")
    }
}

private struct PhotoGrid: View {
    let photoTiles: [Int]
    var onAdd: () -> Void
    var onRemove: (Int) -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 3), spacing: 9) {
            ForEach(Array(photoTiles.enumerated()), id: \.element) { index, id in
                PhotoTileShell {
                    ZStack(alignment: .topTrailing) {
                        ArtworkView(style: InspirationPost.VisualStyle.allCases[index % InspirationPost.VisualStyle.allCases.count], rotation: index.isMultiple(of: 2) ? -5 : 5, cornerRadius: 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)

                        Button {
                            onRemove(id)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .heavy))
                                .foregroundStyle(.white)
                                .frame(width: 26, height: 26)
                                .background(.black.opacity(0.46), in: Circle())
                        }
                        .padding(6)
                        .accessibilityLabel("删除图片")
                    }
                }
            }

            Button(action: onAdd) {
                PhotoTileShell(isDashed: true) {
                    VStack(spacing: 7) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                        Text("添加图片")
                            .font(.system(size: 12, weight: .heavy))
                    }
                    .foregroundStyle(HuahuoTheme.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("添加图片")
        }
    }
}

private struct PhotoTileShell<Content: View>: View {
    var isDashed = false
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(
                        isDashed ? HuahuoTheme.border : .white.opacity(0.72),
                        style: StrokeStyle(lineWidth: 1, dash: isDashed ? [5, 5] : [])
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
    }
}

private struct FieldBlock<Content: View>: View {
    let label: String
    let counter: String
    let isOverLimit: Bool
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundStyle(HuahuoTheme.foreground)
                Spacer()
                Text(counter)
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundStyle(isOverLimit ? HuahuoTheme.accent : HuahuoTheme.muted)
            }

            content
        }
    }
}
