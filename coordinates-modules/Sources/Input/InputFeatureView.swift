//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import SwiftUI
import ComposableArchitecture
import Chart

public struct InputFeatureView: View {
    private let store: StoreOf<InputFeature>

    @FocusState var focusedField: InputFeature.State.Field?

    public init(store: StoreOf<InputFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("Введите количество точек:")
                TextField("от 1 до 1000", text: viewStore.$text)
                    .focused($focusedField, equals: .number)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .frame(width: 250)
                    .font(.title2)
                    .border(.blue)
                    .buttonBorderShape(.roundedRectangle)
                    .padding()
                    .synchronize(viewStore.$focusedField, self.$focusedField)
                if case let .error(errorText) = viewStore.buttonState {
                    Text(errorText)
                        .foregroundColor(.red)
                }
                letsGoButton(viewStore.buttonState,
                             action: { viewStore.send(.letsGoButtonTapped) })
                .frame(width: 280)
                .padding(.top, 30)
            }
            .padding()
            .animation(.default, value: viewStore.buttonState)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("Готово") { viewStore.send(.keyboardDoneButtonTapped) }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .sheet(store: self.store.scope(state: \.$destination,
                                           action: InputFeature.Action.destination),
                   state: /InputFeature.Destination.State.chart,
                   action: InputFeature.Destination.Action.openChart) {
                ChartFeatureView(store: $0)
            }
        }
    }

    @ViewBuilder
    private func letsGoButton(_ state: InputFeature.State.ButtonState,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack {
                switch state {
                case .ready:
                    Text("Поехали 🚀")
                case .loading:
                    ProgressView()
                case .error:
                    Label("Повторить", systemImage: "repeat")
                }
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(.blue.opacity(state == .loading ? 0.5 : 1))
            .font(.title3.bold())
            .cornerRadius(16)
        }
        .disabled(state == .loading)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        InputFeatureView(store: .init(initialState: InputFeature.State(text: "42"),
                                 reducer: { InputFeature() }))
    }
}
