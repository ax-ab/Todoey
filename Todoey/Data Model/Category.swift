//
//  Category.swift
//  Todoey
//
//  Created by Axel Abildtrup on 13/12/2018.
//  Copyright © 2018 Axel Abildtrup. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name:String = ""
    @objc dynamic var color:String = ""
    let items = List<Item>() //defines the forward relationship
    
}
