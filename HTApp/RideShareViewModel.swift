//
//  RideShareViewModel.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import Foundation
import SwiftUI

// MARK: - View Models

// MARK: - Updated ViewModel

class RideShareViewModel: ObservableObject {
    @Published var currentStudent: Student?
    @Published var availableDrivers: [Driver] = []
    @Published var selectedRouteType: RouteType = .inbound
    @Published var myRideRequests: [RideRequest] = []
    @Published var incomingRideRequests: [RideRequest] = []
    @Published var selectedDriver: Driver?
    @Published var numberOfPassengers: Int = 1
    @Published var pointsTransactions: [PointsTransaction] = [] // Track points history
    
    // Points calculation constants
    private let basePointsPerRide: Int = 10
    private let passengerMultiplier: Int = 5 // Additional points per passenger
    private let perfectRatingBonus: Int = 15
    
    // Sample data for demonstration
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        // Set current student
        currentStudent = Student(
            id: "s12345",
            name: "Ayomide Isinkaye",
            major: "Computer Science",
            classification: "Sophomore",
            email: "aisinkaye@htu.edu",
            phoneNumber: "512-555-1234",
            isDriver: true,
            rating: 4.8,
            totalRides: 42,
            points: 580 // Initial points
        )
        
        // Sample drivers
        availableDrivers = [
            Driver(
                id: "d1001",
                student: Student(
                    id: "s23456",
                    name: "Nashel Kapeta",
                    major: "Business Administration",
                    classification: "Sophomore",
                    email: "nkapeta@htu.edu",
                    phoneNumber: "512-555-2345",
                    isDriver: true,
                    rating: 4.9,
                    totalRides: 120,
                    points: 1250
                ),
                vehicle: Vehicle(
                    id: "v1001",
                    make: "Honda",
                    model: "Civic",
                    year: 2020,
                    color: "Blue",
                    licensePlate: "ABC123",
                    seatsAvailable: 4
                ),
                isAvailable: true,
                currentLocation: RideLocation(latitude: 30.2290, longitude: -97.7440, name: "Near St. Edwards"),
                departureTime: Date().addingTimeInterval(600), // 10 minutes from now
                routeType: .inbound
            ),
            Driver(
                id: "d1002",
                student: Student(
                    id: "s34567",
                    name: "Grace Kolawole",
                    major: "Computer Science",
                    classification: "Senior",
                    email: "gkolawole@htu.edu",
                    phoneNumber: "512-555-3456",
                    isDriver: true,
                    rating: 4.7,
                    totalRides: 85,
                    points: 910
                ),
                vehicle: Vehicle(
                    id: "v1002",
                    make: "Toyota",
                    model: "Corolla",
                    year: 2021,
                    color: "Silver",
                    licensePlate: "XYZ789",
                    seatsAvailable: 3
                ),
                isAvailable: true,
                currentLocation: RideLocation(latitude: 30.2260, longitude: -97.7540, name: "Near Main Campus"),
                departureTime: Date().addingTimeInterval(900), // 15 minutes from now
                routeType: .outbound
            ),
            Driver(
                id: "d1003",
                student: Student(
                    id: "s45678",
                    name: "Penueli Kihundu",
                    major: "Kinesiology",
                    classification: "Junior",
                    email: "pkihundu@htu.edu",
                    phoneNumber: "512-555-4567",
                    isDriver: true,
                    rating: 4.95,
                    totalRides: 200,
                    points: 2150
                ),
                vehicle: Vehicle(
                    id: "v1003",
                    make: "Mazda",
                    model: "3",
                    year: 2022,
                    color: "Red",
                    licensePlate: "LMN456",
                    seatsAvailable: 3
                ),
                isAvailable: true,
                currentLocation: RideLocation(latitude: 30.2310, longitude: -97.7350, name: "St. Edwards Campus"),
                departureTime: Date().addingTimeInterval(300), // 5 minutes from now
                routeType: .inbound
            )
        ]
        
