//
//  LoginView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//

import Foundation
import SwiftUI
import CryptoKit
@preconcurrency import PostgresNIO

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""
    @State var isPasswordVisible: Bool = false
    @State var isLoginSuccessful: Bool = false
    @State var errorMessage: String? = nil
    @State var showAlert: Bool = false
    @State var alertMessage: String = ""
    @StateObject private var locationManager = LocationManager()


    func hashPassword(password: String) -> String {
        let passwordData = Data(password.utf8)
        let hashed = SHA256.hash(data: passwordData)
        return hashed.map { String(format: "%02x", $0) }.joined()
    }
    
    func updateUserLocation(userID: Int, latitude: Double, longitude: Double) async {
        guard let connection = DatabaseManager.shared.getConnection() else {
            print("❌ No active database connection")
            return
        }

        let sql = "UPDATE users SET latitude = $1, longitude = $2 WHERE id = $3"
        let latData = PostgresData(double: latitude)
        let lonData = PostgresData(double: longitude)
        let userIDData = PostgresData(int: userID)

        do {
            try await connection.query(sql, [latData, lonData, userIDData]).get()
            print("✅ Location updated successfully")
        } catch {
            print("❌ Error updating location: \(error)")
        }
    }

        
    func login(username: String, password: String) async -> Bool {
        guard let connection = DatabaseManager.shared.getConnection() else {
            print("❌ No active database connection")
            return false
        }

        let hashedPassword = hashPassword(password: password)
        let sql = """
          SELECT id, username, password, full_name, email, role 
          FROM users 
          WHERE username = $1
        """
        let usernameData = PostgresData(string: username)

        do {
            let result = try await connection.query(sql, [usernameData]).get()
           print(result)
          if let row = result.first,
            let storedPasswordHash = row.column("password")?.string,
             let userID = row.column("id")?.int,
             let fullName = row.column("full_name")?.string,
             let email = row.column("email")?.string,
              let role = row.column("role")?.string{
                if storedPasswordHash == hashedPassword {
                    if let userLocation = locationManager.location {
                         let latitude = userLocation.coordinate.latitude
                         let longitude = userLocation.coordinate.longitude
                         await updateUserLocation(userID: userID, latitude: latitude, longitude: longitude)
                    }
                  
                    
                  let user = User(
                    id: userID, // You'll need to return or fetch the inserted user's ID
                      fullName: fullName,
                      email: email,
                      username: username,
                      role: role
                  )
                    
              
                  AppState.shared.login(user: user)
                  // After successful login/signup
                  UserDefaults.standard.set(user.id, forKey: "currentUserID")
                  UserDefaults.standard.set(user.fullName, forKey: "currentUserFullName")
                  UserDefaults.standard.set(user.email, forKey: "currentUserEmail")
                  
                    

                    alertMessage = "✅ Login successful"
                    showAlert = true
                    clearFields()
                    return true
                } else {
                    alertMessage = "❌ Incorrect password"
                    showAlert = true
                    return false
                }
            } else {
                alertMessage = "❌ Username not found"
                showAlert = true
                return false
            }
        } catch {
            print("❌ Error during login: \(error)")
            return false
        }
    }
    
    func clearFields() {
        username = ""
        password = ""
    }
    
    var body: some View {
        NavigationStack{
            VStack{
              Image("ramcore-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 32)
              
                VStack(spacing: 14.0){
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    HStack {
                        if isPasswordVisible {
                            TextField("Password", text: $password)
                        } else {
                            SecureField("Password", text: $password)
                        }
                        Button(action: {isPasswordVisible.toggle()}) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }.padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                }
                .padding(.bottom, 22)
                Button(action: {
                    Task {
                        let isSuccess = await login(username: username, password: password)
                        await MainActor.run {
                            if isSuccess {
                                isLoginSuccessful = true
                                errorMessage = nil
                            } else {
                                isLoginSuccessful = false
                                errorMessage = "Incorrect username or password."
                            }
                        }
                    }
                }) {
                    Text("Log In")
                        .fontWeight(.heavy)
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundStyle(Color.white)
                        .background(Color(red: 90/255, green: 0/255, blue: 0/255))
                        .cornerRadius(10)
                }
                .disabled(username.isEmpty || password.isEmpty)
                
                HStack{
                    NavigationLink(destination: SignupView().navigationBarBackButtonHidden(true) ) {
                        Text("Don't have an account? Sign Up")
                            .fontWeight(.thin)
                            .foregroundColor(.black)
                            .underline()
                            
                    }
                    
                    
                    Spacer()
                    Text("Forgot Password?")
                        .fontWeight(.thin)
                        .foregroundStyle(.black)
                        .underline()
                }
                .padding(.top, 16)
                .navigationDestination(isPresented: $isLoginSuccessful) {
                        ContentView()
                            .navigationBarBackButtonHidden(true)
                }
            }
            .padding()
            .onAppear {
                locationManager.startUpdatingLocation()
            }

        }

    }
}

#Preview {
    LoginView()
    .environmentObject(AppState())
}
