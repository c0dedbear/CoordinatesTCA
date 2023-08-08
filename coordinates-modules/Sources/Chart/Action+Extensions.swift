//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation

extension ChartFeature.Action: Identifiable {
    public var id: String {
        switch self {
        case .activityViewDismissed:
            return "activityViewDismissed"
        case .pdfRendered(let url):
            return "pdfRendered \(url.absoluteString)"
        case .shareButtonTapped:
            return "shareButtonTapped"
        case .binding:
            return "binding"
        case .doneButtonTapped:
            return "doneButtonTapped"
        case let .dragGestureChanged(location, chartProxy, geoProxy),
            let .spatialTapGestureEnded(location, chartProxy, geoProxy):
            return "\(location), \(chartProxy), \(geoProxy)"
        }
    }
}

extension ChartFeature.Action: Equatable {
    public static func == (lhs: ChartFeature.Action, rhs: ChartFeature.Action) -> Bool { lhs.id == rhs.id }
}
