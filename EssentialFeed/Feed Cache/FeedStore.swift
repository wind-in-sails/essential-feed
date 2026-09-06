//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void

    func deleteCacheFeed(completion: @escaping DeletionCompletion)
    func insertItems(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
}

public struct LocalFeedItem: Sendable, Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL

    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
