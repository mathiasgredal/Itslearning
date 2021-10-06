//
//  FileProviderEnumerator.swift
//  Itslearning
//
//  Created by Mathias Gredal on 15/09/2021.
//

import FileProvider
import OAuth2
import Alamofire
import os.log

class FileProviderEnumerator: NSObject, NSFileProviderEnumerator {
    private let logger = Logger(subsystem: "sdu.magre21.itslearning.itslearningfileprovider", category: "enumeration")
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
        logger.log("Enumerating \(String(self.enumeratedItemIdentifier.rawValue), privacy: .public)")
        
        guard let authHandler = fpExtension.authHandler else {
            logger.log("Not signed in")
            observer.didEnumerate([FileProviderItem(identifier: NSFileProviderItemIdentifier("Error: Not signed in"))])
            observer.finishEnumerating(upTo: nil)
            return;
        }
        
        if(self.enumeratedItemIdentifier == .rootContainer) {
            // We should iterate courses
            authHandler.GetCourses { courses in
                observer.didEnumerate(courses.map {
                    return FileProviderItem(identifier: NSFileProviderItemIdentifier(String($0.CourseId)), title: $0.Title)
                } as [FileProviderItem])
                observer.finishEnumerating(upTo: nil)
            }
        } else if let courseId = Int(self.enumeratedItemIdentifier.rawValue) {
            // We should iterate folders in course
            authHandler.GetResources(course: courseId, folder: 0) { resources in
                observer.didEnumerate(resources.map {
                    self.logger.log("\(String($0.Title), privacy: .public)")
                    return FileProviderItem(identifier: NSFileProviderItemIdentifier($0.Title), parent: NSFileProviderItemIdentifier(String(courseId)))
                } as [FileProviderItem])
                observer.finishEnumerating(upTo: nil)
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
