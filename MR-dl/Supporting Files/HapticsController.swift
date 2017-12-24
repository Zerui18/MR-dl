//
//  HapticsController.swift
//  MR-dl
//
//  Created by Chen Zerui on 24/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import UIKit

class HapticsController {
    
    static func notificationFeedback(ofType type: UINotificationFeedbackType){
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    static func selectionFeedback(ofType type: UISelectionFeedbackGenerator){
        UISelectionFeedbackGenerator().selectionChanged()
    }
    
}
