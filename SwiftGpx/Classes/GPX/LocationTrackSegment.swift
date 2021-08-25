//  Created by Axel Ancona Esselmann on 1/14/18.
//

import CoreLocation

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
