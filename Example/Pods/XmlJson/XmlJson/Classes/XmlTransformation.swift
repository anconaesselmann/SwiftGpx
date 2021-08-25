//  Created by Axel Ancona Esselmann on 1/14/18.
//  Copyright © 2018 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

public struct XmlTransformation: Hashable {
    let key: String
    let map: ((Any) -> Any)
    
    public init(key: String, map: @escaping (Any) -> Any) {
        self.key = key
        self.map = map
    }
    
    public var hashValue: Int { return key.hashValue }
    
    public static func ==(lhs: XmlTransformation, rhs: XmlTransformation) -> Bool {
        return lhs.key == rhs.key
    }
}
