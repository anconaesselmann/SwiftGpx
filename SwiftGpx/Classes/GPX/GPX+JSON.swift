//  Created by Axel Ancona Esselmann on 8/24/21.
//

import Foundation

public extension LocationTrackSegment {
    var gpxJson: [JsonDictionary] {
        return locations.gpxJson
    }
}

public extension LocationTrack {
    var gpxJson: JsonDictionary {
        return [
            Keys.name: name,
            Keys.trksegElements: trackSegments.map { $0.gpxJson }
        ]
    }
}

public extension GPX {
    var gpxJson: JsonDictionary {
        return [
            Keys.gpx: track.gpxJson
        ]
    }
}
