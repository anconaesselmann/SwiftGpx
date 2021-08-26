//  Created by Axel Ancona Esselmann on 1/14/18.
//

import CoreLocation

public extension CLLocationCoordinate2D {
    init?(gpxJson: JsonDictionary) {
        guard
            let lat = gpxJson[Keys.lat] as? CLLocationDegrees,
            let lon = gpxJson[Keys.lon] as? CLLocationDegrees
        else { return nil }
        self.init(latitude: lat, longitude: lon)
    }
}

public extension CLLocation {
    convenience init?(gpxJson: JsonDictionary) {
        guard
            let coordinate = CLLocationCoordinate2D(gpxJson: gpxJson),
            let altitude = gpxJson[Keys.ele] as? CLLocationDistance,
            let timeString = gpxJson[Keys.time] as? String,
            let timestamp = GPX.fromISO8601Timestamp(timeString)
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
    convenience init?(lat: Double, lon: Double, alt: Double, timestamp: String) {
        guard let date = GPX.fromISO8601Timestamp(timestamp) else  {
            return nil
        }
        let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.init(coordinate: coord, altitude: alt, horizontalAccuracy: kCLLocationAccuracyBest, verticalAccuracy: kCLLocationAccuracyBest, timestamp: date)
    }
}

public extension CLLocationCoordinate2D {
    var gpxJson: JsonDictionary {
        return [
            Keys.lat: latitude,
            Keys.lon: longitude
        ]
    }
}

public extension CLLocation {
    var gpxJson: JsonDictionary {
        var result = coordinate.gpxJson
        result[Keys.ele] = altitude
        result[Keys.time] = GPX.toISO8601Timestamp(timestamp)
        return result
    }
}

public extension Array where Element == CLLocation {
    var gpxJson: [JsonDictionary] {
        map { $0.gpxJson }
    }
}
