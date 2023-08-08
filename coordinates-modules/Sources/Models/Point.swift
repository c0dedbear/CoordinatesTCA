//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation

// swiftlint:disable identifier_name

public struct Point: Hashable, Identifiable, Decodable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public var id: String { "\(x) \(y)" }
}
