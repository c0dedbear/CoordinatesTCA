import XCTest
import ComposableArchitecture
@testable import Chart
import SwiftUI

@MainActor
final class ChartTests: XCTestCase {
    func testDismissal() async {
        let effect = DismissalEffect()
        let store = TestStore(initialState: ChartFeature.State()) {
            ChartFeature()
        } withDependencies: {
            $0.dismiss = .init { Task { await effect.dismiss() } }
        }

        await store.send(.doneButtonTapped)
        let isDismissed = await effect.dismissed

        XCTAssertEqual(isDismissed, true)
    }

    func testPDFExport() async {
        let store = TestStore(initialState: ChartFeature.State()) {
            ChartFeature()
        }
        let fileUrl = URL.documentsDirectory.appending(path: "chart.pdf")

        await store.send(.shareButtonTapped(content: EmptyView()))
        await store.receive(.pdfRendered(at: fileUrl)) {
            $0.chatRenderURL = fileUrl
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path()))

        await store.send(.activityViewDismissed)
        XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path()))
    }
}

extension ChartTests {
    actor DismissalEffect {
        var dismissed = false

        func dismiss() async {
            dismissed = true
        }
    }
}
