//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import ComposableArchitecture
import APIClient
import Models
import Charts

public struct InputFeature: Reducer {
    @Dependency(\.apiClient) var apiClient: APIClient

    public struct State: Equatable {
        public enum Field: Hashable {
            case number
        }

        public enum ButtonState: Equatable {
            case ready
            case loading
            case error(String)
        }

        var buttonState: ButtonState

        @BindingState var focusedField: Field?
        @BindingState var text: String
        @PresentationState var destination: Destination.State?

        public init(buttonState: ButtonState = .ready,
                    focusedField: Field? = nil,
                    text: String = "",
                    destination: Destination.State? = nil) {
            self.buttonState = buttonState
            self.focusedField = focusedField
            self.text = text
            self.destination = destination
        }
    }

    public enum Action: BindableAction, Equatable {
        case destination(PresentationAction<Destination.Action>)
        case binding(BindingAction<State>)

        case keyboardDoneButtonTapped
        case letsGoButtonTapped
        case pointsFetched(Result<[Point], APIError>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .destination:
                break
            case .keyboardDoneButtonTapped:
                state.focusedField = nil
            case .binding:
                state.buttonState = .ready
            case .letsGoButtonTapped:
                guard let count = getValidCount(state.text) else {
                    state.buttonState = .error("Введите номер от 1 до 1000")
                    return .none
                }
                state.buttonState = .loading
                state.focusedField = nil
                return .run { send in
                    await loadPoints(count: count, send: send)
                }
            case .pointsFetched(let result):
                switch result {
                case .success(let points):
                    state.focusedField = nil
                    state.buttonState = .ready
                    let sortedPoints = self.sortedByX(points)
                    state.destination = .chart(.init(points: sortedPoints))
                case .failure:
                    state.buttonState = .error("Что то пошло не так...")
                }
            }
            return .none
        }
        .ifLet(\.$destination, action: /Action.destination) {
            Destination()
        }
        BindingReducer()
    }
}

private extension InputFeature {
    func loadPoints(count: Int, send: Send<InputFeature.Action>) async {
        do {
            let points = try await apiClient.getPoints(count)
            await send(.pointsFetched(.success(points)))
        } catch {
            await send(.pointsFetched(.failure(.requestError(desription: error.localizedDescription))))
        }
    }

    func sortedByX(_ points: [Point]) -> [Point] {
        points.sorted(by: { $0.x < $1.x })
    }

    func getValidCount(_ text: String) -> Int? {
        guard !text.isEmpty,
              let number = Int(text),
              number > 0 && number <= 1000
        else { return nil }

        return number
    }
}
