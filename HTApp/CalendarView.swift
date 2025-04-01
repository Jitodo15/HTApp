//
//  CalendarView.swift
//  HT_App
//
//  Created by Ayomide Isinkaye on 2/3/25.
//

import Foundation
import SwiftUI
import EventKit

// Date extension for weekStart
extension Date {
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
}

// View modes
enum CalendarViewMode {
    case day, week, month
}

// Week View
struct WeekView: View {
    @Binding var weekStartDate: Date
    @Binding var selectedDate: Date
    let events: [CalendarEventDetail]
    let onEventTap: (CalendarEventDetail) -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let hourHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 0) {
                // Time column spacer
                Text("")
                    .frame(width: 50)
                
                ForEach(0..<daysInWeek, id: \.self) { dayOffset in
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate) {
                        DayHeaderView(date: date, isSelected: calendar.isDate(date, inSameDayAs: selectedDate))
                            .onTapGesture {
                                selectedDate = date
                            }
                    }
                }
            }
            .padding(.top, 10)
            
            // Week grid with events
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<24) { hour in
                        WeekHourRowView(
                            hour: hour,
                            weekStartDate: weekStartDate,
                            events: events,
                            hourHeight: hourHeight,
                            onEventTap: onEventTap
                        )
                    }
                }
            }
        }
    }
}

struct DayHeaderView: View {
    let date: Date
    let isSelected: Bool
    
    var body: some View {
        VStack {
            Text(dayText)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(dateText)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var dayText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    private var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

struct WeekHourRowView: View {
    let hour: Int
    let weekStartDate: Date
    let events: [CalendarEventDetail]
    let hourHeight: CGFloat
    let onEventTap: (CalendarEventDetail) -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    
    var body: some View {
        HStack(spacing: 0, content: {
            // Hour label
            Text(timeText)
                .font(.caption)
                .frame(width: 50, alignment: .trailing)
                .padding(.trailing, 5)
            
            // Hour grid for all days
            HStack(spacing: 0) {
                ForEach(0..<daysInWeek, id: \.self) { dayOffset in
                    if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStartDate) {
                        DayHourCell(
                            date: date,
                            hour: hour,
                            events: eventsForDay(date, hour: hour),
                            hourHeight: hourHeight,
                            onEventTap: onEventTap
                        )
                    }
                }
            }
        })
        .frame(height: hourHeight)
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components)!
        return formatter.string(from: date)
    }
    
    private func eventsForDay(_ day: Date, hour: Int) -> [CalendarEventDetail] {
        return events.filter { event in
            guard calendar.isDate(event.startDate, inSameDayAs: day) else { return false }
            
            let eventHour = calendar.component(.hour, from: event.startDate)
            let eventEndHour = calendar.component(.hour, from: event.endDate)
            
            return (eventHour == hour) || (eventHour < hour && eventEndHour > hour)
        }
    }
}

struct DayHourCell: View {
    let date: Date
    let hour: Int
    let events: [CalendarEventDetail]
    let hourHeight: CGFloat
    let onEventTap: (CalendarEventDetail) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Hour cell background
            Rectangle()
                .fill(Color.gray.opacity(0.1))
                .border(Color.gray.opacity(0.3), width: 0.5)
            
            // Events in this hour
            ForEach(events) { event in
                EventView(event: event, hourHeight: hourHeight)
                    .frame(width: 80)
                    .onTapGesture {
                        onEventTap(event)
                    }
                    .offset(y: yOffset(for: event))
            }
        }
    }
    
    private func yOffset(for event: CalendarEventDetail) -> CGFloat {
        let eventMinute = calendar.component(.minute, from: event.startDate)
        return CGFloat(eventMinute) / 60.0 * hourHeight
    }
}

