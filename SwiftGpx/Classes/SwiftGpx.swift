//  Created by Axel Ancona Esselmann on 1/14/18.
//  Copyright © 2018 Axel Ancona Esselmann. All rights reserved.
//

import CoreLocation
import XmlJson
import AFDateHelper

fileprivate struct Keys {
    static let lat = "lat"
    static let lon = "lon"
    static let ele = "ele"
    static let time = "time"
    
    static let trkptElements = "trkpt_elements"
    
    static let trksegElements = "trkseg_elements"
    static let name = "name"
    
    static let trk = "trk"
    static let gpx = "gpx"
    
    static let trkseg = "trkseg"
    static let trkpt = "trkpt"
    
    static let fileExtension = "gpx"

    static let xmlns = "xmlns"
    static let creator = "creator"
    static let version = "version"
    static let xmlns_xsi = "xmlns:xsi"
    static let xsi_schemaLocation = "xsi:schemaLocation"
}

public extension CLLocationCoordinate2D {
    init?(gpxJson: [String: Any]) {
        guard
            let lat = gpxJson[Keys.lat] as? CLLocationDegrees,
            let lon = gpxJson[Keys.lon] as? CLLocationDegrees
        else { return nil }
        self.init(latitude: lat, longitude: lon)
    }
}

public extension CLLocation {
    convenience init?(gpxJson: [String: Any]) {
        guard
            let coordinate = CLLocationCoordinate2D(gpxJson: gpxJson),
            let altitude = gpxJson[Keys.ele] as? CLLocationDistance,
            let timeString = gpxJson[Keys.time] as? String,
            let timestamp = Date(fromString: timeString, format: .isoDateTimeSec, timeZone: .utc)
        else { return nil }
        self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
    }
}

public struct LocationTrackSegment {
    
    public var locations: [CLLocation]
    
    public init(locations: [CLLocation] = []) {
        self.locations = locations
    }
    
    public init?(gpxJson: [String: Any]) {
        guard let trkptElements = gpxJson[Keys.trkptElements] as? [[String: Any]] else { return nil }
        self.init(locations: trkptElements.compactMap(CLLocation.init(gpxJson:)))
    }
}

public struct LocationTrack {
    
    public var trackSegments: [LocationTrackSegment]
    public let name: String
    public let timestamp: Date
    
    public var locations: [CLLocation] {
        return trackSegments.flatMap { $0.locations }
    }
    
    public init(name: String, timestamp: Date, trackSegments: [LocationTrackSegment] = []) {
        self.name = name
        self.timestamp = timestamp
        self.trackSegments = trackSegments
    }
    
    public init?(gpxJson: [String: Any]) {
        guard
            let trksegElements = gpxJson[Keys.trksegElements] as? [[String: Any]],
            let name = gpxJson[Keys.name] as? String,
            let timeString = gpxJson[Keys.time] as? String,
            let timestamp = Date(fromString: timeString, format: .isoDateTimeSec, timeZone: .utc)
        else { return nil }
        self.init(name: name, timestamp: timestamp, trackSegments: trksegElements.compactMap(LocationTrackSegment.init(gpxJson:)))
    }
}

public struct SwiftGpx {
    
    public let track: LocationTrack
    
    public var locations: [CLLocation] {
        return track.locations
    }
    
    public init(track: LocationTrack) {
        self.track = track
    }
    
    public init?(gpxJson: [String: Any]) {
        guard
            let gpxDict = gpxJson[Keys.gpx] as? [String: Any],
            let trackJson = gpxDict[Keys.trk] as? [String: Any],
            let track = LocationTrack(gpxJson: trackJson)
        else { return nil }
        self.init(track: track)
    }
    
    public init?(fileName: String) {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: Keys.fileExtension),
            let xmlData = try? Data(contentsOf: url)
            else { return nil }
        self.init(xmlData: xmlData)
    }
    
    public init?(xmlString: String) {
        guard let xmlData = xmlString.data(using: .utf8) else { return nil }
        self.init(xmlData: xmlData)
    }
    
    public init?(xmlData: Data) {
        let toDouble: (Any) -> Any = { maybeString in
            guard
                let string = maybeString as? String,
                let double = Double(string)
                else { return 0 }
            return double
        }
        guard let xmlDict = XmlJson(
            xmlData: xmlData,
            mappings: Set([
                .holdsArray(key: Keys.trkseg, elementNames: Keys.trkpt),
                .holdsArray(key: Keys.trk, elementNames: Keys.trkseg),
                .isTextNode(key: Keys.ele),
                .isTextNode(key: Keys.time),
                .isTextNode(key: Keys.name)
            ]),
            transformations: Set<XmlTransformation>([
                XmlTransformation(key: Keys.ele, map: toDouble),
                XmlTransformation(key: Keys.lon, map: toDouble),
                XmlTransformation(key: Keys.lat, map: toDouble)
            ])
        ) else { return nil}
        self.init(gpxJson: xmlDict.dictionary!)
    }
}

public extension CLLocationCoordinate2D {
    var gpxJson: [String: Any] {
        return [
            Keys.lat: latitude,
            Keys.lon: longitude
        ]
    }
}

public extension CLLocation {
    var gpxJson: [String: Any] {
        var result = coordinate.gpxJson
        result[Keys.ele] = altitude
        result[Keys.time] = timestamp.toString(format: .isoDateTimeSec, timeZone: .utc)
        return result
    }
}

public extension Array where Element == CLLocation {
    var gpxJson: [[String: Any]] {
        map { $0.gpxJson }
    }
}

public extension LocationTrackSegment {
    var gpxJson: [[String: Any]] {
        return locations.gpxJson
    }
}

public extension LocationTrack {
    var gpxJson: [String: Any] {
        return [
            Keys.name: name,
            Keys.trksegElements: trackSegments.map { $0.gpxJson }
        ]
    }
}

public extension SwiftGpx {
    var gpxJson: [String: Any] {
        return [
            Keys.gpx: track.gpxJson
        ]
    }
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

public extension SwiftGpx {

    init(name: String, locations: [CLLocation]) {
        self.init(name: name, locations: [locations])
    }

    init(name: String, locations: [[CLLocation]]) {
        self.init(
            track: LocationTrack(
                name: name,
                timestamp: locations.first?.first?.timestamp ?? Date(),
                trackSegments: locations.map { LocationTrackSegment(locations: $0) }
            )
        )
    }

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

    var data: Data? { xmlString.data(using: .utf8) }

    func saveToFile(_ fileName: String) -> NSURL? {
        guard let data = data else {
            return nil
        }
        return data.dataToFile(fileName: fileName)
    }
}

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}

extension Data {
    func dataToFile(fileName: String) -> NSURL? {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try write(to: URL(fileURLWithPath: filePath))
            return NSURL(fileURLWithPath: filePath)
        } catch {
            return nil
        }
    }
}
