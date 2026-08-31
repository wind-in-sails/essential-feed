//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sergey Kudryavtsev on 8/31/26.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case error(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