// Month View
struct MonthView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEventDetail]
    let onDateSelect: (Date) -> Void
    
    @State private var currentMonth: Date
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let dayWidth: CGFloat = 40
    
    init(selectedDate: Binding<Date>, events: [CalendarEventDetail], onDateSelect: @escaping (Date) -> Void) {
        self._selectedDate = selectedDate
        self.events = events
        self.onDateSelect = onDateSelect
        
        // Initialize currentMonth from selectedDate
        let components = calendar.dateComponents([.year, .month], from: selectedDate.wrappedValue)
        self._currentMonth = State(initialValue: calendar.date(from: components) ?? selectedDate.wrappedValue)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Day of week header
            HStack(spacing: 0) {
                ForEach(0..<7, id: \.self) { index in
                    Text(getDayOfWeekLetter(for: index))
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(width: dayWidth, height: 30)
                }
            }
            
            // Days grid
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        let dayEvents = eventsForDate(date)
                        
                        VStack(spacing: 2) {
                            Text("\(calendar.component(.day, from: date))")
                                .font(.callout)
                                .fontWeight(calendar.isDate(date, inSameDayAs: selectedDate) ? .bold : .regular)
                            
                            if !dayEvents.isEmpty {
                                HStack {
                                    ForEach(0..<min(dayEvents.count, 3), id: \.self) { index in
                                        Circle()
                                            .fill(dayEvents[index].color)
                                            .frame(width: 6, height: 6)
                                    }
                                    if dayEvents.count > 3 {
                                        Text("+\(dayEvents.count - 3)")
                                            .font(.system(size: 8))
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                        .frame(width: dayWidth, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? Color.blue.opacity(0.2) : Color.clear)
                        )
                        .opacity(calendar.component(.month, from: date) == calendar.component(.month, from: currentMonth) ? 1 : 0.3)
                        .onTapGesture {
                            onDateSelect(date)
                        }
                    } else {
                        // Empty cell
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: dayWidth, height: 50)
                    }
                }
            }
        }
    }
    
    private func getDayOfWeekLetter(for index: Int) -> String {
        let days = ["S", "M", "T", "W", "T", "F", "S"]
        return days[index]
    }
    
    private func daysInMonth() -> [Date?] {
        var days = [Date?]()
        
        // Find first day of month
        let components = calendar.dateComponents([.year, .month], from: currentMonth)
        guard let firstDay = calendar.date(from: components) else { return [] }
        
        // Find last day of month
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay),
              let lastDay = calendar.date(byAdding: .day, value: -1, to: nextMonth) else { return [] }
        
        // Determine weekday of first day (0 = Sunday)
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        
        // Add empty cells for days before first day of month
        for _ in 0..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in month
        let daysInMonth = calendar.component(.day, from: lastDay)
        for day in 1...daysInMonth {
            if let date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: day - 1, to: firstDay)!) {
                days.append(date)
            }
        }
        
        // Fill remaining cells to complete the grid
        let remainingCells = 42 - days.count // 6 rows of 7 days
        for _ in 0..<remainingCells {
            days.append(nil)
        }
        
        return days
    }
    
    private func eventsForDate(_ date: Date) -> [CalendarEventDetail] {
        return events.filter { calendar.isDate($0.startDate, inSameDayAs: date) }
    }
}

// Event Editor View
struct EventEditorView: View {
    let isNew: Bool
    let event: CalendarEventDetail?
    @State var title: String
    @State var startTime: Date
    @State var endTime: Date
    @State var notes: String
    @State var color: Color
    let onSave: (String, Date, Date, String, Color, Bool) -> Void
    let onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    
                    DatePicker("Start", selection: $startTime)
                    
                    DatePicker("End", selection: $endTime)
                    
                    ColorPicker("Color", selection: $color)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                if !isNew {
                    Section {
                        Button("Delete Event") {
                            onDelete()
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isNew ? "New Event" : "Edit Event")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(title, startTime, endTime, notes, color, isNew)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

// Event Detail View
struct EventDetailView: View {
    let event: CalendarEventDetail
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.gray)
                            
                            Text("\(dateFormatter.string(from: event.startDate)) - \(dateFormatter.string(from: event.endDate))")
                                .font(.subheadline)
                        }
                        
                        if !event.notes.isEmpty {
                            HStack(alignment: .top) {
                                Image(systemName: "note.text")
                                    .foregroundColor(.gray)
                                
                                Text(event.notes)
                                    .font(.body)
                            }
                            .padding(.top, 4)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .listRowBackground(event.color.opacity(0.2))
            }
            .navigationTitle("Event Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Edit", action: onEdit)
                        
                        Button("Delete", role: .destructive, action: onDelete)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

// Day view
struct DayView: View {
    @Binding var selectedDate: Date
    let events: [CalendarEventDetail]
    let onEventTap: (CalendarEventDetail) -> Void
    
    private let hourHeight: CGFloat = 60
    private let calendar = Calendar.current
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(0..<24) { hour in
                    HourRowView(
                        hour: hour,
                        events: eventsForHour(hour),
                        hourHeight: hourHeight,
                        onEventTap: onEventTap
                    )
                }
            }
        }
    }
    
    private func eventsForHour(_ hour: Int) -> [CalendarEventDetail] {
        return events.filter { event in
            let eventHour = calendar.component(.hour, from: event.startDate)
            let eventEndHour = calendar.component(.hour, from: event.endDate)
            
            // Include events that start in this hour or span across this hour
            return (eventHour == hour) ||
                   (eventHour < hour && eventEndHour > hour) ||
                   (calendar.isDate(event.startDate, inSameDayAs: selectedDate) &&
                    eventHour < hour &&
                    !calendar.isDate(event.endDate, inSameDayAs: selectedDate))
        }
    }
}

