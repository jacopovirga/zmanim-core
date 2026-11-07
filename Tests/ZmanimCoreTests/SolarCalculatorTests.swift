// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import XCTest
@testable import ZmanimCore

final class SolarCalculatorTests: XCTestCase {
    func testSunsetMatchesReference() throws {
        let ref = try Reference.load()
        for city in ref.cities {
            for day in city.days {
                let date = try XCTUnwrap(CivilDate(iso: day.date))
                let s = try XCTUnwrap(SolarCalculator.sunset(on: date, at: city.location),
                                      "\(city.name) \(day.date): tramonto mancante")
                XCTAssertEqual(s.timeIntervalSince1970, day.sunset, accuracy: 2,
                               "\(city.name) \(day.date): tramonto diverso dal riferimento")
            }
        }
    }

    func testDepression8_5MatchesReference() throws {
        let ref = try Reference.load()
        for city in ref.cities {
            for day in city.days {
                let date = try XCTUnwrap(CivilDate(iso: day.date))
                let t = SolarCalculator.timeOfDepression(8.5, on: date, at: city.location)
                switch (t, day.tzeit85) {
                case (nil, nil):
                    continue
                case let (t?, r?):
                    // vicino al limite (Helsinki d'estate) i modelli divergono di qualche secondo
                    XCTAssertEqual(t.timeIntervalSince1970, r, accuracy: 15, "\(city.name) \(day.date)")
                default:
                    XCTFail("\(city.name) \(day.date): esistenza di tzeit 8,5° diversa dal riferimento")
                }
            }
        }
    }
}
