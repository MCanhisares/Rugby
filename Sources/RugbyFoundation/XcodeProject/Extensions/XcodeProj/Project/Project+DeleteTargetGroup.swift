//
//  Project+DeleteTargetGroup.swift
//  RugbyFoundation
//
//  Created by Vyacheslav Khorkov on 29.03.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

import XcodeProj

extension Project {
    func deleteTargetGroups(_ targetsForRemove: Set<Target>, targets: Set<Target>) {
        let excludedFiles = targets
            .subtracting(targetsForRemove)
            .flatMap { targetFiles($0.pbxTarget) }
        let filesForRemove = targetsForRemove
            .flatMap { targetFiles($0.pbxTarget) }
            .subtracting(excludedFiles)
        filesForRemove.forEach(deleteFileElement)
    }

    private func targetFiles(_ target: PBXTarget) -> [PBXFileElement] {
        target.buildPhases.flatMap { $0.files ?? [] }.compactMap(\.file)
    }

    private func deleteFileElement(_ fileElement: PBXFileElement) {
        if let group = fileElement as? PBXGroup {
            group.children.forEach(deleteFileElement)
        }
        pbxProj.delete(object: fileElement)

        guard let groupParent = fileElement.parent as? PBXGroup else { return }
        groupParent.children.removeAll(where: { $0.uuid == fileElement.uuid })
        fileElement.parent = nil

        // Delete all parent folders recursively if they are empty or contain only CocoaPods files
        groupParent.children
            .compactMap(\.displayName)
            .contains { $0 != .supportFilesGroupName && $0 != .podspecGroupName && !$0.hasPrefix(.appHostName) }
            .ifFalse { deleteFileElement(groupParent) }
    }
}

private extension String {
    static let supportFilesGroupName = "Support Files"
    static let podspecGroupName = "Pod"
    static let appHostName = "AppHost"
}
