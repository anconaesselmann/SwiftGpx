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
}

public extension CLLocationCoordinate2D {
    public init?(gpxJson: [String: Any]) {
        guard
            let lat = gpxJson[Keys.lat] as? CLLocationDegrees,
            let lon = gpxJson[Keys.lon] as? CLLocationDegrees
        else { return nil }
        self.init(latitude: lat, longitude: lon)
    }
}

public extension CLLocation {
    public convenience init?(gpxJson: [String: Any]) {
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
        self.init(locations: trkptElements.flatMap(CLLocation.init(gpxJson:)))
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
        self.init(name: name, timestamp: timestamp, trackSegments: trksegElements.flatMap(LocationTrackSegment.init(gpxJson:)))
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
