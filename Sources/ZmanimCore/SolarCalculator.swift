// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
// Copyright (c) 2026 Jacopo Virga

import Foundation

/// Algoritmo solare NOAA (pubblico dominio), calcolo a livello del mare.
/// Verificato contro il port di KosherJava: differenze < 0,1 s sul tramonto.
public enum SolarCalculator {
    /// Tramonto standard: centro del Sole 50' sotto l'orizzonte geometrico
    /// (16' di semidiametro + 34' di rifrazione). Stessa definizione di Hebcal.
    public static let sunsetZenith = 90.8333

    public static func sunset(on date: CivilDate, at location: Location) -> Date? {
        descendingTime(on: date, latitude: location.latitude,
                       longitude: location.longitude, zenith: sunsetZenith)
    }

    /// Momento serale in cui il Sole scende a `degrees` gradi sotto l'orizzonte geometrico
    /// (senza correzione di rifrazione, come d'uso per gli zmanim in gradi).
    public static func timeOfDepression(_ degrees: Double, on date: CivilDate, at location: Location) -> Date? {
        descendingTime(on: date, latitude: location.latitude,
                       longitude: location.longitude, zenith: 90 + degrees)
    }

    /// Momento serale in cui il centro del Sole raggiunge lo zenith dato.
    /// Restituisce nil se quel giorno il Sole non ci arriva (es. latitudini alte d'estate):
    /// in quel caso NON si inventa un orario.
    public static func descendingTime(on date: CivilDate, latitude: Double,
                                      longitude: Double, zenith: Double) -> Date? {
        let jd = julianDay(date)
        var utcMinutes = 720 - 4 * longitude
        for _ in 0..<8 {
            let t = (jd + utcMinutes / 1440 - 2451545) / 36525
            let (declination, equationOfTime) = sunPosition(julianCenturies: t)
            let c = cos(rad(zenith)) / (cos(rad(latitude)) * cos(rad(declination)))
                - tan(rad(latitude)) * tan(rad(declination))
            if c < -1 || c > 1 { return nil }
            let hourAngle = deg(acos(c))
            utcMinutes = 720 - 4 * longitude - equationOfTime + 4 * hourAngle
        }
        return date.utcMidnight.addingTimeInterval(utcMinutes * 60)
    }

    // MARK: - Dettagli NOAA

    static func julianDay(_ date: CivilDate) -> Double {
        var y = Double(date.year), m = Double(date.month)
        let d = Double(date.day)
        if m <= 2 { y -= 1; m += 12 }
        let a = floor(y / 100)
        let b = 2 - a + floor(a / 4)
        return floor(365.25 * (y + 4716)) + floor(30.6001 * (m + 1)) + d + b - 1524.5
    }

    /// Restituisce declinazione (gradi) ed equazione del tempo (minuti).
    static func sunPosition(julianCenturies t: Double) -> (Double, Double) {
        let l0 = (280.46646 + t * (36000.76983 + 0.0003032 * t)).truncatingRemainder(dividingBy: 360)
        let m = 357.52911 + t * (35999.05029 - 0.0001537 * t)
        let e = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)
        let center = sin(rad(m)) * (1.914602 - t * (0.004817 + 0.000014 * t))
            + sin(rad(2 * m)) * (0.019993 - 0.000101 * t)
            + sin(rad(3 * m)) * 0.000289
        let omega = 125.04 - 1934.136 * t
        let lambda = l0 + center - 0.00569 - 0.00478 * sin(rad(omega))
        let eps0 = 23 + (26 + (21.448 - t * (46.815 + t * (0.00059 - t * 0.001813))) / 60) / 60
        let eps = eps0 + 0.00256 * cos(rad(omega))
        let declination = deg(asin(sin(rad(eps)) * sin(rad(lambda))))
        let y = pow(tan(rad(eps / 2)), 2)
        let eot = 4 * deg(y * sin(2 * rad(l0)) - 2 * e * sin(rad(m))
            + 4 * e * y * sin(rad(m)) * cos(2 * rad(l0))
            - 0.5 * y * y * sin(4 * rad(l0)) - 1.25 * e * e * sin(2 * rad(m)))
        return (declination, eot)
    }

    private static func rad(_ d: Double) -> Double { d * .pi / 180 }
    private static func deg(_ r: Double) -> Double { r * 180 / .pi }
}
