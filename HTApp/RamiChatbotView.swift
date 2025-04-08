//
//  RamiChatbotView.swift
//  HTApp
//
//  Created by Joy Itodo on 3/27/25.
//
import SwiftUI
import Foundation
import GoogleGenerativeAI

class AcademicAdvisorChatbot {
    private let geminiApiKey: String
    private let advisorData: [String: Any]
    private let model: GenerativeModel
    
    init?(jsonData: Data, apiKey: String) {
      // Add detailed error logging
              do {
                  // Try parsing JSON with more detailed error handling
                  guard let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] else {
                      print("❌ ERROR: Failed to parse JSON - Invalid JSON structure")
                      print("JSON Data (first 500 chars): \(String(data: jsonData, encoding: .utf8)?.prefix(500) ?? "Unable to convert")")
                      return nil
                  }
                  
                  // Optional: Add validation for expected keys
                  guard jsonObject["advisor_information"] != nil else {
                      print("❌ ERROR: JSON missing 'advisor_information' key")
                      return nil
                  }
                  
                  self.geminiApiKey = apiKey
                  self.advisorData = jsonObject
                  
                  // Initialize Gemini model
                  self.model = GenerativeModel(
                    name: "gemini-2.0-flash", 
                      apiKey: apiKey
                  )
                  
              } catch {
                  print("❌ JSON Parsing Error: \(error.localizedDescription)")
                  return nil
              }
    }
    
    // Prepare comprehensive context from JSON
    private func prepareKnowledgeBaseContext() -> String {
        var context = "Academic Advising Information:\n\n"
        
        // Add departments and their advisors
        if let departments = (advisorData["advisor_information"] as? [String: Any])?["departments"] as? [String: Any] {
            context += "Department Advisors:\n"
            for (department, advisorInfo) in departments {
                context += "- \(department): "
                
                // Handle single advisor
                if let singleAdvisor = advisorInfo as? [String: String] {
                    context += "\(singleAdvisor["advisor"] ?? "N/A"), "
                    context += "Office: \(singleAdvisor["office"] ?? "N/A"), "
                    context += "Email: \(singleAdvisor["email"] ?? "N/A")\n"
                }
                
                // Handle multiple advisors
                if let multipleAdvisors = advisorInfo as? [String: [[String: String]]] {
                    if let advisors = multipleAdvisors["advisors"] {
                        context += advisors.map { advisor in
                            "\(advisor["name"] ?? "N/A"), Office: \(advisor["office"] ?? "N/A")"
                        }.joined(separator: "; ")
                        context += "\n"
                    }
                }
            }
        }
        
        // Add freshman advising information
        if let freshmanAdvising = (advisorData["advisor_information"] as? [String: Any])?["freshman_advising"] as? [String: [String: String]] {
            context += "\nFreshman Advising:\n"
            for (lastNameGroup, advisorInfo) in freshmanAdvising {
                context += "- \(lastNameGroup): Advisor \(advisorInfo["advisor"] ?? "N/A"), "
                context += "Booking: \(advisorInfo["booking_link"] ?? "N/A"), "
                context += "Office: \(advisorInfo["office"] ?? "N/A")\n"
            }
        }
        
        return context
    }
    
    // Generate response using Gemini with contextual knowledge base
    func generateResponse(message: String) async throws -> String {
        let knowledgeBaseContext = prepareKnowledgeBaseContext()
        
        let prompt = """
        You are an academic advising chatbot. Use the following context to provide accurate and helpful responses:

        \(knowledgeBaseContext)

        Context Guidelines:
        - Provide specific, actionable information
        - Reference exact advisor names, offices, and contact details when possible
        - If the query is unclear, ask for more specific information
        - Stay professional and helpful

        User Query: \(message)

        Response:
        """
        
        do {
            let response = try await model.generateContent(prompt)
            return response.text ?? "I couldn't generate a response."
        } catch {
            print("Error generating response: \(error)")
            return "I'm sorry, but I encountered an error processing your request."
        }
    }
}

// Updated ChatbotOverlay to use Gemini integration
struct ChatbotOverlay: View {
    let maroonColor: Color
    let goldColor: Color
    @Binding var isShowing: Bool
    
    // Message state
    @State private var messageText: String = ""
    @State private var messages: [ChatMessage] = [
        ChatMessage(content: "Hello! I'm RAMmy, your academic advising assistant. How can I help you today?", isUser: false)
    ]
    
    // Chatbot instance
    @State private var chatbot: AcademicAdvisorChatbot?
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
                
