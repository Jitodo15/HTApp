//
//  AcademicEvent.swift
//  HT_App
//
//  Created by Ayomide Isinkaye on 3/28/25.
//

import Foundation

struct AcademicEvent: Codable, Identifiable {
    let id = UUID()
    let title: String
    let date: Date
    let description: String
}

func loadAcademicEvents() -> [AcademicEvent] {
    guard let url = Bundle.main.url(forResource: "calendar", withExtension: "json"),
          let data = try? Data(contentsOf: url) else {
        return []
    }
    
//    let decoder = JSONDecoder()
//    decoder.dateDecodingStrategy = .iso8601
//    return (try? decoder.decode([AcademicEvent].self, from: data)) ?? []
    
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    decoder.dateDecodingStrategy = .formatted(formatter)
    return (try? decoder.decode([AcademicEvent].self, from: data)) ?? []
}


extension AcademicEvent {
    func toCalendarEventDetail() -> CalendarEventDetail {
        let defaultDuration: TimeInterval = 3600 // 1 hour default duration
        return CalendarEventDetail(
            title: self.title,
            startDate: self.date,
            endDate: self.date.addingTimeInterval(defaultDuration),
            notes: self.description,    // or use a different property name if needed
            color: .blue                // default color, customize as desired
        )
    }
}
