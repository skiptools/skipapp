// Copyright 2023 Skip
//
// This is free software: you can redistribute and/or modify it
// under the terms of the GNU Lesser General Public License 3.0
// as published by the Free Software Foundation https://fsf.org
#if canImport(SkipUnit)
import SkipUnit

/// This test case will run the transpiled tests for the Skip module.
@available(macOS 13, macCatalyst 16, *)
final class XCSkipTests: XCTestCase, XCGradleHarness {
    public func testSkipModule() async throws {
        #if DEBUG
        try await gradle(actions: ["testDebug"])
        #else
        try await gradle(actions: ["testRelease"])
        #endif
    }
}
#endif
