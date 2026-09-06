//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 9/5/26.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore

    init(store: FeedStore) {
        self.store = store
    }

    func save(_ items: [FeedItem]) {
        store.deleteCacheFeed { [unowned self] error in
            if error == nil {
                self.store.insertCallCount += 1
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCacheFeedCallCount = 0
    var insertCallCount = 0
    private var deletionCompltions: [DeletionCompletion] = []

    func deleteCacheFeed(completion: @escaping DeletionCompletion) {
        deleteCacheFeedCallCount += 1
        deletionCompltions.append(completion)
    }

    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompltions[index](error)
    }

    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompltions[index](nil)
    }

    func insertItems() {
        insertCallCount += 1
    }
 }

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items)

        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }

    func test_save_doesNotRequestsCacheInsertionOnDelitionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        let deletionError = anyNSError()
        sut.save(items)
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.insertCallCount, 0)
    }

    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let items = [uniqueItem(), uniqueItem()]
        let (sut, store) = makeSUT()

        sut.save(items)
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.insertCallCount, 1)
    }

    //MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://a-url.com/")!
    }

    private func anyNSError() -> Error {
        return NSError(domain: "any error", code: 1)
    }
}
