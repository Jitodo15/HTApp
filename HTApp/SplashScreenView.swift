//
//  SplashScreenView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/30/25.
//


import SwiftUI

struct SplashScreenView: View {
    @State private var isActive = false
    @Binding var showSplash: Bool
    
    var body: some View {
        ZStack {
            Color.maroonDark
                .ignoresSafeArea()
            
            VStack {
                Image("RAM")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 350, height: 350)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .onAppear {
            // Dismiss the splash screen after 7 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                withAnimation {
                    self.showSplash = false
                }
            }
        }
    }
}
