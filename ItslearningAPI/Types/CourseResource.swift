//
//  Resource.swift
//  ItslearningAPI
//
//  Created by Mathias Gredal on 25/09/2021.
//

import Foundation
import SwiftUI

struct CourseResource: Codable {
    var itemId: ItemID?;
    let Title: String
    let ElementId: Int
    let ElementType: ElementType
    let CourseId: Int
    let Url, ContentUrl: String
    let IconUrl: String
    let Active: Bool
    let LearningToolId: Int
    let AddElementUrl: String?
    let Homework: Bool
    let path: String?
    let LearningObjectId, LearningObjectInstanceId: Int
}

