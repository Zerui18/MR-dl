//
//  MRSerie+Extensions.swift
//  MR-dl
//
//  Created by Chen Changheng on 20/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import MRClient
import CoreData

@objc class MRSerie: NSManagedObject{
    
    convenience init(fromMeta meta: MRSerieMeta, context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = meta.name
        self.thumbnailURL = meta.thumbnailURL
        self.oid = meta.oid
    }
    
    func update(withMeta meta: MRSerieMeta){
        
    }
    
}