struct HourRowView: View {
    let hour: Int
    let events: [CalendarEventDetail]
    let hourHeight: CGFloat
    let onEventTap: (CalendarEventDetail) -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // Hour divider and label
            HStack(alignment: .top) {
                Text(timeText)
                    .font(.caption)
                    .frame(width: 40, alignment: .trailing)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            .padding(.top, 8)
            
            // Events
            HStack {
                Spacer().frame(width: 50)
                
                ZStack(alignment: .topLeading) {
                    ForEach(events) { event in
                        EventView(event: event, hourHeight: hourHeight)
                            .onTapGesture {
                                onEventTap(event)
                            }
                            .offset(y: yOffset(for: event))
                    }
                }
            }
        }
        .frame(height: hourHeight)
    }
    
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components)!
        return formatter.string(from: date)
    }
    
    private func yOffset(for event: CalendarEventDetail) -> CGFloat {
        let eventMinute = calendar.component(.minute, from: event.startDate)
        return CGFloat(eventMinute) / 60.0 * hourHeight
    }
}

struct EventView: View {
    let event: CalendarEventDetail
    let hourHeight: CGFloat
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if height > 40 {
                Text(timeRangeText)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: height)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(event.color.opacity(0.8))
        )
    }
    
    private var height: CGFloat {
        // Calculate height based on event duration, but limit to avoid overflowing
        let duration = event.endDate.timeIntervalSince(event.startDate)
        let durationHours = duration / 3600 // Convert seconds to hours
        let calculatedHeight = durationHours * hourHeight
        return min(calculatedHeight, hourHeight * 4) // Cap at 4 hours for display
    }
    
    private var timeRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
    }
}

struct EnhancedCalendarView: View {
    // Event store to access system calendar
    private let eventStore = EKEventStore()
    
    // States
    @State private var selectedDate: Date = Date()
    @State private var events: [CalendarEventDetail] = []
    @State private var showingEventDetail: Bool = false
    @State private var showingEventEditor: Bool = false
    @State private var selectedEvent: CalendarEventDetail?
    @State private var newEventTitle: String = ""
    @State private var newEventStartTime: Date = Date()
    @State private var newEventEndTime: Date = Date().addingTimeInterval(3600) // 1 hour later
    @State private var newEventNotes: String = ""
    @State private var newEventColor: Color = .blue
    @State private var isTyping: Bool = false
    @State private var searchText: String = ""
    @State private var calendarAccessGranted: Bool = false
    @State private var weekStartDate: Date = Date().startOfWeek()
    @State private var viewMode: CalendarViewMode = .month
    
    // Filtered events based on search or date selection
    var filteredEvents: [CalendarEventDetail] {
        if searchText.isEmpty {
            return filteredEventsByDate
        } else {
            return events.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    // Events filtered by selected date
    var filteredEventsByDate: [CalendarEventDetail] {
        switch viewMode {
        case .day:
            return events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
        case .week:
            let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate)!
            return events.filter { event in
                let eventDate = event.startDate
                return eventDate >= weekStartDate && eventDate <= endOfWeek
            }
        case .month:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.year, .month], from: selectedDate)
            let startOfMonth = calendar.date(from: components)!
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth)!
            
            return events.filter { event in
                let eventDate = event.startDate
                return eventDate >= startOfMonth && eventDate <= endOfMonth
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                HStack {
                  Text("Calendar")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.maroonDark)
                  
                  Spacer()
                }
                .padding(.horizontal)
              
