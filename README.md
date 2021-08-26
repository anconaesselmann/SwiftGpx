# SwiftGpx

[![CI Status](http://img.shields.io/travis/anconaesselmann/SwiftGpx.svg?style=flat)](https://travis-ci.org/anconaesselmann/SwiftGpx)
[![Version](https://img.shields.io/cocoapods/v/SwiftGpx.svg?style=flat)](http://cocoapods.org/pods/SwiftGpx)
[![License](https://img.shields.io/cocoapods/l/SwiftGpx.svg?style=flat)](http://cocoapods.org/pods/SwiftGpx)
[![Platform](https://img.shields.io/cocoapods/p/SwiftGpx.svg?style=flat)](http://cocoapods.org/pods/SwiftGpx)

SwiftGpx is a library for parsing and writing [GPX](https://www.topografix.com/gpx.asp) data.

## Example

To run the example playground clone the repo, run `pod install` in the `Example` directory and open the `Example.xcworkspace` workspace. The `Example` playground (first element in the Project Navigator) contains all the examples from below.


Import `SwiftGpx`
```swift
import SwiftGpx
```
some examples below reqire you to import
```swift
import CoreLocation
```

### Instantiating [GPX](https://www.topografix.com/gpx.asp) objects...

...with an `Array` of `CLLocation` instances:
```swift
let locations: [CLLocation] = [
    CLLocation(lat: 38.1237270, lon: -119.4670500, alt: 2899.8, timestamp: "2021-06-03T20:25:26Z"),
    CLLocation(lat: 38.1237330, lon: -119.4670490, alt: 2899.8, timestamp: "2021-06-03T20:25:27Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670510, alt: 2899.8, timestamp: "2021-06-03T20:25:28Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670500, alt: 2899.8, timestamp: "2021-06-03T20:25:29Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670500, alt: 2899.8, timestamp: "2021-06-03T20:25:30Z"),
    CLLocation(lat: 38.1237360, lon: -119.4670510, alt: 2899.8, timestamp: "2021-06-03T20:25:31Z")
].compactMap { $0 }

let gpx = GPX(name: "My Track", locations: locations)
```

...with the xml contents of a GPX file
```swift
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

let gpx = GPX(xmlString: gpxString)
```

...with the name of a file that is located in the `Bundle`
```swift
let gpx = GPX(fileName: "example", fileExtension: "gpx")
```

...with a local file resource
```swift
if let localResource = Bundle.main.url(forResource: "example", withExtension: "gpx") {
    let gpx = GPX(localResource: localResource)
    ...
}
```

### Converting `GPX` content to...

...a GPX `String`
```swift
let gpx = GPX(name: "My Track", locations: locations)
let xmlString = gpx.xmlString
```

... `Data`, which is encoded to be stored or transmitted as a GPX file
```swift
let gpx = GPX(name: "My Track", locations: locations)
let xmlData = gpx.data
```

### Serializing/Deserializing using Codabl

the `JSONEncoder` settings below will produce output like the following:
```json
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
```

Encoding using JSONEncoder
```swift
let gpx = GPX(name: "My Track", locations: locations)

let encoder = JSONEncoder()
encoder.dateEncodingStrategy = .iso8601
encoder.keyEncodingStrategy = .convertToSnakeCase
encoder.outputFormatting = [.prettyPrinted]
let encoded = try encoder.encode(gpx)
let encodedString = String(data: encoded, encoding: .utf8)
```

Decoding using JSONDecoder
```swift
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .iso8601
decoder.keyDecodingStrategy = .convertFromSnakeCase
// uses the encoded data from the previous example
let gpxFromJson = try decoder.decode(GPX.self, from: encoded) 
```

## Serializing into a dictionary that keeps the structure of the XML intact

the `gpxJson` propperty will produce a dictionary that can be serialized to look like the following:
```json
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
```

```swift
let gpx = GPX(name: "My Track", locations: locations)
let dictionary: [String: Any] = gpx.gpxJson
```

You can get a JSON string using
```swift
let gpx = GPX(name: "My Track", locations: locations)
let data = try JSONSerialization.data(withJSONObject: gpx.gpxJson, options: [.prettyPrinted])
let jsonString = String(data: data, encoding: .utf8)
```

## Installation

SwiftGpx is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftGpx'
```

## Author

anconaesselmann, axel@anconaesselmann.com

## License

SwiftGpx is available under the MIT license. See the LICENSE file for more info.
