//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import Models
import ComposableArchitecture
import SwiftUI
import Charts

public struct ChartFeature: Reducer {
    @Dependency(\.dismiss) var dismiss

    public init() {}

    public struct State: Equatable {
        var selectedElement: Point?
        var points: [Point]

        @BindingState var isDotsShown = true
        @BindingState var isSmoothLines = true
        @BindingState var needScaleXAxis = false
        @BindingState var needScaleYAxis = false
        @BindingState var chatRenderURL: URL?

        public init(selectedElement: Point? = nil, points: [Point] = []) {
            self.selectedElement = selectedElement
            self.points = points
        }

        var xScaleRange: ClosedRange<Int> {
            guard needScaleXAxis else { return -100...100 }
            let max = Int(self.points.map { $0.x }.max() ?? 1) + 1
            let min = Int(self.points.map { $0.x }.min() ?? 0) - 1
            return min...max
        }

        var yScaleRange: ClosedRange<Int> {
            guard needScaleYAxis else { return -100...100 }
            let max = Int(self.points.map { $0.y }.max() ?? 1) + 20
            let min = Int(self.points.map { $0.y }.min() ?? 0) - 20
            return min...max
        }
    }

    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case doneButtonTapped
        case shareButtonTapped(content: any View)
        case activityViewDismissed
        case pdfRendered(at: URL)
        case spatialTapGestureEnded(location: CGPoint,
                                    chartProxy: ChartProxy,
                                    geoProxy: GeometryProxy)
        case dragGestureChanged(location: CGPoint,
                                chartProxy: ChartProxy,
                                geoProxy: GeometryProxy)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .activityViewDismissed:
                return .run { _ in try self.removePDFFile() }
            case .shareButtonTapped(let content):
                return .run { send in
                    let url = await self.renderAndExportPDF(content: content)
                    await send(.pdfRendered(at: url))
                }
            case .pdfRendered(let url):
                state.chatRenderURL = url
            case .doneButtonTapped:
                return .run { _ in await self.dismiss() }
            case let .spatialTapGestureEnded(location, chartProxy, geoProxy):
                let element = self.findElement(in: state.points, location: location, chartProxy: chartProxy, geometry: geoProxy)
                let newPoint = (state.selectedElement?.x == element?.x) ? nil : element
                state.selectedElement = newPoint
            case let .dragGestureChanged(location, chartProxy, geoProxy):
                let newPoint = self.findElement(in: state.points, location: location, chartProxy: chartProxy, geometry: geoProxy)
                state.selectedElement = newPoint
            }
            return .none
        }
        BindingReducer()
    }
}

private extension ChartFeature {
    func findElement(in points: [Point],
                     location: CGPoint,
                     chartProxy: ChartProxy,
                     geometry: GeometryProxy) -> Point? {
        let relativeXPosition = location.x - geometry[chartProxy.plotAreaFrame].origin.x
        if let xPointValue = chartProxy.value(atX: relativeXPosition) as Double? {
            return closestPoint(to: xPointValue, in: points)
        }
        return nil
    }

    func closestPoint(to xValue: Double, in points: [Point]) -> Point? {
        guard !points.isEmpty else { return nil }
        return points.min(by: { abs($0.x - xValue) < abs($1.x - xValue) })
    }

    func renderAndExportPDF(content: some View) async -> URL {
        let fileUrl = URL.documentsDirectory.appending(path: "chart.pdf")

        await ImageRenderer(content: content).render { size, renderInContext in
            let translation: CGAffineTransform = .init(translationX: -size.width / 4, y: -size.height / 4)
            var box = CGRect(origin: .zero, size: .init(width: size.width * 1.5, height: size.height * 1.5)).applying(translation)

            guard let context = CGContext(fileUrl as CFURL, mediaBox: &box, nil) else {
                return
            }

            context.beginPDFPage(nil)
            renderInContext(context)
            context.endPage()
            context.closePDF()
        }

        return fileUrl
    }

    func removePDFFile() throws {
        let fileUrl = URL.documentsDirectory.appending(path: "chart.pdf")
        try FileManager.default.removeItem(at: fileUrl)
    }
}
