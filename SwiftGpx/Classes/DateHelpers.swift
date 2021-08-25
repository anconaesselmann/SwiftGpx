//  Created by Axel Ancona Esselmann on 1/14/18.
//

import Foundation

struct ISODateFormatter {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter
    }()

    static func date(from isoISO8601String: String) -> Date? {
        Self.dateFormatter.date(from: isoISO8601String)
    }

    static func string(from date: Date) -> String {
        Self.dateFormatter.string(from: date)
    }
}

extension String {
    var iso8601Date: Date? {
        ISODateFormatter.date(from: self)
    }
}

extension Date {
    var iso8601DateString: String {
        ISODateFormatter.string(from: self)
    }
}
