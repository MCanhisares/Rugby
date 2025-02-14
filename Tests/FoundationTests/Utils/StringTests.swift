//
//  StringTests.swift
//  FoundationTests
//
//  Created by Vyacheslav Khorkov on 03.09.2023.
//  Copyright © 2023 Vyacheslav Khorkov. All rights reserved.
//

@testable import RugbyFoundation
import XCTest

final class StringTests: XCTestCase {

    // MARK: - homeFinderRelativePath

    func test_homeFinderRelativePath_success() {
        let homeDirectoryPath = ProcessInfo.processInfo.environment["HOME"] ?? ""
        let path = "\(homeDirectoryPath)/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeFinderRelativePath(), "~/some/path/to/folder")
    }

    func test_homeFinderRelativePath_fail() {
        let path = "/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeFinderRelativePath(), path)
    }

    // MARK: - homeEnvRelativePath

    func test_homeEnvRelativePath_success() {
        let homeDirectoryPath = ProcessInfo.processInfo.environment["HOME"] ?? ""
        let path = "\(homeDirectoryPath)/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeEnvRelativePath(), "${HOME}/some/path/to/folder")
    }

    func test_homeEnvRelativePath_fail() {
        let path = "/some/path/to/folder"

        // Act & Assert
        XCTAssertEqual(path.homeEnvRelativePath(), path)
    }

    // MARK: - groups(regex:)

    func test_groupRegex() throws {
        let regex = #"(Apple Swift version)\s(\d+\.\d+(?:\.\d)?)"#

        // Act
        let groups = try "Apple Swift version 5.7.1".groups(regex: regex)

        // Assert
        XCTAssertEqual(groups, ["Apple Swift version 5.7.1", "Apple Swift version", "5.7.1"])
    }
}
