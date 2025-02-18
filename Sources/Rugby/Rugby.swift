//
//  Rugby.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 04.07.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser
import RugbyFoundation

extension String {
    static let version = "2.0.3"
    // ╭────────────────────────────────╮
    // │                                │
    // │       █▀█ █ █ █▀▀ █▄▄ █▄█      │
    // │     > █▀▄ █▄█ █▄█ █▄█  █       │
    // │                 v.2.0.3        │
    // │ Cache Cocoa 🌱 pods            │
    // │             for faster rebuild │
    // │   and indexing Xcode project   │
    // │                                │
    // ╰────────────────────────────────╯
    static let abstract = """
    ╭────────────────────────────────╮
    │                                │
    │       \("█▀█ █ █ █▀▀ █▄▄ █▄█".accent)      │
    │     \(">".black.bold.onAccent) \("█▀▄ █▄█ █▄█ █▄█  █".accent)       │
    │                 \("v.\(version)".accent.bold)        │
    │ \("Cache Cocoa 🌱 pods".bold)            │
    │             \("for faster rebuild".bold) │
    │   \("and indexing Xcode project".bold)   │
    │                                │
    ╰────────────────────────────────╯
    """.white
}

@main
struct Rugby: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: String.abstract,
        discussion: Links.docs("README.md"),
        version: String.version,
        subcommands: [
            Shortcuts.self,
            Build.self,
            Use.self,
            Delete.self,
            Warmup.self,
            Rollback.self,
            Plan.self,
            Clear.self,
            Update.self,
            Doctor.self,
            Shell.self,
            Env.self
        ],
        defaultSubcommand: Shortcuts.self
    )

    static func main() async {
        prepareDependencies()
        do {
            if try printHelp() { return }

            var command = try parseCommand()
            if var asyncCommand = command as? AsyncParsableCommand {
                try await asyncCommand.run()
            } else {
                try command.run()
            }
        } catch {
            exit(withError: error)
        }
    }

    // MARK: - Private

    private static func prepareDependencies() {
        Vault.setupShared(
            featureToggles: FeatureToggles(),
            logger: Logger()
        )
    }

    private static func printHelp() throws -> Bool {
        if CommonFlags.help.isDisjoint(with: CommandLine.arguments) { return false }
        let commandInfo = try HelpDumper().dump(command: Rugby.self)
        HelpPrinter().print(command: commandInfo)
        return true
    }
}
