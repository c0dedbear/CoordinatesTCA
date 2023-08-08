//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation

extension URL: Identifiable {
    public var id: String { self.absoluteString }
}
