# ZmanimCore

Motore di calcolo per orari di Shabbat e Yom Tov: accensione delle candele e uscita (Havdalah).
Calcolo locale, senza rete, senza dipendenze esterne, senza licenze di terzi.

## Principi (non negoziabili)

1. I parametri halakhici li stabilisce il rabbino. `HalachicParameters` non ha valori di default; `source` dice chi li ha approvati e quando.
2. Nel dubbio, la scelta più rigorosa: candele arrotondate per difetto, uscita per eccesso, margine aggiuntivo sulla notifica.
3. Meglio nessun orario che un orario sbagliato: se il calcolo non è affidabile, il risultato è `nil`.
4. Shabbat e Yom Tov consecutivi formano un solo periodo, con una sola uscita.
5. I test di `SafetyTests` sono bloccanti: se uno fallisce, non si pubblica.

## Uso

```swift
let milano = Location(name: "Milano", latitude: 45.4642, longitude: 9.19,
                      timeZone: TimeZone(identifier: "Europe/Rome")!)
let params = HalachicParameters(candleLightingMinutes: /* rabbino */,
                                havdalahMinutesAfterSunset: /* rabbino */,
                                havdalahMinimumDepression: nil,   // solo minuti fissi
                                notificationSafetyMarginMinutes: 2,
                                diaspora: true,
                                source: "Rav …, approvato il …")
let next = ShabbatScheduler(location: milano, parameters: params).nextPeriod(after: Date())
```

## Test

Richiede Xcode (o almeno i Command Line Tools) su macOS 13+:

```bash
cd ZmanimCore
swift test
```

I dati di riferimento (`Tests/ZmanimCoreTests/Fixtures/reference.json`) sono generati con
librerie indipendenti (port Python di KosherJava e pyluach), usate solo nei test e mai distribuite:

```bash
pip install zmanim pyluach
python3 Tests/ZmanimCoreTests/Fixtures/genera_riferimenti.py
```

Coprono 2026–2030 per Milano, Gerusalemme, New York e Helsinki (latitudine alta, d'estate senza tzeit a 8,5°).

## Licenza

Mozilla Public License 2.0 — vedi `LICENSE`.
