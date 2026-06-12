import Combine
import Foundation

enum UnsplashConfig {
    static let accessKey = "yoRTvInLY8T6PoZBrDtpS88crbcGvGyBZvpra7-yF_4"
    static let defaultQuery = "photography illustration pastel"
    static let perPage = 20
}

struct UnsplashAPIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    nonisolated init(session: URLSession = .shared) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder = decoder
    }

    func searchPhotos(query: String, page: Int) async throws -> UnsplashSearchPage {
        var components = URLComponents(string: "https://api.unsplash.com/search/photos")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(UnsplashConfig.perPage)"),
            URLQueryItem(name: "order_by", value: "relevant"),
            URLQueryItem(name: "content_filter", value: "high")
        ]

        guard let url = components?.url else {
            throw UnsplashAPIError.invalidURL
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
        request.setValue("Client-ID \(UnsplashConfig.accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("v1", forHTTPHeaderField: "Accept-Version")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UnsplashAPIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            let apiError = try? decoder.decode(UnsplashErrorResponse.self, from: data)
            let textError = String(data: data, encoding: .utf8)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let message = apiError?.errors.first ?? (textError?.isEmpty == false ? textError : nil)
            throw UnsplashAPIError.requestFailed(statusCode: httpResponse.statusCode, message: message)
        }

        let payload = try decoder.decode(UnsplashSearchResponse.self, from: data)
        return UnsplashSearchPage(
            posts: payload.results.map(InspirationPost.init(unsplashPhoto:)),
            totalPages: payload.totalPages
        )
    }
}

@MainActor
final class UnsplashFeedStore: ObservableObject {
    @Published private(set) var posts: [InspirationPost] = []
    @Published private(set) var isLoadingInitial = false
    @Published private(set) var isLoadingPage = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var isRateLimited = false

    private let client: UnsplashAPIClient
    private var activeQuery = UnsplashConfig.defaultQuery
    private var activeQueryToken: String?
    private var page = 0
    private var totalPages = 1
    private var loadedIDs = Set<InspirationPost.ID>()

    init(client: UnsplashAPIClient = UnsplashAPIClient()) {
        self.client = client
    }

    var hasLoadedContent: Bool {
        page > 0 || !posts.isEmpty
    }

    var canLoadMore: Bool {
        page > 0 && page < totalPages && !isLoadingInitial && !isLoadingPage && !isRateLimited
    }

    func reloadIfNeeded(query: String, token: String) async {
        let normalizedQuery = Self.normalizedQuery(query)
        guard activeQueryToken != token || (!hasLoadedContent && errorMessage == nil) else { return }
        guard !isLoadingInitial || activeQueryToken != token else { return }
        await reload(query: normalizedQuery, token: token)
    }

    private func reload(query: String, token: String?) async {
        let normalizedQuery = Self.normalizedQuery(query)
        activeQuery = normalizedQuery
        activeQueryToken = token
        page = 0
        totalPages = 1
        posts = []
        loadedIDs = []
        errorMessage = nil
        isRateLimited = false
        isLoadingInitial = true
        defer { isLoadingInitial = false }

        do {
            let searchPage = try await client.searchPhotos(query: normalizedQuery, page: 1)
            guard isCurrentReload(query: normalizedQuery, token: token) else { return }
            page = 1
            totalPages = max(searchPage.totalPages, 1)
            appendUniquePosts(searchPage.posts)
        } catch is CancellationError {
            return
        } catch {
            guard isCurrentReload(query: normalizedQuery, token: token) else { return }
            isRateLimited = Self.isRateLimitError(error)
            errorMessage = Self.displayMessage(for: error)
        }

    }

    func loadNextPage() async {
        guard canLoadMore else { return }

        isLoadingPage = true
        defer { isLoadingPage = false }
        errorMessage = nil
        isRateLimited = false
        let nextPage = page + 1
        let query = activeQuery
        let token = activeQueryToken

        do {
            let searchPage = try await client.searchPhotos(query: query, page: nextPage)
            guard isCurrentReload(query: query, token: token) else { return }
            page = nextPage
            totalPages = max(searchPage.totalPages, 1)
            appendUniquePosts(searchPage.posts)
        } catch is CancellationError {
            return
        } catch {
            guard isCurrentReload(query: query, token: token) else { return }
            isRateLimited = Self.isRateLimitError(error)
            errorMessage = Self.displayMessage(for: error)
        }

    }

    func retry() async {
        if posts.isEmpty {
            await reload(query: activeQuery, token: activeQueryToken)
        } else {
            await loadNextPage()
        }
    }

    func toggleLike(_ id: InspirationPost.ID) {
        guard let index = posts.firstIndex(where: { $0.id == id }) else { return }
        posts[index].liked.toggle()
        posts[index].likes += posts[index].liked ? 1 : -1
    }

