//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import Models

public struct APIClient {
    public var getPoints: @Sendable (_ count: Int) async throws -> [Point]

    public init(getCoordinates: @escaping @Sendable (Int) async throws -> [Point]) {
        self.getPoints = getCoordinates
    }
}
