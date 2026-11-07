// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation

public struct Location: Sendable, Equatable {
    public let name: String
    /// Gradi decimali, nord positivo.
    public let latitude: Double
    /// Gradi decimali, est positivo.
    public let longitude: Double
    public let timeZone: TimeZone

    public init(name: String, latitude: Double, longitude: Double, timeZone: TimeZone) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.timeZone = timeZone
    }
}
