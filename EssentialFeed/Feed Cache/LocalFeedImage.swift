//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import Foundation

public struct LocalFeedImage: Sendable, Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL

    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
