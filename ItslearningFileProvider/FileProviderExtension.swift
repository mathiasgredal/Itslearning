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


class FileProviderExtension: NSObject, NSFileProviderReplicatedExtension {
    public let logger = Logger(subsystem: "sdu.magre21.itslearning.itslearningfileprovider", category: "extension")
    public let domain: NSFileProviderDomain
    public var manager: NSFileProviderManager
    public var authHandler: AuthHandler?
    
    required public init(domain: NSFileProviderDomain) {
        self.logger.debug("Initializing file provider extension")
        self.domain = domain
        self.manager = NSFileProviderManager(for: domain)!
        self.authHandler = AuthHandler()
        super.init()
        
        
        
        // HACK: The fileprovider responds better to updates with this
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.pingFinder), userInfo: nil, repeats: true)
    }
    
    @objc func pingFinder() {
        manager.signalEnumerator(for: .rootContainer) { error in
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
        completionHandler(FileProviderItem(identifier: identifier), nil)
        return Progress()
    }
    
    // TODO: implement fetching of the contents for the itemIdentifier at the specified version
    func fetchContents(for itemIdentifier: NSFileProviderItemIdentifier, version requestedVersion: NSFileProviderItemVersion?, request: NSFileProviderRequest, completionHandler: @escaping (URL?, NSFileProviderItem?, Error?) -> Void) -> Progress {
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
        return FileProviderEnumerator(enumeratedItemIdentifier: containerItemIdentifier, fpExtension: self)
    }
}
