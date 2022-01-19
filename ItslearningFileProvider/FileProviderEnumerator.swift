//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  FileProviderEnumerator.swift
//  Itslearning

import FileProvider
import OAuth2
import Alamofire
import Combine

// TODO: Move to seperate file
enum FileProviderError: Error {
    case notSignedIn
    case loading
    case invalidId
    case unexpected(code: Int)
}

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    private let fpExtension: FileProviderExtension
    private let enumeratedItemIdentifier: NSFileProviderItemIdentifier
    private let anchor = NSFileProviderSyncAnchor("an anchor".data(using: .utf8)!)
    private var loadingCancellable: AnyCancellable?

    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, fpExtension: FileProviderExtension) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        self.fpExtension = fpExtension
        super.init()
    }
    
    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }
    
    /// This method is used for listing the contents of a folder
    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        Logging.Log(message: "Enumerating \(self.enumeratedItemIdentifier.rawValue)", source: .FileProvider)
        
        if(fpExtension.authHandler.loading) {
            // We are still waiting for the authentication handler, so we listen to changes to its state
            loadingCancellable = fpExtension.authHandler.$loading
                .timeout(.seconds(10), scheduler: DispatchQueue.main).sink { loading in
                    // We are still loading, so we don't need to do anything
                    if(loading) {
                        return
                    }
                    
                    if(!loading && self.fpExtension.authHandler.isLoggedIn) {
                        // We are signed in, so we can cancel the listener and enumerate the items
                        self.loadingCancellable?.cancel()
                        self.enumerateItems(for: observer, startingAt: page)
                    } else {
                        // We are not logged in, so we will return an error and cancel the listener
                        observer.finishEnumeratingWithError(NSFileProviderError(.notAuthenticated))
                        self.loadingCancellable?.cancel()
                    }
                }
        } else {
            // We are ready to do the enumeration
            if(self.enumeratedItemIdentifier == .rootContainer) {
                // Iterate courses
                ItslearningAPI.GetCourses(fpExtension.authHandler) { response in
                    observer.didEnumerate(response.data.map {
                        return FileProviderCourseItem(item: $0)
                    })
                    observer.finishEnumerating(upTo: nil)
                }
            } else {
                do {
                    let itemId = try ItemID(idString: self.enumeratedItemIdentifier.rawValue)
                    ItslearningAPI.GetResources(fpExtension.authHandler, itemId: itemId) { resources in
                        observer.didEnumerate(resources.map {
                            return FileProviderResourceItem(item: $0)
                        })
                        observer.finishEnumerating(upTo: nil)
                    }
                } catch {
                    Logging.Log(message: "Invalid Item ID: \(self.enumeratedItemIdentifier.rawValue)", source: .FileProvider)
                    observer.finishEnumeratingWithError(FileProviderError.invalidId)
                }
            }
        }
    }
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }
    
    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(anchor)
    }
}
