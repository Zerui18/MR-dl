//
//  Sequence+Extension.swift
//  MR-dl
//
//  Created by Chen Zerui on 27/12/17.
//  Copyright © 2017 Chen Zerui. All rights reserved.
//

import Foundation

extension Sequence {
    
    func count(isIncluded criteria: (Iterator.Element)throws-> Bool)rethrows-> Int {
        var cnt = 0
        for element in self where try criteria(element) {
            cnt += 1
        }
        return cnt
    }
    
}

extension Array where Iterator.Element: Equatable {
    
    @discardableResult
    mutating func delete(_ element: Iterator.Element)-> Iterator.Element? {
        if let idx = index(of: element) {
            return remove(at: idx)
        }
        return nil
    }
    
}
extension Array {
    
    mutating func sortUsingProperty<VariableType: Comparable>(atKeypath keypath: KeyPath<Iterator.Element, VariableType>, ascending: Bool = true) {
        sort {ascending ? $0[keyPath: keypath] < $1[keyPath: keypath] : $0[keyPath: keypath] > $1[keyPath: keypath]}
    }
    
}
