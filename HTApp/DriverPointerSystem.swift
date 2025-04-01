//
//  DriverPointerSystem.swift
//  HTApp
//
//  Created by Joy Itodo on 3/31/25.
//

import Foundation
import SwiftUI

// MARK: - Updated Models



// Points transaction record
struct PointsTransaction: Identifiable, Codable {
    let id: String
    let driverId: String
    let rideRequestId: String
    let points: Int
    let timestamp: Date
    let reason: PointsReason
    var description: String?
}

// Reasons for earning points
enum PointsReason: String, Codable, CaseIterable {
    case completedRide = "Completed Ride"
    case perfectRating = "Perfect Rating"
    case consistentDriver = "Consistent Driver"
    case referral = "Referred New User"
    case specialEvent = "Special Event"
    case monthlyBonus = "Monthly Bonus"
}



// MARK: - Points UI Components

// Driver Points Dashboard View
struct DriverPointsDashboardView: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Points summary card
                PointsSummaryCard()
                    .environmentObject(viewModel)
                
                // Points history
                PointsHistorySection()
                    .environmentObject(viewModel)
                
                // Rewards section
                RewardsSection()
                    .environmentObject(viewModel)
            }
            .padding()
        }
        .navigationTitle("Driver Points")
    }
}

// Points Summary Card
struct PointsSummaryCard: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // Current points
            HStack {
                VStack(alignment: .leading) {
                    Text("Your Points")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(viewModel.currentStudent?.points ?? 0)")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Points badge
                ZStack {
                    Circle()
                        .fill(Color.goldDark)
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "star.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                }
            }
            
            Divider()
            
            // Stats summary
            HStack(spacing: 20) {
                PointsStatItem(
                    value: "\(viewModel.currentStudent?.totalRides ?? 0)",
                    label: "Total Rides",
                    iconName: "car.fill"
                )
                
                Divider()
                    .frame(height: 40)
                
                PointsStatItem(
                    value: "\(viewModel.pointsTransactions.prefix(5).reduce(0) { $0 + $1.points })",
                    label: "Recent Points",
                    iconName: "chart.line.uptrend.xyaxis"
                )
                
                Divider()
                    .frame(height: 40)
                
                PointsStatItem(
                    value: String(format: "%.1f", viewModel.currentStudent?.rating ?? 0.0),
                    label: "Rating",
                    iconName: "star.fill"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Points Stat Item
struct PointsStatItem: View {
    let value: String
    let label: String
    let iconName: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.maroonDark)
                Text(value)
                    .fontWeight(.semibold)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// Points History Section
struct PointsHistorySection: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Points History")
                .font(.headline)
            
            if viewModel.pointsTransactions.isEmpty {
                Text("No points activity yet")
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(viewModel.pointsTransactions.prefix(5)) { transaction in
                    PointsTransactionRow(transaction: transaction)
                }
                
                NavigationLink(destination: AllPointsHistoryView().environmentObject(viewModel)) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundColor(.maroonDark)
                        .padding(.top, 5)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Points Transaction Row
struct PointsTransactionRow: View {
    let transaction: PointsTransaction
    
    var body: some View {
        HStack {
            // Icon based on reason
            ZStack {
                Circle()
                    .fill(reasonColor.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: reasonIcon)
                    .foregroundColor(reasonColor)
            }
            
            // Transaction details
            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.reason.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let description = transaction.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(formattedDate)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Points
            Text("+\(transaction.points)")
                .font(.headline)
                .foregroundColor(.green)
        }
        .padding(.vertical, 8)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: transaction.timestamp)
    }
    
    private var reasonColor: Color {
        switch transaction.reason {
        case .completedRide:
            return .blue
        case .perfectRating:
            return .yellow
        case .consistentDriver:
            return .green
        case .referral:
            return .purple
        case .specialEvent:
            return .red
        case .monthlyBonus:
            return .orange
        }
    }
    
    private var reasonIcon: String {
        switch transaction.reason {
        case .completedRide:
            return "car.fill"
        case .perfectRating:
            return "star.fill"
        case .consistentDriver:
            return "calendar.badge.clock"
        case .referral:
            return "person.badge.plus"
        case .specialEvent:
            return "sparkles"
        case .monthlyBonus:
            return "calendar"
        }
    }
}

// All Points History View
struct AllPointsHistoryView: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.pointsTransactions.sorted(by: { $0.timestamp > $1.timestamp })) { transaction in
                PointsTransactionRow(transaction: transaction)
            }
        }
        .navigationTitle("Points History")
    }
}

