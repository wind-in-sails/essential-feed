//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 9/6/26.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date

        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local }
        }
    }

    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL

        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }

        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
    }

    private let storeURL: URL

    init(storeURL: URL) {
        self.storeURL = storeURL
    }

    func retrieve(completion: @escaping FeedStore.RetrievalCompltion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }

    func insertItems(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map { CodableFeedImage($0) }, timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

final class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }

    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }

    func test_retrieve_deliversmptyOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieve: .empty)
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()

        expect(sut, toRetrieveTwice: .empty)
    }

    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let exp = expectation(description: "wait for cache insertion")
        sut.insertItems(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }

    func test_retrieve_hasNoSideEffectsnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()

        let exp = expectation(description: "wait for cache insertion")
        sut.insertItems(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)

        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }

    //MARK: - Helpers

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }

    private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "wait for cache retrieval")

        sut.retrieve { retrieveResult in
            switch (retrieveResult, expectedResult) {
            case let (.found(retrieveFeed, retrieveTimestamp), .found(expectedFeed, expectedTimestamp)):
                XCTAssertEqual(retrieveFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrieveTimestamp, expectedTimestamp, file: file, line: line)
            case (.empty, .empty):
                break
            default:
                XCTFail("Expected to retrieve \(expectedResult) got \(retrieveResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)
    }

    private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
    }

    private func testSpecificStoreURL() -> URL {
        let storeURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of:self)).store")
        return storeURL
    }


    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }

    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }

    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
