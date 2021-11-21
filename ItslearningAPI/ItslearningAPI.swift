//
//  ItslearningAPI.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import Foundation
import SwiftSoup
import OAuth2
import Alamofire

/// A namespace for interacting with the Itslearning API
public enum ItslearningAPI {
    
    /// Gets a list of courses from itslearning
    /// - Parameters:
    ///   - authHandler: An authenticated authhandler
    ///   - completion: A completion handler, with the return value passed as a parameter, an empty list is returned in case of an error
    /// - Returns: The return value is in the completion handler
    static func GetCourses(_ authHandler: AuthHandler, completion: @escaping ((data: [PersonCourse], error: AFError?))->()){
        // TODO: Do paging of API
        let url = "https://sdu.itslearning.com/restapi/personal/courses/v2"
        authHandler.GetRequest(url: url, type: EntityListOfPersonCourse.self) { response in
            guard let data = response.data else {
                completion(([], response.error))
                return
            }
            
            // Add the item id
            var newEntityArray: [PersonCourse] = []
            for (i, item) in data.EntityArray.enumerated() {
                var newItem = data.EntityArray[i]
                newItem.itemId = ItemID(courseId: item.CourseId)
                newEntityArray.append(newItem)
            }
            
            completion((newEntityArray, nil))
        }
    }
    
    static func GetCourse(_ authHandler: AuthHandler, itemID: ItemID, completion: @escaping ((course: PersonCourse?, error: AFError?)) ->()) {
        GetCourses(authHandler) { response in
            for course in response.data {
                if(course.itemId?.courseId == itemID.courseId) {
                    completion((course, nil))
                    return
                }
            }
            completion((nil, response.error))
        }
    }
    
    /// Get list of resources from subfolder or course
    /// - Parameters:
    ///   - authHandler: An authenticated authhandler
    ///   - completion: A completion handler, with the return value passed as a parameter, an empty list is returned in case of an error
    /// - Returns: The return value is in the completion handler
    static func GetResources(_ authHandler: AuthHandler, itemId: ItemID, completion: @escaping ([CourseResource])->()) {
        let url = itemId.itemType == .Course ? "https://sdu.itslearning.com/restapi/personal/courses/\(itemId.courseId)/resources/v1" : "https://sdu.itslearning.com/restapi/personal/courses/\(itemId.courseId)/folders/\(itemId.baseItem)/resources/v1";
        
        authHandler.GetRequest(url: url, type: CourseFolderDetails.self) { response in
            guard let data = response.data else {
                print(response.error ?? "Unknown error")
                completion([])
                return;
            }
            
            // Add item id
            var newEntityArray: [CourseResource] = []
            for (i, item) in data.Resources.EntityArray.enumerated() {
                var newItem = data.Resources.EntityArray[i]
                newItem.itemId = ItemID(_itemId: itemId, newItem: item.ElementId)
                newEntityArray.append(newItem)
            }
            
            completion(newEntityArray)
        }
    }
    
    /// Lookup resource by id
    static func GetResource(_ authHandler: AuthHandler, resourceId: ItemID, completion: @escaping ((data: CourseResource?, error: AFError?))->()) {
        authHandler.GetRequest(url: "https://sdu.itslearning.com/restapi/personal/courses/resources/\(resourceId.baseItem)/v1", type: CourseResource.self) { response in
            var responseWithId = response
            responseWithId.data?.itemId = resourceId
            completion(responseWithId)
        }
    }
    
    /*
     /// <#Description#>
     /// - Parameters:
     ///   - authHandler: <#authHandler description#>
     ///   - itemId: <#itemId description#>
     ///   - completion: <#completion description#>
     /// - Returns: <#description#>
     static func GetItemParent(_ authHandler: AuthHandler, resourceId: Int, completion: @escaping ((data: CourseResource?, error: Error?))->()) {
     let urlSSO = "https://sdu.itslearning.com/Folder/processfolder.aspx?FolderID=\(resourceId)"
     authHandler.GetRequestSSO(url: urlSSO) { response in
     // Guard against request errors
     guard let data = response.data else {
     completion((nil, response.error))
     return
     }
     
     do {
     // Parse HTML
     let doc: Document = try SwiftSoup.parse(data)
     
     // Select button for going a directory up
     let selector = "#ctl00_ContentPlaceHolder_ProcessFolderGrid_GTB_ToolbarUpOneLevelLink"
     guard let parentFolderURL = try doc.select(selector).first()?.attr("href") else {
     // No button was found, which means that we are selecting the root folder for the course or we have selected an invalid
     completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "HTML doesn't contain specified link"])))
     return
     }
     
     // Get the folder id from query item in link(eg. /Folder/processfolder.aspx?FolderID=12345)
     //                guard let folderID = URLComponents(string: parentFolderURL)?.queryItems?.filter({$0.name == "FolderID"}).first?.value else {
     //                    completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Specified link doesn't contain folderID"])))
     //                    return
     //                }
     
     // Get the courseResource
     
     
     print(parentFolderURL)
     completion((nil, nil))
     return
     } catch let error as Exception {
     completion((nil, error))
     } catch {
     completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Unknown error when parsing HTML"])))
     }
     
     //completion(("\(data)", nil))
     }
     
     // Create an SSO request
     // Parse HTML and find the go up directory id
     // Get the CourseResource using this https://sdu.itslearning.com/restapi/personal/courses/resources/311300/v1
     // Return it
     
     
     //        let url = isRootFolder ? "https://sdu.itslearning.com/restapi/personal/courses/\(course)/resources/v1" : "https://sdu.itslearning.com/restapi/personal/courses/\(course)/folders/\(folder)/resources/v1";
     //
     //        authHandler.GetRequest(url: url, type: CourseFolderDetails.self) { response in
     //            guard let data = response.data else {
     //                print(response.error ?? "Unknown error")
     //                completion([])
     //                return;
     //            }
     //            completion(data.Resources.EntityArray)
     //        }
     }*/
}
