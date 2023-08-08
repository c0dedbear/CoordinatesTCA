//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import SwiftUI
import ComposableArchitecture

public struct ChartFeatureView: View {
    private let store: StoreOf<ChartFeature>

    public init(store: StoreOf<ChartFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationStack {
                List {
                    Section(header: Text("Координаты"),
                            footer: Text("Всего значений: \(viewStore.points.count)")) {
                        PointsListView(points: viewStore.points)
                            .frame(maxHeight: 200)
                    }
                    Section("График") {
                        chart
                    }

                    Section("Настройки графика") {
                        Toggle(isOn: viewStore.$needScaleXAxis) {
                            Text("Масштабировать ось X")
                        }
                        Toggle(isOn: viewStore.$needScaleYAxis) {
                            Text("Масштабировать ось Y")
                        }
                        Toggle(isOn: viewStore.$isDotsShown) {
                            Text("Показывать точки")
                        }
                        Toggle(isOn: viewStore.$isSmoothLines) {
                            Text("Сглаживать линии")
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .toolbar(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { viewStore.send(.doneButtonTapped) }) {
                            Text("Закрыть")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { viewStore.send(.shareButtonTapped(content: self.chart.frame(width: 300, height: 260))) }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                .interactiveDismissDisabled(true)
            }
            .sheet(item: viewStore.$chatRenderURL, onDismiss: { viewStore.send(.activityViewDismissed) }) { url in
                ActivityViewController(url: url)
            }
        }
    }

    private var chart: some View {
        ChartView(store: self.store)
            .frame(height: 280)
    }
}

// MARK: - Preview
struct ChartFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        ChartFeatureView(store: .init(initialState: ChartFeature.State(),
                                      reducer: { ChartFeature() })
        )
    }
}
