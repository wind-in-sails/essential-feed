//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 9/5/26.
//

import XCTest
import EssentialFeed

final class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesNotMessagetoreUponCreation() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]
        sut.save(items) { _ in }

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_doesNotRequestsCacheInsertionOnDelitionError() {
        let (sut, store) = makeSUT()
        let items = [uniqueItem(), uniqueItem()]

        let deletionError = anyNSError()
        sut.save(items) { _ in }
        store.completeDeletion(with: deletionError)

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }

    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let items = [uniqueItem(), uniqueItem()]
        let localItems = items.map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.imageURL)}
        let (sut, store) = makeSUT(currentDate: { timestamp })

        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()

        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(localItems, timestamp)])
    }

    func test_save_failsOnDelitionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()

        expect(sut, toCompletteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }

    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()

        expect(sut, toCompletteWithError: anyNSError()) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }

    func test_save_succedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()

        expect(sut, toCompletteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }

    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueItem()]) { receivedResults.append($0) }

        sut = nil
        store.completeDeletion(with: anyNSError())

        XCTAssertTrue(receivedResults.isEmpty)
    }

    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

        var receivedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueItem()]) { receivedResults.append($0) }

        store.completeDeletionSuccessfully()
        sut = nil

        store.completeInsertion(with: anyNSError())
        XCTAssertTrue(receivedResults.isEmpty)
    }

    //MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func expect(_ sut: LocalFeedLoader, toCompletteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "whaiting for save conpletion")
        var receivedError: Error?
        sut.save([uniqueItem()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }

    private class FeedStoreSpy: FeedStore {
        private var deletionCompltions: [DeletionCompletion] = []
        private var insertionCompltions: [InsertionCompletion] = []
        private(set) var receivedMessages: [ReceivedMessags] = []

        enum ReceivedMessags: Equatable {
            case deleteCachedFeed
            case insert([LocalFeedItem], Date)
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

        func insertItems(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCompletion) {
            insertionCompltions.append(completion)
            receivedMessages.append(.insert(items, timestamp))
        }

        func completeInsertion(with error: Error, at index: Int = 0) {
            insertionCompltions[index](error)
        }
    }

    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }

    private func anyURL() -> URL {
        return URL(string: "https://a-url.com/")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}
