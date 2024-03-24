//
//  User.swift
//  SmartWaste
//
//  Created by Yegor Myropoltsev on 04.12.2023.
//

import Foundation

struct User: Codable, Equatable {
    let id: Int
    let email: String
    let username: String
    let score: Int
    let buckets: Int
    let createdAt: String

    var days: Int { return daysGone(from: dateFromISOString(createdAt)) + 1 }
    var level: Int { return (score / 500) + 1 }
    var completedScore: Int { return score % 500 }

    private func dateFromISOString(_ dateString: String) -> Date {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds, .withTimeZone]

        return dateFormatter.date(from: dateString) ?? Date()
    }

    private func daysGone(from day: Date) -> Int {
        let calendar = Calendar.current
        let currentDate = Date()

        let components = calendar.dateComponents([.day], from: day, to: currentDate)

        return components.day ?? 0
    }
}
