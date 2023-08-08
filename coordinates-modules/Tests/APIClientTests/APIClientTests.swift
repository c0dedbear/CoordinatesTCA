import XCTest
import APIClient
import Models

@MainActor
final class APIClientTests: XCTestCase {
    func testInterface() async throws {
        let points = [
            Point(x: 1.2, y: 1),
            Point(x: 1.2, y: 2),
            Point(x: 1.2, y: 3)
        ]

        let testClient = APIClient { number in
            if number == 3 {
                return points
            } else {
                return []
            }
        }

        let response = try await testClient.getPoints(3)
        XCTAssertEqual(points, response)

        let emptyResponse = try await testClient.getPoints(0)
        XCTAssertEqual([], emptyResponse)
    }

    func testErrorThrowing() async throws {
        let expectedError = APIError.requestError(desription: "Some error")

        let testClient = APIClient { _ in
            throw APIError.requestError(desription: "Some error")
        }

        try await XCTAssertThrowsError(await testClient.getPoints(3)) { handledError in
            XCTAssertEqual(handledError.localizedDescription, expectedError.localizedDescription)
        }
    }
}
