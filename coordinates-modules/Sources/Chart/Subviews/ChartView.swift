//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import SwiftUI
import Charts
import Models
import ComposableArchitecture

public struct ChartView: View {
    private let lineWidth: Double = 1.2
    private let chartColor: Color = .blue
    private let tipHoverColor: Color = .red
    @State private var selectedPoint: Point?

    private let store: StoreOf<ChartFeature>

    public init(store: StoreOf<ChartFeature>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Chart {
                ForEach(viewStore.points) { point in
                    let baselineMarker = makeLineMark(for: point,
                                                      showSymbols: viewStore.isDotsShown,
                                                      isSmooth: viewStore.isSmoothLines)
                    if selectedPoint == point && viewStore.isDotsShown {
                        baselineMarker.symbol {
                            Circle()
                                .strokeBorder(chartColor, lineWidth: lineWidth)
                                .background(
                                    Circle()
                                        .foregroundColor(tipHoverColor)
                                )
                                .frame(width: 11)
                        }
                    } else {
                        baselineMarker.symbol(Circle().strokeBorder(lineWidth: lineWidth))
                    }
                }
            }
            .chartYScale(domain: viewStore.yScaleRange)
            .chartXScale(domain: viewStore.xScaleRange)
            .chartOverlay { chartOverlay($0, points: viewStore.points) }
            .chartBackground { chartBackground($0, isDotsShown: viewStore.isDotsShown) }
        }
    }

    private func chartBackground(_ proxy: ChartProxy, isDotsShown: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { geo in
                if let selectedElement = selectedPoint, isDotsShown {
                    let startPositionX1 = proxy.position(forX: selectedElement.x) ?? 0

                    let lineX = startPositionX1 + geo[proxy.plotAreaFrame].origin.x
                    let lineHeight = geo[proxy.plotAreaFrame].maxY
                    let boxWidth: CGFloat = 70
                    let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))

                    Rectangle()
                        .fill(tipHoverColor)
                        .frame(width: lineWidth, height: lineHeight)
                        .position(x: lineX, y: lineHeight / 2)

                    VStack(alignment: .leading) {
                        Text("X: \(selectedElement.x, specifier: "%.1f")")
                            .font(.callout.bold())
                        Text("Y: \(selectedElement.y, specifier: "%.1f")")
                            .font(.callout.bold())
                    }
                    .frame(maxWidth: boxWidth)
                    .foregroundColor(.white)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.green)
                            .padding(.horizontal, -8)
                            .padding(.vertical, -4)
                    }
                    .offset(x: boxOffset)
                }
            }
        }
    }

    private func chartOverlay(_ proxy: ChartProxy, points: [Point]) -> some View {
        GeometryReader { geo in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(
                    SpatialTapGesture()
                        .onEnded { value in
                            selectedPoint = self.findElement(in: points, location: value.location, chartProxy: proxy, geo: geo)
                        }
                        .exclusively(
                            before: DragGesture()
                                .onChanged { value in
                                    selectedPoint = self.findElement(in: points, location: value.location, chartProxy: proxy, geo: geo)
                                }
                        )
                )
        }
    }

    private func makeLineMark(for point: Point,
                              showSymbols: Bool,
                              isSmooth: Bool) -> some ChartContent {
        LineMark(x: .value("X", point.x),
                 y: .value("Y", point.y))
        .lineStyle(StrokeStyle(lineWidth: lineWidth))
        .foregroundStyle(chartColor)
        .interpolationMethod(isSmooth ? .cardinal : .linear)
        .symbolSize(showSymbols ? 60 : 0)
    }

    private func findElement(in points: [Point],
                             location: CGPoint,
                             chartProxy: ChartProxy,
                             geo: GeometryProxy) -> Point? {
        let relativeXPosition = location.x - geo[chartProxy.plotAreaFrame].origin.x
        if let xPointValue = chartProxy.value(atX: relativeXPosition) as Double? {
            return closestPoint(to: xPointValue, in: points)
        }
        return nil
    }

    private func closestPoint(to xValue: Double, in points: [Point]) -> Point? {
        guard !points.isEmpty else { return nil }
        return points.min(by: { abs($0.x - xValue) < abs($1.x - xValue) })
    }
}

// MARK: - Preview
struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView(store: .init(initialState: ChartFeature.State(),
                               reducer: { ChartFeature() })
        )
    }
}
