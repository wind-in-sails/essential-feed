//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 8/27/26.
//

import XCTest
import EssentialFeed

final class RemoteFeedLoaderTests: XCTestCase {

    func test_init_doesNotequestDataFromURL() {
        let (_, client) = makeSUT()

        XCTAssertTrue(client.requestedURLs.isEmpty)
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .connectivity) {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        }
    }

    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let sample = [199, 201, 300, 400, 500]
        sample.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .invalidData) {
                client.complete(withStatusCode: code, at: index)
            }
        }
    }

    func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: .invalidData) {
            let invalidJSON = Data("invalid json".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    // MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://example.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }

    private func expect(
        _ sut: RemoteFeedLoader,
        toCompleteWith error: RemoteFeedLoader.Error,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        var capturedResult: [RemoteFeedLoader.Result] = []
        sut.load { capturedResult.append($0) }
        action()
        XCTAssertEqual(capturedResult, [.failure(error)], file: file, line: line)
    }

    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClientResult) -> Void)] = []
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }

        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }

        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.error(error))
        }

        func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
            let response = HTTPURLResponse(url: messages[index].url, statusCode: code, httpVersion: nil, headerFields: nil)!
            messages[index].completion(.success(data, response))
        }
    }
}
