// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation

/// Parametri halakhici. Nessun valore di default di proposito:
/// li stabilisce il rabbino della comunità, e `source` dice chi e quando.
public struct HalachicParameters: Sendable, Equatable {
    /// Minuti prima del tramonto per l'accensione delle candele.
    public var candleLightingMinutes: Int
    /// Minuti fissi dopo il tramonto per l'uscita (criterio della comunità).
    public var havdalahMinutesAfterSunset: Int
    /// Se impostato, l'uscita non è mai prima del Sole a questi gradi sotto l'orizzonte.
    /// Se quel giorno il Sole non li raggiunge, l'uscita NON viene calcolata (nil).
    public var havdalahMinimumDepression: Double?
    /// Minuti aggiunti all'orario di uscita mostrato, solo per la notifica.
    public var notificationSafetyMarginMinutes: Int
    /// Secondo giorno di Yom Tov.
    public var diaspora: Bool
    /// Chi ha approvato questi valori e quando (mostrato nell'app).
    public var source: String

    public init(candleLightingMinutes: Int,
                havdalahMinutesAfterSunset: Int,
                havdalahMinimumDepression: Double?,
                notificationSafetyMarginMinutes: Int,
                diaspora: Bool,
                source: String) {
        self.candleLightingMinutes = candleLightingMinutes
        self.havdalahMinutesAfterSunset = havdalahMinutesAfterSunset
        self.havdalahMinimumDepression = havdalahMinimumDepression
        self.notificationSafetyMarginMinutes = notificationSafetyMarginMinutes
        self.diaspora = diaspora
        self.source = source
    }
}
