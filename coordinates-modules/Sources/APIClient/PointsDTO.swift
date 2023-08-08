//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import Models

// MARK: - Welcome
public struct PointsDTO: Decodable {
    public let points: [Point]
}
