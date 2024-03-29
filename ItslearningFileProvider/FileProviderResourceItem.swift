//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  FileProviderResourceItem.swift
//  ItslearningFileProvider

import Foundation
import FileProvider
import UniformTypeIdentifiers


// TODO: implement an initializer to create an item from your extension's backing model
// TODO: implement the accessors to return the values from your extension's backing model
class FileProviderResourceItem: NSObject, NSFileProviderItem {
    public let item: CourseResource
    
    init(item: CourseResource) {
        self.item = item
    }
    
    var itemIdentifier: NSFileProviderItemIdentifier {
        guard let itemId = item.itemId?.description else {
            return .rootContainer
        }
        
        return NSFileProviderItemIdentifier(rawValue: itemId)
    }
    
    var parentItemIdentifier: NSFileProviderItemIdentifier {
        do {
            guard let parentId = try item.itemId?.getContainingFolder() else {
                return .rootContainer
            }
            
            return NSFileProviderItemIdentifier(rawValue: parentId.description)

        } catch {
            return .rootContainer
        }
    }
    
    var capabilities: NSFileProviderItemCapabilities {
        return .allowsReading
    }
    
    var itemVersion: NSFileProviderItemVersion {
       NSFileProviderItemVersion(contentVersion: "a content version".data(using: .utf8)!, metadataVersion: "a metadata version".data(using: .utf8)!)
    }
    
    var filename: String {
        return item.Title + (ItslearningAPI.IsWebpage(resource: item) ? ".url" : "")
    }
    
    var contentType: UTType {
        return item.ElementType == .Folder ? .folder : .item
    }
    
    var documentSize: NSNumber? {
        return 10
    }
}
