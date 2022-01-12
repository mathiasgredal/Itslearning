//  SPDX-License-Identifier: CC-BY-NC-SA-4.0
//  Copyright (C) 2022 Mathias Gredal
//
//  ItslearningAPI.swift
//  ItslearningAPI

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
    
    static func DownloadFile(_ authHandler: AuthHandler, resourceId: ItemID, file: URL, completion: @escaping ((url: String?, error: Error?)) -> ()) -> Progress {
        let urlSSO = "https://sdu.itslearning.com/LearningToolElement/ViewLearningToolElement.aspx?LearningToolElementId=\(resourceId.baseItem)"
        let downloadProgress = Progress(totalUnitCount: 100);
        
        authHandler.GetRequestSSO(url: urlSSO) { response in
            guard let data = response.data else {
                completion((nil, response.error))
                return
            }
            
            downloadProgress.completedUnitCount += 10;
            
            do {
                let doc: Document = try SwiftSoup.parse(data)
                
                let iframeSelector = "#ctl00_ContentPlaceHolder_ExtensionIframe"
                
                guard let iframeURL = try doc.select(iframeSelector).first()?.attr("src") else {
                    completion((nil, NSError(domain: "", code: 0, userInfo: [ NSLocalizedDescriptionKey: "Could not find iframe"])))
                    return
                }
                
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
                    
                    downloadProgress.completedUnitCount += 10;

                    
                   let destination: DownloadRequest.Destination = { _, _ in
                        return (file, [.removePreviousFile, .createIntermediateDirectories])
                    }
                    
                    let downloadRequest = AF.download(downloadLink, to: destination);
                    
                    downloadProgress.addChild(downloadRequest.downloadProgress, withPendingUnitCount: 80);
                    downloadRequest.response { response in
                        completion(("Success", nil))
                    }
                }
            } catch {
                completion((nil, CommonError.internalError))
            }
        }
        return downloadProgress;
    }
    
    static func GetNestedLink(authHandler: AuthHandler, resource: CourseResource, completion: @escaping ((data: String?, error: AFError?))->()) {
        if(!IsNestedLink(resource: resource)) {
            completion((nil, "Not nested link".asAFError))
        }
        
        authHandler.GetRequestSSO(url: resource.ContentUrl) { response in
            guard let data = response.data else {
                completion((nil, response.error))
                return
            }
            
            // TODO: Some duplicated code
            do {
                let doc: Document = try SwiftSoup.parse(data)
                
                let iframeSelector = "#ctl00_ContentPlaceHolder_ExtensionIframe"
                
                guard let iframeURL = try doc.select(iframeSelector).first()?.attr("src") else {
                    completion((nil, "Could not find iframe".asAFError))
                    return
                }
                
                AF.request(iframeURL).responseString { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let doc: Document = try SwiftSoup.parse(data)
                            let linkSelector = "#ctl00_ctl00_MainFormContent_ResourceContent_Link"
                            guard let link = try doc.select(linkSelector).first()?.attr("href") else {
                                completion((nil, "Could not find link".asAFError))
                                return
                            }
                            completion((link, nil))
                        } catch {
                            completion((nil, "Could not parse link response".asAFError))
                        }
                        break
                    case .failure(let error):
                        completion((nil, error))
                        break
                    }
                }
            } catch {
                completion((nil, "Could not parse iframe response".asAFError))
            }
        }
    }
    
    static func IsNestedLink(resource: CourseResource) -> Bool {
        // We can look at the icon url to determine if a resource is a webpage
        let queryItems = URLComponents(string: resource.IconUrl)?.queryItems
        let extensionId = queryItems?.filter({$0.name == "ExtensionId"}).first
        
        return extensionId?.value == "5010" && resource.ElementType == .LearningToolElement
    }

    
    static func IsWebpage(resource: CourseResource) -> Bool {
        // If it is a nested link, then it is also a link
        if(IsNestedLink(resource: resource)) {
            return true
        }
        
        // We can look at the icon url to determine if a resource is a webpage
        let queryItems = URLComponents(string: resource.IconUrl)?.queryItems
        let extensionId = queryItems?.filter({$0.name == "ExtensionId"}).first
        
        if(extensionId?.value == "5" && resource.ElementType == .LearningToolElement) {
            return true
        }
        
        // To detect whether an item is a webpage we can also look at the element type
        switch(resource.ElementType) {
        case .LearningPath:
            return true
        case .Unknown:
            return false
        case .Discussion:
            return true
        case .PictureWithDescription:
            return false
        case .Folder:
            return false
        case .Note:
            return true
        case .WebLink:
            return true
        case .FolderFile:
            return false
        case .Survey:
            return true
        case .Assignment:
            return true
        case .Lesson:
            return true
        case .Conference:
            return true
        case .Test:
            return true
        case .LearningToolElement:
            return false
        case .CustomActivity:
            return true
        }
    }
}
