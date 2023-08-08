//
//  Created by Mikhail Medvedev on 06.08.2023.
//

import Foundation
import Models
import APIClient
import Dependencies

extension APIClient {
    public static let live = APIClient(getCoordinates: Self.getPoints)
}

extension APIClientTestDependencyKey: DependencyKey {
    public static let liveValue: APIClient = .live
}

extension APIClient {
    @Sendable
    static func getPoints(count: Int) async throws -> [Point] {
        var urlComponents = URLComponents(string: "https://hr-challenge.interactivestandard.com/api/test/points")
        let query = URLQueryItem(name: "count", value: String(count))
        urlComponents?.queryItems = [query]

        guard let url = urlComponents?.url
        else { throw APIError.requestError(desription: "Invalid URL") }

        var request = URLRequest(url: url, timeoutInterval: 10)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let okResponse = response as? HTTPURLResponse,
              okResponse.statusCode == 200
        else { throw APIError.requestError(desription: "Bad response") }

        let pointsDto = try JSONDecoder().decode(PointsDTO.self, from: data)

        return pointsDto.points
    }
}
