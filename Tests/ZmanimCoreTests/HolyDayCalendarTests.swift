// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import XCTest
@testable import ZmanimCore

final class HolyDayCalendarTests: XCTestCase {
    func testYomTovDatesMatchReference() throws {
        let ref = try Reference.load()
        for diaspora in [true, false] {
            let expected = ref.yomTovSet(diaspora: diaspora)
            let cal = HolyDayCalendar(diaspora: diaspora)
            var day = rangeStart
            while day <= rangeEnd {
                XCTAssertEqual(cal.isYomTov(day), expected.contains(day),
                               "\(day) diaspora=\(diaspora)")
                day = day.adding(days: 1)
            }
        }
    }

    func testKnownDates() {
        let d = HolyDayCalendar(diaspora: true)
        XCTAssertTrue(d.isYomTov(CivilDate(year: 2026, month: 9, day: 12)))   // Rosh haShanà 5787
        XCTAssertTrue(d.isYomTov(CivilDate(year: 2026, month: 4, day: 2)))    // 1° giorno di Pesach
        XCTAssertTrue(d.isYomTov(CivilDate(year: 2026, month: 4, day: 3)))    // 2° giorno (diaspora)
        XCTAssertFalse(HolyDayCalendar(diaspora: false).isYomTov(CivilDate(year: 2026, month: 4, day: 3)))
    }
}
