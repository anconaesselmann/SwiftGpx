//  Created by Axel Ancona Esselmann on 1/14/18.
//

import CoreLocation

public struct LocationTrack {

    public var trackSegments: [LocationTrackSegment]
    public let name: String
    public let timestamp: Date

    public var locations: [CLLocation] {
        return trackSegments.flatMap { $0.locations }
    }

    public init(name: String? = nil, timestamp: Date? = nil, trackSegments: [LocationTrackSegment] = []) {
        let timestamp = timestamp ?? trackSegments.last.flatMap({ $0.locations })?.first?.timestamp
        if let trackName = name {
            self.name = trackName
        } else {
            if let timestamp = timestamp {
                self.name = "Track from \(GPX.toISO8601Timestamp(timestamp))"
            } else {
                self.name = "Untitled Track"
            }
        }
        self.timestamp = timestamp ?? Date()
        self.trackSegments = trackSegments
    }

    public init?(gpxJson: JsonDictionary) {
        guard
            let trksegElements = gpxJson[Keys.trksegElements] as? [JsonDictionary],
            let name = gpxJson[Keys.name] as? String
        else { return nil }
        if
            let timeString = gpxJson[Keys.time] as? String,
            let timestamp = GPX.fromISO8601Timestamp(timeString)
        {
            self.init(name: name, timestamp: timestamp, trackSegments: trksegElements.compactMap(LocationTrackSegment.init(gpxJson:)))
        } else {
            self.init(name: name, trackSegments: trksegElements.compactMap(LocationTrackSegment.init(gpxJson:)))
        }

    }
}
