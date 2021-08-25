//  Created by Axel Ancona Esselmann on 8/24/21.
//

import CoreLocation
import XmlJson

public extension CLLocation {
    var xmlTag: XmlTag {
        XmlTag(
            name: Keys.trkpt,
            properties: [
                XmlTagProperty(name: Keys.lat, data: .double(coordinate.latitude)),
                XmlTagProperty(name: Keys.lon, data: .double(coordinate.longitude))
            ],
            data: .tags([
                XmlTag(
                    name: Keys.ele,
                    data: .text(.double(altitude))
                ),
                XmlTag(
                    name: Keys.time,
                    data: .text(
                        .array(
                            [
                                .date(
                                    XmlDate(
                                        date: timestamp,
                                        formatString: "yyyy-MM-dd'T'HH:mm:ss"
                                    )
                                ),
                                .string("Z")
                            ]
                        )
                    )
                )
            ])
        )
    }
}

public extension LocationTrackSegment {
    var xmlTag: XmlTag {
        XmlTag(
            name: Keys.trkseg,
            data: .tags(
                locations.map { $0.xmlTag }
            )
        )
    }
}

public extension LocationTrack {
    var xmlTag: XmlTag {
        XmlTag(
            name: Keys.trk,
            data: .tags([
                XmlTag(name: Keys.name, data: .text(.string(name))),
                XmlTag(name: nil, data: .tags(trackSegments.map { $0.xmlTag }))
            ])
        )
    }
}

public extension GPX {
    var xmlTag: XmlTag {
        XmlTag(name: Keys.gpx, properties: [
            XmlTagProperty(
                name: Keys.xmlns,
                data: .string("http://www.topografix.com/GPX/1/1")
            ),
            XmlTagProperty(
                name: Keys.creator,
                data: .string("SwiftGpx by Axel Ancona Esselmann")
            ),
            XmlTagProperty(
                name: Keys.version,
                data: .double(1.1)
            ),
            XmlTagProperty(
                name: Keys.xmlns_xsi,
                data: .string("http://www.w3.org/2001/XMLSchema-instance")
            ),
            XmlTagProperty(
                name: Keys.xsi_schemaLocation,
                data: .string("http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd")
            )
        ], data:
            .tags(
                [
                    track.xmlTag
                ]
            )
        )
    }

    var xmlString: String {
        "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\" ?>" + xmlTag.stringValue
    }
}
