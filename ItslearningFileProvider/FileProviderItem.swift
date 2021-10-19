//
//  FileProviderItem.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import FileProvider
import UniformTypeIdentifiers


// TODO: implement an initializer to create an item from your extension's backing model
// TODO: implement the accessors to return the values from your extension's backing model
class FileProviderItem: NSObject, NSFileProviderItem {
    private let identifier: NSFileProviderItemIdentifier
    private let parent: NSFileProviderItemIdentifier
    private let title: String

    
    init(identifier: NSFileProviderItemIdentifier, title: String? = nil) {
        self.identifier = identifier
        self.parent = .rootContainer
        self.title = title ?? identifier.rawValue
    }
    
    init(identifier: NSFileProviderItemIdentifier, parent: NSFileProviderItemIdentifier, title: String? = nil) {
        self.identifier = identifier
        self.title = title ?? identifier.rawValue
        self.parent = parent
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        return identifier
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return parent
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsAll
    }
    
    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }
    
    var filename: String {
        return self.title
    }
    
    var contentType: UTType {
        return .folder
        //return identifier == NSFileProviderItemIdentifier.rootContainer ? .folder : .plainText
    }
}
