import Foundation
import SwiftGpx
import MapKit

print("Instantiating GPX objects:")

let locations: [CLLocation] = [
    CLLocation(lat: 38.1237270, lon: -119.4670500, alt: 2899.8, dateString: "2021-06-03T20:25:26Z"),
    CLLocation(lat: 38.1237330, lon: -119.4670490, alt: 2899.8, dateString: "2021-06-03T20:25:27Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670510, alt: 2899.8, dateString: "2021-06-03T20:25:28Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670500, alt: 2899.8, dateString: "2021-06-03T20:25:29Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670500, alt: 2899.8, dateString: "2021-06-03T20:25:30Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670510, alt: 2899.8, dateString: "2021-06-03T20:25:31Z")
].compactMap { $0 }

print()
print("With an array of CLLocation instances:")
let trackFromLocations = GPX(name: "My Track", locations: locations)
print(trackFromLocations)


let gpxString = """
<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<gpx
    xmlns="http://www.topografix.com/GPX/1/1" creator="SwiftGpx by Axel Ancona Esselmann" version="1.1"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">
    <trk>
        <name>My Track</name>
        <trkseg>
            <trkpt lat="38.123727" lon="-119.46705">
                <ele>2899.8</ele>
                <time>2021-06-03T20:25:26Z</time>
            </trkpt>
            <trkpt lat="38.123733" lon="-119.467049">
                <ele>2899.8</ele>
                <time>2021-06-03T20:25:27Z</time>
            </trkpt>
        </trkseg>
        <trkseg>
            <trkpt lat="38.123736" lon="-119.467051">
                <ele>2899.8</ele>
                <time>2021-06-03T20:25:28Z</time>
            </trkpt>
            <trkpt lat="38.123736" lon="-119.46705">
                <ele>2899.8</ele>
                <time>2021-06-03T20:25:29Z</time>
            </trkpt>
        </trkseg>
    </trk>
</gpx>
"""

print()
print("With the xml contents of a GPX file")
let trackFromGPXString = GPX(xmlString: gpxString)
print(trackFromGPXString?.locations ?? "None")

print()
print("With the name of a file that is located in the Bundle")
let fileName = "example"
let trackFromFileName = GPX(fileName: fileName, fileExtension: "gpx")
print(trackFromFileName?.locations ?? "None")

print()
print("With a local file resource")
if let localResource = Bundle.main.url(forResource: fileName, withExtension: "gpx") {
    let trackFromLocalResource = GPX(localResource: localResource)
    print(trackFromLocalResource?.locations ?? "None")
}

print("\n\n")
print("Converting a GPX instance into....")

print()
print("... a GPX string.")
let xmlString = trackFromGPXString?.xmlString
print(xmlString ?? "")

print()
print("... Data, which is encoded to be stored or transmitted as a GPX file.")
let xmlData = trackFromGPXString?.data
print(xmlData ?? "")
print(String(data: xmlData!, encoding: .utf8) ?? "")

print("\n\n")
print("Serializing/Deserializing using Codable")

"""
{
  "name" : "My Track",
  "track_segments" : [
    [
      {
        "lat" : 38.123727000000002,
        "lon" : -119.46705,
        "ele" : 2899.8000000000002,
        "date" : "2021-06-03T20:25:26Z"
      },
      {
        "lat" : 38.123733000000001,
        "lon" : -119.467049,
        "ele" : 2899.8000000000002,
        "date" : "2021-06-03T20:25:27Z"
      }
    ],
    [
      {
        "lat" : 38.123736000000001,
        "lon" : -119.46705,
        "ele" : 2899.8000000000002,
        "date" : "2021-06-03T20:25:29Z"
      },
      {
        "lat" : 38.123736000000001,
        "lon" : -119.46705,
        "ele" : 2899.8000000000002,
        "date" : "2021-06-03T20:25:30Z"
      }
    ]
  ]
}
"""

print()
print("Encoding using JSONEncoder:")
let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.outputFormatting = [.prettyPrinted]
let encoded = try encoder.encode(trackFromFileName!)
let encodedString = String(data: encoded, encoding: .utf8)!
print(encodedString)

print()
print("Decoding using JSONDecoder")
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase
let gpxFromJson = try decoder.decode(GPX.self, from: encoded)
print(gpxFromJson.locations)


print("\n\n")
print("Serializing into a dictionary that keeps the structure of the XML intact:")
let serialized = """
{
    "gpx": {
        "name": "My Track",
        "trkseg_elements": [
            [
                {
                    "lon": -119.46705,
                    "lat": 38.123727000000002,
                    "ele": 2899.8000000000002,
                    "time": "2021-06-03T13:25:26-0700"
                },
                {
                    "time": "2021-06-03T13:25:27-0700",
                    "lon": -119.467049,
                    "lat": 38.123733000000001,
                    "ele": 2899.8000000000002
                }
            ]
        ]
    }
}
"""
print(trackFromGPXString?.gpxJson ?? "")

let data = try JSONSerialization.data(withJSONObject: trackFromGPXString!.gpxJson, options: [.prettyPrinted])
print(String(data: data, encoding: .utf8) ?? "")

