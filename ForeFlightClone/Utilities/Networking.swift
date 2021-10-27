//
//  Networking.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import Foundation
import Alamofire

enum NetworkError: Error, CustomStringConvertible {
    case unknown(String?)
    
    var description: String {
        switch self {
        case .unknown(let what):
            return "Request failed: \(what ?? "Unknown")"
        }
    }
}

typealias JSON = Any
typealias FFResult = Result<JSON, NetworkError>

// Generic requestor interface useful to make unit testing easier if time allowed
// (could mock the requestor and provide fake data without hitting the network)
//
protocol Requestor {
    func requestJSON(url: URL, headers: Dictionary<String, String>, completion: @escaping (_ result: FFResult) -> Void)
}

// Alamofire does some nice validation work for us making this speedier and more robust to implement
final class AlamofireRequestor: Requestor {
    func requestJSON(url: URL, headers: Dictionary<String, String>, completion: @escaping (FFResult) -> Void) {
        AF.request(url, headers: HTTPHeaders(headers)).validate().responseJSON { response in
            if let data = response.value {
                completion(.success(data))
            }
            else {
                completion(.failure(.unknown(response.error?.errorDescription)))
            }
        }
    }
}
