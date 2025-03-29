//
//  GoogleRoutesService.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import Foundation
import CoreLocation
import GoogleMaps

class GoogleRoutesService {
    // Singleton instance
     static let shared = GoogleRoutesService()
    
     let apiKey = ProcessInfo.processInfo.environment["MAP_API_KEY"]!
    
     func fetchRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping ([CLLocationCoordinate2D]?, Error?) -> Void) {
      
        // Use Directions API instead of Routes V2 API for more consistent results
      let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=\(apiKey)"
     
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: 0, userInfo: nil))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            // Print the raw data for debugging
            if let jsonString = String(data: data, encoding: .utf8) {
                print("API Response: \(jsonString)")
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    // Check for API error
                    if let status = json["status"] as? String, status != "OK" {
                        let errorMessage = json["error_message"] as? String ?? "Unknown error"
                        print("API Error: \(status) - \(errorMessage)")
                        completion(nil, NSError(domain: errorMessage, code: 0, userInfo: nil))
                        return
                    }
                    
                    guard let routes = json["routes"] as? [[String: Any]],
                          let route = routes.first,
                          let legs = route["legs"] as? [[String: Any]],
                          let leg = legs.first,
                          let steps = leg["steps"] as? [[String: Any]] else {
                        print("Failed to parse route structure")
                        completion(nil, NSError(domain: "Failed to parse route structure", code: 0, userInfo: nil))
                        return
                    }
                    
                    var coordinates: [CLLocationCoordinate2D] = []
                    
                    // Extract start location
                    if let startLocation = leg["start_location"] as? [String: Any],
                       let startLat = startLocation["lat"] as? Double,
                       let startLng = startLocation["lng"] as? Double {
                        coordinates.append(CLLocationCoordinate2D(latitude: startLat, longitude: startLng))
                    }
                    
                    // Extract coordinates from steps
                    for step in steps {
                        if let polyline = step["polyline"] as? [String: Any],
                           let points = polyline["points"] as? String {
                            let decodedPoints = self.decodePolyline(points)
                            coordinates.append(contentsOf: decodedPoints)
                        }
                    }
                    
                    // Extract end location
                    if let endLocation = leg["end_location"] as? [String: Any],
                       let endLat = endLocation["lat"] as? Double,
                       let endLng = endLocation["lng"] as? Double {
                        coordinates.append(CLLocationCoordinate2D(latitude: endLat, longitude: endLng))
                    }
                    
                    if coordinates.isEmpty {
                        print("No coordinates found in the route")
                        completion(nil, NSError(domain: "No coordinates found in the route", code: 0, userInfo: nil))
                    } else {
                        print("Successfully parsed \(coordinates.count) coordinates")
                        completion(coordinates, nil)
                    }
                } else {
                    print("Failed to parse JSON response")
                    completion(nil, NSError(domain: "Failed to parse JSON response", code: 0, userInfo: nil))
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
        
        task.resume()
    }
    
    // Google Polyline decoder function
    func decodePolyline(_ polyline: String) -> [CLLocationCoordinate2D] {
        var coordinates: [CLLocationCoordinate2D] = []
        var index = 0
        let length = polyline.count
        var lat = 0.0
        var lng = 0.0
        
        while index < length {
            var b: Int
            var shift = 0
            var result = 0
            
            repeat {
                let char = polyline[polyline.index(polyline.startIndex, offsetBy: index)]
                let charInt = Int(char.unicodeScalars.first!.value)
                b = charInt - 63
                result |= (b & 0x1f) << shift
                shift += 5
                index += 1
            } while b >= 0x20
            
            let dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lat += Double(dlat)
            
            shift = 0
            result = 0
            
            repeat {
                let char = polyline[polyline.index(polyline.startIndex, offsetBy: index)]
                let charInt = Int(char.unicodeScalars.first!.value)
                b = charInt - 63
                result |= (b & 0x1f) << shift
                shift += 5
                index += 1
            } while b >= 0x20
            
            let dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1))
            lng += Double(dlng)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat * 1e-5, longitude: lng * 1e-5)
            coordinates.append(coordinate)
        }
        
        return coordinates
    }
}
