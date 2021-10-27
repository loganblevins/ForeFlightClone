//
//  FakeRequestor.swift
//  ForeFlightCloneTests
//
//  Created by Logan Blevins on 10/2/21.
//

import Foundation
@testable import ForeFlightClone

final class FakeRequestor: Requestor {
    var result: FFResult!
    
    func requestJSON(url: URL, headers: Dictionary<String, String>, completion: @escaping (FFResult) -> Void) {
        completion(result)
    }
}
