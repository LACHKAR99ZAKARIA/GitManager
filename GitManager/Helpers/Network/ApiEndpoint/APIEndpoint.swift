//
//  APIEndpoint.swift
//  git Mobile
//
//  Created by Zakaria Lachkar on 26/10/2024.
//


import Foundation

protocol APIEndpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var parameters: [String: Any]? { get }
    var query: [String: Any]? { get }
}

extension APIEndpoint {
    var query: [String: Any]? {
        nil
    }
}
