//
//  GoogleMapView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//


import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    @ObservedObject var viewModel: ShuttleViewModel
    
    func makeUIView(context: Context) -> GMSMapView {
        let mapView = GMSMapView.map(withFrame: .zero, camera: viewModel.camera)
        mapView.delegate = context.coordinator
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.mapType = .normal
        
        return mapView
    }
    
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Update camera to follow driver
        mapView.animate(to: viewModel.camera)
        
        // Clear map
        mapView.clear()
        
        // Create polylines for the route with different colors based on progress
        if viewModel.routePoints.count > 1 {
            // First, add the yet-to-be-completed part of the route in maroon
            if viewModel.routeProgress < viewModel.routePoints.count - 1 {
                let futurePath = GMSMutablePath()
                for i in viewModel.routeProgress..<viewModel.routePoints.count {
                    futurePath.add(viewModel.routePoints[i])
                }
                
                let futurePolyline = GMSPolyline(path: futurePath)
                futurePolyline.strokeWidth = 5
                futurePolyline.strokeColor = UIColor(red: 128/255, green: 0/255, blue: 0/255, alpha: 1.0) // Maroon
                futurePolyline.geodesic = true
                futurePolyline.map = mapView
            }
            
            // Then, add the completed part of the route in lighter blue
            if viewModel.routeProgress > 0 {
                let completedPath = GMSMutablePath()
                for i in 0...viewModel.routeProgress {
                    completedPath.add(viewModel.routePoints[i])
                }
                
                let completedPolyline = GMSPolyline(path: completedPath)
                completedPolyline.strokeWidth = 5
                completedPolyline.strokeColor = UIColor(red: 66/255, green: 133/255, blue: 244/255, alpha: 0.4) // Lighter blue
                completedPolyline.geodesic = true
                completedPolyline.map = mapView
            }
        }
        
        // The rest of your code for markers remains the same
        // Add pickup marker
        let pickupMarker = GMSMarker()
        pickupMarker.position = viewModel.pickupLocation.coordinate
        pickupMarker.title = "Pickup Point"
        pickupMarker.snippet = "Your pickup location"
        pickupMarker.icon = GMSMarker.markerImage(with: .red)
        pickupMarker.map = mapView
        
        // Calculate rotation angle based on movement direction
        var rotation: CLLocationDirection = 0
        if viewModel.routeProgress > 0 && viewModel.routeProgress < viewModel.routePoints.count - 1 {
            let currentCoord = viewModel.routePoints[viewModel.routeProgress]
            let nextCoord = viewModel.routePoints[viewModel.routeProgress + 1]
            
            // Calculate bearing between points
            rotation = bearingBetweenLocations(
                from: CLLocation(latitude: currentCoord.latitude, longitude: currentCoord.longitude),
                to: CLLocation(latitude: nextCoord.latitude, longitude: nextCoord.longitude)
            )
        }
        
        // Add driver marker with car icon
        let driverMarker = GMSMarker()
        driverMarker.position = viewModel.driverLocation.coordinate
        driverMarker.title = "Driver"
        
        // Create custom car icon with rotation
        if let carImage = createCarIcon(rotation: rotation) {
            driverMarker.icon = carImage
            driverMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5) // Center the car icon
        } else {
            // Fallback to colored marker if car icon creation fails
            driverMarker.icon = GMSMarker.markerImage(with: .blue)
        }
        
        driverMarker.map = mapView
        
        // Fit bounds to show both markers when route is first loaded
        if context.coordinator.isFirstUpdate {
            let bounds = GMSCoordinateBounds(coordinate: viewModel.driverLocation.coordinate,
                                           coordinate: viewModel.pickupLocation.coordinate)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100)
            mapView.animate(with: update)
            context.coordinator.isFirstUpdate = false
        }
    }
    
    // Helper function to create a car icon with proper rotation
    private func createCarIcon(rotation: CLLocationDirection) -> UIImage? {
        // You can use a built-in image or create one programmatically
        let carImage = UIImage(systemName: "car.fill") ?? UIImage(systemName: "location.north.fill")
        
        if let carImage = carImage {
            UIGraphicsBeginImageContextWithOptions(carImage.size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()!
            
            // Move to center and rotate
            context.translateBy(x: carImage.size.width / 2, y: carImage.size.height / 2)
            context.rotate(by: CGFloat(rotation * .pi / 180.0))
            context.translateBy(x: -carImage.size.width / 2, y: -carImage.size.height / 2)
            
            // Draw the image
            carImage.draw(in: CGRect(origin: .zero, size: carImage.size))
            
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage
        }
        
        return nil
    }
    
    // Calculate bearing between two locations (in degrees)
    private func bearingBetweenLocations(from: CLLocation, to: CLLocation) -> CLLocationDirection {
        let lat1 = from.coordinate.latitude * .pi / 180
        let lon1 = from.coordinate.longitude * .pi / 180
        let lat2 = to.coordinate.latitude * .pi / 180
        let lon2 = to.coordinate.longitude * .pi / 180
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        
        var bearing = atan2(y, x) * 180 / .pi
        if bearing < 0 {
            bearing += 360
        }
        
        return bearing
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        var isFirstUpdate: Bool = true
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            // Show info window when marker is tapped
            return false
        }
    }
}
