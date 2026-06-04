import Foundation

public struct ReminderScheduleService: Sendable {
    public init() {}

    public func nextGentleReminder(after date: Date, calendar: Calendar = .current) -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) ?? date.addingTimeInterval(86_400)
        var components = calendar.dateComponents([.year, .month, .day], from: tomorrow)
        components.hour = 20
        components.minute = 0
        return calendar.date(from: components) ?? tomorrow
    }
}