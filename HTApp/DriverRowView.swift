//
//  DriverRowView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import Foundation
import SwiftUI

// Driver Row View
struct DriverRowView: View {
    let driver: Driver
    
    var body: some View {
        HStack {
            // Driver avatar
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(String(driver.student.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            // Driver information
            VStack(alignment: .leading, spacing: 4) {
                Text(driver.student.name)
                    .font(.headline)
                
                Text("\(driver.student.major) • \(driver.student.classification)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Vehicle information
                Text("\(driver.vehicle.color) \(driver.vehicle.make) \(driver.vehicle.model)")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Rating and departure info
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Text(String(format: "%.1f", driver.student.rating))
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                .font(.subheadline)
                
                Text("Departs in \(Int(driver.departureTime.timeIntervalSinceNow / 60)) min")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("\(driver.vehicle.seatsAvailable) seats")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// Driver Detail View
struct DriverDetailView: View {
    let driver: Driver
    @EnvironmentObject var viewModel: RideShareViewModel
    @State private var numberOfPassengers = 1
    @State private var hasRequested = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Driver Information")) {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(driver.student.name)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Major")
                        Spacer()
                        Text(driver.student.major)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Classification")
                        Spacer()
                        Text(driver.student.classification)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Rating")
                        Spacer()
                        HStack {
                            Text(String(format: "%.1f", driver.student.rating))
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                }
                
                Section(header: Text("Vehicle Information")) {
                    HStack {
                        Text("Vehicle")
                        Spacer()
                        Text("\(driver.vehicle.year) \(driver.vehicle.make) \(driver.vehicle.model)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Color")
                        Spacer()
                        Text(driver.vehicle.color)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("License Plate")
                        Spacer()
                        Text(driver.vehicle.licensePlate)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Available Seats")
                        Spacer()
                        Text("\(driver.vehicle.seatsAvailable)")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Trip Details")) {
                    HStack {
                        Text("Route")
                        Spacer()
                        Text(driver.routeType.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Departure")
                        Spacer()
                        Text("In \(Int(driver.departureTime.timeIntervalSinceNow / 60)) minutes")
                            .foregroundColor(.green)
                    }
                    
                    Stepper("Passengers: \(numberOfPassengers)", value: $numberOfPassengers, in: 1...driver.vehicle.seatsAvailable)
                }
                
                Section {
                    Button(action: {
                        viewModel.numberOfPassengers = numberOfPassengers
                        viewModel.requestRide(driver: driver)
                        hasRequested = true
                        
                        // Close the sheet after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Request Ride")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(hasRequested)
                }
            }
            .navigationTitle("Driver Details")
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
            .overlay(
                Group {
                    if hasRequested {
                        VStack {
                            Text("Ride Requested!")
                                .font(.headline)
                                .padding()
                                .background(Color.green.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.spring())
                    }
                }
            )
        }
    }
}

// My Rides View
struct MyRidesView: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        NavigationView {
            List {
                if viewModel.myRideRequests.isEmpty {
                    Text("You don't have any rides yet")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(viewModel.myRideRequests) { request in
                        RideRequestRow(request: request)
                            .swipeActions {
                                if request.status == .requested || request.status == .accepted {
                                    Button(role: .destructive) {
                                        viewModel.cancelRideRequest(request: request)
                                    } label: {
                                        Label("Cancel", systemImage: "xmark.circle")
                                    }
                                }
                            }
                    }
                }
            }
            .navigationTitle("My Rides")
        }
    }
}

// Ride Request Row
struct RideRequestRow: View {
    let request: RideRequest
    
    var body: some View {
        HStack {
            // Status icon
            ZStack {
                Circle()
                    .fill(statusColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: statusIcon)
                    .foregroundColor(.white)
            }
            
            // Ride details
            VStack(alignment: .leading, spacing: 4) {
                Text("\(routeDescription) Ride")
                    .font(.headline)
                
                Text("Requested at \(formattedDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Status:")
                    Text(request.status.rawValue.capitalized)
                        .foregroundColor(statusColor)
                }
                .font(.footnote)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private var routeDescription: String {
        if request.pickupLocation.name == "St. Edwards Campus" &&
           request.dropoffLocation.name == "Main Campus" {
            return "Inbound"
        } else {
            return "Outbound"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
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

// Driver Dashboard View
struct DriverDashboardView: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                // Driver toggle
                Toggle(isOn: .constant(true)) {
                    Text("Available for rides")
                }
                .padding()
                .tint(.green)
                
                // Ride requests list
                List {
                    Section(header: Text("Incoming Requests")) {
                        if viewModel.incomingRideRequests.isEmpty {
                            Text("No incoming ride requests")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.incomingRideRequests) { request in
                                IncomingRequestRow(request: request)
                                    .environmentObject(viewModel)
                            }
                        }
                    }
                    
                    Section(header: Text("Upcoming Rides")) {
                        if !viewModel.incomingRideRequests.contains(where: { $0.status == .accepted }) {
                            Text("No upcoming rides")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.incomingRideRequests.filter { $0.status == .accepted }) { request in
                                AcceptedRideRow(request: request)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Driver Dashboard")
        }
    }
}

// Incoming Request Row
struct IncomingRequestRow: View {
    let request: RideRequest
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        if request.status == .requested {
            VStack(alignment: .leading) {
                Text("Ride Request")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Passenger: Ayomide Isinkaye")
                            .font(.subheadline)
                        
                        Text("Passengers: \(request.numberOfPassengers)")
                            .font(.subheadline)
                        
                        Text("Pickup: \(request.pickupLocation.name ?? "Unknown")")
                            .font(.caption)
                        
                        Text("Dropoff: \(request.dropoffLocation.name ?? "Unknown")")
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    // Accept/Decline buttons
                    VStack(spacing: 8) {
                        Button(action: {
                            viewModel.acceptRideRequest(request: request)
                        }) {
                            Text("Accept")
                                .frame(width: 80)
                                .padding(.vertical, 5)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.subheadline)
                        }
                        
                        Button(action: {
                            viewModel.cancelRideRequest(request: request)
                        }) {
                            Text("Decline")
                                .frame(width: 80)
                                .padding(.vertical, 5)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .font(.subheadline)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}

// Accepted Ride Row
struct AcceptedRideRow: View {
    let request: RideRequest
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .padding(10)
                .background(Circle().fill(Color.blue.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ayomide Isinkaye")
                    .font(.headline)
                
                Text("\(request.numberOfPassengers) passenger(s)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("\(request.pickupLocation.name ?? "Pickup") → \(request.dropoffLocation.name ?? "Dropoff")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: {
                // In a real app, this would open navigation or messaging
            }) {
                Image(systemName: "message.fill")
                    .padding(10)
                    .background(Circle().fill(Color.green.opacity(0.2)))
                    .foregroundColor(.green)
            }
        }
        .padding(.vertical, 8)
    }
}
