//
//  BottomSheetView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import SwiftUI

// MARK: - Bottom Sheet View
struct BottomSheetView: View {
    @ObservedObject var viewModel: ShuttleViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle indicator
            Rectangle()
                .frame(width: 40, height: 5)
                .cornerRadius(2.5)
                .foregroundColor(Color.gray.opacity(0.5))
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image(systemName: "car.fill")
                        .font(.title)
                        .foregroundColor(Color.maroonDark)
                    
                    VStack(alignment: .leading) {
                        Text(viewModel.vehicleStatus.rawValue)
                            .font(.headline)
                        Text("ETA: \(viewModel.estimatedTimeOfArrival)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    
                }
                
                Divider()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Trip Details")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        Image(systemName: "mappin.circle.fill")
                        .foregroundColor(Color.maroonDark)
                        .frame(height:20)
                        Text("Pickup: St. Edwards University")
                            .font(.subheadline)
                    }
                    
                    HStack(spacing: 15) {
                        Image(systemName: "flag.circle.fill")
                        .foregroundColor(Color.goldDark)
                        .frame(height:20)
                        Text("Destination: Huston-Tillotson University")
                            .font(.subheadline)
                    }
                }
                
  
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20, corners: [.topLeft, .topRight])
            .shadow(radius: 5)
        }
    }
}

// Helper extension for rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
