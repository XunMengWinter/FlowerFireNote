import Foundation
import SwiftData

@Model
final class FavoritePost {
    @Attribute(.unique) var postID: String
    var title: String
    var author: String
    var likes: Int
    var styleRawValue: String
    var sizeRawValue: String
    var copy: String
    var imageURLString: String?
    var detailImageURLString: String?
    var imageWidth: Int?
    var imageHeight: Int?
    var photoPageURLString: String?
    var authorAvatarURLString: String?
    var sourceName: String
    var createdAt: Date

    init(post: InspirationPost, createdAt: Date = .now) {
        self.postID = post.id
        self.title = post.title
        self.author = post.author
        self.likes = post.likes
        self.styleRawValue = post.style.rawValue
        self.sizeRawValue = post.size.rawValue
        self.copy = post.copy
        self.imageURLString = post.imageURL?.absoluteString
        self.detailImageURLString = post.detailImageURL?.absoluteString
        self.imageWidth = post.imageWidth
        self.imageHeight = post.imageHeight
        self.photoPageURLString = post.photoPageURL?.absoluteString
        self.authorAvatarURLString = post.authorAvatarURL?.absoluteString
        self.sourceName = post.sourceName
        self.createdAt = createdAt
    }

    var inspirationPost: InspirationPost {
        InspirationPost(
            id: postID,
            title: title,
            author: author,
            likes: likes,
            style: InspirationPost.VisualStyle(rawValue: styleRawValue) ?? .window,
            size: InspirationPost.CardSize(rawValue: sizeRawValue) ?? .medium,
            copy: copy,
            liked: true,
            imageURL: Self.url(from: imageURLString),
            detailImageURL: Self.url(from: detailImageURLString),
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            photoPageURL: Self.url(from: photoPageURLString),
            authorAvatarURL: Self.url(from: authorAvatarURLString),
            sourceName: sourceName
        )
    }

    private static func url(from value: String?) -> URL? {
        guard let value, !value.isEmpty else { return nil }
        return URL(string: value)
    }
}
