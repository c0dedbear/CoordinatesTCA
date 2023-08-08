//
//  Created by Mikhail Medvedev on 07.08.2023.
//

import Foundation
import ComposableArchitecture
import Input
import Chart
import enum SwiftUI.ScenePhase

struct AppReducer: Reducer {
    struct State: Equatable {
        var scenePhase: ScenePhase?

        // MARK: Features state
        var input = InputFeature.State()
        var chart = ChartFeature.State()
    }

    enum Action: Equatable {
        // MARK: App
        case scenePhaseChanged(ScenePhase)

        // MARK: Child actions
        case input(InputFeature.Action)
        case chart(ChartFeature.Action)
    }

    // MARK: Reduce body
    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            self.handleChanges(into: &state, action: action)
        }
        Scope(state: \.input, action: /Action.input) {
            InputFeature()
        }
        Scope(state: \.chart, action: /Action.chart) {
            ChartFeature()
        }
        ._printChanges()
    }
}

// MARK: Effects Handling
private extension AppReducer {
    func handleChanges(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .scenePhaseChanged(let phase):
            self.onScenePhaseChanged(in: &state, phase: phase)
            return .none
        case .chart, .input:
            return .none
        }
    }

    private func onScenePhaseChanged(in state: inout State, phase: ScenePhase) {
        state.scenePhase = phase

        switch phase {
        case .background:
            print(phase)
        case .inactive:
            print(phase)
        case .active:
            print(phase)
        @unknown default:
            fatalError("Unknown scene phase: \(phase)")
        }
    }
}
