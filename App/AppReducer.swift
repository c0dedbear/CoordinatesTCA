//
//  Created by Mikhail Medvedev on 07.08.2023.
//

import Foundation
import ComposableArchitecture
import Input
import Chart

struct AppReducer: Reducer {
    struct State: Equatable {
        // MARK: Features state
        var input = InputFeature.State()
        var chart = ChartFeature.State()
    }

    enum Action: Equatable {
        // MARK: Child actions
        case input(InputFeature.Action)
        case chart(ChartFeature.Action)
    }

    // MARK: Reduce body
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { _, _ in
            // Если бы нужно было как то отреагировать на изменения в фичах
            // на уровне приложения, то делали бы это здесь
            return .none
        }
        Scope(state: \.input, action: /Action.input) {
            InputFeature()
        }
        Scope(state: \.chart, action: /Action.chart) {
            ChartFeature()
        }
    }
}
