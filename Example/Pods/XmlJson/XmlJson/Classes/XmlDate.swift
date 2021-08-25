//  Created by Axel Ancona Esselmann on 12/23/20.
//

import Foundation

public struct XmlDate {
    public let date: Date
    public let formatString: String
    public let isUtc: Bool

    public init(date: Date, formatString: String, isUtc: Bool = true) {
        self.date = date
        self.formatString = formatString
        self.isUtc = isUtc
    }

    var stringValue: String {
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        formatter.timeZone = isUtc ? TimeZone(secondsFromGMT: 0)! : NSTimeZone.local
        formatter.isLenient = true
        return formatter.string(from: date)
    }
}
