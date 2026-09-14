//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import Foundation

 struct RemoteFeedItem: Decodable {
     let id: UUID
     let description: String?
     let location: String?
     let image: URL
}
