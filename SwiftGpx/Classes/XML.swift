//  Created by Axel Ancona Esselmann on 8/24/21.
//

import CoreLocation
import XmlJson
import Foundation

extension String {
    static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    static let schemaDocumentationUrl = "http://www.topografix.com/GPX/1/1"
    static let schemaUri = "/gpx.xsd"
    static let schemaNamespace = "http://www.w3.org/2001/XMLSchema-instance"
    static let creator = "SwiftGpx by Axel Ancona Esselmann"
    static let xmlProlog = #"<?xml version="1.0" encoding="UTF-8" standalone="no" ?>"#
}

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
                                        formatString: .dateFormat
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

    init?(xmlData: Data) {
        guard let xmlDict = XmlJson(
            xmlData: xmlData,
            mappings:[
                .array(Keys.trkseg, element: Keys.trkpt),
                .array(Keys.trk, element: Keys.trkseg),
                .textNode(Keys.ele),
                .textNode(Keys.time),
                .textNode(Keys.name)
            ],
            transformations: [
                .double(Keys.ele),
                .double(Keys.lon),
                .double(Keys.lat)
            ]
        ) else { return nil}
        self.init(gpxJson: xmlDict.dictionary!)
    }
    
    var xmlTag: XmlTag {
        XmlTag(name: Keys.gpx, properties: [
            XmlTagProperty(
                name: Keys.xmlns,
                data: .string(.schemaDocumentationUrl)
            ),
            XmlTagProperty(
                name: Keys.creator,
                data: .string(.creator)
            ),
            XmlTagProperty(
                name: Keys.version,
                data: .double(1.1)
            ),
            XmlTagProperty(
                name: Keys.xmlns_xsi,
                data: .string(.schemaNamespace)
            ),
            XmlTagProperty(
                name: Keys.xsi_schemaLocation,
                data: .string(.schemaDocumentationUrl + " " + .schemaDocumentationUrl + .schemaUri)
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
        .xmlProlog + xmlTag.stringValue
    }

    var gpxString: String {
        xmlString
    }
}
