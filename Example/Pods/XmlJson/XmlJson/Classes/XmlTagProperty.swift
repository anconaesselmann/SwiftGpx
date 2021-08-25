//  Created by Axel Ancona Esselmann on 12/23/20.
//

import Foundation

public struct XmlTagProperty {

    public let name: String
    public let data: XmlData

    public init(name: String, data: XmlData) {
        self.name = name
        self.data = data
    }

    public var stringValue: String {
        "\(name)=\"\(data.stringValue)\""
    }
}
