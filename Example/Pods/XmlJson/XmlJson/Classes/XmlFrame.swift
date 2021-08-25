//  Created by Axel Ancona Esselmann on 1/14/18.
//  Copyright © 2018 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

public struct XmlFrame {
    public let key: String
    public var data: Any
    public let mapping: XmlMapping?
    
    public init(key: String, data: Any, mapping: XmlMapping? = nil) {
        self.key = key
        self.data = data
        self.mapping = mapping
    }
}
