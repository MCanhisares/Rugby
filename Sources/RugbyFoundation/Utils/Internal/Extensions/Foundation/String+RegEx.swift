//
//  String+RegEx.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 05.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation

enum RegexError: Error {
    case incorrectStringRange
}

extension String {
    func regex() throws -> NSRegularExpression {
        try NSRegularExpression(pattern: self, options: .anchorsMatchLines)
    }

    func match(_ regex: NSRegularExpression) -> Bool {
        let matches = try? groups(regex)
        return matches.isNotEmpty
    }

    func groups(_ regex: NSRegularExpression) throws -> [String] {
        guard let result = regex.firstMatch(self) else { return [] }
        return try (0..<result.numberOfRanges).map {
            let nsrange = result.range(at: $0)
            guard let range = Range(nsrange, in: self) else { throw RegexError.incorrectStringRange }
            return String(self[range])
        }
    }
}

private extension NSRegularExpression {
    func firstMatch(_ string: String) -> NSTextCheckingResult? {
        let range = NSRange(string.startIndex..., in: string)
        return firstMatch(in: string, range: range)
    }
}
