// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation

/// Un periodo continuo di Shabbat e/o Yom Tov (es. venerdì sera → sabato sera,
/// oppure Shabbat seguito da due giorni di Yom Tov: un solo periodo, una sola uscita).
public struct HolyPeriod: Sendable, Equatable {
    public let firstDay: CivilDate
    public let lastDay: CivilDate
    public let includesYomTov: Bool
    /// Accensione delle candele alla vigilia, arrotondata per DIFETTO al minuto.
    /// nil se il tramonto non è calcolabile.
    public let candleLighting: Date?
    /// Uscita da mostrare, arrotondata per ECCESSO al minuto.
    /// nil = non calcolabile in modo affidabile: l'app non mostra nulla e lo dice.
    public let havdalah: Date?
    /// Istante della notifica di uscita: havdalah + margine. nil se havdalah è nil.
    public let havdalahNotification: Date?
}

public struct ShabbatScheduler: Sendable {
    public let location: Location
    public let parameters: HalachicParameters
    public let holyDays: HolyDayCalendar

    public init(location: Location, parameters: HalachicParameters) {
        self.location = location
        self.parameters = parameters
        self.holyDays = HolyDayCalendar(diaspora: parameters.diaspora)
    }

    /// Periodi che INIZIANO tra `start` e `end` inclusi (possono finire dopo `end`).
    public func periods(from start: CivilDate, through end: CivilDate) -> [HolyPeriod] {
        var result: [HolyPeriod] = []
        var day = start
        while day <= end {
            if holyDays.isHolyDay(day) && !holyDays.isHolyDay(day.adding(days: -1)) {
                var last = day
                var hasYomTov = holyDays.isYomTov(day)
                while holyDays.isHolyDay(last.adding(days: 1)) {
                    last = last.adding(days: 1)
                    hasYomTov = hasYomTov || holyDays.isYomTov(last)
                }
                result.append(makePeriod(first: day, last: last, includesYomTov: hasYomTov))
                day = last.adding(days: 1)
            } else {
                day = day.adding(days: 1)
            }
        }
        return result
    }

    /// Il prossimo periodo la cui uscita non è ancora passata rispetto a `now`.
    public func nextPeriod(after now: Date) -> HolyPeriod? {
        let today = CivilDate.from(now, in: location.timeZone)
        return periods(from: today.adding(days: -3), through: today.adding(days: 10))
            .first { p in (p.havdalah ?? .distantFuture) > now }
    }

    func makePeriod(first: CivilDate, last: CivilDate, includesYomTov: Bool) -> HolyPeriod {
        let candles = SolarCalculator.sunset(on: first.adding(days: -1), at: location)
            .map { floorToMinute($0.addingTimeInterval(-Double(parameters.candleLightingMinutes) * 60)) }

        let havdalah = havdalahTime(on: last).map(ceilToMinute)
        let notification = havdalah?.addingTimeInterval(Double(parameters.notificationSafetyMarginMinutes) * 60)

        return HolyPeriod(firstDay: first, lastDay: last, includesYomTov: includesYomTov,
                          candleLighting: candles, havdalah: havdalah,
                          havdalahNotification: notification)
    }

    /// Uscita esatta (non arrotondata): il più tardi tra i due criteri.
    func havdalahTime(on day: CivilDate) -> Date? {
        guard let sunset = SolarCalculator.sunset(on: day, at: location) else { return nil }
        let byMinutes = sunset.addingTimeInterval(Double(parameters.havdalahMinutesAfterSunset) * 60)
        guard let degrees = parameters.havdalahMinimumDepression else { return byMinutes }
        guard let byDegrees = SolarCalculator.timeOfDepression(degrees, on: day, at: location) else {
            return nil  // il Sole non scende abbastanza: meglio nessun orario che uno sbagliato
        }
        return max(byMinutes, byDegrees)
    }
}

func floorToMinute(_ d: Date) -> Date {
    Date(timeIntervalSince1970: (d.timeIntervalSince1970 / 60).rounded(.down) * 60)
}

func ceilToMinute(_ d: Date) -> Date {
    Date(timeIntervalSince1970: (d.timeIntervalSince1970 / 60).rounded(.up) * 60)
}