                // Top bar with search and view mode
                HStack {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search events...", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    
                    // View mode picker
                    Picker("View", selection: $viewMode) {
                        Text("Day").tag(CalendarViewMode.day)
                        Text("Week").tag(CalendarViewMode.week)
                        Text("Month").tag(CalendarViewMode.month)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .frame(width: 150)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Date navigation
                HStack {
                    Button(action: previousDate) {
                        Image(systemName: "chevron.left")
                            .padding()
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(headerDateText)
                            .font(.headline)
                        
                        if viewMode == .week {
                            Text(weekRangeText)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: nextDate) {
                        Image(systemName: "chevron.right")
                            .padding()
                    }
                    
                    Button(action: { selectedDate = Date() }) {
                        Text("Today")
                            .padding(.horizontal)
                    }
                }
                .padding(.vertical, 5)
                
                
                // Calendar view based on mode
                Group {
                    switch viewMode {
                    case .day:
                        DayView(selectedDate: $selectedDate, events: filteredEventsByDate, onEventTap: selectEvent)
                    case .week:
                        WeekView(weekStartDate: $weekStartDate, selectedDate: $selectedDate, events: filteredEventsByDate, onEventTap: selectEvent)
                    case .month:
                        VStack {
                            MonthView(selectedDate: $selectedDate, events: filteredEventsByDate, onDateSelect: { date in
                                selectedDate = date
                            })
                            
                            // Daily events list below month view
                            VStack(alignment: .leading) {
                                Text("\(dayHeaderText)")
                                    .font(.headline)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                
                                Divider()
                                
                                if dailyEvents.isEmpty {
                                    Text("No events")
                                        .foregroundColor(.gray)
                                        .padding()
                                } else {
                                    List {
                                        ForEach(dailyEvents) { event in
                                            DailyEventRow(event: event)
                                                .onTapGesture {
                                                    selectEvent(event)
                                                }
                                        }
                                    }
                                    .listStyle(PlainListStyle())
                                    .frame(height: 200)
                                }
                            }
                            .background(Color(.systemBackground))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                }
                .onChange(of: viewMode) { _ in
                    // Update dates when changing view modes
                    if viewMode == .week {
                        weekStartDate = selectedDate.startOfWeek()
                    }
                }
                
                // Add Event Button
                HStack {
                    TextField("Add event title", text: $newEventTitle, onEditingChanged: { editing in
                        isTyping = editing
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading)
                    
                    ColorPicker("", selection: $newEventColor)
                        .frame(width: 30)
                        .padding(.trailing, 5)
                    
                    Button(action: quickAddEvent) {
                        Image(systemName: isTyping ? "checkmark.circle.fill" : "plus.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 10)
                .background(Color.white)
                .shadow(radius: 2)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingEventEditor) {
                EventEditorView(
                    isNew: selectedEvent == nil,
                    event: selectedEvent,
                    title: selectedEvent?.title ?? newEventTitle,
                    startTime: selectedEvent?.startDate ?? selectedDate,
                    endTime: selectedEvent?.endDate ?? selectedDate.addingTimeInterval(3600),
                    notes: selectedEvent?.notes ?? "",
                    color: selectedEvent?.color ?? newEventColor,
                    onSave: saveEvent,
                    onDelete: deleteEvent
                )
            }
            .sheet(isPresented: $showingEventDetail) {
                if let event = selectedEvent {
                    EventDetailView(
                        event: event,
                        onEdit: {
                            showingEventDetail = false
                            showingEventEditor = true
                        },
                        onDelete: {
                            deleteEvent()
                            showingEventDetail = false
                        }
                    )
                }
            }
            .onAppear {
                requestCalendarAccess()
            }
        }
    }
    
    // Events for the selected day only
    private var dailyEvents: [CalendarEventDetail] {
        events.filter { Calendar.current.isDate($0.startDate, inSameDayAs: selectedDate) }
            .sorted { $0.startDate < $1.startDate }
    }

    // Header text for the selected day
    private var dayHeaderText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: selectedDate)
    }

    // Row view for daily events
    struct DailyEventRow: View {
        let event: CalendarEventDetail
        
        var body: some View {
            HStack {
                Rectangle()
                    .fill(event.color)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                    
                    Text(timeRangeText)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        
        private var timeRangeText: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: event.endDate))"
        }
    }
    private var headerDateText: String {
        let formatter = DateFormatter()
        
        switch viewMode {
        case .day:
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
        case .week:
            formatter.dateFormat = "MMMM yyyy"
        case .month:
            formatter.dateFormat = "MMMM yyyy"
        }
        
        return formatter.string(from: selectedDate)
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let endOfWeek = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate)!
        
        return "\(formatter.string(from: weekStartDate)) - \(formatter.string(from: endOfWeek))"
    }
    
    // Navigation functions
    private func previousDate() {
        switch viewMode {
        case .day:
            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate)!
        case .week:
            weekStartDate = Calendar.current.date(byAdding: .day, value: -7, to: weekStartDate)!
            selectedDate = weekStartDate
        case .month:
            selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
        }
    }
    
//    private func nextDate() {
//        switch viewMode {
//        case .day:
//            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
//        case .week:
//            weekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: weekStartDate)!
//            selectedDate = weekStartDate
//        case .month:
//            selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate)!
//        }
//    }
    
    private func nextDate() {
        switch viewMode {
        case .day:
            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate)!
        case .week:
            weekStartDate = Calendar.current.date(byAdding: .day, value: 7, to: weekStartDate)!
            selectedDate = weekStartDate
        case .month:
            selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate)!
        }
    }
    
    // Event handling functions
    private func requestCalendarAccess() {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                calendarAccessGranted = granted
                if granted {
                    loadEvents()
                }
            }
        }
    }
    
    private func loadEvents() {
        // In a real app, you would load events from EKEventStore
        // Here we'll use sample data
        if events.isEmpty {
            let calendar = Calendar.current
            let today = Date()
            
            // Create sample events
            for i in -5...10 {
                if let date = calendar.date(byAdding: .day, value: i, to: today) {
                    // Morning event
                    let morningDate = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: date)!
                    events.append(CalendarEventDetail(
                        title: "Event \(i+6)",
                        startDate: morningDate,
                        endDate: morningDate.addingTimeInterval(3600),
                        notes: "Description for event \(i+6)",
                        color: [.blue, .green, .red, .orange, .purple].randomElement()!
                    ))
                    
                   
                    
                    // Afternoon event (some days)
                    if i % 2 == 0 {
                        let afternoonDate = calendar.date(bySettingHour: 14, minute: 30, second: 0, of: date)!
                        events.append(CalendarEventDetail(
                            title: "Meeting \(i+6)",
                            startDate: afternoonDate,
                            endDate: afternoonDate.addingTimeInterval(5400),
                            notes: "Important meeting \(i+6)",
                            color: [.blue, .green, .red, .orange, .purple].randomElement()!
                        ))
                    }
                    
                    // Evening event (some other days)
                    if i % 3 == 0 {
                        let eveningDate = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: date)!
                        events.append(CalendarEventDetail(
                            title: "Dinner \(i+6)",
                            startDate: eveningDate,
                            endDate: eveningDate.addingTimeInterval(7200),
                            notes: "Networking dinner \(i+6)",
                            color: [.blue, .green, .red, .orange, .purple].randomElement()!
                        ))
                    }
                }
                            }
                        }
                    }
                    
                    private func selectEvent(_ event: CalendarEventDetail) {
                        selectedEvent = event
                        showingEventDetail = true
                    }
                    
                    private func quickAddEvent() {
                        if !newEventTitle.isEmpty {
                            // Create a new event with current details
                            let startTime = Calendar.current.date(
                                bySettingHour: Calendar.current.component(.hour, from: selectedDate),
                                minute: Calendar.current.component(.minute, from: selectedDate),
                                second: 0,
                                of: selectedDate
                            ) ?? selectedDate
                            
                            let endTime = startTime.addingTimeInterval(3600) // 1 hour later
                            
                            events.append(CalendarEventDetail(
                                title: newEventTitle,
                                startDate: startTime,
                                endDate: endTime,
                                notes: "",
                                color: newEventColor
                            ))
                            
                            // Reset fields
                            newEventTitle = ""
                            newEventColor = .blue
                        } else {
                            // Open full editor when no title provided
                            selectedEvent = nil
                            showingEventEditor = true
                        }
                    }
                    
                    private func saveEvent(title: String, startTime: Date, endTime: Date, notes: String, color: Color, isNew: Bool) {
                        if isNew {
                            // Create new event
                            events.append(CalendarEventDetail(
                                title: title,
                                startDate: startTime,
                                endDate: endTime,
                                notes: notes,
                                color: color
                            ))
                        } else if let index = events.firstIndex(where: { $0.id == selectedEvent?.id }) {
                            // Update existing event
                            events[index] = CalendarEventDetail(
                                title: title,
                                startDate: startTime,
                                endDate: endTime,
                                notes: notes,
                                color: color
                            )
                        }
                        
                        selectedEvent = nil
                    }
                    
                    private func deleteEvent() {
                        if let index = events.firstIndex(where: { $0.id == selectedEvent?.id }) {
                            events.remove(at: index)
                            selectedEvent = nil
                        }
                    }
                }

                // Preview provider
                struct CalendarView_Previews: PreviewProvider {
                    static var previews: some View {
                        EnhancedCalendarView()
                    }
                }
