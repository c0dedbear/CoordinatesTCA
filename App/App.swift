//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import SwiftUI
import ComposableArchitecture
import Input

@main
struct CoordinatesApp: App {
    private let store = Store(initialState: AppReducer.State(), reducer: { AppReducer() })

    var body: some Scene {
        WindowGroup {
            InputFeatureView(store: self.store.scope(state: \.input, action: AppReducer.Action.input))
        }
    }
}