        // Sample points transactions
        pointsTransactions = [
            PointsTransaction(
                id: UUID().uuidString,
                driverId: "d1001",
                rideRequestId: "r1001",
                points: 25,
                timestamp: Date().addingTimeInterval(-86400), // Yesterday
                reason: .completedRide,
                description: "Ride from St. Edwards to Main Campus"
            ),
            PointsTransaction(
                id: UUID().uuidString,
                driverId: "d1001",
                rideRequestId: "r1002",
                points: 35,
                timestamp: Date().addingTimeInterval(-43200), // 12 hours ago
                reason: .perfectRating,
                description: "5-star rating on ride"
            ),
            PointsTransaction(
                id: UUID().uuidString,
                driverId: "d1001",
                rideRequestId: "r1003",
                points: 50,
                timestamp: Date().addingTimeInterval(-21600), // 6 hours ago
                reason: .consistentDriver,
                description: "Completed 10 rides this week"
            )
        ]
    }
    
    // Filter drivers by route type
    func filteredDrivers() -> [Driver] {
        return availableDrivers.filter { $0.routeType == selectedRouteType && $0.isAvailable }
    }
    
    // Request a ride
    func requestRide(driver: Driver) {
        guard let student = currentStudent else { return }
        
        let pickupLocation: RideLocation
        let dropoffLocation: RideLocation
        
        if driver.routeType == .inbound {
            pickupLocation = RideLocation.stEdwardsCampus
            dropoffLocation = RideLocation.mainCampus
        } else {
            pickupLocation = RideLocation.mainCampus
            dropoffLocation = RideLocation.stEdwardsCampus
        }
        
        let rideRequest = RideRequest(
            id: UUID().uuidString,
            passengerId: student.id,
            driverId: driver.id,
            pickupLocation: pickupLocation,
            dropoffLocation: dropoffLocation,
            requestTime: Date(),
            numberOfPassengers: numberOfPassengers,
            status: .requested
        )
        
        myRideRequests.append(rideRequest)
        
        // In a real app, you would send this request to a server
        // For demo purposes, simulate an incoming request to the driver
        if driver.id == "d1001" { // Simulate for one of our sample drivers
            incomingRideRequests.append(rideRequest)
        }
    }
    
    // Accept a ride request (for drivers)
    func acceptRideRequest(request: RideRequest) {
        if let index = incomingRideRequests.firstIndex(where: { $0.id == request.id }) {
            incomingRideRequests[index].status = .accepted
            
            // Update in the requester's list too
            if let myIndex = myRideRequests.firstIndex(where: { $0.id == request.id }) {
                myRideRequests[myIndex].status = .accepted
            }
            
            // Update driver availability
            if let driverIndex = availableDrivers.firstIndex(where: { $0.id == request.id }) {
                availableDrivers[driverIndex].isAvailable = false
            }
        }
    }
    
    // Complete a ride and award points
    func completeRide(request: RideRequest, rating: Double? = nil) {
        if let index = incomingRideRequests.firstIndex(where: { $0.id == request.id }) {
            var updatedRequest = incomingRideRequests[index]
            updatedRequest.status = .completed
            updatedRequest.completionTime = Date()
            
            if let rating = rating {
                updatedRequest.rating = rating
            }
            
            incomingRideRequests[index] = updatedRequest
            
            // Update in the requester's list too
            if let myIndex = myRideRequests.firstIndex(where: { $0.id == request.id }) {
                myRideRequests[myIndex] = updatedRequest
            }
            
            // Award points if not already awarded
            if !updatedRequest.pointsAwarded {
                awardPointsForCompletedRide(request: updatedRequest)
            }
        }
    }
    
 
  private func awardPointsForCompletedRide(request: RideRequest) {
      guard let driverIndex = availableDrivers.firstIndex(where: { $0.id == request.driverId }) else {
          return
      }
      
      // Calculate base points
      var totalPoints = basePointsPerRide
      
      // Add points for additional passengers
      let passengerPoints = (request.numberOfPassengers - 1) * passengerMultiplier
      totalPoints += passengerPoints
      
      // Add bonus for perfect rating if applicable
      if let rating = request.rating, rating == 5.0 {
          totalPoints += perfectRatingBonus
      }
      
      // Update driver's points - proper mutation of student property
      var updatedDriver = availableDrivers[driverIndex]
      var updatedStudent = updatedDriver.student
      updatedStudent.points += totalPoints
      updatedStudent.totalRides += 1
      updatedDriver.student = updatedStudent
      updatedDriver.isAvailable = true // Make driver available again
      availableDrivers[driverIndex] = updatedDriver
      
      // Update current student if they're the driver
      if let currentStudent = self.currentStudent, currentStudent.id == updatedDriver.student.id {
          var updatedCurrentStudent = currentStudent
          updatedCurrentStudent.points += totalPoints
          updatedCurrentStudent.totalRides += 1
          self.currentStudent = updatedCurrentStudent
      }
      
      // Record the transaction
      let transaction = PointsTransaction(
          id: UUID().uuidString,
          driverId: request.driverId,
          rideRequestId: request.id,
          points: totalPoints,
          timestamp: Date(),
          reason: .completedRide,
          description: "Ride from \(request.pickupLocation.name ?? "Unknown") to \(request.dropoffLocation.name ?? "Unknown")"
      )
      
      pointsTransactions.append(transaction)
      
      // Mark the ride as having points awarded
      if let index = incomingRideRequests.firstIndex(where: { $0.id == request.id }) {
          incomingRideRequests[index].pointsAwarded = true
      }
      
      if let index = myRideRequests.firstIndex(where: { $0.id == request.id }) {
          myRideRequests[index].pointsAwarded = true
      }
  }

  // Award bonus points method - fixed to properly handle mutations
  func awardBonusPoints(driverId: String, points: Int, reason: PointsReason, description: String) {
      guard let driverIndex = availableDrivers.firstIndex(where: { $0.id == driverId }) else {
          return
      }
      
      // Update driver's points
      var updatedDriver = availableDrivers[driverIndex]
      var updatedStudent = updatedDriver.student
      updatedStudent.points += points
      updatedDriver.student = updatedStudent
      availableDrivers[driverIndex] = updatedDriver
      
      // Update current student if they're the driver
      if let currentStudent = self.currentStudent, currentStudent.id == updatedDriver.student.id {
          var updatedCurrentStudent = currentStudent
          updatedCurrentStudent.points += points
          self.currentStudent = updatedCurrentStudent
      }
      
      // Record the transaction
      let transaction = PointsTransaction(
          id: UUID().uuidString,
          driverId: driverId,
          rideRequestId: "bonus-\(UUID().uuidString)",
          points: points,
          timestamp: Date(),
          reason: reason,
          description: description
      )
      
      pointsTransactions.append(transaction)
  }
    // Cancel a ride request
    func cancelRideRequest(request: RideRequest) {
        if let index = myRideRequests.firstIndex(where: { $0.id == request.id }) {
            myRideRequests[index].status = .cancelled
            
            // Update in the driver's list too
            if let driverIndex = incomingRideRequests.firstIndex(where: { $0.id == request.id }) {
                incomingRideRequests[driverIndex].status = .cancelled
            }
        }
    }
    
