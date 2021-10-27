//
//  WeatherAPI.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/20/21.
//

import Foundation

protocol API: AnyObject {
    var url: URL { get }
    var headers: Dictionary<String, String>? { get }
    var requestor: Requestor { get }
    func fetchWeather(forIdent ident: String, completion: @escaping (FFResult) -> ())
}


final class WeatherAPI {
    init(requestor: Requestor = AlamofireRequestor()) {
        self.requestor = requestor
    }
    
    let requestor: Requestor
}

extension WeatherAPI: API {
    var url: URL {
        URL(string: Constants.url)!
    }
    
    var headers: Dictionary<String, String>? {
        [
            "Accept": "application/json",
            Constants.Secret.headerKey: Constants.Secret.headerValue
        ]
    }
}

extension API {
    func fetchWeather(forIdent ident: String, completion: @escaping (FFResult) -> ()) {
        guard !ident.isEmpty else {
            completion(.failure(.unknown("Ident is empty")))
            return
        }
        
        guard let headers = headers else {
            completion(.failure(.unknown("Headers are empty")))
            return
        }
        
        let url = url.appendingPathComponent(ident)

        requestor.requestJSON(url: url, headers: headers, completion: completion)
    }
}
