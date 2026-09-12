//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
    private var deletionCompltions: [DeletionCompletion] = []
    private var insertionCompltions: [InsertionCompletion] = []
    private var retrievalCompltions: [RetrievalCompletion] = []
    private(set) var receivedMessages: [ReceivedMessags] = []

    enum ReceivedMessags: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieve
    }

    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deletionCompltions.append(completion)
        receivedMessages.append(.deleteCachedFeed)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompltions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompltions[index](nil)
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompltions[index](nil)
    }

    func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        insertionCompltions.append(completion)
        receivedMessages.append(.insert(items, timestamp))
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompltions[index](error)
    }

    func retrieve(completion: @escaping RetrievalCompletion) {
        retrievalCompltions.append(completion)
        receivedMessages.append(.retrieve)
    }

    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompltions[index](.failure(error))
    }

    func completeRetrievalWithEmptyCache(at index: Int = 0) {
        retrievalCompltions[index](.empty)
    }

    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalCompltions[index](.found(feed: feed, timestamp: timestamp))
    }
}
