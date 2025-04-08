//
//  HomeView.swift
//  HT_App
//
//  Created by Ayomide Isinkaye on 2/3/25.
//

import Foundation
import SwiftUI
import MapKit


struct NewsListView: View {
    let maroonColor: Color
    let goldColor: Color
    let allNewsItems: [NewsItem]
    @Environment(\.presentationMode) var presentationMode // For dismissing
    
    var body: some View {
        NavigationView {
            List {
                ForEach(allNewsItems) { item in
                    VStack(alignment: .leading, spacing: 8) {
                        Link(destination: URL(string: item.url)!) {
                            Text(item.title)
                                .font(.headline)
                                .foregroundColor(maroonColor)
                                .underline()
                                .padding(.top, 6)
                        }
                        
                        Text(item.preview)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        HStack {
                            Spacer()
                            Text(item.date)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Campus News")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing:
                Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct HomeView: View {
    // Theme colors
   let maroonColor = Color.maroonMedium
   let goldColor = Color.goldMedium
    // State for the overlay menu
    @State private var selectedMenuItem: MenuItem? = nil
    @State private var showingMenuDetail = false
    
    // State for chatbot overlay
    @State private var showingChatbot = false
    @State var showingNewsList = false
    
    // Sample data for demonstration
    let menuItems = [
        MenuItem(title: "Main buffet", items: ["🍝 Pasta", "🍗 Chicken Alfredo", "🥦 Roasted Vegetables", "🍚 Rice", "🍲 Gravy"]),
        MenuItem(title: "Veggie bar", items: ["🥗 Coleslaw", "🥬 Kale Salad", "🧀 Shredded cheese", "🥕 Shredded Carrots", "🍯 Sauces"]),
        MenuItem(title: "Grill side menu", items: ["🍔 Hamburgers", "🧀 Cheeseburgers", "🍕 Pizza (Pepperoni and Cheese)", "🍟 French Fries", "🌭 Hot dogs"]),
        MenuItem(title: "Sandwich bar", items: ["🦃 Turkey", "🥩 Ham", "🐟 Tuna Salad", "🧀 Cheese Options", "🍞 Bread Options"]),
        MenuItem(title: "Dessert", items: ["🧁 Blueberry Cupcake", "🍪 Cookies", "🍫 Brownies", "🍎 Fruit", "🍰 Cake"]),
    ]
    
    @State private var events: [CalendarEventDetail] = [
        CalendarEventDetail(title: "Work", startDate: Date(), endDate: Date().addingTimeInterval(7200), notes: "Work meeting", color: .blue),
        CalendarEventDetail(title: "COSC2327-1", startDate: Date(), endDate: Date().addingTimeInterval(3600), notes: "Class lecture", color: .pink)
    ]

      // Featured news items for the preview section
      let previewNewsItems = [
          NewsItem(
              title: "Rams place second in BOTB Nationals",
              preview: "Rams win second place in HBCU Battle of the Brains competition...",
              date: "Mar 16",
              url: "https://www.linkedin.com/posts/huston-tillotson-school-of-business-and-technology-7836b41b0_securing-silver-at-the-2025-hbcu-battle-of-activity-7310269226550734848-oFOs?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADmnp6ABKKJfb9uGgHYUsTyXEvHceWMpqBE"
          ),
          NewsItem(
              title: "Huston-Tillotson Hosting First HBCU AiCON",
              preview: "HT is hosting the first-ever AI conference for HBCUs...",
              date: "Mar 18",
              url: "https://htu.edu/huston-tillotson-university-hosts-inaugural-hbcu-ai-conference-and-training-summit/"
          ),
          NewsItem(
              title: "SBT Financial Wellness Symposium on April 5th",
              preview: "Join the School of Business and Technology for its 4th annual Financial Wellness Symposium...",
              date: "Mar 20",
              url: "https://www.linkedin.com/posts/huston-tillotson-school-of-business-and-technology-7836b41b0_the-school-of-business-technologys-4th-activity-7305558215964930049-6x2G?utm_source=social_share_send&utm_medium=member_desktop_web&rcm=ACoAADmnp6ABKKJfb9uGgHYUsTyXEvHceWMpqBE"
          )
      ]

      // Full list of news items including the preview ones and additional ones
      var allNewsItems: [NewsItem] {
          // Combine preview news with additional news
          let additionalNewsItems = [
              NewsItem(
                  title: "HT Rams Baseball Sweeps Weekend Series",
                  preview: "The Huston-Tillotson Rams baseball team dominated their weekend series against rival university with three consecutive wins...",
                  date: "Mar 25",
                  url: "https://htu.edu"
              ),
              NewsItem(
                  title: "School of Education Hosts Teaching Career Fair",
                  preview: "The Huston-Tillotson School of Education is hosting its annual Teaching Career Fair with over 20 school districts in attendance...",
                  date: "Mar 23",
                  url: "https://htu.edu"
              ),
              NewsItem(
                  title: "Grammy-Winning Artist to Perform at Spring Concert",
                  preview: "Huston-Tillotson's Spring Concert Series will feature a special performance by Grammy-winning artist next month...",
                  date: "Mar 22",
                  url: "https://htu.edu"
              ),
              NewsItem(
                  title: "HT Students Win at Regional Hackathon",
                  preview: "A team of Huston-Tillotson computer science students took first place at the regional collegiate hackathon...",
                  date: "Mar 15",
                  url: "https://htu.edu"
              ),
              NewsItem(
                  title: "New Sustainability Initiative Launched on Campus",
                  preview: "Huston-Tillotson University announces a new campus-wide sustainability initiative that aims to reduce carbon footprint by 30%...",
                  date: "Mar 12",
                  url: "https://htu.edu"
              ),
              NewsItem(
                  title: "Alumni Association Awards $50,000 in Scholarships",
                  preview: "The Huston-Tillotson Alumni Association has awarded $50,000 in scholarships to current students for the upcoming academic year...",
                  date: "Mar 10",
                  url: "https://htu.edu"
              )
          ]
          
          return previewNewsItems + additionalNewsItems
      }

    
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
                  // News Section in HomeView
                  VStack(alignment: .leading) {
                        Text("Campus News")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                                              
                            NewsView(
                              maroonColor: maroonColor,
                              newsItems: previewNewsItems,
                                                  showSheet: $showingNewsList, // Pass the binding
                                                  allNewsItems: allNewsItems
                                              )
                                              .frame(height: 350)
                                              .padding(.horizontal)
                             }
                                          .sheet(isPresented: $showingNewsList) {
                                              // This is the sheet that will slide up
                                              NewsListView(
                                                  maroonColor: maroonColor,
                                                  goldColor: goldColor,
                                                  allNewsItems: allNewsItems
                                              )
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
                    Text("April")
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

// Supporting Views (unchanged)
struct ShuttleTrackingPreviewView: View {
    let maroonColor: Color
    var onTap: (() -> Void)? = nil
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 30.2672, longitude: -97.7431), // Example: Austin coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    
    var body: some View {
        ZStack {
        
          RoundedRectangle(cornerRadius: 10)
          .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
          .fill(Color.maroonLight)
          .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
            
            VStack {
                // Map view with shuttle emoji overlay
                ZStack {
                    Map(coordinateRegion: $region, showsUserLocation: false, userTrackingMode: .none)
                        .cornerRadius(8)
                    
                    Text("🚌")
                        .font(.system(size: 30))
                        .offset(x: 20, y: -15) // Position the shuttle emoji
                }
            }
            .padding(10)
            .onTapGesture {
                onTap?()
            }
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

// Modified NewsView to handle button click
struct NewsView: View {
    let maroonColor: Color
    let newsItems: [NewsItem]
    @Binding var showSheet: Bool // New binding to control the sheet
    let allNewsItems: [NewsItem] // Pass all news items
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            .fill(Color.maroonLight)
            .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
            
            VStack(alignment: .leading) {
                ForEach(newsItems) { item in
                    NewsItemView(item: item, maroonColor: maroonColor)
                }
                
                Button(action: {
                    // Simply toggle the sheet presentation
                    showSheet = true
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

// Helper method to find ancestor view
func findAncestorView<T: View>(ofType type: T.Type) -> HomeView? {
        var responder: UIResponder? = UIApplication.shared.windows.first?.rootViewController?.view
        while let nextResponder = responder?.next {
            if let viewController = nextResponder as? UIHostingController<HomeView> {
                return viewController.rootView
            }
            responder = nextResponder
        }
        return nil
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
    let url: String
}

// Preview Provider
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

