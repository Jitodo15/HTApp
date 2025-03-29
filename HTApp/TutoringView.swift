//
//  TutoringView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/29/25.
//

import SwiftUI

// MARK: - Models

struct Tutor: Identifiable {
    let id = UUID()
    let name: String
    let specialization: String
    let availability: String
    let imageURL: String?
}

struct TutoringCenter: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let iconName: String
    let tutors: [Tutor]
    let location: String
    let hours: String
}

// MARK: - Main Tutoring Tab View

struct TutoringTabView: View {
    @State private var selectedCenter: TutoringCenter?
    @State private var showingCenterDetail = false
    
    let maroonColor: Color
    let goldColor: Color
    
    // Sample data
    let tutoringCenters = [
        TutoringCenter(
            name: "Writers Studio",
            description: "Support for writing assignments, essays, research papers, and resume building.",
            iconName: "doc.text",
            tutors: [
                Tutor(name: "Ifedolapo Jojolola", specialization: "Research Writing", availability: "Mon, Wed: 10am-2pm", imageURL: nil),
                Tutor(name: "A'yanna Price", specialization: "Creative Writing", availability: "Tue, Thu: 1pm-5pm", imageURL: nil),
                Tutor(name: "Lyneisha Fowler", specialization: "Resume Building", availability: "Fri: 9am-3pm", imageURL: nil),
                Tutor(name: "Otis Rolle Jr.", specialization: "Technical Writing", availability: "Mon, Thu: 3pm-6pm", imageURL: nil),
                Tutor(name: "Sky Turntine", specialization: "Essay Structure", availability: "Wed, Fri: 11am-4pm", imageURL: nil)
            ],
            location: "jackson-Moodly, Room 102",
            hours: "Monday-Friday: 9am-5pm"
        ),
        TutoringCenter(
            name: "Math Center",
            description: "Assistance with all levels of mathematics courses, from algebra to advanced calculus.",
            iconName: "function",
            tutors: [
                Tutor(name: "Joy Itodo", specialization: "Calculus", availability: "Mon, Wed, Fri: 9am-1pm", imageURL: nil),
                Tutor(name: "Ayomide Isinkaye", specialization: "Statistics", availability: "Tue, Thu: 10am-3pm", imageURL: nil),
                Tutor(name: "Joshua Umoru", specialization: "Linear Algebra", availability: "Mon, Wed: 2pm-6pm", imageURL: nil),
                Tutor(name: "Israel Ogbonna", specialization: "Differential Equations", availability: "Tue, Thu: 1pm-5pm", imageURL: nil),
                Tutor(name: "Abdulwadud Abdulkadir", specialization: "Algebra", availability: "Fri: 10am-4pm", imageURL: nil),
                Tutor(name: "Grace Kolawole", specialization: "Algebra", availability: "Fri: 10am-4pm", imageURL: nil),
                Tutor(name: "Tochi Okezie", specialization: "Algebra", availability: "Fri: 10am-4pm", imageURL: nil)
            ],
            location: "Dickey-Lawless, Room 102",
            hours: "Monday-Friday: 9am-5pm, Saturday: 10am-2pm"
        ),
        TutoringCenter(
            name: "CAE Tutoring Center",
            description: "General tutoring for all other subjects including sciences, languages, and business courses.",
            iconName: "book",
            tutors: [
                Tutor(name: "Faiqah Salawudeen", specialization: "Chemistry", availability: "Mon, Wed: 11am-3pm", imageURL: nil),
                Tutor(name: "Gavino Vargas", specialization: "Physics", availability: "Tue, Thu: 9am-1pm", imageURL: nil),
                Tutor(name: "Maryam Usman", specialization: "Business", availability: "Wed, Fri: 1pm-5pm", imageURL: nil),
                Tutor(name: "Gahoussou Toure", specialization: "Computer Science", availability: "Mon, Thu: 2pm-6pm", imageURL: nil),
                Tutor(name: "KC Surakshya", specialization: "Foreign Languages", availability: "Tue, Fri: 10am-2pm", imageURL: nil)
            ],
            location: "Jackson-Moody, Room 102",
            hours: "Monday-Friday: 9am-5pm"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Academic Tutoring")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(maroonColor)
                    .padding(.horizontal)
                
                // Subtitle
                Text("Managed by the Center for Academic Excellence (CAE)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Tutoring Centers
                ForEach(tutoringCenters) { center in
                    TutoringCenterCard(
                        center: center,
                        maroonColor: maroonColor,
                        goldColor: goldColor,
                        onTap: {
                            selectedCenter = center
                            showingCenterDetail = true
                        }
                    )
                    .padding(.horizontal)
                }
                
                // General Info Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("About Tutoring Services")
                        .font(.headline)
                        .foregroundColor(maroonColor)
                    
                    Text("All tutoring services are free for enrolled students. Appointments are recommended but walk-ins are welcome based on availability. Bring your course materials and specific questions to make the most of your tutoring session.")
                        .font(.body)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $showingCenterDetail, content: {
            if let center = selectedCenter {
                TutoringCenterDetailView(
                    center: center,
                    maroonColor: maroonColor,
                    goldColor: goldColor,
                    isShowing: $showingCenterDetail
                )
            }
        })
        .navigationTitle("Tutoring")
    }
}

// MARK: - Tutoring Center Card

struct TutoringCenterCard: View {
    let center: TutoringCenter
    let maroonColor: Color
    let goldColor: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                // Icon
                Image(systemName: center.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(maroonColor)
                    .clipShape(Circle())
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(center.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(center.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Label(center.location, systemImage: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(goldColor)
                    }
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .foregroundColor(maroonColor)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Tutoring Center Detail View

struct TutoringCenterDetailView: View {
    let center: TutoringCenter
    let maroonColor: Color
    let goldColor: Color
    @Binding var isShowing: Bool
    @State private var filter: String = ""
    
    var filteredTutors: [Tutor] {
        if filter.isEmpty {
            return center.tutors
        } else {
            return center.tutors.filter {
                $0.name.lowercased().contains(filter.lowercased()) ||
                $0.specialization.lowercased().contains(filter.lowercased())
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Center Info
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: center.iconName)
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(maroonColor)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(center.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(center.location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Text(center.description)
                            .padding(.top, 5)
                        
                        HStack {
                            Label("Hours", systemImage: "clock.fill")
                                .foregroundColor(maroonColor)
                                .font(.headline)
                            Spacer()
                        }
                        
                        Text(center.hours)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search by tutor name or specialization", text: $filter)
                            .foregroundColor(.primary)
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Tutors List
                    VStack(alignment: .leading) {
                        Text("Available Tutors")
                            .font(.headline)
                            .foregroundColor(maroonColor)
                            .padding(.horizontal)
                        
                        ForEach(filteredTutors) { tutor in
                            TutorCard(tutor: tutor, maroonColor: maroonColor, goldColor: goldColor)
                                .padding(.horizontal)
                                .padding(.bottom, 10)
                        }
                        
                        if filteredTutors.isEmpty {
                            Text("No tutors match your search criteria")
                                .foregroundColor(.secondary)
                                .italic()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        }
                    }
                    
                    // Booking Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How to Book a Session")
                            .font(.headline)
                            .foregroundColor(maroonColor)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            BookingStep(number: 1, text: "Check the tutor's availability above", iconName: "calendar")
                            BookingStep(number: 2, text: "Visit the center in person or call to book", iconName: "phone.fill")
                            BookingStep(number: 3, text: "Bring relevant course materials to your session", iconName: "doc.fill")
                            BookingStep(number: 4, text: "Arrive 5 minutes before your scheduled time", iconName: "clock.fill")
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationBarTitle(center.name, displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    isShowing = false
                }) {
                    Text("Close")
                        .foregroundColor(maroonColor)
                }
            )
        }
    }
}

// MARK: - Supporting Views

struct TutorCard: View {
    let tutor: Tutor
    let maroonColor: Color
    let goldColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Profile Image or Initial
            if let imageURL = tutor.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                Text(String(tutor.name.first ?? "T"))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(maroonColor)
                    .clipShape(Circle())
            }
            
            // Tutor Info
            VStack(alignment: .leading, spacing: 4) {
                Text(tutor.name)
                    .font(.headline)
                
                Text(tutor.specialization)
                    .font(.subheadline)
                    .foregroundColor(goldColor)
                
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(tutor.availability)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
}

struct BookingStep: View {
    let number: Int
    let text: String
    let iconName: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                
                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.black)
            }
            
            Text(text)
                .font(.body)
            
            Spacer()
            
            Image(systemName: iconName)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview Provider

struct TutoringTabView_Previews: PreviewProvider {
    static var previews: some View {
        TutoringTabView(maroonColor: Color(red: 0.5, green: 0, blue: 0), goldColor: Color(red: 0.8, green: 0.7, blue: 0.2))
    }
}
