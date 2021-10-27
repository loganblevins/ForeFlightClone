//
//  Airport+CoreDataProperties.swift
//  ForeFlightClone
//
//  Created by Logan Blevins on 9/21/21.
//
//

import Foundation
import CoreData

extension Airport {
    enum Keys: String {
        case created
    }
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Airport> {
        return NSFetchRequest<Airport>(entityName: "Airport")
    }
    
    // Let Core Data assign the birthday for us. Avoids KVO.
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        setPrimitiveValue(Date(), forKey: Keys.created.rawValue)
    }
    
    @NSManaged public var ident: String
    @NSManaged public var report: String?
    @NSManaged public var created: Date
    @NSManaged public var reportUpdated: Date?
}
