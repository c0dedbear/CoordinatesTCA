//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import Models
import XCTestDynamicOverlay
import Dependencies

extension APIClient {
    public static let test = APIClient(
        getCoordinates: unimplemented("This is unimplemented version of \(#function)")
    )

    public static let preview = APIClient { _ in
        [
            Point(x: 0, y: 0.2),
            Point(x: 0.4, y: 0.9),
            Point(x: 1.4, y: 1.8),
            Point(x: 2, y: 2.5),
            Point(x: 3, y: 4),
            Point(x: 3.7, y: 4.2),
            Point(x: 4.6, y: 5.5),
            Point(x: 5.2, y: 7),
            Point(x: 6.5, y: 8),
            Point(x: 7, y: 3),
            Point(x: 10, y: 10)
        ]
    }
}

public enum APIClientTestDependencyKey: TestDependencyKey {
    public static let testValue: APIClient = .test
    public static let previewValue: APIClient = .preview
}

extension DependencyValues {
    public var apiClient: APIClient {
        get { self[APIClientTestDependencyKey.self] }
        set { self[APIClientTestDependencyKey.self] = newValue }
    }
}
