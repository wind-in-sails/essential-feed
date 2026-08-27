//
//  EssentialFeed.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 8/27/26.
//

import Foundation

struct FeedItem: Sendable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
