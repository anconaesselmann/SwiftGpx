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

    public init(name: String, timestamp: Date, trackSegments: [LocationTrackSegment] = []) {
        self.name = name
        self.timestamp = timestamp
        self.trackSegments = trackSegments
    }

    public init(name: String, trackSegments: [LocationTrackSegment] = []) {
        self.name = name
        self.timestamp = trackSegments.first?.locations.first?.timestamp ?? Date()
        self.trackSegments = trackSegments
    }

    public init?(gpxJson: [String: Any]) {
        guard
            let trksegElements = gpxJson[Keys.trksegElements] as? [[String: Any]],
            let name = gpxJson[Keys.name] as? String
        else { return nil }
        if
            let timeString = gpxJson[Keys.time] as? String,
            let timestamp = timeString.iso8601Date
        {
            self.init(name: name, timestamp: timestamp, trackSegments: trksegElements.compactMap(LocationTrackSegment.init(gpxJson:)))
        } else {
            self.init(name: name, trackSegments: trksegElements.compactMap(LocationTrackSegment.init(gpxJson:)))
        }

    }
}
