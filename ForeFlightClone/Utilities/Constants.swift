//
//  Constants.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/21/21.
//

import Foundation

struct Constants {
    static let url = "https://qa.foreflight.com/weather/report"
    static let initialIdents = ["KAUS", "KPWM"]
    static let alertTitle = "Did you preflight your input?"
    static let alertButtonTitle = "Ok"
    static let noDataMessage = "Unavailable"
    
    struct Secret {
        static let headerKey = "ff-coding-exercise"
        static let headerValue = "1"
    }
}
