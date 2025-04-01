//
//  RideModels.swift
//  Sample
//
//  Created by CAIT on 3/23/25.
//
import Foundation
import SwiftUI

// MARK: - Models

// Student Profile Model
struct Student: Identifiable, Encodable {
    let id: String
    let name: String
    let major: String
    let classification: String // Freshman, Sophomore, etc.
    let email: String
    let phoneNumber: String
    var isDriver: Bool = false
    var rating: Double = 0.0
    var totalRides: Int = 0
    var points: Int = 0
}

// Driver's vehicle information
struct Vehicle: Identifiable, Codable {
    let id: String
    let make: String
    let model: String
    let year: Int
    let color: String
    let licensePlate: String
    let seatsAvailable: Int
}

// Updated Location model to avoid conflicts
struct RideLocation: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var name: String?
    
    static let mainCampus = RideLocation(
        latitude: 30.2265,
        longitude: -97.7553,
        name: "Main Campus"
    )
    
    static let stEdwardsCampus = RideLocation(
        latitude: 30.2304,
        longitude: -97.7332,
        name: "St. Edwards Campus"
    )
}

//// Driver model that extends Student
//struct Driver: Identifiable, Codable {
//    let id: String
//    let student: Student
//    let vehicle: Vehicle
//    var isAvailable: Bool = true
//    var currentLocation: RideLocation
//    var destination: RideLocation? // For outbound/inbound indication
//    var departureTime: Date
//    var routeType: RouteType
//}
struct Driver: Identifiable {
    let id: String
    var student: Student // Changed from 'let' to 'var' to allow mutation
    let vehicle: Vehicle
    var isAvailable: Bool
    var currentLocation: RideLocation
    var departureTime: Date
    var routeType: RouteType
}

// Route type enum
enum RouteType: String, Codable, CaseIterable {
    case inbound = "Inbound (St. Edwards → Main)"
    case outbound = "Outbound (Main → St. Edwards)"
}

// Ride request model
// Update RideRequest to track if points were awarded
struct RideRequest: Identifiable, Codable {
    let id: String
    let passengerId: String
    let driverId: String
    let pickupLocation: RideLocation
    let dropoffLocation: RideLocation
    let requestTime: Date
    let numberOfPassengers: Int
    var status: RideStatus
    var rating: Double?
    var feedback: String?
    var pointsAwarded: Bool = false // Track if points were awarded
    var completionTime: Date?
}

// Ride status enum
enum RideStatus: String, Codable {
    case requested
    case accepted
    case inProgress
    case completed
    case cancelled
}




//// Profile View
//struct ProfileView: View {
//    @EnvironmentObject var viewModel: RideShareViewModel
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                if let student = viewModel.currentStudent {
//                    Section(header: Text("Personal Information")) {
//                        HStack {
//                            Text("Name")
//                            Spacer()
//                            Text(student.name)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        HStack {
//                            Text("Major")
//                            Spacer()
//                            Text(student.major)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        HStack {
//                            Text("Classification")
//                            Spacer()
//                            Text(student.classification)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        HStack {
//                            Text("Email")
//                            Spacer()
//                            Text(student.email)
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        HStack {
//                            Text("Phone")
//                            Spacer()
//                            Text(student.phoneNumber)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                    
//                    Section(header: Text("Statistics")) {
//                        HStack {
//                            Text("Total Rides")
//                            Spacer()
//                            Text("\(student.totalRides)")
//                                .foregroundColor(.secondary)
//                        }
//                        
//                        HStack {
//                            Text("Rating")
//                            Spacer()
//                            HStack {
//                                Text(String(format: "%.1f", student.rating))
//                                Image(systemName: "star.fill")
//                                    .foregroundColor(.yellow)
//                            }
//                        }
//                    }
//                    
//                    if student.isDriver {
//                        Section(header: Text("Driver Settings")) {
//                            Toggle("Available for rides", isOn: .constant(true))
//                                .tint(.green)
//                            
//                            NavigationLink("My Vehicle") {
//                                Text("Vehicle details would go here")
//                            }
//                            
//                            NavigationLink("Schedule") {
//                                Text("Schedule management would go here")
//                            }
//                        }
//                    } else {
//                        Section {
//                            Button("Become a Driver") {
//                                // This would show driver registration in a real app
//                            }
//                            .foregroundColor(.blue)
//                        }
//                    }
//                    
//                    Section {
//                        Button("Log Out") {
//                            // This would log out in a real app
//                        }
//                        .foregroundColor(.red)
//                    }
//                }
//            }
//            .navigationTitle("Profile")
//        }
//    }
//}
//
//
//#Preview {
//    ProfileView()
//        .environmentObject(RideShareViewModel())
//}
//
//
