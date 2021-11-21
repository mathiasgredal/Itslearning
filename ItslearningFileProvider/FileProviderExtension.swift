//
//  FileProviderExtension.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import FileProvider
import os.log
import OAuth2
import Foundation
import Alamofire


class FileProviderExtension: NSObject, NSFileProviderReplicatedExtension {
    public let logger = Logger(subsystem: "sdu.magre21.itslearning.itslearningfileprovider", category: "extension")
    public let domain: NSFileProviderDomain
    public var manager: NSFileProviderManager
    public var authHandler: AuthHandler
    
    required public init(domain: NSFileProviderDomain) {
        self.logger.debug("Initializing file provider extension")
        self.domain = domain
        self.manager = NSFileProviderManager(for: domain)!
        self.authHandler = AuthHandler()
        super.init()
        
        // HACK: The fileprovider responds better to updates with this
        Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(self.pingFinder), userInfo: nil, repeats: true)
    }
    
    @objc func pingFinder() {
        manager.signalEnumerator(for: .workingSet) { error in
            guard error == nil else {
                self.logger.debug("Error: \(String(describing: error), privacy: .public)")
                return
            }
        }
    }
    
    // TODO: cleanup any resources
    func invalidate() {
        
    }
    
    // Resolve item from identifier
    func item(for identifier: NSFileProviderItemIdentifier, request: NSFileProviderRequest, completionHandler: @escaping (NSFileProviderItem?, Error?) -> Void) -> Progress {
        self.logger.debug("Resolving item from identifier: \(String(describing: identifier.rawValue), privacy: .public)")
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
                        completionHandler(nil, response.error)
                        return
                    }
                    completionHandler(FileProviderCourseItem(item: course), nil)
                }
                break
            case .Resource:
                ItslearningAPI.GetResource(authHandler, resourceId: itemId) { response in
                    guard let data = response.data else {
                        completionHandler(nil, response.error)
                        return
                    }
                    completionHandler(FileProviderResourceItem(item: data), nil)
                    
                }
                break
            }
        } catch let error {
            completionHandler(nil, error)
        }
        
        return Progress()
    }
    
    // TODO: implement fetching of the contents for the itemIdentifier at the specified version
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
        self.logger.debug("Fetch contents: \(String(describing: itemIdentifier.rawValue), privacy: .public)")
        completionHandler(nil, nil, NSError(domain: NSCocoaErrorDomain, code: NSFeatureUnsupportedError, userInfo:[:]))
        return Progress()
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
        // Fail if we are stil authenticating
        if(authHandler.loading) {
            throw FileProviderError.loading
        } else if(!authHandler.isLoggedIn) {
            throw FileProviderError.notSignedIn
        }
        
        return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier, fpExtension: self)
    }
}