//    // Award bonus points (e.g., for referrals, special events)
//    func awardBonusPoints(driverId: String, points: Int, reason: PointsReason, description: String) {
//        guard let driverIndex = availableDrivers.firstIndex(where: { $0.id == driverId }) else {
//            return
//        }
//        
//        // Update driver's points
//        var updatedDriver = availableDrivers[driverIndex]
//        updatedDriver.student.points += points
//        availableDrivers[driverIndex] = updatedDriver
//        
//        // Update current student if they're the driver
//        if currentStudent?.id == updatedDriver.student.id {
//            currentStudent?.points += points
//        }
//        
//        // Record the transaction
//        let transaction = PointsTransaction(
//            id: UUID().uuidString,
//            driverId: driverId,
//            rideRequestId: "bonus-\(UUID().uuidString)",
//            points: points,
//            timestamp: Date(),
//            reason: reason,
//            description: description
//        )
//        
//        pointsTransactions.append(transaction)
//    }
//    
    // Get points transactions for a specific driver
    func getPointsTransactionsForDriver(driverId: String) -> [PointsTransaction] {
        return pointsTransactions.filter { $0.driverId == driverId }
            .sorted(by: { $0.timestamp > $1.timestamp }) // Sort by most recent first
    }
}

// MARK: - Views

