//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import SwiftUI
import Models

struct PointsListView: View {
    private let points: [Point]

    init(points: [Point]) {
        self.points = points
    }

    var body: some View {
        ScrollView {
            ForEach(points) { point in
                let number = (points.firstIndex(of: point) ?? 1) + 1
                VStack {
                    HStack {
                        Text("\(number).")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("X: \(point.x, specifier: "%.2f")")
                        Text("-")
                        Text("Y: \(point.y, specifier: "%.2f")")
                        Spacer()
                    }
                    .padding(.horizontal)
                    if points.last != point {
                        Divider()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.top)
        }
        .scrollBounceBehavior(.basedOnSize)
        .scrollIndicators(.automatic)
    }
}

// MARK: - Preview
struct PointsListView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            Section("Координаты") {
                PointsListView(points: [.init(x: 1, y: 2)])
            }
        }
    }
}
