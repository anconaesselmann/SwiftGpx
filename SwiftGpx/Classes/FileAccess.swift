//  Created by Axel Ancona Esselmann on 8/24/21.
//

import Foundation

func getDocumentsDirectory() -> NSString {
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    return documentsDirectory as NSString
}

extension Data {
    func dataToFile(fileName: String) -> NSURL? {
        let filePath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            try write(to: URL(fileURLWithPath: filePath))
            return NSURL(fileURLWithPath: filePath)
        } catch {
            return nil
        }
    }
}
