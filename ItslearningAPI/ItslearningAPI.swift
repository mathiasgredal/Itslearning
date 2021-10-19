//
//  ItslearningAPI.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 15/09/2021.
//

import OAuth2

// An Id is constructed the following way:
// - <(R)esource/(C)ourse><course id>_<folder_id>
func ConvertToId(course: PersonCourse) -> String {
    return "C" + String(course.CourseId)
}

func ConvertToId(resource: CourseResource) -> String {
    return "R" + String(resource.CourseId) + "_" + String(resource.ElementId)
}

enum IdType {
    case Unknown
    case Resource(Int, Int)
    case Course(Int)
}

func ConvertIdToType(id: String) -> IdType{
    switch id.first {
    case "C":
        guard let courseId = Int(id.dropFirst()) else {
            return .Unknown
        }
        return .Course(courseId)
    case "R":
        guard let underscoreOffset = id.firstIndex(of: "_")?.utf16Offset(in: id.self) else {
            return .Unknown
        }
        guard let courseId = Int(id.dropFirst().dropLast(id.count-underscoreOffset)) else {
            return .Unknown
        }
        guard let resourceId = Int(id.dropFirst(underscoreOffset+1)) else {
            return .Unknown
        }
        return .Resource(courseId, resourceId)
    default:
        return .Unknown
    }
}


public class ItslearningAPI {
    public static let shared = ItslearningAPI();
    
    private init() {
        print("Initializing Itslearning API")
    }

    
}