                VStack(spacing: 0) {
                    // Header (remains the same)
                    HStack {
                        // Ram icon
                        ZStack {
                            Circle()
                            .fill(Color.maroonDark)
                                .frame(width: 40, height: 40)
                            
                            Text("🐏")
                                .font(.system(size: 24))
                        }
                        
                        Text("RAMmy Advisor")
                            .font(.headline)
                            .foregroundColor(maroonColor)
                        
                        Spacer()
                        
                        // Close Button
                        Button(action: {
                            isShowing = false
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    
                    Divider()
                    
                    // Chat messages
                    ScrollView {
                        ScrollViewReader { proxy in
                            VStack(spacing: 12) {
                                ForEach(messages) { message in
                                    ChatBubble(message: message, maroonColor: maroonColor, goldColor: goldColor)
                                }
                                .onChange(of: messages.count) { _ in
                                    // Scroll to bottom when new messages arrive
                                    if let lastMessage = messages.last {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }
                    }
                    
                    Divider()
                    
                    // Input field
                    HStack {
                        TextField("Ask about academic advisors", text: $messageText)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(20)
                        
                        Button(action: sendMessage) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(goldColor)
                                .padding(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }
        }
        .frame(width: 320, height: 450)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .onAppear {
            // Initialize chatbot when view appears
            initializeChatbot()
        }
    }
    
    // Initialize chatbot with JSON data and API key
    private func initializeChatbot() {
        guard let jsonData = loadJSONData(from: "data"),
              let apiKey = getGeminiAPIKey() else {
            print("Failed to initialize chatbot")
            return
        }
        
        chatbot = AcademicAdvisorChatbot(jsonData: jsonData, apiKey: apiKey)
    }
    
    // Function to send a message
    func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: messageText, isUser: true)
        messages.append(userMessage)
        
        // Clear input field
        let currentMessage = messageText
        messageText = ""
        
        // Generate response using Gemini
        Task {
            do {
                if let response = try await chatbot?.generateResponse(message: currentMessage) {
                    await MainActor.run {
                        messages.append(ChatMessage(content: response, isUser: false))
                    }
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatMessage(content: "Sorry, I couldn't process your request.", isUser: false))
                }
            }
        }
    }
    
    // Helper method to load JSON
    func loadJSONData(from filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("JSON file not found")
            return nil
        }
        
        do {
            return try Data(contentsOf: url)
        } catch {
            print("Error loading JSON file: \(error)")
            return nil
        }
    }
    
    // Securely retrieve API key (replace with your preferred method)
    func getGeminiAPIKey() -> String? {
        // Implement secure API key retrieval
        // e.g., from environment, keychain, configuration file
        return ProcessInfo.processInfo.environment["MAP_API_KEY"]!
    }
}


// Modified RAMi Chatbot View
struct RamiChatbotView: View {
    let maroonColor: Color
    let goldColor: Color
    @Binding var showChatbot: Bool
    
    var body: some View {
        Button(action: {
            // Toggle the chatbot overlay
            showChatbot = true
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                .stroke(Color.maroonDark.opacity(0.2), lineWidth: 1)
                .fill(Color.maroonLight)
                .shadow(color: Color.maroonDark.opacity(0.3), radius: 5, x: 0, y: 2)
                
                HStack {
                    // Ram icon or mascot
                    ZStack {
                        Circle()
                        .fill(Color.maroonDark)
                            .frame(width: 50, height: 50)
                        
                        Text("🐏")
                            .font(.system(size: 30))
                    }
                    .padding(.leading, 5)
                    
                    // Text content
                    VStack(alignment: .leading) {
                        Text("Talk to RAMmy")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("Your academic advising assistant")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    // Arrow indicator
                    Image(systemName: "chevron.right")
                    .foregroundColor(Color.maroonDark)
                        .padding(.trailing)
                }
                .padding(.vertical, 15)
            }
            .frame(height: 80)
        }
    }
}

extension RamiChatbotView {
    func debugLoadJSONData(from filename: String) -> Data? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ ERROR: JSON file '\(filename).json' not found in app bundle")
            // List all available resources for debugging
            let resourcePaths = Bundle.main.paths(forResourcesOfType: "json", inDirectory: nil)
            print("Available JSON resources: \(resourcePaths)")
            return nil
        }
        
        do {
            let jsonData = try Data(contentsOf: url)
            // Optional: Print first 500 characters of JSON for inspection
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("JSON Content (first 500 chars): \(jsonString.prefix(500))")
            }
            return jsonData
        } catch {
            print("❌ ERROR loading JSON file: \(error.localizedDescription)")
            return nil
        }
    }
}



// Chat Bubble View
struct ChatBubble: View {
    let message: ChatMessage
    let maroonColor: Color
    let goldColor: Color
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            Text(message.content)
                .padding(12)
                .background(message.isUser ? Color.goldDark : Color.maroonDark)
                .foregroundColor(.white)
                .cornerRadius(16)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
}

// Chat Message Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp = Date()
}
