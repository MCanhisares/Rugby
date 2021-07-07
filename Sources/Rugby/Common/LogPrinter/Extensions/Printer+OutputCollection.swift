//
//  Printer+OutputCollection.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 06.04.2021.
//  Copyright © 2021 Vyacheslav Khorkov. All rights reserved.
//

extension Printer {
    func print<T: Collection>(
        _ collection: T,
        text: String,
        level: Int = .verbose,
        deletion: Bool = false
    ) where T.Element == String {
        print("\(text) ".yellow + "(\(collection.count))" + ":".yellow, level: level)
        collection.caseInsensitiveSorted().forEach {
            let bullet = deletion ? "* ".red : "* ".yellow
            print(bullet + "\($0)", level: level)
        }
    }
}
