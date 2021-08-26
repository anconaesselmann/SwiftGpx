//  Created by Axel Ancona Esselmann on 8/24/21.
//

import Foundation

public typealias JsonDictionary = [String: Any]

public extension Dictionary where Key == String {

    subscript(json key: String) -> JsonDictionary? {
        self[key] as? JsonDictionary
    }
}
