// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import XCTest
@testable import ZmanimCore

/// TEST BLOCCANTI. Se uno solo fallisce, l'app non va pubblicata.
/// I parametri qui sono valori di prova, NON quelli della comunità.
final class SafetyTests: XCTestCase {
    func params(depression: Double?, diaspora: Bool = true) -> HalachicParameters {
        HalachicParameters(candleLightingMinutes: 18, havdalahMinutesAfterSunset: 50,
                           havdalahMinimumDepression: depression,
                           notificationSafetyMarginMinutes: 2, diaspora: diaspora,
                           source: "valori di prova")
    }

    /// L'uscita mostrata e la notifica non sono MAI prima dell'uscita di riferimento,
    /// e le candele non sono mai dopo l'orario di riferimento.
    func testNeverEarlyOverFiveYears() throws {
        let ref = try Reference.load()
        for city in ref.cities {
            let days = city.byDate
            for diaspora in [true, false] {
                for depression in [nil, 8.5] as [Double?] {
                    let s = ShabbatScheduler(location: city.location,
                                             parameters: params(depression: depression, diaspora: diaspora))
                    for p in s.periods(from: rangeStart, through: rangeEnd.adding(days: -7)) {
                        let tag = "\(city.name) \(p.lastDay) diaspora=\(diaspora) gradi=\(String(describing: depression))"

                        // Candele
                        let eve = try XCTUnwrap(days[p.firstDay.adding(days: -1)], "manca riferimento vigilia \(tag)")
                        let refCandles = eve.sunset - 18 * 60
                        let candles = try XCTUnwrap(p.candleLighting, tag).timeIntervalSince1970
                        XCTAssertLessThanOrEqual(candles, refCandles + 2, "candele DOPO il riferimento: \(tag)")
                        XCTAssertGreaterThan(candles, refCandles - 62, "candele troppo anticipate: \(tag)")

                        // Uscita
                        let end = try XCTUnwrap(days[p.lastDay], "manca riferimento uscita \(tag)")
                        var refHavdalah = end.sunset + 50 * 60
                        if depression != nil {
                            guard let t = end.tzeit85 else {
                                XCTAssertNil(p.havdalah, "orario inventato senza tzeit: \(tag)")
                                XCTAssertNil(p.havdalahNotification, tag)
                                continue
                            }
                            refHavdalah = max(refHavdalah, t)
                        }
                        let h = try XCTUnwrap(p.havdalah, tag).timeIntervalSince1970
                        let n = try XCTUnwrap(p.havdalahNotification, tag).timeIntervalSince1970
                        XCTAssertGreaterThanOrEqual(h, refHavdalah - 1, "USCITA IN ANTICIPO: \(tag)")
                        XCTAssertLessThan(h, refHavdalah + 75, "uscita troppo ritardata: \(tag)")
                        XCTAssertGreaterThanOrEqual(n, h + 120, "margine notifica mancante: \(tag)")
                    }
                }
            }
        }
    }

    /// Nessun periodo finisce la sera prima di uno Yom Tov o di uno Shabbat.
    func testNoHavdalahBeforeAnotherHolyDay() throws {
        let ref = try Reference.load()
        let city = ref.cities[0]
        for diaspora in [true, false] {
            let yt = ref.yomTovSet(diaspora: diaspora)
            let s = ShabbatScheduler(location: city.location, parameters: params(depression: nil, diaspora: diaspora))
            for p in s.periods(from: rangeStart, through: rangeEnd.adding(days: -7)) {
                let next = p.lastDay.adding(days: 1)
                XCTAssertFalse(yt.contains(next) || next.isSaturday, "uscita a \(p.lastDay) ma il giorno dopo è festivo")
            }
        }
    }

    /// Shavuot 5789 cade domenica 20/5/2029: in diaspora sabato→lunedì è un solo periodo.
    func testShabbatFollowedByShavuot() {
        let milano = Location(name: "Milano", latitude: 45.4642, longitude: 9.19,
                              timeZone: TimeZone(identifier: "Europe/Rome")!)
        let s = ShabbatScheduler(location: milano, parameters: params(depression: nil))
        let p = s.periods(from: CivilDate(year: 2029, month: 5, day: 14),
                          through: CivilDate(year: 2029, month: 5, day: 25))
        XCTAssertEqual(p.count, 2)
        XCTAssertEqual(p[0].firstDay, CivilDate(year: 2029, month: 5, day: 19))
        XCTAssertEqual(p[0].lastDay, CivilDate(year: 2029, month: 5, day: 21))
        XCTAssertTrue(p[0].includesYomTov)
    }

    /// Helsinki a giugno: il Sole non scende a 8,5°. Con il criterio in gradi niente orario.
    func testHighLatitudeGivesNoTimeInsteadOfWrongTime() {
        let helsinki = Location(name: "Helsinki", latitude: 60.1699, longitude: 24.9384,
                                timeZone: TimeZone(identifier: "Europe/Helsinki")!)
        let day = CivilDate(year: 2026, month: 6, day: 13)
        let withDegrees = ShabbatScheduler(location: helsinki, parameters: params(depression: 8.5))
            .periods(from: day, through: day)
        XCTAssertEqual(withDegrees.count, 1)
        XCTAssertNil(withDegrees[0].havdalah)
        XCTAssertNil(withDegrees[0].havdalahNotification)

        let minutesOnly = ShabbatScheduler(location: helsinki, parameters: params(depression: nil))
            .periods(from: day, through: day)
        XCTAssertNotNil(minutesOnly[0].havdalah)
    }

    func testRoundingToWholeMinutes() {
        let milano = Location(name: "Milano", latitude: 45.4642, longitude: 9.19,
                              timeZone: TimeZone(identifier: "Europe/Rome")!)
        let s = ShabbatScheduler(location: milano, parameters: params(depression: nil))
        for p in s.periods(from: rangeStart, through: CivilDate(year: 2026, month: 12, day: 31)) {
            XCTAssertEqual(p.candleLighting!.timeIntervalSince1970.truncatingRemainder(dividingBy: 60), 0)
            XCTAssertEqual(p.havdalah!.timeIntervalSince1970.truncatingRemainder(dividingBy: 60), 0)
        }
    }
}
