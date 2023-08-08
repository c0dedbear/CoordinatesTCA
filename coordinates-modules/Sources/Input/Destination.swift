//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import ComposableArchitecture
import Chart

extension InputFeature {
    public struct Destination: Reducer {
        public enum State: Equatable {
            case chart(ChartFeature.State)
        }

        public enum Action: Equatable {
            case openChart(ChartFeature.Action)
        }

        public init() {}

        public var body: some ReducerOf<Self> {
            Scope(state: /State.chart, action: /Action.openChart) {
                ChartFeature()
            }
        }
    }
}
