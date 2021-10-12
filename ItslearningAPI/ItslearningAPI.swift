//
//  ItslearningAPI.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import OAuth2



public class ItslearningAPI {
    public static let shared = ItslearningAPI();
    
    private init() {
        print("Initializing Itslearning API")
    }

    func ConvertToId(course: PersonCourse) -> String {
        return "C" + String(course.CourseId)
    }

    func ConvertToId(resource: CourseResource) -> String {
        return "R" + String(resource.ElementId)
    }

    enum IdType {
        case Unknown
        case Resource(CourseResource.Type, Int)
        case Course(PersonCourse.Type, Int)
   }
    
    func ConvertIdToType(id: String) -> IdType{
        switch id.first {
        case "C":
            guard let idnumber = Int(id.dropFirst()) else {
                return .Unknown
            }
            return .Course(PersonCourse.self, idnumber)
        case "R":
            guard let idnumber = Int(id.dropFirst()) else {
                return .Unknown
            }
            return .Resource(CourseResource.self, idnumber)
        default:
            return .Unknown
        }
    }
    
}
