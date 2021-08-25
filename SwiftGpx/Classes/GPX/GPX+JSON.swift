//  Created by Axel Ancona Esselmann on 8/24/21.
//

import Foundation

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

public extension GPX {
    var gpxJson: [String: Any] {
        return [
            Keys.gpx: track.gpxJson
        ]
    }
}
