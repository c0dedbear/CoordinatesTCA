//
//  Created by Mikhail Medvedev on 08.08.2023.
//

import Foundation
import XCTest

// swiftlint:disable identifier_name

// Темная магия для фикса ошибки компилятора: Macro 'XCTFail' not imported: function like macros not supported
// https://forums.swift.org/t/dynamically-call-xctfail-in-spm-module-without-importing-xctest/36375

typealias XCTCurrentTestCase = @convention(c) () -> AnyObject
typealias XCTFailureHandler = @convention(c) (AnyObject, Bool, UnsafePointer<CChar>, UInt, String, String?) -> Void

private func _XCTFail(_ message: String = "", file: StaticString = #file, line: UInt = #line) {
    guard
        let _XCTest = NSClassFromString("XCTest")
            .flatMap(Bundle.init(for:))
            .flatMap({ $0.executablePath })
            .flatMap({ dlopen($0, RTLD_NOW) })
    else { return }

    guard
        let _XCTFailureHandler = dlsym(_XCTest, "_XCTFailureHandler")
            .map({ unsafeBitCast($0, to: XCTFailureHandler.self) })
    else { return }

    guard
        let _XCTCurrentTestCase = dlsym(_XCTest, "_XCTCurrentTestCase")
            .map({ unsafeBitCast($0, to: XCTCurrentTestCase.self) })
    else { return }

    _XCTFailureHandler(_XCTCurrentTestCase(), true, "\(file)", line, message, nil)
}

extension XCTest {
    /// Хэлпер для ассертов асинхронных методов
    public func XCTAssertThrowsError<T: Sendable>(
        _ expression: @autoclosure () async throws -> T,
        _ message: @autoclosure () -> String = "",
        file: StaticString = #filePath,
        line: UInt = #line,
        _ errorHandler: (_ error: Error) -> Void = { _ in }
    ) async {
        do {
            _ = try await expression()
            _XCTFail(message(), file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}
