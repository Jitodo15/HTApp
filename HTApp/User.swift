//
//  User.swift
//  HTApp
//
//  Created by Joy Itodo on 3/26/25.
//


import Foundation
import SwiftUI

struct User: Codable {
    let id: Int
    let fullName: String
    let email: String
    let username: String
    let role: String
    // Add other relevant user properties
}

class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var currentUser: User?
    
    public init() {
        // Try to load user from UserDefaults on initialization
        loadUser()
    }
    
    func login(user: User) {
        currentUser = user
        saveUser()
    }
    
    func logout() {
        currentUser = nil
        clearSavedUser()
    }
    
    private func saveUser() {
        guard let user = currentUser else { return }
        
        do {
            let encodedUser = try JSONEncoder().encode(user)
            UserDefaults.standard.set(encodedUser, forKey: "currentUser")
        } catch {
            print("Error saving user: \(error)")
        }
    }
    
    private func loadUser() {
        guard let userData = UserDefaults.standard.data(forKey: "currentUser") else { return }
        
        do {
            currentUser = try JSONDecoder().decode(User.self, from: userData)
        } catch {
            print("Error loading user: \(error)")
            UserDefaults.standard.removeObject(forKey: "currentUser")
        }
    }
    
    private func clearSavedUser() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }
}
