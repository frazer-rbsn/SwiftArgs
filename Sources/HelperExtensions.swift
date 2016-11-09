//
//  HelperExtensions.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 27/10/2016.
//  Copyright © 2016 Frazer Robinson. All rights reserved.
//
import Foundation

extension String {
    
    var firstChar : Character {
        return self[self.startIndex]
    }
    
    func character(atIndex : Int) -> Character {
        let index = self.index(self.startIndex, offsetBy: atIndex)
        return self[index]
    }
}

extension Array {
    
    subscript (safe index: UInt) -> Element? {
        return Int(index) < count ? self[Int(index)] : nil
    }
}

