//
//  ResourceType.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 25/09/2021.
//

import Foundation

// https://sdu.itslearning.com/restapi/help/ResourceModel?modelName=ElementType
enum ElementType: String, Codable {
    case Unknown
    case Discussion
    case PictureWithDescription
    case Folder
    case Note
    case WebLink
    case FolderFile
    case Survey
    case Assignment
    case Lesson
    case Conference
    case Test
    case LearningToolElement
    case CustomActivity
    case LearningPath
}
