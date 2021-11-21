//
//  FileProviderCourseItem.swift
//  ItslearningFileProvider
//
//  Created by Mathias Gredal on 06/10/2021.
//

import Foundation
import FileProvider
import UniformTypeIdentifiers

class FileProviderCourseItem: NSObject, NSFileProviderItem {
    private let item: PersonCourse
    
    init(item: PersonCourse) {
        self.item = item
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        guard let itemId = item.itemId?.description else {
            return .rootContainer
        }
        
        return NSFileProviderItemIdentifier(rawValue: itemId)
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        return .rootContainer
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsReading
    }
    
    var itemVersion: NSFileProviderItemVersion {
        NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }
    
    var fileSystemFlags: NSFileProviderFileSystemFlags {
        return .userReadable
    }
    
    var filename: String {
        return item.Title
    }
    
    var contentType: UTType {
        return .folder
    }
}
