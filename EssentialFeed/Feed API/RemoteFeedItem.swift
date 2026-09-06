//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