    func post(id: InspirationPost.ID) -> InspirationPost? {
        posts.first { $0.id == id }
    }

    func update(_ post: InspirationPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index] = post
    }

    private func appendUniquePosts(_ newPosts: [InspirationPost]) {
        for post in newPosts where !loadedIDs.contains(post.id) {
            posts.append(post)
            loadedIDs.insert(post.id)
        }
    }

    private func isCurrentReload(query: String, token: String?) -> Bool {
        activeQuery == query && activeQueryToken == token
    }

    private static func normalizedQuery(_ query: String) -> String {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? UnsplashConfig.defaultQuery : trimmed
    }

    private static func displayMessage(for error: Error) -> String {
        if let apiError = error as? UnsplashAPIError {
            if apiError.isRateLimitExceeded {
                return "Unsplash 当前额度已用完，请稍后再试。"
            }
            return apiError.localizedDescription
        }
        return "图片加载失败，请稍后重试。"
    }

    private static func isRateLimitError(_ error: Error) -> Bool {
        (error as? UnsplashAPIError)?.isRateLimitExceeded == true
    }
}

struct UnsplashSearchPage {
    var posts: [InspirationPost]
    var totalPages: Int
}

private enum UnsplashAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)

    var isRateLimitExceeded: Bool {
        if case .requestFailed(403, let message) = self {
            return message?.localizedCaseInsensitiveContains("rate limit") == true
        }
        return false
    }

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Unsplash 搜索地址无效。"
        case .invalidResponse:
            return "Unsplash 返回了无法识别的响应。"
        case .requestFailed(let statusCode, let message):
            if let message, !message.isEmpty {
                return "Unsplash 请求失败（\(statusCode)）：\(message)"
            }
            return "Unsplash 请求失败（\(statusCode)）。"
        }
    }
}

private struct UnsplashErrorResponse: Decodable {
    let errors: [String]
}

private struct UnsplashSearchResponse: Decodable {
    let total: Int
    let totalPages: Int
    let results: [UnsplashPhoto]
}

private struct UnsplashPhoto: Decodable {
    let id: String
    let description: String?
    let altDescription: String?
    let width: Int
    let height: Int
    let likes: Int
    let color: String?
    let urls: UnsplashPhotoURLs
    let links: UnsplashPhotoLinks
    let user: UnsplashUser
}

private struct UnsplashPhotoURLs: Decodable {
    let raw: String?
    let regular: String?
    let small: String?
    let thumb: String?
}

private struct UnsplashPhotoLinks: Decodable {
    let html: String?
}

private struct UnsplashUser: Decodable {
    let name: String
    let username: String
    let profileImage: UnsplashProfileImage?
}

private struct UnsplashProfileImage: Decodable {
    let small: String?
    let medium: String?
    let large: String?
}

private extension InspirationPost {
    init(unsplashPhoto photo: UnsplashPhoto) {
        let title = Self.cleanedText(photo.description)
            ?? Self.cleanedText(photo.altDescription)
            ?? "来自 \(photo.user.name) 的灵感照片"
        let copy = Self.cleanedText(photo.altDescription)
            ?? Self.cleanedText(photo.description)
            ?? "这张图片来自 Unsplash，可作为摄影、插画、配色和构图参考。"
        let style = Self.style(for: photo)

        self.init(
            id: photo.id,
            title: title,
            author: photo.user.name.isEmpty ? photo.user.username : photo.user.name,
            likes: photo.likes,
            style: style,
            size: Self.cardSize(width: photo.width, height: photo.height),
            copy: copy,
            imageURL: URL(string: photo.urls.small ?? photo.urls.thumb ?? photo.urls.regular ?? ""),
            detailImageURL: URL(string: photo.urls.regular ?? photo.urls.small ?? photo.urls.raw ?? ""),
            imageWidth: photo.width,
            imageHeight: photo.height,
            photoPageURL: URL(string: photo.links.html ?? ""),
            authorAvatarURL: URL(string: photo.user.profileImage?.medium ?? photo.user.profileImage?.small ?? ""),
            sourceName: "Unsplash"
        )
    }

    static func cleanedText(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func cardSize(width: Int, height: Int) -> CardSize {
        guard width > 0, height > 0 else { return .medium }
        let heightWeight = Double(height) / Double(width)
        if heightWeight < 0.92 {
            return .short
        } else if heightWeight < 1.22 {
            return .medium
        } else {
            return .tall
        }
    }

    static func style(for photo: UnsplashPhoto) -> VisualStyle {
        let styles = VisualStyle.allCases
        let seed = photo.id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return styles[seed % styles.count]
    }
}
