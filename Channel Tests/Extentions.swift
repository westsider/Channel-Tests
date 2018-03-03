//
//  Extentions.swift
//  Channel Tests
//
//  Created by Warren Hansen on 3/2/18.
//  Copyright © 2018 Warren Hansen. All rights reserved.
//

import Foundation

//extension Array where Element: Hashable {
//    var mode: Element? {
//        return self.reduce([Element: Int]()) {
//            var counts = $0
//            counts[$1] = ($0[$1] ?? 0) + 1
//            return counts
//            }.max { $0.1 < $1.1 }?.0
//    }
//}
//
//extension Array where Element: FloatingPoint {
//    
//    func sum() -> Element {
//        return self.reduce(0, +)
//    }
//    
//    func avg() -> Element {
//        return self.sum() / Element(self.count)
//    }
//    
//    func std() -> Element {
//        let mean = self.avg()
//        let v = self.reduce(0, { $0 + ($1-mean)*($1-mean) })
//        return sqrt(v / (Element(self.count) - 1))
//    }
//    
//}

