import XCTest
import ComposableArchitecture
import APIClient
import Models
@testable import Input

@MainActor
final class InputTests: XCTestCase {
    func testKeyboardHiding() async {
        let store = TestStore(initialState: InputFeature.State()) {
            InputFeature()
        }

        await store.send(.binding(.set(\.$focusedField, .number))) {
            $0.focusedField = .number
        }

        await store.send(.binding(.set(\.$text, "3"))) {
            $0.text = "3"
        }

        await store.send(.keyboardDoneButtonTapped) {
            $0.focusedField = nil
        }
    }

    func testOpenChart() async {
        let response = [
            Point(x: 0.4, y: 0.9),
            Point(x: 0, y: 0.2),
            Point(x: 1.4, y: 1.8)
        ]
        let store = TestStore(initialState: InputFeature.State()) {
            InputFeature()
        } withDependencies: {
            $0.apiClient = APIClient(getCoordinates: { _ in
                response
            })
        }

        await store.send(.binding(.set(\.$text, "10"))) {
            $0.text = "10"
        }

        await store.send(.letsGoButtonTapped) {
            $0.buttonState = .loading
            $0.focusedField = nil
        }

        await store.receive(.pointsFetched(.success(response))) {
            $0.focusedField = nil
            $0.buttonState = .ready
            $0.destination = .chart(.init(points: response.sorted(by: { $0.x < $1.x })))
        }
    }

    func testReceiveAnErrorResponse() async {
        let error = APIError.requestError(desription: "Не удалось завершить операцию. (APIClient.APIError, ошибка 0)")
        let store = TestStore(initialState: InputFeature.State()) {
            InputFeature()
        } withDependencies: {
            $0.apiClient = APIClient(getCoordinates: { _ in throw error })
        }

        await store.send(.binding(.set(\.$text, "10"))) {
            $0.text = "10"
        }

        await store.send(.letsGoButtonTapped) {
            $0.buttonState = .loading
            $0.focusedField = nil
        }

        await store.receive(.pointsFetched(.failure(error))) {
            $0.buttonState = .error("Что то пошло не так...")
        }
    }

    func testTextInputValidation() async {
        let store = TestStore(initialState: InputFeature.State()) {
            InputFeature()
        }

        await store.send(.binding(.set(\.$focusedField, .number))) {
            $0.focusedField = .number
        }

        await store.send(.binding(.set(\.$text, "10ddf"))) {
            $0.text = "10ddf"
        }

        await store.send(.letsGoButtonTapped) {
            $0.buttonState = .error("Введите номер от 1 до 1000")
        }
    }
}
