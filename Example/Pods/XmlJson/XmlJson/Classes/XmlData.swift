//  Created by Axel Ancona Esselmann on 12/23/20.
//

import Foundation

public enum XmlData {

    case none
    case string(String)
    case double(Double)
    case date(XmlDate)
    case array([XmlData])

    public var stringValue: String {
        switch self {
        case .none: return ""
        case .string(let string): return string
        case .double(let double): return "\(double)"
        case .date(let xmlDate): return xmlDate.stringValue
        case .array(let data): return data.map { $0.stringValue }.joined(separator: "")
        }
    }
}
