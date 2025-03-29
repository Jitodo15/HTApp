//
//  HomeView.swift
//  HT_App
//
//  Created by Ayomide Isinkaye on 2/3/25.
//

import Foundation
import SwiftUI
import MapKit

struct HomeView: View {
    // Theme colors
   let maroonColor = Color.maroonMedium
   let goldColor = Color.goldMedium
    // State for the overlay menu
    @State private var selectedMenuItem: MenuItem? = nil
    @State private var showingMenuDetail = false
    
    // State for chatbot overlay
    @State private var showingChatbot = false
    
    // Sample data for demonstration
    let menuItems = [
        MenuItem(title: "Main buffet", items: ["🍝 Pasta", "🥢 Stir Fry", "🥦 Roasted Vegetables", "🍚 Rice", "🍲 Soup of the Day"]),
        MenuItem(title: "Veggie bar", items: ["🥗 Coleslaw", "🥬 Kale Salad", "🧀 Shredded cheese", "🥕 Shredded Carrots", "🍯 Sauces"]),
        MenuItem(title: "Grill side menu", items: ["🍔 Hamburgers", "🧀 Cheeseburgers", "🍗 Grilled Chicken", "🍟 French Fries", "🧅 Onion Rings"]),
        MenuItem(title: "Sandwich bar", items: ["🦃 Turkey", "🥩 Ham", "🐟 Tuna Salad", "🧀 Cheese Options", "🍞 Bread Options"]),
        MenuItem(title: "Dessert", items: ["🍦 Ice Cream", "🍪 Cookies", "🍫 Brownies", "🍎 Fruit", "🍰 Cake"]),
    ]
    
    @State private var events: [CalendarEventDetail] = [
        CalendarEventDetail(title: "Work", startDate: Date(), endDate: Date().addingTimeInterval(7200), notes: "Work meeting", color: .blue),
        CalendarEventDetail(title: "COSC2327-1", startDate: Date(), endDate: Date().addingTimeInterval(3600), notes: "Class lecture", color: .pink)
    ]

    let newsItems = [
        NewsItem(title: "Spring Break Service Trip Signups Open", preview: "Students interested in volunteer opportunities during the Spring break should...", date: "Mar 14"),
        NewsItem(title: "New Amazon Lockers on campus!", preview: "New Amazon lockers (Cantu) have been installed across campus as...", date: "Mar 15"),
        NewsItem(title: "Rams place second in BOTB Nationals", preview: "Rams win second place in HBCU Battle of the Brains competition...", date: "Mar 16")
    ]
    
    var body: some View {
        ZStack {
            // Main Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                  HStack {
                    Text("RAMCore Home")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.maroonDark)
                    
                    Spacer()
                        
                    Image("ramcore-logo")
                       .resizable()
                       .scaledToFit()
                       .frame(height: 40)
                       .clipShape(RoundedRectangle(cornerRadius: 10))
                  }
                  .padding(.horizontal)
                    
                    
                    // RAMi ChatBot Section
                    RamiChatbotView(maroonColor: maroonColor, goldColor: goldColor, showChatbot: $showingChatbot)
                        .padding(.horizontal)
                    
