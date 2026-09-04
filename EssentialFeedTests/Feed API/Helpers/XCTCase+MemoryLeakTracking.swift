//
//  XCTCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Sergey Kudryavtsev on 9/4/26.
//

import Foundation
import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instanse: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instanse] in
            XCTAssertNil(instanse, "Instanse should be deallocated", file: file, line: line)
        }
    }
}
