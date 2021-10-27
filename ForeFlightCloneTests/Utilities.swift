//
//  Utilities.swift
//  ForeFlightCloneTests
//
//  Created by Logan Blevins on 10/2/21.
//

import Foundation

func text(forResource resource: String) -> String {
    let path = Bundle.main.path(forResource: resource, ofType: "json")!
    return try! String(contentsOfFile: path)
}

func obj(forText txt: String) -> [String: AnyObject] {
    let data = txt.data(using: .utf8)!
    return try! JSONSerialization.jsonObject(with: data, options: []) as! [String: AnyObject]
}

func obj(forResource resource: String) -> [String: AnyObject] {
    let txt = text(forResource: resource)
    return obj(forText: txt)
}
