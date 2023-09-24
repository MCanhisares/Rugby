//
//  Regex.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 28.12.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import RugbyFoundation

func regex(patterns: [String], exactMatches: [String]) throws -> NSRegularExpression? {
    guard !patterns.isEmpty || !exactMatches.isEmpty else { return nil }
    let exactMatches = exactMatches.map { "^\($0)$" }
    let joinedStrings = (patterns + exactMatches).joined(separator: "|")
    let regexString = "(" + joinedStrings + ")"
    return try NSRegularExpression(pattern: regexString, options: .anchorsMatchLines)
}
