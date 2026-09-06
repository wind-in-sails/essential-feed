//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {
    func test_init_doesNotMessagetoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    //MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private class FeedStoreSpy: FeedStore {
        private var deletionCompltions: [DeletionCompletion] = []
        private var insertionCompltions: [InsertionCompletion] = []
        private(set) var receivedMessages: [ReceivedMessags] = []

        enum ReceivedMessags: Equatable {
            case deleteCachedFeed
            case insert([LocalFeedImage], Date)
        }

        func deleteCacheFeed(completion: @escaping DeletionCompletion) {
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

        func insertItems(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompltions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompltions[index](error)
        }
    }

}

