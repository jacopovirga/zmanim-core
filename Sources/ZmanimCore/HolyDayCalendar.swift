// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation

/// Giorni di Yom Tov (melakhà vietata), dal calendario ebraico di Foundation.
///
/// Numerazione dei mesi in Foundation/ICU (costante, anche negli anni non embolismici,
/// dove il mese 6 Adar I viene saltato): 1 Tishrì … 7 Adar, 8 Nisan, 9 Iyar, 10 Sivan.
/// L'assunzione è verificata dai test contro pyluach: se fallissero, NON pubblicare.
public struct HolyDayCalendar: Sendable {
    public let diaspora: Bool

    public init(diaspora: Bool) {
        self.diaspora = diaspora
    }

    static let hebrew: Calendar = {
        var c = Calendar(identifier: .hebrew)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    public func isYomTov(_ date: CivilDate) -> Bool {
        let c = Self.hebrew.dateComponents([.month, .day], from: date.utcNoon)
        guard let month = c.month, let day = c.day else { return false }
        switch month {
        case 1:  // Tishrì: Rosh haShanà, Kippur, Sukkot, Sheminì Atzèret (+ secondi giorni in diaspora)
            return [1, 2, 10, 15, 22].contains(day) || (diaspora && [16, 23].contains(day))
        case 8:  // Nisan: Pesach primi e ultimi giorni
            return [15, 21].contains(day) || (diaspora && [16, 22].contains(day))
        case 10: // Sivan: Shavuot
            return day == 6 || (diaspora && day == 7)
        default:
            return false
        }
    }

    /// Shabbat o Yom Tov.
    public func isHolyDay(_ date: CivilDate) -> Bool {
        date.isSaturday || isYomTov(date)
    }
}
