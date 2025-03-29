//
//  ProfileView.swift
//  HT_App
//
//  Created by Ayomide Isinkaye on 2/3/25.
//

import Foundation
import SwiftUI
import PhotosUI

struct ProfileView: View {

    @State private var userName: String = UserDefaults.standard.string(forKey: "currentUserFullName") ?? "Joy Isinkaye"
    @State private var email: String = UserDefaults.standard.string(forKey: "currentUserEmail") ?? "joy.isink@example.com"
  @StateObject private var appState = AppState.shared

  
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingPhotoOptions = false
    @State private var profileImage: UIImage? = nil
    @State private var inputImage: UIImage?
    
    // Edit Mode State
    @State private var isEditing = false
    
    // Preferences
    @State private var selectedTheme: String = "System Default"
    
    // Integrations
    @State private var googleConnected = true
    @State private var microsoftConnected = false
    @State private var appleConnected = true
    
    // Statistics
    let meetingTimePercentage = 35
    let freeTimePercentage = 65
    
    // View options
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // User Information Section
                    userInfoSection
                    
                    // Tabs for different sections
                    Picker("Options", selection: $selectedTab) {
                        Text("Integrations").tag(0)
                        Text("Statistics").tag(1)
                        Text("Help").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Content based on selected tab
                    switch selectedTab {
                    case 0:
                        integrationsSection
                    case 1:
                        statisticsSection
                    case 2:
                        helpAndSupportSection
                    default:
                        integrationsSection
                    }
                    
                    // Quick Actions
                    quickActionsSection
                }
                .padding()
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if isEditing {
                        Button(action: {
                            // Save profile changes
                            isEditing = false
                        }) {
                            Text("Save")
                        }
                    } else {
                        Button(action: {
                            // Enter edit mode
                            isEditing = true
                        }) {
                            Text("Edit")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
                    .onDisappear {
                        if let inputImage = inputImage {
                            profileImage = inputImage
                        }
                    }
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker(image: $inputImage)
                    .onDisappear {
                        if let inputImage = inputImage {
                            profileImage = inputImage
                        }
                    }
            }
            .actionSheet(isPresented: $showingPhotoOptions) {
                ActionSheet(
                    title: Text("Change Profile Picture"),
                    message: Text("Choose a new profile picture"),
                    buttons: [
                        .default(Text("Take Photo")) {
                            self.showingCamera = true
                        },
                        .default(Text("Choose from Gallery")) {
                            self.showingImagePicker = true
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
    
    // User Information Section
    var userInfoSection: some View {
        VStack(alignment: .center, spacing: 15) {
            ZStack {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                
                if isEditing {
                    Button(action: {
                        showingPhotoOptions = true
                    }) {
                        Circle()
                        .fill(Color.goldDark)
                            .frame(width: 30, height: 30)
                            .overlay(Image(systemName: "camera.fill").foregroundColor(.white))
                    }
                    .offset(x: 35, y: 35)
                }
            }
            
            if isEditing {
                TextField("Name", text: $userName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
            } else {
                Text(userName)
                    .font(.title2)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Picker("Theme", selection: $selectedTheme) {
                Text("Light").tag("Light")
                Text("Dark").tag("Dark")
                Text("System Default").tag("System Default")
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .disabled(!isEditing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // Integrations Section
    var integrationsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Connected Accounts")
                .font(.headline)
            
            GroupBox {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                    Text("Google")
                    Spacer()
                    Toggle("", isOn: $googleConnected)
                }
                
                HStack {
                    Image(systemName: "m.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                    Text("Microsoft")
                    Spacer()
                    Toggle("", isOn: $microsoftConnected)
                }
                
                HStack {
                    Image(systemName: "applelogo")
                        .resizable()
                        .frame(width: 25, height: 25)
                    Text("Apple")
                    Spacer()
                    Toggle("", isOn: $appleConnected)
                }
            }
            
            Text("Third-party Apps")
                .font(.headline)
                .padding(.top, 10)
            
            GroupBox {
                HStack {
                    Image(systemName: "video.fill")
                        .resizable()
                        .frame(width: 25, height: 15)
                        .foregroundColor(.blue)
                    Text("Zoom")
                    Spacer()
                    Toggle("", isOn: .constant(true))
                }
                
                HStack {
                    Image(systemName: "message.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.green)
                    Text("Slack")
                    Spacer()
                    Toggle("", isOn: .constant(false))
                }
                
                HStack {
                    Image(systemName: "doc.text.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.orange)
                    Text("Canvas")
                    Spacer()
                    Toggle("", isOn: .constant(false))
                }
                
                HStack {
                    Image(systemName: "mail.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.blue)
                    Text("Outlook")
                    Spacer()
                    Toggle("", isOn: .constant(false))
                }
                
                HStack {
                    Image(systemName: "message.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(.green)
                    Text("GroupMe")
                    Spacer()
                    Toggle("", isOn: .constant(false))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // Statistics Section
    var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Calendar Insights")
                .font(.headline)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("This Week's Schedule")
                        .font(.subheadline)
                    
                    HStack {
                        Text("Meeting Time")
                        Spacer()
                        Text("\(meetingTimePercentage)%")
                    }
                    
                    ProgressView(value: Float(meetingTimePercentage) / 100)
                        .tint(.blue)
                    
                    HStack {
                        Text("Free Time")
                        Spacer()
                        Text("\(freeTimePercentage)%")
                    }
                    
                    ProgressView(value: Float(freeTimePercentage) / 100)
                        .tint(.green)
                }
            }
            
            Text("Upcoming Schedule")
                .font(.headline)
                .padding(.top, 10)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today")
                                .font(.subheadline)
                            Text("3 Events")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tomorrow")
                                .font(.subheadline)
                            Text("5 Events")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    
                    Divider()
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Next 7 Days")
                                .font(.subheadline)
                            Text("12 Events")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Text("Productivity")
                .font(.headline)
                .padding(.top, 10)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Most Productive Day")
                        .font(.subheadline)
                    Text("Wednesday")
                        .foregroundColor(.gray)
                    
                    Text("Longest Meeting")
                        .font(.subheadline)
                    Text("Project Review: 2 hours")
                        .foregroundColor(.gray)
                    
                    Text("Average Meeting Length")
                        .font(.subheadline)
                    Text("45 minutes")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // Quick Actions Section
    var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Actions")
                .font(.headline)
            
            GroupBox {
                HStack(spacing: 20) {
                    Button(action: {
                        // Toggle focus mode
                    }) {
                        VStack {
                            Image(systemName: "moonphase.waxing.gibbous")
                                .font(.largeTitle)
                            Text("Focus Mode")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        // Toggle availability
                    }) {
                        VStack {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                                .font(.largeTitle)
                            Text("Available")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        // Schedule meeting
                    }) {
                        VStack {
                            Image(systemName: "calendar.badge.plus")
                                .font(.largeTitle)
                            Text("Schedule")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
    
    // Help & Support Section
    var helpAndSupportSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Help & Support")
                .font(.headline)
            
            GroupBox {
                NavigationLink(destination: FAQView()) {
                    Label("Frequently Asked Questions", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                NavigationLink(destination: ContactSupportView()) {
                    Label("Contact Support", systemImage: "envelope")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// FAQ View
struct FAQView: View {
    let faqs = [
        ("How do I change my profile picture?", "You can change your profile picture by tapping the edit button and then the camera icon on your current profile picture."),
        ("Can I connect multiple calendars?", "Yes, you can enable and disable different calendars in the Integrations section."),
        ("How do I set my availability?", "Use the Quick Actions section to toggle your availability status."),
        ("What third-party apps can I integrate?", "Currently, you can integrate Zoom, Slack, Canvas, Outlook, and GroupMe."),
        ("How do I contact support?", "You can contact support through the Contact Support section with the provided email.")
    ]
    
    var body: some View {
        List(faqs, id: \.0) { question, answer in
            VStack(alignment: .leading, spacing: 8) {
                Text(question)
                    .font(.headline)
                Text(answer)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Frequently Asked Questions")
    }
}

// Contact Support View
struct ContactSupportView: View {
    @State private var issueTitle: String = ""
    @State private var issueDescription: String = ""
    @State private var showConfirmation: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "envelope.open.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Contact Support")
                    .font(.title)
                
                Text("Email: support@htu.edu")
                    .font(.headline)
                
                Text("Please describe your issue below. Our support team will respond via email.")
                    .multilineTextAlignment(.center)
                    .padding()
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Issue Title")
                        .font(.headline)
                    TextField("Enter a brief title for your issue", text: $issueTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Issue Description")
                        .font(.headline)
                    TextEditor(text: $issueDescription)
                        .frame(height: 200)
                        .border(Color.gray.opacity(0.2), width: 1)
                        .cornerRadius(5)
                }
                .padding()
                
                Button(action: {
                    // Here you would typically implement the actual email sending logic
                    // For now, we'll just show a confirmation
                    showConfirmation = true
                }) {
                    Text("Submit Issue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.maroonDark)
                        .cornerRadius(10)
                }
                .disabled(issueTitle.isEmpty || issueDescription.isEmpty)
                .padding()
            }
        }
        .navigationTitle("Contact Support")
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Issue Submitted"),
                message: Text("Your issue has been recorded. Our support team will contact you at support@htu.edu shortly."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

// Camera Picker struct to access the device camera
struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// Image Picker struct to access the device photo library
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
        .environmentObject(AppState())
    }
}
