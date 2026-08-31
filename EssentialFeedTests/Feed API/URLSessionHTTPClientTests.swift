//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 8/31/26.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in
            //
        }
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test() {
        let url = URL(string: "https://a-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        sut.get(from: url)

        XCTAssertEqual(session.reseivedURLs, [url])
    }

    // MARK: -Helpers
    private class URLSessionSpy: URLSession, @unchecked Sendable {
        var reseivedURLs: [URL] = []

        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            reseivedURLs.append(url)
            return FakeURLSessionDataTask()
        }
    }

    private class FakeURLSessionDataTask: URLSessionDataTask, @unchecked Sendable { }
}
