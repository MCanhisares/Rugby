//
//  Project.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 07.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import XcodeProj

enum ProjectError: LocalizedError {
    case missingRootProject
    case emptyProjectPath
    case cantReadBuildConfigurations

    var errorDescription: String? {
        switch self {
        case .missingRootProject:
            return "Missing root project."
        case .emptyProjectPath:
            return "Project path is empty."
        case .cantReadBuildConfigurations:
            return "Can't read build configurations."
        }
    }
}

final class Project {
    let xcodeProj: XcodeProj
    let reference: PBXFileReference?
    let path: String

    enum Path {
        case string(String)
        case reference(PBXFileReference)

        var reference: PBXFileReference? {
            switch self {
            case .string:
                return nil
            case .reference(let reference):
                return reference
            }
        }

        var string: String? {
            switch self {
            case .string(let path):
                return path
            case .reference(let reference):
                return reference.fullPath
            }
        }
    }

    init(path: Path) throws {
        guard let pathString = path.string else { throw ProjectError.emptyProjectPath }
        self.path = pathString
        self.xcodeProj = try XcodeProj(pathString: pathString)
        self.reference = path.reference
    }

    var pbxProj: PBXProj { xcodeProj.pbxproj }
    var pbxProject: PBXProject {
        get throws {
            guard let rootProject = try pbxProj.rootProject() else {
                throw ProjectError.missingRootProject
            }
            return rootProject
        }
    }

    var buildConfigurationList: XCConfigurationList {
        get throws {
            try pbxProject.buildConfigurationList
        }
    }

    private var cachedBuildConfigurations: [String: XCBuildConfiguration]?
    var buildConfigurations: [String: XCBuildConfiguration] {
        get async throws {
            if let cachedBuildConfigurations = cachedBuildConfigurations { return cachedBuildConfigurations }
            let buildConfigurations = try buildConfigurationList.buildConfigurations
            let buildConfigurationsMap = Dictionary(uniqueKeysWithValues: buildConfigurations.map { ($0.name, $0) })
            cachedBuildConfigurations = buildConfigurationsMap
            return buildConfigurationsMap
        }
    }
}

// MARK: - Equatable

extension Project: Equatable {
    static func == (lhs: Project, rhs: Project) -> Bool {
        (lhs.xcodeProj, lhs.reference, lhs.path) == (rhs.xcodeProj, rhs.reference, rhs.path)
    }
}

// MARK: - Hashable

extension Project: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}
