//
//  FileProviderCourseItem.swift
//  ItslearningFileProvider
//
//  Created by Mathias Gredal on 06/10/2021.
//

import Foundation
import FileProvider
import UniformTypeIdentifiers


// TODO: implement an initializer to create an item from your extension's backing model
// TODO: implement the accessors to return the values from your extension's backing model
class FileProviderCourseItem: NSObject, NSFileProviderItem {
    private let identifier: NSFileProviderItemIdentifier
    private let title: String

    
    init(item: PersonCourse) {
        self.identifier = NSFileProviderItemIdentifier(rawValue: "hello")
        self.title = "hello"
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        return identifier
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
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
