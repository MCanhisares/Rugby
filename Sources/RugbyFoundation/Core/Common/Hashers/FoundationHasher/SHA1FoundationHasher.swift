//
//  SHA1FoundationHasher.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 03.09.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import CryptoKit
import Foundation

// MARK: - Interface

protocol FoundationHasher {
    func hash(_ string: String) -> String
    func hash(_ arrayOfStrings: [String]) -> String
    func hash(_ data: Data) -> String
}

// MARK: - Implementation

final class SHA1Hasher: FoundationHasher {
    private let sha1Length = 7

    func hash(_ string: String) -> String {
        hash(Data(string.utf8))
    }

    func hash(_ arrayOfStrings: [String]) -> String {
        hash(arrayOfStrings.joined(separator: ","))
    }

    func hash(_ data: Data) -> String {
        let sha1 = Insecure.SHA1.hash(data: data).map {
            String(format: "%02hhx", $0)
        }.joined()
        return String(sha1.prefix(sha1Length))
    }
}
