//
//  AppTabView.swift
//  HT_App
//
//  Created by Ayomide Isinkaye on 2/3/25.
//

import Foundation
import SwiftUI

struct AppTabView: View {
    var body: some View {
        VStack {
           
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
              TutoringTabView(maroonColor: Color(red: 0.5, green: 0, blue: 0), goldColor: Color(red: 0.8, green: 0.7, blue: 0.2))
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Tutoring")
                }
                TransportationView()
  
                    .tabItem {
                        Image(systemName: "car.fill")
                        Text("Transport")
                    }
                
                EnhancedCalendarView()
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Calendar")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
               
            }
            .accentColor(Color(red: 128/255, green: 0/255, blue: 0/255))
            .background(
                Color.white.opacity(0.8)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            )
            .padding(.bottom, 0)
           
        }
    }
}

#Preview {
    AppTabView()
    .environmentObject(RideShareViewModel())
    .environmentObject(AppState())
}
