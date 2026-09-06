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

    func test_load_requestsCacheRtrival() {
        let (sut, store) = makeSUT()

        sut.load() { _ in }
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }

    func test_load_failsOnRtrivalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        var receivedError: Error?
        let exp = expectation(description: "Wait for completion")
        sut.load { result in
            switch result {
            case let .failure(error):
                receivedError = error
                break
            default:
                XCTFail("expected error got result \(result) instead")
            }

            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }

    //MARK: - Helpers

    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut, store)
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 1)
    }
}