struct RideShareMainView: View {
    @StateObject private var viewModel = RideShareViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 10) {
                    Text("Ride Share")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Connect with campus riders")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                // Quick Action Buttons
                HStack(spacing: 15) {
                    // Find a Ride Button
                    NavigationLink(destination: RideFinderView()
                        .environmentObject(viewModel)) {
                        VStack {
                            Image(systemName: "car.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            
                            Text("Find a Ride")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.goldDark)
                        .cornerRadius(12)
                    }
                    
                    // My Rides Button
                    NavigationLink(destination: MyRidesView()
                        .environmentObject(viewModel)) {
                        VStack {
                            Image(systemName: "list.bullet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                            
                            Text("My Rides")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.maroonDark)
                        .cornerRadius(12)
                    }
                  
                  // My Rides Button
                  // My Rides Button
                  NavigationLink(destination:
                    DriverDashboardView()
                      .environmentObject(viewModel)) {
                      VStack {
                          Image(systemName: "person.fill")
                              .resizable()
                              .aspectRatio(contentMode: .fit)
                              .frame(width: 40, height: 40)
                              .foregroundColor(.white)
                          
                          Text("Driver Dash")
                              .font(.caption)
                              .foregroundColor(.white)
                      }
                      .frame(maxWidth: .infinity)
                      .padding()
                      .background(Color.goldDark)
                      .cornerRadius(12)
                  }
                }
                .padding()
                
              // Recent Activity Section
              VStack(alignment: .leading, spacing: 10) {
                  Text("Recent Activity")
                      .font(.headline)
                      .padding(.horizontal)
                  
                  if viewModel.myRideRequests.isEmpty {
                      Text("No recent rides")
                          .foregroundColor(.secondary)
                          .frame(maxWidth: .infinity, alignment: .center)
                          .padding()
                  } else {
                      ScrollView(.vertical, showsIndicators: false) {
                          VStack(spacing: 15) {
                              ForEach(viewModel.myRideRequests.prefix(3)) { request in
                                  RideActivityCard(request: request)
                              }
                          }
                          .padding(.horizontal)
                      }
                  }
              }
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
}

// Ride Activity Card
struct RideActivityCard: View {
    let request: RideRequest
    
    var body: some View {
        HStack {
            // Status Icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.title2)
            }
            
            // Ride Details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(request.pickupLocation.name ?? "Unknown") → \(request.dropoffLocation.name ?? "Unknown")")
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text(request.status.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(statusColor)
                    
                    Spacer()
                    
                    Text(formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
//            // Chevron
//            Image(systemName: "chevron.right")
//                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .frame(height: 90) // Fixed height
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: request.requestTime)
    }
    
    private var statusColor: Color {
        switch request.status {
        case .requested:
            return .orange
        case .accepted:
            return .blue
        case .inProgress:
            return .green
        case .completed:
            return .gray
        case .cancelled:
            return .red
        }
    }
    
    private var statusIcon: String {
        switch request.status {
        case .requested:
            return "clock.fill"
        case .accepted:
            return "checkmark.circle.fill"
        case .inProgress:
            return "car.fill"
        case .completed:
            return "flag.checkered.fill"
        case .cancelled:
            return "xmark.circle.fill"
        }
    }
}

// Ride Finder View
struct RideFinderView: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    @State private var showingDriverDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Route Type Picker
                Picker("Route", selection: $viewModel.selectedRouteType) {
                    ForEach(RouteType.allCases, id: \.self) { routeType in
                        Text(routeType.rawValue).tag(routeType)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Available Drivers List
                List(viewModel.filteredDrivers()) { driver in
                    DriverRowView(driver: driver)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedDriver = driver
                            showingDriverDetail = true
                        }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationTitle("Find a Ride")
            .sheet(isPresented: $showingDriverDetail) {
                if let driver = viewModel.selectedDriver {
                    DriverDetailView(driver: driver)
                        .environmentObject(viewModel)
                }
            }
        }
    }
}

#Preview {
    RideShareMainView()
        .environmentObject(RideShareViewModel())
}




