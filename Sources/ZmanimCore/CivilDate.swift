// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation

/// Una data del calendario civile (giorno, mese, anno), senza orario.
/// Per Shabbat e Yom Tov indica il giorno "di luce": il sabato è il sabato.
public struct CivilDate: Hashable, Comparable, Sendable, CustomStringConvertible {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    /// Accetta "AAAA-MM-GG".
    public init?(iso: String) {
        let p = iso.split(separator: "-").compactMap { Int($0) }
        guard p.count == 3 else { return nil }
        self.init(year: p[0], month: p[1], day: p[2])
    }

    /// La data civile in cui cade `date` nel fuso orario indicato.
    public static func from(_ date: Date, in timeZone: TimeZone) -> CivilDate {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return CivilDate(year: c.year!, month: c.month!, day: c.day!)
    }

    static let utcCalendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    /// Mezzanotte UTC di questa data (base per i calcoli astronomici).
    var utcMidnight: Date {
        Self.utcCalendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    /// Mezzogiorno UTC: usato per leggere la data ebraica del giorno di luce.
    var utcNoon: Date { utcMidnight.addingTimeInterval(12 * 3600) }

    public func adding(days n: Int) -> CivilDate {
        let d = Self.utcCalendar.date(byAdding: .day, value: n, to: utcMidnight)!
        let c = Self.utcCalendar.dateComponents([.year, .month, .day], from: d)
        return CivilDate(year: c.year!, month: c.month!, day: c.day!)
    }

    /// 1 = domenica … 7 = sabato (convenzione Foundation).
    public var weekday: Int { Self.utcCalendar.component(.weekday, from: utcMidnight) }

    public var isSaturday: Bool { weekday == 7 }

    public static func < (a: CivilDate, b: CivilDate) -> Bool {
        (a.year, a.month, a.day) < (b.year, b.month, b.day)
    }

    public var description: String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }
}
