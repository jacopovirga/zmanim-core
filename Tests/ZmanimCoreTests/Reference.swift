// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation
import XCTest
@testable import ZmanimCore

/// Dati di riferimento indipendenti (zmanim per Python, port KosherJava + pyluach).
/// Vedi Fixtures/genera_riferimenti.py.
struct Reference: Decodable {
    struct Day: Decodable {
        let date: String
        let sunset: Double
        let tzeit85: Double?
    }
    struct City: Decodable {
        let name: String
        let latitude: Double
        let longitude: Double
        let timeZone: String
        let days: [Day]

        var location: Location {
            Location(name: name, latitude: latitude, longitude: longitude,
                     timeZone: TimeZone(identifier: timeZone)!)
        }
        var byDate: [CivilDate: Day] {
            Dictionary(uniqueKeysWithValues: days.map { (CivilDate(iso: $0.date)!, $0) })
        }
    }
    let yomTov: [String: [String]]
    let cities: [City]

    static func load() throws -> Reference {
        let url = try XCTUnwrap(Bundle.module.url(forResource: "reference", withExtension: "json"),
                                "reference.json mancante nel bundle dei test")
        return try JSONDecoder().decode(Reference.self, from: Data(contentsOf: url))
    }

    func yomTovSet(diaspora: Bool) -> Set<CivilDate> {
        Set((yomTov[diaspora ? "diaspora" : "israel"] ?? []).compactMap(CivilDate.init(iso:)))
    }
}

let rangeStart = CivilDate(year: 2026, month: 1, day: 1)
let rangeEnd = CivilDate(year: 2030, month: 12, day: 31)
