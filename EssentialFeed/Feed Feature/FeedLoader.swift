//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 8/27/26.
//

import Foundation

public typealias LoadFeedResult = Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
