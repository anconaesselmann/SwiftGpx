//  Created by Axel Ancona Esselmann on 12/23/20.
//

import Foundation

public struct XmlTag {
    public let name: String?
    public var properties: [XmlTagProperty]
    public var data: TagChild

    public enum TagChild {
        case none
        case text(XmlData)
        case tags([XmlTag])

        public var stringValue: String {
            switch self {
            case .none: return ""
            case .text(let text): return text.stringValue
            case .tags(let tags):
                return tags.map { $0.stringValue }.joined(separator: "")
            }
        }
    }

    public init(name: String?, properties: [XmlTagProperty] = [], data: TagChild = .none) {
        self.name = name
        self.properties = properties
        self.data = data
    }

    public var stringValue: String {
        var result = ""
        var propertyString = ""
        if !properties.isEmpty {
            for property in properties {
                propertyString += " \(property.stringValue)"
            }
        }
        if let name = name {
            result += "<\(name)\(propertyString)>"
        }
        result += data.stringValue
        if let name = name {
            result += "</\(name)>"
        }
        return result
    }
}

public extension Array where Element == XmlTag {
    var xmlStringValue: String {
        map { $0.stringValue }.joined(separator: "")
    }
}
