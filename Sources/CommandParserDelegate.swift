//
//  CommandParserDelegate.swift
//  SwiftCommandLineKit
//
//  Created by Frazer Robinson on 11/11/2016.
//
//

import Foundation

public protocol CommandParserDelegate {
    func commandNotSupplied()
    func receivedCommand(command : Command)
}
