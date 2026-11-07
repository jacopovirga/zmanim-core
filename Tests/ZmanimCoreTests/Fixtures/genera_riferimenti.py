# This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at https://mozilla.org/MPL/2.0/.
# Copyright (c) 2026 Jacopo Virga

import json, datetime as dt
from pyluach import dates as hd
from zmanim.zmanim_calendar import ZmanimCalendar
from zmanim.util.geo_location import GeoLocation
START,END=dt.date(2026,1,1),dt.date(2030,12,31)
# pyluach: 1=Nisan ... 7=Tishrei
def yt(diaspora):
    out=set()
    for y in range(5786,5792):
        days=[(7,1),(7,2),(7,10),(7,15),(7,22),(1,15),(1,21),(3,6)]
        if diaspora: days+=[(7,16),(7,23),(1,16),(1,22),(3,7)]
        for m,d in days:
            g=hd.HebrewDate(y,m,d).to_pydate()
            if START<=g<=END: out.add(g)
    return sorted(out)
ytd,yti=yt(True),yt(False)
need=set(ytd)|{d-dt.timedelta(1) for d in ytd}
d=START
while d<=END:
    if d.weekday() in (4,5): need.add(d)
    d+=dt.timedelta(1)
cities=[("Milano",45.4642,9.19,"Europe/Rome"),("Gerusalemme",31.778,35.2354,"Asia/Jerusalem"),("New York",40.7128,-74.006,"America/New_York"),("Helsinki",60.1699,24.9384,"Europe/Helsinki")]
out={"source":"Generato con la libreria Python zmanim (port di KosherJava, NOAA, livello del mare) e pyluach. Solo per i test, non distribuito.",
     "yomTov":{"diaspora":[x.isoformat() for x in ytd],"israel":[x.isoformat() for x in yti]},"cities":[]}
for n,la,lo,tz in cities:
    g=GeoLocation(n,la,lo,tz,elevation=0); days=[]
    for x in sorted(need):
        zc=ZmanimCalendar(geo_location=g,date=x)
        s=zc.sunset(); t=zc.sunset_offset_by_degrees(98.5)
        days.append({"date":x.isoformat(),"sunset":round(s.timestamp(),1),"tzeit85":round(t.timestamp(),1) if t else None})
    out["cities"].append({"name":n,"latitude":la,"longitude":lo,"timeZone":tz,"days":days})
json.dump(out,open("reference.json","w"),ensure_ascii=False,separators=(",",":"))
print(len(ytd),len(yti),len(need)); print(ytd[:8])
