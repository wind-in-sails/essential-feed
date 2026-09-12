//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 9/11/26.
//

import Foundation

public class CoreDataFeedStore: FeedStore {
    public init() {}

    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {

    }

    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {

    }

    public func retrieve(completion: @escaping RetrievalCompltion) {
        completion(.empty)
    }
}
