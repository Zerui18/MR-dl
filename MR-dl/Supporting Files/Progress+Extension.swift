//
//  Progress+Extension.swift
//  MR-dl
//
//  Created by Chen Zerui on 28/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

extension Progress {
    
    var descriptionInUnit: String {
        return "\(completedUnitCount)/\(totalUnitCount)"
    }
    
}
