//
//  ShuttleTrackingApp.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//


import Foundation
import SwiftUI
import GoogleMaps
import GooglePlaces


struct ShuttleTrackingView: View {
    @StateObject private var viewModel = ShuttleViewModel()
    
    var body: some View {
        ZStack {
            GoogleMapView(viewModel: viewModel)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                BottomSheetView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    ShuttleTrackingView()
}
