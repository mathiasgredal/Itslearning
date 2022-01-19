//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  FileProviderExtension.swift
//  Itslearning

import FileProvider
import OAuth2
import Foundation
import Alamofire


class FileProviderExtension: NSObject, NSFileProviderReplicatedExtension {
    public let domain: NSFileProviderDomain
    public var manager: NSFileProviderManager
    public var authHandler: AuthHandler
    
    required public init(domain: NSFileProviderDomain) {
        Logging.Log(message: "Initializing File Provider", source: .FileProvider)
        NetworkLogger.shared.startLogging()
        self.domain = domain
        self.manager = NSFileProviderManager(for: domain)!
        self.authHandler = AuthHandler()
        super.init()
    }
    
    // TODO: cleanup any resources
    func invalidate() {
    }
    
    // Resolve item from identifier
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        Logging.Log(message: "Resolving item from identifier: \(identifier.rawValue)", source: .FileProvider)
        
        // Handle som built-in identifiers
        if(identifier == .rootContainer || identifier == .trashContainer || identifier == .workingSet) {
            completionHandler(FileProviderItem(identifier: identifier), nil)
            return Progress()
        }
        
        do {
            let itemId = try ItemID(idString: identifier.rawValue)
            switch itemId.itemType {
            case .Course:
                ItslearningAPI.GetCourse(authHandler, itemID: itemId) { response in
                    guard let course = response.course else {
                        Logging.Log(message: response.error.debugDescription, source: .FileProvider)
                        completionHandler(nil, response.error)
                        return
                    }
                    completionHandler(FileProviderCourseItem(item: course), nil)
                }
                break
            case .Resource:
                ItslearningAPI.GetResource(authHandler, resourceId: itemId) { response in
                    guard let data = response.data else {
                        Logging.Log(message: response.error.debugDescription, source: .FileProvider)
                        completionHandler(nil, response.error)
                        return
                    }
                    completionHandler(FileProviderResourceItem(item: data), nil)
                }
                break
            }
        } catch let error {
            Logging.Log(message: error.asAFError.debugDescription, source: .FileProvider)
            completionHandler(nil, error)
        }
        
        return Progress()
    }
    
    // TODO: implement fetching of the contents for the itemIdentifier at the specified version
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        Logging.Log(message: "Fetch contents: \(itemIdentifier.rawValue), version: \(requestedVersion.debugDescription)", source: .FileProvider)
        let progress = Progress(totalUnitCount: 100);
        
        let _ = self.item(for: itemIdentifier, request: request) { itemOpt, errorOpt in
            if let error = errorOpt as NSError? {
                Logging.Log(message: "Error calling item for identifier \"\(itemIdentifier)\": \(error)", source: .FileProvider)
                completionHandler(nil, nil, error)
                return
            }
            
            guard let item = itemOpt else {
                Logging.Log(message: "Could not find item metadata, identifier: \(itemIdentifier)", source: .FileProvider)
                completionHandler(nil, nil, CommonError.internalError)
                return
            }
            
            guard let itemCasted = item as? FileProviderResourceItem else {
                Logging.Log(message: "Could not cast item to FileProviderResourceItem class, identifier: \(itemIdentifier)", source: .FileProvider)
                completionHandler(nil, nil, CommonError.internalError)
                return
            }
            
            if let requestedVersion = requestedVersion {
                guard requestedVersion == item.itemVersion else {
                    Logging.Log(message: "requestedVersion (\(requestedVersion) != item.itemVersion (\(item.itemVersion?.description ?? "nil")", source: .FileProvider)
                    completionHandler(nil, nil, CommonError.internalError)
                    return
                }
            }
            
            do {
                let url = try self.manager.temporaryDirectoryURL().appendingPathComponent("\("itslearning")-\(UUID().uuidString)")
                
                // Some Itslearning file types are not actually files but just links
                // For these we should create a url, that opens in the webbrowser
                if(ItslearningAPI.IsWebpage(resource: itemCasted.item)) {
                    // Make url
                    if(ItslearningAPI.IsNestedLink(resource: itemCasted.item)) {
                        ItslearningAPI.GetNestedLink(authHandler: self.authHandler, resource: itemCasted.item) { response in
                            guard let data = response.data else {
                                Logging.Log(message: "Failed to get nested url", source: .FileProvider)
                                return
                            }
                            do {
                                try "[InternetShortcut]\nURL=\(data)".write(to: url, atomically: true, encoding: .utf8)
                                completionHandler(url, item, nil) }
                            catch {
                                Logging.Log(message: "Could not write nested url", source: .FileProvider)
                            }
                        }
                    } else {
                        try "[InternetShortcut]\nURL=\(itemCasted.item.Url)".write(to: url, atomically: true, encoding: .utf8)
                        completionHandler(url, item, nil)
                    }
                } else {
                    Logging.Log(message: "Downloading \"\(itemCasted.filename)\" to \(url.path)", source: .FileProvider)
                    
                    let downloadProgress = ItslearningAPI.DownloadFile(self.authHandler, resourceId: try ItemID(idString: itemIdentifier.rawValue), file: url) { response in
                        Logging.Log(message: "Finished downloading \"\(itemCasted.filename)\"", source: .FileProvider)
                        completionHandler(url, item, nil)
                    }
                    
                    progress.addChild(downloadProgress, withPendingUnitCount: 100)
                }
            } catch {
                Logging.Log(message: "Failed downloading \"\(itemCasted.filename)\"", source: .FileProvider)
            }
        }
        
        return progress
    }
    
    // TODO: a new item was created on disk, process the item's creation
    func createItem(basedOn itemTemplate: NSFileProviderItem, fields: NSFileProviderItemFields, contents url: URL?, options: NSFileProviderCreateItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        completionHandler(itemTemplate, [], false, nil)
        return Progress()
    }
    
    // TODO: an item was modified on disk, process the item's modification
    func modifyItem(_ item: NSFileProviderItem, baseVersion version: NSFileProviderItemVersion, changedFields: NSFileProviderItemFields, contents newContents: URL?, options: NSFileProviderModifyItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, NSFileProviderItemFields, Bool, Error?) -> Void) -> Progress {
        completionHandler(nil, [], false, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    // TODO: an item was deleted on disk, process the item's deletion
    func deleteItem(identifier: NSFileProviderItemIdentifier, baseVersion version: NSFileProviderItemVersion, options: NSFileProviderDeleteItemOptions = [], request: NSFileProviderRequest, completionHandler: @escaping (Error?) -> Void) -> Progress {
        completionHandler(NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
    }
    
    func enumerator(for containerItemIdentifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest) throws -> NSFileProviderEnumerator {
        // Do some basic checks for log-in status
        if((!authHandler.loading && !authHandler.isLoggedIn) ||
           authHandler.GetAuthToken() == nil) {
            throw NSFileProviderError(.notAuthenticated)
        }
        
        return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier, fpExtension: self)
    }
}