                    // Calendar Preview Section
                    VStack(alignment: .leading) {
                        Text("Today's Schedule")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        CalendarPreviewView(events: $events, maroonColor: maroonColor, goldColor: goldColor)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    // Cafeteria Menu Section
                    VStack(alignment: .leading) {
                        Text("Today's Menu")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(menuItems) { item in
                                    CafeteriaMenuItemView(
                                        item: item,
                                        maroonColor: maroonColor,
                                        goldColor: goldColor,
                                        onTap: {
                                            selectedMenuItem = item
                                            showingMenuDetail = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Shuttle Tracking Preview
                    VStack(alignment: .leading) {
                        Text("Shuttle Tracking")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        ShuttleTrackingPreviewView(maroonColor: maroonColor)
                            .frame(height: 200)
                            .padding(.horizontal)
                    }
                    
                    // News Section
                    VStack(alignment: .leading) {
                        Text("Campus News")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        
                        NewsView(maroonColor: maroonColor, newsItems: newsItems)
                            .frame(height: 350)
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            
            
            // Overlay Menu Detail
            if showingMenuDetail, let menuItem = selectedMenuItem {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingMenuDetail = false
                    }
                
                // Menu Detail Overlay
                MenuDetailOverlay(
                    item: menuItem,
                    maroonColor: maroonColor,
                    goldColor: goldColor,
                    isShowing: $showingMenuDetail
                )
                .transition(.opacity)
                .zIndex(1)
            }
            
            // Chatbot Overlay
            if showingChatbot {
                // Semi-transparent background
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showingChatbot = false
                    }
                
                // Chatbot Overlay
                ChatbotOverlay(
                    maroonColor: maroonColor,
                    goldColor: goldColor,
                    isShowing: $showingChatbot
                )
                .transition(.opacity)
                .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showingMenuDetail)
        .animation(.easeInOut(duration: 0.2), value: showingChatbot)
    }
}



// Supporting Views

struct CafeteriaMenuItemView: View {
    let item: MenuItem
    let maroonColor: Color
    let goldColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
                    .fill(Color.maroonLight)
                    .shadow(color: Color.maroonLight.opacity(0.3), radius: 4)
                    .frame(width: 150, height: 120)
                
                VStack {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
    }
}

struct MenuDetailOverlay: View {
    let item: MenuItem
    let maroonColor: Color
    let goldColor: Color
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 15)
                .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
                    .fill(Color.white)
                    .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
              
                VStack(spacing: 12) {
                    // Header
                    Text(item.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(maroonColor)
                        .padding(.top, 10)

                    // Menu items list
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(item.items, id: \.self) { menuItem in
                            Text(menuItem)
                                .font(.body)
                                .foregroundColor(.black)       .padding(.vertical, 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                }
                .padding(.vertical, 20)

                // Close Button (X)
                Button(action: {
                    isShowing = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color.maroonDark)
                }
                .padding()
            }
        }
        .frame(width: 280, height: 290) // Adjust width
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

struct CalendarPreviewView: View {
    @Binding var events: [CalendarEventDetail]
    let maroonColor: Color
    let goldColor: Color
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
                .fill(Color.maroonLight)
                .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
                
            
            VStack(alignment: .leading) {
                // Date header
                HStack {
                    Text("March")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    Spacer()
                    Text("2 all-day events")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(.bottom, 5)
                
                // Day indicator
                // Get today's day as a string
                let today = Calendar.current.component(.day, from: Date())

                Text("\(today)") // ✅ Dynamic day indicator
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(8)
                    .background(Circle().fill(Color.goldLight.opacity(0.2)))
                    .foregroundColor(.black)

                
                // Events
                ForEach(events) { event in
                    HStack {
                        Circle()
                            .fill(event.color) // ✅ No Binding<Color> error
                            .frame(width: 10, height: 10)
                        Text(event.title)
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                        Spacer()
                        Text(event.notes) // Now correctly included
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding()
        }
    }
}

struct ShuttleTrackingPreviewView: View {
    let maroonColor: Color
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431), // Austin coordinates as example
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
            .fill(Color.maroonLight)
            .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
            
            VStack {
                // Map view with car emoji overlay
                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: false, userTrackingMode: .none)
                        .cornerRadius(8)
                    
                    Text("🚌")
                        .font(.system(size: 30))
                        .offset(x: 20, y: -15) // Position the shuttle emoji
                }
            }
            .padding(10)
        }
    }
}

struct NewsItemView: View {
    let item: NewsItem
    let maroonColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(item.preview)
                .font(.subheadline)
                .foregroundColor(.black)
                .lineLimit(2)
            
            HStack {
                Spacer()
                Text(item.date)
                    .font(.caption)
                    .foregroundColor(.black)
            }
            
            Divider()
        }
        .padding(.vertical, 5)
    }
}

struct NewsView: View {
    let maroonColor: Color
    let newsItems: [NewsItem]
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
            .fill(Color.maroonLight)
            .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading) {
                ForEach(newsItems) { item in
                    NewsItemView(item: item, maroonColor: maroonColor)
                }
                
                Button(action: {
                    // Action to see all news
                }) {
                    HStack {
                        Spacer()
                        Text("See All News")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    .background(Color.maroonDark)
                    .cornerRadius(8)
                }
                .padding(.top, 5)
            }
            .padding()
        }
    }
}

// Data Models
struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let items: [String]
    
    init(title: String, items: [String] = []) {
        self.title = title
        self.items = items
    }
}

struct CalendarEvent: Identifiable {
    let id = UUID()
    let title: String
    let time: String
    let color: Color
}

struct CalendarEventDetail: Identifiable {
    let id = UUID()
    let title: String
    let startDate: Date
    let endDate: Date
    let notes: String
    let color: Color
}

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let preview: String
    let date: String
}

// Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

