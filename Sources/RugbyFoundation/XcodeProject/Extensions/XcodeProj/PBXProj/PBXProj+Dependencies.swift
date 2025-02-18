//
//  PBXProj+Dependencies.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 20.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import Foundation
import XcodeProj

enum AddDependencyError: LocalizedError {
    case missingProjectReference(String)
    case emptyProjectPath(String?)

    var errorDescription: String? {
        switch self {
        case .missingProjectReference(let name):
            return "Missing project reference '\(name)'."
        case .emptyProjectPath(let name):
            return "Empty project path '\(name ?? "Unknown")'."
        }
    }
}

extension PBXProj {
    func addDependencies(_ dependencies: Set<Target>, target: Target) throws {
        try dependencies.forEach {
            try addDependency($0, toTarget: target.pbxTarget)
        }
        target.addDependencies(dependencies)
    }

    @discardableResult
    func addDependency(_ dependency: Target, toTarget target: PBXTarget) throws -> PBXTargetDependency {
        let proxyType: PBXContainerItemProxy.ProxyType
        let containerPortal: PBXContainerItemProxy.ContainerPortal
        if let reference = dependency.project.reference {
            if let existingReference = projectReferences().first(where: { $0.name == reference.name }) {
                containerPortal = .fileReference(existingReference)
            } else {
                add(object: reference)
                // Add project dependency to root Dependencies group
                let dependenciesGroup = groups.first(where: { $0.name == .dependenciesGroup && $0.parent?.path == nil })
                dependenciesGroup?.children.append(reference)
                rootObject?.projects.append([.projectRefKey: reference])
                containerPortal = .fileReference(reference)
            }
            proxyType = .reference
        } else {
            proxyType = .nativeTarget
            let pbxProject = try dependency.project.pbxProject
            containerPortal = .project(pbxProject)
        }
        let proxy = PBXContainerItemProxy(containerPortal: containerPortal,
                                          remoteGlobalID: .string(dependency.uuid),
                                          proxyType: proxyType,
                                          remoteInfo: dependency.name)
        add(object: proxy)

        let targetDependency = PBXTargetDependency(name: dependency.name, targetProxy: proxy)
        add(object: targetDependency)
        target.dependencies.append(targetDependency)
        return targetDependency
    }

    func deleteDependencies(_ dependencies: Set<Target>, target: Target) {
        let dependenciesUUIDs = dependencies.map(\.pbxTarget.uuid)
        let pbxDependencies = target.pbxTarget.dependencies.filter {
            guard let remoteGlobalID = $0.targetProxy?.remoteGlobalID else { return false }
            switch remoteGlobalID {
            case .object(let object):
                return dependenciesUUIDs.contains(object.uuid)
            case .string(let uuid):
                return dependenciesUUIDs.contains(uuid)
            }
        }
        pbxDependencies.forEach {
            $0.targetProxy.map(delete)
            delete(object: $0)
        }
        target.pbxTarget.dependencies.removeAll(where: pbxDependencies.contains)
        target.deleteDependencies(dependencies)
    }
}

private extension String {
    static let dependenciesGroup = "Dependencies"
    static let projectRefKey = "ProjectRef"
}
