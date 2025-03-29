//
//  ShuttleViewModel.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import SwiftUI
import GoogleMaps
import Combine

// MARK: - Models
struct Location: Equatable {
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

enum VehicleStatus: String {
    case arriving = "Arriving"
    case onTheWay = "On the way"
    case approaching = "Approaching"
    case arrived = "Arrived"
}

class ShuttleViewModel: ObservableObject {
    @Published var driverLocation: Location
    @Published var pickupLocation: Location
    @Published var vehicleStatus: VehicleStatus = .onTheWay
    @Published var estimatedTimeOfArrival: String = "5 min"
    @Published var routePoints: [CLLocationCoordinate2D] = []
    @Published var camera: GMSCameraPosition
    
    private var timer: AnyCancellable?
//    private var routeProgress: Int = 0
  
     // New properties for smoother movement
    private var currentInterpolationStep: Double = 0
    private let interpolationSteps: Double = 10.0 // Number of intermediate steps between route points
    private var currentRouteSegment: (start: CLLocationCoordinate2D, end: CLLocationCoordinate2D)?
    
    init() {
        // Initialize locations first
        let initialDriverLocation = Location(latitude: 30.2290, longitude: -97.7526)
        let initialPickupLocation = Location(latitude: 30.2646, longitude: -97.7223)
        
        // Set initial camera to show both points
        let centerLat = (initialDriverLocation.latitude + initialPickupLocation.latitude) / 2
        let centerLng = (initialDriverLocation.longitude + initialPickupLocation.longitude) / 2
        
        // Initialize properties in the correct order
        self.driverLocation = initialDriverLocation
        self.pickupLocation = initialPickupLocation
        self.camera = GMSCameraPosition.camera(
            withLatitude: centerLat,
            longitude: centerLng,
            zoom: 15.0
        )
        
        // Get directions from Google
        self.fetchDirections()
    }
    
    func fetchDirections() {
        // Replace the simulation with actual Google Directions API
        fetchRoutesFromAPI()
    }
    
    private func fetchRoutesFromAPI() {
        print("Fetching route from \(driverLocation.coordinate) to \(pickupLocation.coordinate)")
        
        GoogleRoutesService.shared.fetchRoute(
            from: driverLocation.coordinate,
            to: pickupLocation.coordinate
        ) { [weak self] coordinates, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching route: \(error.localizedDescription)")
                    // Fallback to simulation if API fails
                    self.simulateRouteResponse()
                    return
                }
                
                if let coordinates = coordinates, !coordinates.isEmpty {
                    print("Received \(coordinates.count) route points")
                    self.routePoints = coordinates
                    // Start the simulation with the real route
                    self.startSimulation()
                } else {
                    print("No route points received")
                    // Fallback to simulation if no points
                    self.simulateRouteResponse()
                }
            }
        }
    }
    
    func simulateRouteResponse() {
        print("Falling back to simulated route")
        // Create a simple simulated route
        let numberOfPoints = 20
        var points: [CLLocationCoordinate2D] = []
        
        for i in 0...numberOfPoints {
            let fraction = Double(i) / Double(numberOfPoints)
            let latitude = driverLocation.latitude + (pickupLocation.latitude - driverLocation.latitude) * fraction
            let longitude = driverLocation.longitude + (pickupLocation.longitude - driverLocation.longitude) * fraction
            points.append(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        }
        
        // Update the route
        self.routePoints = points
        
        // Start the simulation
        self.startSimulation()
    }
    
    
    // Add a property to expose the routeProgress for polyline updating
        var routeProgress: Int {
            get { _routeProgress }
        }
        
        // Rename the private variable to avoid naming conflicts
        private var _routeProgress: Int = 0
        
//        // Update the updateDriverPosition method to use _routeProgress
//        private func updateDriverPosition() {
//            guard _routeProgress < routePoints.count - 1 else {
//                timer?.cancel()
//                vehicleStatus = .arrived
//                estimatedTimeOfArrival = "Arrived"
//                return
//            }
//            
//            _routeProgress += 1
//            let newCoordinate = routePoints[_routeProgress]
//            driverLocation = Location(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
//            
//            // Update camera to follow driver
//            camera = GMSCameraPosition.camera(
//                withLatitude: driverLocation.latitude,
//                longitude: driverLocation.longitude,
//                zoom: 16.0
//            )
//            
//            // Update ETA
//            let remainingPoints = routePoints.count - _routeProgress - 1
//            if remainingPoints > 0 {
//                estimatedTimeOfArrival = "\(remainingPoints) min"
//                
//                // Update status based on progress
//                if Double(_routeProgress) / Double(routePoints.count) > 0.7 {
//                    vehicleStatus = .approaching
//                } else if Double(_routeProgress) / Double(routePoints.count) > 0.3 {
//                    vehicleStatus = .onTheWay
//                }
//            } else {
//                estimatedTimeOfArrival = "Less than a minute"
//                vehicleStatus = .arriving
//            }
//        }
//
  
        private func interpolateLocation(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, progress: Double) -> CLLocationCoordinate2D {
            let lat = start.latitude + (end.latitude - start.latitude) * progress
            let lng = start.longitude + (end.longitude - start.longitude) * progress
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        
        private func updateDriverPosition() {
            guard _routeProgress < routePoints.count - 1 else {
                timer?.cancel()
                vehicleStatus = .arrived
                estimatedTimeOfArrival = "Arrived"
                return
            }
            
            // Smooth interpolation between route points
            if currentRouteSegment == nil {
                currentRouteSegment = (routePoints[_routeProgress], routePoints[_routeProgress + 1])
                currentInterpolationStep = 0
            }
            
            // Increment interpolation step
            currentInterpolationStep += 1
            let interpolationProgress = currentInterpolationStep / interpolationSteps
            
            // Interpolate location
            if let segment = currentRouteSegment {
                let newCoordinate = interpolateLocation(start: segment.start, end: segment.end, progress: interpolationProgress)
                driverLocation = Location(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
                
                // Update camera to follow driver
                camera = GMSCameraPosition.camera(
                    withLatitude: driverLocation.latitude,
                    longitude: driverLocation.longitude,
                    zoom: 16.0
                )
            }
            
            // Move to next route segment when interpolation is complete
            if currentInterpolationStep >= interpolationSteps {
                _routeProgress += 1
                currentRouteSegment = nil
                currentInterpolationStep = 0
            }
            
            // Estimate ETA more realistically
            let totalRoutePoints = routePoints.count
            let pointsCovered = _routeProgress + 1
            let percentageComplete = Double(pointsCovered) / Double(totalRoutePoints)
            
            // More nuanced ETA calculation
            if percentageComplete < 0.2 {
                vehicleStatus = .onTheWay
                estimatedTimeOfArrival = "15 min"
            } else if percentageComplete < 0.5 {
                vehicleStatus = .onTheWay
                estimatedTimeOfArrival = "10 min"
            } else if percentageComplete < 0.7 {
                vehicleStatus = .approaching
                estimatedTimeOfArrival = "5 min"
            } else if percentageComplete < 0.9 {
                vehicleStatus = .arriving
                estimatedTimeOfArrival = "2 min"
            } else {
                vehicleStatus = .arriving
                estimatedTimeOfArrival = "Almost there"
            }
        }
  
        
        // Update startSimulation to reset _routeProgress
        func startSimulation() {
            // Cancel existing timer if there is one
            timer?.cancel()
            
            // Reset progress
            _routeProgress = 0
            
            print("Starting simulation with \(routePoints.count) points")
            
            // Update the driver's position along the route every second
            timer = Timer.publish(every: 0.1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.updateDriverPosition()
                }
        }
}
