//
//  ParsableCommand+ParseCommand.swift
//  Rugby
//
//  Created by Vyacheslav Khorkov on 01.11.2022.
//  Copyright © 2022 Vyacheslav Khorkov. All rights reserved.
//

import ArgumentParser

// MARK: - Interface

protocol AnyArgumentsCommand: ParsableCommand {
    var arguments: [String] { get set }
}

// MARK: - Implementation

extension ParsableCommand {
    static func parseCommand(_ arguments: [String]? = nil) throws -> ParsableCommand {
        let arguments = arguments ?? Array(CommandLine.arguments.dropFirst())
        let (commandType, argumentsWithoutCommandNames) = parseCommandType(arguments: arguments)
        guard CommonFlags.all.isDisjoint(with: argumentsWithoutCommandNames),
              commandType is AnyArgumentsCommand.Type,
              var hasArgumentsCommand = commandType.init() as? AnyArgumentsCommand else {
            return try parseAsRoot(arguments)
        }
        hasArgumentsCommand.arguments = argumentsWithoutCommandNames
        return hasArgumentsCommand
    }
}
