//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  FileProviderEnumerator.swift
//  Itslearning

import FileProvider
import OAuth2
import Alamofire


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
    
    init(enumeratedItemIdentifier: NSFileProviderItemIdentifier, fpExtension: FileProviderExtension) {
        self.enumeratedItemIdentifier = enumeratedItemIdentifier
        self.fpExtension = fpExtension
        super.init()
    }
    
    func invalidate() {
        // TODO: perform invalidation of server connection if necessary
    }
    
    func enumerateItems(for observer: NSFileProviderEnumerationObserver, startingAt page: NSFileProviderPage) {
        Logging.Log(message: "Enumerating \(self.enumeratedItemIdentifier.rawValue)", source: .FileProvider)
        
        // First we check if the authHandler is valid
        if !fpExtension.authHandler.isLoggedIn || fpExtension.authHandler.loading {
            Logging.Log(message: "Not signed in", source: .FileProvider)
            let error = NSError(domain: NSFileProviderErrorDomain, code: NSFileProviderError.notAuthenticated.rawValue, userInfo: [:])
            observer.finishEnumeratingWithError(error)
            return;
        }
        
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
    
    func enumerateChanges(for observer: NSFileProviderChangeObserver, from anchor: NSFileProviderSyncAnchor) {
        /* TODO:
         - query the server for updates since the passed-in sync anchor
         
         If this is an enumerator for the active set:
         - note the changes in your local database
         
         - inform the observer about item deletions and updates (modifications + insertions)
         - inform the observer when you have finished enumerating up to a subsequent sync anchor
         */
        observer.finishEnumeratingChanges(upTo: anchor, moreComing: false)
    }
    
    func currentSyncAnchor(completionHandler: @escaping (NSFileProviderSyncAnchor?) -> Void) {
        completionHandler(anchor)
    }
}


/* TODO:
 - inspect the page to determine whether this is an initial or a follow-up request
 
 If this is an enumerator for a directory, the root container or all directories:
 - perform a server request to fetch directory contents
 If this is an enumerator for the active set:
 - perform a server request to update your local database
 - fetch the active set from your local database
 
 - inform the observer about the items returned by the server (possibly multiple times)
 - inform the observer that you are finished with this page
 */
