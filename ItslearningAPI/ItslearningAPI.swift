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
    
    static func getDownloadURL(_ authHandler: AuthHandler, resourceId: ItemID, completion: @escaping ((url: String?, error: Error?)) -> ()) {
        //let urlSSO = "https://sdu.itslearning.com/LearningToolElement/ViewLearningToolElement.aspx?LearningToolElementId=\(resourceId.baseItem)"
        let urlSSO = "https://sdu.itslearning.com/LearningToolElement/ViewLearningToolElement.aspx?LearningToolElementId=352598"
        print(urlSSO)
        
        authHandler.GetRequestSSO(url: urlSSO) { response in
            guard let data = response.data else {
                completion((nil, response.error))
                return
            }
            
            do {
                let doc: Document = try SwiftSoup.parse(data)
                
                let iframeSelector = "#ctl00_ContentPlaceHolder_ExtensionIframe"
                
                guard let iframeURL = try doc.select(iframeSelector).first()?.attr("src") else {
                    completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Could not find iframe"])))
                    return
                }
                
                print(iframeURL)
                AF.request(iframeURL).response { response in
                    guard let redirectURL = response.response?.url else {
                        completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Could not find redirected url"])))
                        return
                    }
                    
                    guard let queryItems = URLComponents(url: redirectURL, resolvingAgainstBaseURL: true)?.queryItems else {
                        completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Failed to parse url"])))
                        return
                    }
                    
                    guard let learningObjectId = queryItems.filter({$0.name == "LearningObjectId"}).first?.value else {
                        completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Failed to get learningObjectId from url"])))
                        return
                    }
                    guard let learningObjectInstanceId = queryItems.filter({$0.name == "LearningObjectInstanceId"}).first?.value else {
                        completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Failed to get learningObjectInstanceId from url"])))
                        return
                    }

                    let downloadLink = "https://resource.itslearning.com/Proxy/DownloadRedirect.ashx?LearningObjectId=\(learningObjectId)&LearningObjectInstanceId=\(learningObjectInstanceId)"
                    
                    // TODO: Make this use AF.download
                    AF.request(downloadLink).response { response in
                        // This works and downloads the file
                        print(response.response)
                    }
                    print(downloadLink)
                    
                }

                
            } catch {
                completion((nil, CommonError.internalError))
            }
            
        }
    }
}
