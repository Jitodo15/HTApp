//
//  TransportationView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import SwiftUI

struct TransportationView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Conditional views based on user role
                if let user = appState.currentUser {
                    switch user.role {
                    case "driver":
                        DriverTransportationView()
                    case "student":
                        StudentTransportationView()
                    default:
                        DefaultTransportationView()
                    }
                } else {
                    DefaultTransportationView()
                }
            }
            .navigationTitle("Transportation")
            .padding()
        }
    }
}

struct DriverTransportationView: View {
    @StateObject private var rideShareViewModel = RideShareViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Ride Share Option for Drivers
            NavigationLink(destination: DriverDashboardView().environmentObject(rideShareViewModel)) {
                TransportationOptionCard(
                    title: "Driver Dashboard",
                    description: "Manage your ride requests",
                    iconName: "car.fill",
                    color: Color.goldDark
                )
            }
            
            // Shuttle Tracking Option
            NavigationLink(destination: ShuttleTrackingView()) {
                TransportationOptionCard(
                    title: "Shuttle Tracking",
                    description: "Track campus shuttle locations",
                    iconName: "bus.fill",
                    color: Color.maroonDark
                )
            }
            
            Spacer()
        }
    }
}

struct StudentTransportationView: View {
    @StateObject private var rideShareViewModel = RideShareViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Ride Finder Option
          NavigationLink(destination: RideShareMainView().environmentObject(rideShareViewModel)) {
                TransportationOptionCard(
                    title: "Ride Share",
                    description: "Find rides between campuses",
                    iconName: "car.fill",
                    color: Color.maroonDark
                )
            }
            
            // Shuttle Tracking Option
            NavigationLink(destination: ShuttleTrackingView()) {
                TransportationOptionCard(
                    title: "Shuttle Tracking",
                    description: "Track campus shuttle locations",
                    iconName: "bus.fill",
                    color: Color.goldDark
                )
            }
            
            Spacer()
        }
    }
}

struct DefaultTransportationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Please log in to access transportation features")
                .foregroundColor(.secondary)
            
            // Shuttle Tracking Option (always available)
            NavigationLink(destination: ShuttleTrackingView()) {
                TransportationOptionCard(
                    title: "Shuttle Tracking",
                    description: "Track campus shuttle locations",
                    iconName: "bus.fill",
                    color: Color.goldDark
                )
            }
            
            Spacer()
        }
    }
}



struct TransportationOptionCard: View {
    let title: String
    let description: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .foregroundColor(color)
                .padding(.trailing)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

#Preview {
    TransportationView()
    .environmentObject(AppState())
  
}
