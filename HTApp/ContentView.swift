//
//  ContentView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject private var appState = AppState()
    var body: some View {
        
        AppTabView()
        .environmentObject(appState)
        .preferredColorScheme(.light)
        
    }
}

extension Color {
    // Maroon Color Palette
    static let maroonDark = Color(red: 0.5, green: 0.0, blue: 0.0)
    static let maroonLight = Color(red: 0.5, green: 0.0, blue: 0.0).opacity(0.1)
    static let maroonMedium = Color(red: 0.6, green: 0.2, blue: 0.2)
    
    // Gold Color Palette
    static let goldDark = Color(red: 0.85, green: 0.65, blue: 0.0)
    static let goldLight = Color(red: 0.85, green: 0.65, blue: 0.0).opacity(0.1)
    static let goldMedium = Color(red: 1.0, green: 0.84, blue: 0.0)
    
    // Combination Colors
    static let maroonAndGold = Color(red: 0.55, green: 0.27, blue: 0.07)
    static let goldAccentOnMaroon = Color(red: 0.85, green: 0.55, blue: 0.1)
}

#Preview {
    ContentView()
     
}
