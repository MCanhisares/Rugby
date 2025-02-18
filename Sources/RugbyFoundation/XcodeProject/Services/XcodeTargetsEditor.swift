//
//  XcodeTargetsEditor.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 20.08.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

final class XcodeTargetsEditor: Loggable {
    let logger: ILogger

    private let projectDataSource: XcodeProjectDataSource
    private let targetsDataSource: XcodeTargetsDataSource
    private let schemesEditor: XcodeProjectSchemesEditor

    init(logger: ILogger,
         projectDataSource: XcodeProjectDataSource,
         targetsDataSource: XcodeTargetsDataSource,
         schemesEditor: XcodeProjectSchemesEditor) {
        self.logger = logger
        self.projectDataSource = projectDataSource
        self.targetsDataSource = targetsDataSource
        self.schemesEditor = schemesEditor
    }

    func resetCache() {
        targetsDataSource.resetCache()
    }

    func createAggregatedTarget(name: String, dependencies: Set<Target>) async throws -> Target {
        let project = try await projectDataSource.rootProject
        let pbxTarget = PBXAggregateTarget(name: name)
        pbxTarget.buildConfigurationList = try project.buildConfigurationList
        try project.pbxProject.targets.append(pbxTarget)
        project.pbxProj.add(object: pbxTarget)

        try dependencies.forEach {
            try project.pbxProj.addDependency($0, toTarget: pbxTarget)
        }

        let target = try await Target(pbxTarget: pbxTarget,
                                      project: project,
                                      explicitDependencies: dependencies,
                                      projectBuildConfigurations: project.buildConfigurations)
        targetsDataSource.addAggregatedTarget(target)
        return target
    }

    // MARK: - Delete Targets

    func deleteTargets(_ targetsForRemove: Set<Target>, keepGroups: Bool) async throws {
        guard targetsForRemove.isNotEmpty else { return }

        // Remove all dependencies with these targets
        let targets = try await targetsDataSource.targets.subtracting(targetsForRemove)
        try await targets.concurrentCompactMap { target in
            // Add sub-dependencies of removing dependency explicitly
            let dependencies = target.explicitDependencies.intersection(targetsForRemove)
            guard dependencies.isNotEmpty else { return }

            try dependencies.forEach { targetForRemove in
                let shouldBeExplicit = targetForRemove.dependencies
                    .subtracting(targetsForRemove)
                    .subtracting(target.explicitDependencies)
                if shouldBeExplicit.isNotEmpty {
                    try target.project.pbxProj.addDependencies(shouldBeExplicit, target: target)
                }
            }
            target.project.pbxProj.deleteDependencies(dependencies, target: target)
        }

        if !keepGroups {
            let targetsByProject: [Project: Set<Target>] = targetsForRemove.reduce(into: [:]) { dictionary, target in
                dictionary[target.project, default: []].insert(target)
            }
            let targets = try await targetsDataSource.targets
            targetsByProject.forEach { project, targetsForRemove in
                project.deleteTargetGroups(targetsForRemove, targets: targets)
            }
        }

        let pbxTargetsForRemove = targetsForRemove.lazy.map(\.pbxTarget)
        try targetsForRemove.forEach { target in
            try target.project.pbxProj.deleteTargetReferences(target.pbxTarget)
            try target.project.pbxProject.targets.removeAll(where: { $0.uuid == target.pbxTarget.uuid })
        }
        try await projectDataSource.rootProject.pbxProject.targets.removeAll(where: pbxTargetsForRemove.contains)

        targetsDataSource.deleteTargets(targetsForRemove)

        try await schemesEditor.deleteSchemes(ofTargets: targetsForRemove,
                                              targets: targetsDataSource.targets)
    }
}
