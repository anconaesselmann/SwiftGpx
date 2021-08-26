//  Created by Axel Ancona Esselmann on 8/24/21.
//

import CoreLocation
import XmlJson

public struct GPX: Codable {

    public let track: LocationTrack

    public var locations: [CLLocation] { track.locations }

    public var data: Data? { xmlString.data(using: .utf8) }

    public init(name: String? = nil, locations: [[CLLocation]]) {
        self.init(track: LocationTrack(
            name: name,
            trackSegments: locations.map { LocationTrackSegment(locations: $0) }
        ))
    }

    public init(name: String? = nil, locations: [CLLocation]) {
        self.init(name: name, locations: [locations])
    }

    public init(track: LocationTrack) {
        self.track = track
    }

    public init?(gpxJson: JsonDictionary) {
        guard
            let gpxDict = gpxJson[json: Keys.gpx],
            let trackJson = gpxDict[json: Keys.trk],
            let track = LocationTrack(gpxJson: trackJson)
        else { return nil }
        self.init(track: track)
    }

    public init?(fileName: String, fileExtension: String? = nil) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension ?? Keys.fileExtension) else { return nil}
        self.init(localResource: url)
    }

    public init?(localResource url: URL) {
        guard let xmlData = try? Data(contentsOf: url) else { return nil }
        self.init(xmlData: xmlData)
    }

    public init?(xmlString: String) {
        guard let xmlData = xmlString.data(using: .utf8) else { return nil }
        self.init(xmlData: xmlData)
    }

    @discardableResult
    public func saveToFile(_ fileName: String) -> NSURL? {
        guard let data = data else {
            return nil
        }
        return data.dataToFile(fileName: fileName)
    }

    // MARK: Codable

    enum CodingKeys: CodingKey {
        case name, trackSegments
    }

    private struct LocationData: Codable {
        let lon: Double, lat: Double, ele: Double, date: Date

        var asCLLocation: CLLocation {
            CLLocation(lat: lon, lon: lon, alt: ele, date: date)
        }

        init(_ clLocation: CLLocation) {
            lat = clLocation.coordinate.latitude
            lon = clLocation.coordinate.longitude
            ele = clLocation.altitude
            date = clLocation.timestamp
        }
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let segments = try values.decode([[LocationData]].self, forKey: .trackSegments)
        let name = try values.decode(String.self, forKey: .name)

        let locations = segments.map { $0.map { $0.asCLLocation } }
        self.init(name: name, locations: locations)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let trackSegments = track.trackSegments.map { $0.locations.map { LocationData($0) } }
        try container.encode(trackSegments, forKey: .trackSegments)
        try container.encode(track.name, forKey: .name)
    }

    // MARK: - Date conversion

    private static let timestampFormat: String = "yyyy-MM-dd'T'HH:mm:ssZ"

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = timestampFormat
        return dateFormatter
    }()

    public static func toISO8601Timestamp(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    public static func fromISO8601Timestamp(_ timestamp: String) -> Date? {
        dateFormatter.date(from: timestamp)
    }
}

