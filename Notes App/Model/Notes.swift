//
//  Notes.swift
//  Notes App
//
//  Created by Shashwat  on 12/03/19.
//  Copyright © 2019 Shashwat . All rights reserved.
//

import UIKit
import CoreData

class Notes: NSManagedObject , Encodable{
    enum CodingKeys: String, CodingKey {
        case title
        case longitude
        case latitude
        case isSynced
        case desc
        case created
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(isSynced, forKey: .isSynced)
        try container.encode(desc, forKey: .desc)
        try container.encode(created, forKey: .created)
    }
}
