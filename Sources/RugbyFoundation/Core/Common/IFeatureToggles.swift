//
//  IFeatureToggles.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 26.02.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

/// The protocol describing a service providing the feature toggles.
public protocol IFeatureToggles: AnyObject {
    /// A flag to keep yaml files with target hash in the binaries folder.
    var keepHashYamls: Bool { get }

    /// A flag to print missing binaries as a tree during an analysing process.
    var printMissingBinaries: Bool { get }
}
