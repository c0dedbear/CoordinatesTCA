//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation

public enum APIError: Error, Equatable {
    case requestError(desription: String)
}
