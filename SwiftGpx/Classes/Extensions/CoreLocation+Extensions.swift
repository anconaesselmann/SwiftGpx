//  Created by Axel Ancona Esselmann on 1/14/18.
//

import CoreLocation

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
            let timestamp = timeString.iso8601Date
        else { return nil }
        self.init(coordinate: coordinate, altitude: altitude, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: timestamp)
    }
}

public extension CLLocation {
    convenience init(lat: Double, lon: Double, alt: Double, date: Date) {
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.init(coordinate: coord, altitude: alt, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: date)
    }
}

public extension CLLocation {
    convenience init?(lat: Double, lon: Double, alt: Double, dateString: String) {
        guard let date = dateString.iso8601Date else  {
            return nil
        }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.init(coordinate: coord, altitude: alt, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: date)
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
        result[Keys.time] = timestamp.iso8601DateString
        return result
    }
}

public extension Array where Element == CLLocation {
    var gpxJson: [[String: Any]] {
        map { $0.gpxJson }
    }
}
