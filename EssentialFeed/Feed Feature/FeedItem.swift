//
//  EssentialFeed.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 8/27/26.
//

import Foundation

public struct FeedItem: Sendable, Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
