//
//  EssentialFeed.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 8/27/26.
//

import Foundation

public struct FeedItem: Sendable, Equatable {
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