// Rewards Section
struct RewardsSection: View {
    @EnvironmentObject var viewModel: RideShareViewModel
    
    // Sample rewards
    let rewards = [
        (name: "Free Coffee at Campus Cafe", points: 100, icon: "cup.and.saucer.fill"),
        (name: "Discount on Campus Store", points: 250, icon: "bag.fill"),
        (name: "Free Campus Parking (1 week)", points: 500, icon: "car.fill"),
        (name: "HTU Branded Merchandise", points: 750, icon: "tshirt.fill"),
        (name: "Textbook Discount Voucher", points: 1000, icon: "book.fill")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Redeem Points")
                .font(.headline)
            
            ForEach(rewards, id: \.name) { reward in
                RewardRow(
                    name: reward.name,
                    points: reward.points,
                    icon: reward.icon,
                    isAvailable: (viewModel.currentStudent?.points ?? 0) >= reward.points
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Reward Row
struct RewardRow: View {
    let name: String
    let points: Int
    let icon: String
    let isAvailable: Bool
    
    var body: some View {
        HStack {
            // Reward icon
            ZStack {
                Circle()
                    .fill(isAvailable ? Color.goldDark.opacity(0.2) : Color.gray.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(isAvailable ? .goldDark : .gray)
            }
            
            // Reward details
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("\(points) points")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Redeem button
            Button(action: {
                // In a real app, this would trigger the reward redemption process
            }) {
                Text("Redeem")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(isAvailable ? Color.maroonDark : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(!isAvailable)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Integration with Existing Views




// Extended AcceptedRideRow with completion functionality
struct AcceptedRideRowWithCompletion: View {
    let request: RideRequest
    let onComplete: (Double) -> Void
    @State private var isShowingCompletionSheet = false
    
    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .padding(10)
                .background(Circle().fill(Color.blue.opacity(0.2)))
            
            VStack(alignment: .leading, spacing: 4) {
                
                        Text("Ayomide Isinkaye")
                                  .font(.subheadline)
                                  .fontWeight(.medium)
                              
                              Text("\(request.numberOfPassengers) passenger(s)")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                              
                              Text("From: \(request.pickupLocation.name ?? "Unknown")")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                              
                              Text("To: \(request.dropoffLocation.name ?? "Unknown")")
                                  .font(.caption)
                                  .foregroundColor(.secondary)
                          }
                          
                          Spacer()
                          
                          Button(action: {
                              isShowingCompletionSheet = true
                          }) {
                              Text("Complete")
                                  .font(.caption)
                                  .padding(.horizontal, 12)
                                  .padding(.vertical, 6)
                                  .background(Color.green)
                                  .foregroundColor(.white)
                                  .cornerRadius(8)
                          }
                      }
                      .padding(.vertical, 4)
                      .sheet(isPresented: $isShowingCompletionSheet) {
                          RideCompletionView(onComplete: onComplete)
                      }
        }
}


// Ride Completion View
struct RideCompletionView: View {
    let onComplete: (Double) -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var rating: Double = 5.0
    @State private var feedback: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rate the experience")) {
                    VStack {
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: rating >= Double(star) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.title)
                                    .onTapGesture {
                                        rating = Double(star)
                                    }
                            }
                        }
                        .padding()
                        
                        Text("Rating: \(rating, specifier: "%.1f")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Section(header: Text("Additional Feedback")) {
                    TextField("Optional feedback", text: $feedback)
                }
                
                Section {
                    Button(action: {
                        onComplete(rating)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Submit & Complete Ride")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.green)
                }
            }
            .navigationTitle("Complete Ride")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}




