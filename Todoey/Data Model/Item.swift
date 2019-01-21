//
//  Item.swift
//  Todoey
//
//  Created by Axel Abildtrup on 13/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {

    @objc dynamic var title:String = ""
    @objc dynamic var done:Bool = false
    @objc dynamic var dateCreated:Date = Date()
    @objc dynamic var deadline:String = ""
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")

}
