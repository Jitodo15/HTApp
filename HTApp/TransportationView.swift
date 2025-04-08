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
                 HStack {
                   Text("Transportation")
                     .font(.largeTitle)
                     .fontWeight(.bold)
                     .foregroundColor(Color.maroonDark)
                   
                   Spacer()
                 }
                 .padding(.horizontal)
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
               .navigationBarHidden(true)
               .padding()
           }
       }
}

//struct DriverTransportationView: View {
//    @StateObject private var rideShareViewModel = RideShareViewModel()
//
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 20) {
//                // Ride Share Option for Drivers
//                NavigationLink(destination: DriverDashboardView().environmentObject(rideShareViewModel)) {
//                    TransportationOptionCard(
//                        title: "Driver Dashboard",
//                        description: "Manage your ride requests",
//                        iconName: "car.fill",
//                        color: .blue
//                    )
//                }
//
//                // Shuttle Tracking Option
//                NavigationLink(destination: ShuttleTrackingView()) {
//                    TransportationOptionCard(
//                        title: "Shuttle Tracking",
//                        description: "Track campus shuttle locations",
//                        iconName: "bus.fill",
//                        color: .green
//                    )
//                }
//
//                // Shuttle schedule section
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("Shuttle Schedule")
//                        .font(.headline)
//                        .padding(.top, 5)
//
//                    // Weekday schedule
//                    ScheduleSection(
//                        title: "Monday - Friday",
//                        departingA: ["7:00am", "9:00am", "11:00am", "1:00pm", "5:00pm", "7:00pm"],
//                        departingB: ["8:00am", "10:00am", "12:00pm", "4:00pm", "6:00pm", "8:00pm", "9:00pm"],
//                        locationA: "Departing SEU",
//                        locationB: "Departing HT"
//                    )
//
//                    // Weekend schedule
//                    ScheduleSection(
//                        title: "Weekend Shuttle",
//                        departingA: ["10:00am", "1:00pm"],
//                        departingB: ["12:00pm", "6:00pm"],
//                        locationA: "Departing SEU",
//                        locationB: "Departing HT"
//                    )
//
//                    InfoCard(
//                        title: "Pickup Location",
//                        description: "In front of Student Union",
//                        iconName: "mappin.circle.fill"
//                    )
//
//                    HStack {
//                        Spacer()
//                        Text("Questions? Email studentaffairs@htu.edu")
//                            .font(.footnote)
//                            .foregroundColor(.secondary)
//                        Spacer()
//                    }.padding(.top, 8)
//                }
//                .padding()
//                .background(Color.gray.opacity(0.1))
//                .cornerRadius(12)
//                .padding(.horizontal)
//            }
//            .padding(.vertical)
//        }
//    }
//}

// Update TransportationView to include Driver Points Dashboard
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
            
            // Driver Points
            NavigationLink(destination: DriverPointsDashboardView().environmentObject(rideShareViewModel)) {
                TransportationOptionCard(
                    title: "Driver Points",
                    description: "View and redeem your earned points",
                    iconName: "star.circle.fill",
                    color: Color.maroonDark
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
        ScrollView {
            VStack(spacing: 20) {
                // Ride Finder Option
                NavigationLink(destination: RideShareMainView().environmentObject(rideShareViewModel)) {
                    TransportationOptionCard(
                        title: "Ride Share",
                        description: "Find rides between campuses and earn points for driving",
                        iconName: "car.fill",
                        color: .maroonDark
                    )
                }
                
                // Shuttle Tracking Option
                NavigationLink(destination: ShuttleTrackingView()) {
                    TransportationOptionCard(
                        title: "Shuttle Tracking",
                        description: "Track shuttles between HT and St. Edwards",
                        iconName: "bus.fill",
                        color: .goldDark
                    )
                }
                
                // Shuttle schedule section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Teresa Hall Shuttle Schedule")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    // Weekday schedule
                    ScheduleSection(
                        title: "Monday - Friday",
                        departingA: ["7:00am", "9:00am", "11:00am", "1:00pm", "5:00pm", "7:00pm"],
                        departingB: ["8:00am", "10:00am", "12:00pm", "4:00pm", "6:00pm", "8:00pm", "9:00pm"],
                        locationA: "Departing SEU",
                        locationB: "Departing HT"
                    )
                    
                    // Weekend schedule
                    ScheduleSection(
                        title: "Weekend Shuttle",
                        departingA: ["10:00am", "1:00pm"],
                        departingB: ["12:00pm", "6:00pm"],
                        locationA: "Departing SEU",
                        locationB: "Departing HT"
                    )
                    
                    InfoCard(
                        title: "Pickup Location",
                        description: "In front of Student Union",
                        iconName: "mappin.circle.fill"
                    )
                    
                    Divider().padding(.vertical, 5)
                    
                    Text("Ride Sharing Benefits")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    InfoCard(
                        title: "Earn Points",
                        description: "Get rewarded for giving rides to fellow students",
                        iconName: "star.fill"
                    )
                    
                    InfoCard(
                        title: "Convenience",
                        description: "Share rides to nearby destinations like grocery stores or beauty supply stores",
                        iconName: "bag.fill"
                    )
                    
                    HStack {
                        Spacer()
                        Text("Questions? Email studentaffairs@htu.edu")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }.padding(.top, 8)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct DefaultTransportationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Please log in to access transportation features")
                    .foregroundColor(.secondary)
                
                // Shuttle Tracking Option (always available)
                NavigationLink(destination: ShuttleTrackingView()) {
                    TransportationOptionCard(
                        title: "Shuttle Tracking",
                        description: "Track campus shuttle locations",
                        iconName: "bus.fill",
                        color: .goldDark
                    )
                }
                // Shuttle schedule section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Teresa Hall Shuttle Schedule")
                        .font(.headline)
                        .padding(.top, 5)
                    
                    // Weekday schedule
                    ScheduleSection(
                        title: "Monday - Friday",
                        departingA: ["7:00am", "9:00am", "11:00am", "1:00pm", "5:00pm", "7:00pm"],
                        departingB: ["8:00am", "10:00am", "12:00pm", "4:00pm", "6:00pm", "8:00pm", "9:00pm"],
                        locationA: "Departing SEU",
                        locationB: "Departing HT"
                    )
                    
                    // Weekend schedule
                    ScheduleSection(
                        title: "Weekend Shuttle",
                        departingA: ["10:00am", "1:00pm"],
                        departingB: ["12:00pm", "6:00pm"],
                        locationA: "Departing SEU",
                        locationB: "Departing HT"
                    )
                    
                    InfoCard(
                        title: "Pickup Location",
                        description: "In front of Student Union",
                        iconName: "mappin.circle.fill"
                    )
                    
                    HStack {
                        Spacer()
                        Text("Questions? Email studentaffairs@htu.edu")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Spacer()
                    }.padding(.top, 8)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct TransportationOptionCard: View {
    let title: String
    let description: String
    let iconName: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(color)
                .padding(.trailing)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading) // Ensure multi-line text is left-aligned
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

// Component for shuttle schedule display
struct ScheduleSection: View {
    let title: String
    let departingA: [String]
    let departingB: [String]
    let locationA: String
    let locationB: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            HStack(alignment: .top, spacing: 0) {
                // First column
                VStack(alignment: .leading) {
                    Text(locationA)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                    
                    ForEach(departingA, id: \.self) { time in
                        Text(time)
                            .font(.caption)
                            .padding(.vertical, 1)
                    }
                }
                .frame(width: 100)
                
                Spacer()
                
                // Second column
                VStack(alignment: .leading) {
                    Text(locationB)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 2)
                    
                    ForEach(departingB, id: \.self) { time in
                        Text(time)
                            .font(.caption)
                            .padding(.vertical, 1)
                    }
                }
                .frame(width: 100)
            }
        }
    }
}

// Add a simpler info card component for the tips section
struct InfoCard: View {
    let title: String
    let description: String
    let iconName: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: iconName)
            .foregroundColor(Color.maroonDark)
                .frame(width: 20)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    TransportationView()
    .environmentObject(AppState())
}
