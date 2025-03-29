//
//  GoogleDirections.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import Foundation
import CoreLocation

//extension ShuttleViewModel {
//    // Function to fetch actual directions from Google Directions API
//    func fetchActualDirections() {
//        let origin = "\(driverLocation.latitude),\(driverLocation.longitude)"
//        let destination = "\(pickupLocation.latitude),\(pickupLocation.longitude)"
//        let apiKey = "AIzaSyC2yPOEWxrF_381zpLA8ZSyUqCMzC3C6nA"
//
//        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&key=\(apiKey)"
//
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            guard let data = data, error == nil else {
//                print("Network error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let routes = json["routes"] as? [[String: Any]],
//                   let route = routes.first,
//                   let legs = route["legs"] as? [[String: Any]],
//                   let leg = legs.first,
//                   let steps = leg["steps"] as? [[String: Any]] {
//
//                    var points: [CLLocationCoordinate2D] = []
//
//                    for step in steps {
//                        if let polyline = step["polyline"] as? [String: Any],
//                           let points_encoded = polyline["points"] as? String {
//                            let stepPoints = self?.decodePolyline(points_encoded)
//                            if let stepPoints = stepPoints {
//                                points.append(contentsOf: stepPoints)
//                            }
//                        }
//                    }
//
//                    DispatchQueue.main.async {
//                        self?.routePoints = points
//                        self?.startSimulation()
//                    }
//                }
//            } catch {
//                print("JSON parsing error: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//
//    // Google Polyline decoder function
//    func decodePolyline(_ polyline: String) -> [CLLocationCoordinate2D] {
//        var coordinates: [CLLocationCoordinate2D] = []
//        var index = 0
//        let length = polyline.count
//        var lat = 0.0
//        var lng = 0.0
//
//        while index < length {
//            var b: Int
//            var shift = 0
//            var result = 0
//
//            repeat {
//                let char = polyline[polyline.index(polyline.startIndex, offsetBy: index)]
//                let charInt = Int(char.unicodeScalars.first!.value)
//                b = charInt - 63
//                result |= (b & 0x1f) << shift
//                shift += 5
//                index += 1
//            } while b >= 0x20
//
//            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
//            lat += Double(dlat)
//
//            shift = 0
//            result = 0
//
//            repeat {
//                let char = polyline[polyline.index(polyline.startIndex, offsetBy: index)]
//                let charInt = Int(char.unicodeScalars.first!.value)
//                b = charInt - 63
//                result |= (b & 0x1f) << shift
//                shift += 5
//                index += 1
//            } while b >= 0x20
//
//            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
//            lng += Double(dlng)
//
//            let coordinate = CLLocationCoordinate2D(latitude: lat * 1e-5, longitude: lng * 1e-5)
//            coordinates.append(coordinate)
//        }
//
//        return coordinates
//    }
//}

// MARK: - Updated ShuttleViewModel
//extension ShuttleViewModel {
//    private let routesService = GoogleRoutesService()
//
////    func fetchDirections() {
////        // Replace the simulation with actual Google Routes API
////        fetchRoutesFromAPI()
////    }
//
//    private func fetchRoutesFromAPI() {
//        routesService.fetchRoute(
//            from: driverLocation.coordinate,
//            to: pickupLocation.coordinate
//        ) { [weak self] coordinates, error in
//            guard let self = self else { return }
//
//            DispatchQueue.main.async {
//                if let error = error {
//                    print("Error fetching route: \(error.localizedDescription)")
//                    // Fallback to simulation if API fails
//                    self.simulateRouteResponse()
//                    return
//                }
//
//                if let coordinates = coordinates, !coordinates.isEmpty {
//                    self.routePoints = coordinates
//                    // Start the simulation with the real route
//                    self.startSimulation()
//                } else {
//                    print("No route points received")
//                    // Fallback to simulation if no points
//                    self.simulateRouteResponse()
//                }
//            }
//        }
//    }
//}

