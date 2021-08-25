//  Created by Axel Ancona Esselmann on 1/14/18.
//  Copyright © 2018 Axel Ancona Esselmann. All rights reserved.
//

import Foundation

public class XmlJson: NSObject {
    
    public var dictionary: [String: Any]? {
        return stack.first?.data as? [String: Any]
    }
    
    public var jsonString: String? {
        guard
            let dict = dictionary,
            let data = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
            let str = String(data: data, encoding: .utf8)
            else { return nil }
        return str
    }
    
    fileprivate var stack: [XmlFrame] = []
    
    fileprivate let mappings: Set<XmlMapping>
    
    fileprivate let transformations: Set<XmlTransformation>
    
    public convenience init?(fileName: String, mappings: Set<XmlMapping> = Set(), transformations: Set<XmlTransformation> = Set()) {
        guard
            let url = Bundle.main.url(forResource: fileName, withExtension: "gpx"),
            let xmlData = try? Data(contentsOf: url)
            else { return nil }
        self.init(xmlData: xmlData, mappings: mappings, transformations: transformations)
    }
    
    public convenience init?(xmlString: String, mappings: Set<XmlMapping> = Set(), transformations: Set<XmlTransformation> = Set()) {
        guard let xmlData = xmlString.data(using: .utf8) else { return nil }
        self.init(xmlData: xmlData, mappings: mappings, transformations: transformations)
    }
    
    public required init?(xmlData: Data, mappings: Set<XmlMapping> = Set(), transformations: Set<XmlTransformation> = Set()) {
        self.mappings = mappings
        self.transformations = transformations
        super.init()
        
        let frame = XmlFrame(key: "trunk", data: [:])
        stack.append(frame)
        let parser = XMLParser(data: xmlData)
        parser.delegate = self;
        parser.parse()
    }
}

extension XmlJson: XMLParserDelegate {
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let lastIndex = stack.count - 1
        let frame: XmlFrame
        let arrayMapping = XmlMapping.holdsArray(key: stack[lastIndex].key, elementNames: elementName)
        let textNodeMapping = XmlMapping.isTextNode(key: elementName)
        var mapped: [String:Any] = [:]
        for (key, value) in attributeDict {
            let mappdedValue: Any
            if let transformation = transformations.first(where: {$0.key == key}) {
                mappdedValue = transformation.map(value)
            } else {
                mappdedValue = value
            }
            mapped[key] = mappdedValue
        }
        let data = !mapped.isEmpty ? mapped : [:]
        if mappings.contains(arrayMapping) {
            frame = XmlFrame(key: elementName, data: data, mapping: arrayMapping)
        } else if mappings.contains(textNodeMapping) {
            frame = XmlFrame(key: elementName, data: data, mapping: textNodeMapping)
        } else {
            frame = XmlFrame(key: elementName, data: data)
        }
        stack.append(frame)
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        let lastIndex = stack.count - 1
        guard let arrayMapping = stack[lastIndex].mapping else {
            return
        }
        if case XmlMapping.isTextNode(key:_) = arrayMapping {
            var text = stack[lastIndex].data as? String ?? ""
            text += string
            stack[lastIndex].data = text
        }
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard var frame = stack.popLast() else { return }
        let lastIndex = stack.count - 1
        
        if let transformation = transformations.first(where: {$0.key == elementName}) {
            frame.data = transformation.map(frame.data)
        }
        
        if let arrayMapping = frame.mapping {
            switch arrayMapping {
            case .holdsArray(key:_, elementNames: let elementNames):
                let arrayKey = "\(elementNames)_elements"
                if var dict = stack[lastIndex].data as? [String: Any] {
                    var array: [Any] = dict[arrayKey] as? [Any] ?? []
                    array.append(frame.data)
                    dict[arrayKey] = array
                    stack[lastIndex].data = dict
                    return
                } else {
                    assertionFailure("")
                }
            default: ()
            }
        }
        if var dict = stack[lastIndex].data as? [String: Any] {
            dict[frame.key] = frame.data
            stack[lastIndex].data = dict
        } else {
            assertionFailure("")
        }
    }
    
}
